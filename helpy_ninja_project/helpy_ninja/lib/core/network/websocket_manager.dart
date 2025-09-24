import 'dart:async';
import 'package:logger/logger.dart';

import 'websocket_service.dart';
import '../storage/secure_storage.dart';
import '../di/injection.dart';
import '../../data/models/websocket/websocket_event.dart';
import '../../data/repositories/offline_chat_repository_impl.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/shared_enums.dart';

/// WebSocket manager that handles real-time events and offline sync
class WebSocketManager {
  final WebSocketService _webSocketService;
  final OfflineChatRepositoryImpl _chatRepository;
  final Logger _logger = Logger();

  // Stream controllers for typed events
  final StreamController<MessageEvent> _messageStreamController = 
      StreamController<MessageEvent>.broadcast();
  final StreamController<TypingEvent> _typingStreamController = 
      StreamController<TypingEvent>.broadcast();
  final StreamController<UserPresenceEvent> _presenceStreamController = 
      StreamController<UserPresenceEvent>.broadcast();
  final StreamController<bool> _connectionStreamController = 
      StreamController<bool>.broadcast();

  // Current typing users per conversation
  final Map<String, Set<String>> _typingUsers = {};
  
  // Current user presence status
  final Map<String, UserPresenceEvent> _userPresence = {};
  
  // Message send queue for offline messages
  final List<Map<String, dynamic>> _messageQueue = [];
  
  bool _isInitialized = false;

  WebSocketManager(this._webSocketService, this._chatRepository);

  /// Factory constructor with dependency injection
  factory WebSocketManager.create() {
    final webSocketService = WebSocketService(getIt<SecureStorage>());
    final chatRepository = OfflineChatRepositoryImpl();
    return WebSocketManager(webSocketService, chatRepository);
  }

  /// Initialize WebSocket manager and set up listeners
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setupWebSocketListeners();
    _isInitialized = true;
    
    _logger.d('WebSocket manager initialized');
  }

  /// Connect to WebSocket server
  Future<void> connect() async {
    await _webSocketService.connect();
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    await _webSocketService.disconnect();
  }

  /// Check if WebSocket is connected
  bool get isConnected => _webSocketService.isConnected;

  /// Stream of connection status changes
  Stream<bool> get connectionStatus => _connectionStreamController.stream;

  /// Stream of incoming messages
  Stream<MessageEvent> get messageStream => _messageStreamController.stream;

  /// Stream of typing indicators
  Stream<TypingEvent> get typingStream => _typingStreamController.stream;

  /// Stream of user presence updates
  Stream<UserPresenceEvent> get presenceStream => _presenceStreamController.stream;

  /// Send a chat message
  Future<void> sendMessage({
    required String conversationId,
    required String content,
    String contentType = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final currentUser = await _getCurrentUser();
    
    // Create message entity for local storage
    final message = Message(
      id: messageId,
      conversationId: conversationId,
      senderId: currentUser?['id'] ?? 'anonymous',
      senderName: currentUser?['name'] ?? 'Anonymous',
      content: content,
      type: _getMessageType(contentType),
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
      metadata: metadata,
      messageId: messageId,
      sentAt: DateTime.now(),
      deliveryStatus: MessageDeliveryStatus.sending,
    );

    // Save message locally first (offline-first)
    await _chatRepository.saveMessage(message);

    if (_webSocketService.isConnected) {
      try {
        // Send through WebSocket
        await _webSocketService.sendChatMessage(
          conversationId: conversationId,
          content: content,
          messageId: messageId,
          contentType: contentType,
          metadata: metadata,
        );

        // Update message status to sent
        final updatedMessage = message.copyWith(
          status: MessageStatus.sent,
          deliveryStatus: MessageDeliveryStatus.sent,
        );
        await _chatRepository.saveMessage(updatedMessage);
        
      } catch (e) {
        _logger.e('Failed to send message via WebSocket', error: e);
        
        // Queue message for later sending
        _messageQueue.add({
          'conversationId': conversationId,
          'content': content,
          'messageId': messageId,
          'contentType': contentType,
          'metadata': metadata,
        });

        // Update message status to failed
        final failedMessage = message.copyWith(
          status: MessageStatus.failed,
          deliveryStatus: MessageDeliveryStatus.failed,
        );
        await _chatRepository.saveMessage(failedMessage);
      }
    } else {
      // Queue message for when connection is available
      _messageQueue.add({
        'conversationId': conversationId,
        'content': content,
        'messageId': messageId,
        'contentType': contentType,
        'metadata': metadata,
      });
    }
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator({
    required String conversationId,
    required bool isTyping,
  }) async {
    if (_webSocketService.isConnected) {
      try {
        await _webSocketService.sendTypingIndicator(
          conversationId: conversationId,
          isTyping: isTyping,
        );
      } catch (e) {
        _logger.e('Failed to send typing indicator', error: e);
      }
    }
  }

  /// Join a conversation room
  Future<void> joinConversation(String conversationId) async {
    if (_webSocketService.isConnected) {
      try {
        await _webSocketService.joinConversation(conversationId);
      } catch (e) {
        _logger.e('Failed to join conversation', error: e);
      }
    }
  }

  /// Leave a conversation room
  Future<void> leaveConversation(String conversationId) async {
    if (_webSocketService.isConnected) {
      try {
        await _webSocketService.leaveConversation(conversationId);
      } catch (e) {
        _logger.e('Failed to leave conversation', error: e);
      }
    }
  }

  /// Get typing users for a conversation
  Set<String> getTypingUsers(String conversationId) {
    return _typingUsers[conversationId] ?? {};
  }

  /// Get user presence status
  UserPresenceEvent? getUserPresence(String userId) {
    return _userPresence[userId];
  }

  /// Process queued messages when connection is restored
  Future<void> _processMessageQueue() async {
    if (_messageQueue.isEmpty || !_webSocketService.isConnected) return;

    final queueCopy = List<Map<String, dynamic>>.from(_messageQueue);
    _messageQueue.clear();

    for (final messageData in queueCopy) {
      try {
        await _webSocketService.sendChatMessage(
          conversationId: messageData['conversationId'],
          content: messageData['content'],
          messageId: messageData['messageId'],
          contentType: messageData['contentType'],
          metadata: messageData['metadata'],
        );

        // Update message status in local storage
        await _updateMessageStatus(
          messageData['messageId'],
          MessageStatus.sent,
          MessageDeliveryStatus.sent,
        );
        
      } catch (e) {
        _logger.e('Failed to send queued message', error: e);
        // Re-queue failed messages
        _messageQueue.add(messageData);
      }
    }
  }

  /// Setup WebSocket event listeners
  void _setupWebSocketListeners() {
    // Connection status
    _webSocketService.connectionStatus.listen((isConnected) {
      _connectionStreamController.add(isConnected);
      
      if (isConnected) {
        _logger.d('WebSocket connected - processing queued messages');
        _processMessageQueue();
      } else {
        _logger.w('WebSocket disconnected');
      }
    });

    // Message events
    _webSocketService.messageStream.listen((data) {
      final event = WebSocketEvent.fromJson(data);
      _handleWebSocketEvent(event);
    });

    // Typing events
    _webSocketService.typingStream.listen((data) {
      final event = WebSocketEvent.fromJson(data) as TypingEvent;
      _handleTypingEvent(event);
    });

    // Presence events
    _webSocketService.presenceStream.listen((data) {
      final event = WebSocketEvent.fromJson(data) as UserPresenceEvent;
      _handlePresenceEvent(event);
    });

    // Participant events
    _webSocketService.participantStream.listen((data) {
      final event = WebSocketEvent.fromJson(data);
      _handleParticipantEvent(event);
    });
  }

  /// Handle incoming WebSocket events
  void _handleWebSocketEvent(WebSocketEvent event) {
    switch (event.type) {
      case 'message':
        _handleMessageEvent(event as MessageEvent);
        break;
      case 'message_update':
        _handleMessageUpdateEvent(event as MessageUpdateEvent);
        break;
      case 'message_delete':
        _handleMessageDeleteEvent(event as MessageDeleteEvent);
        break;
      case 'message_ack':
        _handleMessageAcknowledgmentEvent(event as MessageAcknowledgmentEvent);
        break;
      case 'conversation_update':
        _handleConversationUpdateEvent(event as ConversationUpdateEvent);
        break;
      case 'error':
        _handleErrorEvent(event as ErrorEvent);
        break;
      default:
        _logger.w('Unhandled WebSocket event: ${event.type}');
    }
  }

  /// Handle new message event
  void _handleMessageEvent(MessageEvent event) async {
    _logger.d('Received message: ${event.messageId}');

    // Convert to Message entity and save locally
    final message = Message(
      id: event.messageId,
      conversationId: event.conversationId,
      senderId: event.senderId,
      senderName: event.senderName,
      content: event.content,
      type: _getMessageType(event.contentType),
      status: MessageStatus.delivered,
      timestamp: event.timestamp,
      metadata: event.metadata,
      messageId: event.messageId,
      deliveredAt: DateTime.now(),
      deliveryStatus: MessageDeliveryStatus.delivered,
    );

    await _chatRepository.saveMessage(message);
    _messageStreamController.add(event);

    // Send acknowledgment
    await _webSocketService.acknowledgeMessage(
      messageId: event.messageId,
      status: 'delivered',
    );
  }

  /// Handle message update event
  void _handleMessageUpdateEvent(MessageUpdateEvent event) async {
    _logger.d('Message updated: ${event.messageId}');

    // Update message in local storage
    final existingMessage = _chatRepository.getMessagesForConversation(event.conversationId)
        .where((m) => m.id == event.messageId)
        .firstOrNull;

    if (existingMessage != null) {
      final updatedMessage = existingMessage.copyWith(
        content: event.content,
        isEdited: event.isEdited,
        editedAt: event.editedAt,
        updatedAt: event.timestamp,
      );
      await _chatRepository.saveMessage(updatedMessage);
    }
  }

  /// Handle message delete event
  void _handleMessageDeleteEvent(MessageDeleteEvent event) async {
    _logger.d('Message deleted: ${event.messageId}');
    await _chatRepository.deleteMessage(event.messageId);
  }

  /// Handle typing event
  void _handleTypingEvent(TypingEvent event) {
    _logger.d('Typing indicator: ${event.userId} - ${event.isTyping}');

    final conversationUsers = _typingUsers[event.conversationId] ?? <String>{};
    
    if (event.isTyping) {
      conversationUsers.add(event.userId);
    } else {
      conversationUsers.remove(event.userId);
    }
    
    _typingUsers[event.conversationId] = conversationUsers;
    _typingStreamController.add(event);
  }

  /// Handle presence event
  void _handlePresenceEvent(UserPresenceEvent event) {
    _logger.d('User presence: ${event.userId} - ${event.status}');
    
    _userPresence[event.userId] = event;
    _presenceStreamController.add(event);
  }

  /// Handle participant events
  void _handleParticipantEvent(WebSocketEvent event) {
    _logger.d('Participant event: ${event.type}');
    // Handle participant join/leave events
    // Update conversation participant list in local storage
  }

  /// Handle message acknowledgment event
  void _handleMessageAcknowledgmentEvent(MessageAcknowledgmentEvent event) async {
    _logger.d('Message acknowledged: ${event.messageId} - ${event.status}');
    
    final deliveryStatus = event.status == 'read' 
        ? MessageDeliveryStatus.read 
        : MessageDeliveryStatus.delivered;
    
    await _updateMessageStatus(
      event.messageId,
      event.status == 'read' ? MessageStatus.read : MessageStatus.delivered,
      deliveryStatus,
    );
  }

  /// Handle conversation update event
  void _handleConversationUpdateEvent(ConversationUpdateEvent event) async {
    _logger.d('Conversation updated: ${event.conversationId}');
    
    // Update conversation in local storage
    final conversation = _chatRepository.getConversation(event.conversationId);
    if (conversation != null) {
      // Apply updates to conversation (this would need specific implementation)
      // await _chatRepository.saveConversation(updatedConversation);
    }
  }

  /// Handle error event
  void _handleErrorEvent(ErrorEvent event) {
    _logger.e('WebSocket error: ${event.message} (${event.errorType})');
  }

  /// Update message status in local storage
  Future<void> _updateMessageStatus(
    String messageId,
    MessageStatus status,
    MessageDeliveryStatus deliveryStatus,
  ) async {
    // Find message across all conversations
    for (final conversation in _chatRepository.getAllConversations()) {
      final messages = _chatRepository.getMessagesForConversation(conversation.id);
      final message = messages.where((m) => m.id == messageId).firstOrNull;
      
      if (message != null) {
        final updatedMessage = message.copyWith(
          status: status,
          deliveryStatus: deliveryStatus,
          readAt: status == MessageStatus.read ? DateTime.now() : null,
          deliveredAt: status == MessageStatus.delivered ? DateTime.now() : null,
        );
        await _chatRepository.saveMessage(updatedMessage);
        break;
      }
    }
  }

  /// Get current user info
  Future<Map<String, dynamic>?> _getCurrentUser() async {
    // This would typically come from the auth service
    return {
      'id': 'current_user_id',
      'name': 'Current User',
    };
  }

  /// Convert content type string to MessageType enum
  MessageType _getMessageType(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'audio':
        return MessageType.audio;
      case 'video':
        return MessageType.video;
      case 'document':
        return MessageType.document;
      default:
        return MessageType.text;
    }
  }

  /// Dispose of all resources
  void dispose() {
    _webSocketService.dispose();
    _messageStreamController.close();
    _typingStreamController.close();
    _presenceStreamController.close();
    _connectionStreamController.close();
  }
}