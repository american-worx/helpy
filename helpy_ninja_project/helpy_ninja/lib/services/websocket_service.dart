import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:helpy_ninja/config/config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../domain/entities/message.dart';
import '../domain/entities/shared_enums.dart';

/// WebSocket service for real-time communication in multi-agent chat
class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<Message>? _messageController;
  StreamController<ConnectionState>? _connectionController;
  StreamController<ParticipantChangeEvent>? _participantChangeController;
  StreamController<TypingIndicatorEvent>? _typingIndicatorController;
  StreamController<MessageAcknowledgment>? _acknowledgmentController;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _isConnecting = false;
  int _reconnectAttempts = 0;
  int _sequenceNumber = 0;
  final Map<String, _PendingMessage> _pendingMessages = {};
  final Map<String, Timer> _ackTimeoutTimers = {};
  final int _maxReconnectAttempts = 5;
  final Duration _heartbeatInterval = const Duration(seconds: 30);
  final Duration _reconnectDelay = const Duration(seconds: 5);
  final Duration _ackTimeout = const Duration(seconds: 10);
  final int _maxRetries = 3;

  /// Stream of incoming messages
  Stream<Message> get messageStream =>
      _messageController?.stream ?? const Stream.empty();

  /// Stream of connection state changes
  Stream<ConnectionState> get connectionStream =>
      _connectionController?.stream ?? const Stream.empty();

  /// Stream of participant change events
  Stream<ParticipantChangeEvent> get participantChangeStream =>
      _participantChangeController?.stream ?? const Stream.empty();

  /// Stream of typing indicator events
  Stream<TypingIndicatorEvent> get typingIndicatorStream =>
      _typingIndicatorController?.stream ?? const Stream.empty();

  /// Stream of message acknowledgments
  Stream<MessageAcknowledgment> get acknowledgmentStream =>
      _acknowledgmentController?.stream ?? const Stream.empty();

  /// Current connection state
  bool get isConnected => _isConnected;

  /// Connect to WebSocket server
  Future<void> connect(String userId) async {
    if (_isConnecting || _isConnected) return;

    _isConnecting = true;
    _connectionController?.add(ConnectionState.connecting);

    try {
      final uri = Uri.parse('${AppConstants.websocketUrl}?userId=$userId');
      _channel = WebSocketChannel.connect(uri);

      // Initialize controllers if needed
      _messageController ??= StreamController<Message>.broadcast();
      _connectionController ??= StreamController<ConnectionState>.broadcast();
      _participantChangeController ??=
          StreamController<ParticipantChangeEvent>.broadcast();
      _typingIndicatorController ??=
          StreamController<TypingIndicatorEvent>.broadcast();
      _acknowledgmentController ??=
          StreamController<MessageAcknowledgment>.broadcast();

      // Listen for messages
      _channel?.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      // Wait for connection to be established
      await Future.delayed(const Duration(milliseconds: 100));
      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      _connectionController?.add(ConnectionState.connected);

      // Start heartbeat
      _startHeartbeat();

      debugPrint('WebSocket connected successfully for user: $userId');
    } catch (e) {
      _isConnecting = false;
      _connectionController?.add(ConnectionState.disconnected);
      debugPrint('WebSocket connection failed: $e');

      // Attempt to reconnect
      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _stopHeartbeat();
    _stopReconnectTimer();

    _isConnected = false;
    _isConnecting = false;

    try {
      await _channel?.sink.close(status.goingAway);
    } catch (e) {
      debugPrint('Error closing WebSocket: $e');
    }

    _connectionController?.add(ConnectionState.disconnected);
    debugPrint('WebSocket disconnected');
  }

  /// Join a group session
  Future<void> joinGroupSession(String sessionId) async {
    if (!_isConnected) {
      throw Exception('Not connected to WebSocket server');
    }

    final joinMessage = {
      'type': 'join_session',
      'sessionId': sessionId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(joinMessage);
    debugPrint('Joined group session: $sessionId');
  }

  /// Leave a group session
  Future<void> leaveGroupSession(String sessionId) async {
    if (!_isConnected) {
      throw Exception('Not connected to WebSocket server');
    }

    final leaveMessage = {
      'type': 'leave_session',
      'sessionId': sessionId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(leaveMessage);
    debugPrint('Left group session: $sessionId');
  }

  /// Send a message through WebSocket
  Future<void> sendMessage(Message message) async {
    if (!_isConnected) {
      throw Exception('Not connected to WebSocket server');
    }

    // Generate sequence number and update message
    _sequenceNumber++;
    final sequencedMessage = message.copyWith(
      sequenceNumber: _sequenceNumber,
      messageId: message.id.isEmpty
          ? 'msg_${DateTime.now().millisecondsSinceEpoch}'
          : message.id,
      sentAt: DateTime.now(),
      deliveryStatus: MessageDeliveryStatus.sending,
    );

    // Track pending message
    _pendingMessages[sequencedMessage.messageId] = _PendingMessage(
      message: sequencedMessage,
      retries: 0,
      sentAt: DateTime.now(),
    );

    // Set up acknowledgment timeout
    _setupAckTimeout(sequencedMessage.messageId);

    final messageData = {
      'type': 'message',
      'message': sequencedMessage.toJson(),
      'sequenceNumber': _sequenceNumber,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(messageData);
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator({
    required String userId,
    required String sessionId,
    bool isTyping = true,
  }) async {
    if (!_isConnected) {
      throw Exception('Not connected to WebSocket server');
    }

    final typingData = {
      'type': 'typing',
      'userId': userId,
      'sessionId': sessionId,
      'isTyping': isTyping,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(typingData);
  }

  /// Send presence update
  Future<void> sendPresenceUpdate({
    required String userId,
    required String sessionId,
    required bool isOnline,
  }) async {
    if (!_isConnected) {
      throw Exception('Not connected to WebSocket server');
    }

    final presenceData = {
      'type': 'presence',
      'userId': userId,
      'sessionId': sessionId,
      'isOnline': isOnline,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(presenceData);
  }

  /// Send participant added notification
  Future<void> sendParticipantAdded({
    required String sessionId,
    required String participantId,
    required String participantType, // 'user' or 'helpy'
  }) async {
    if (!_isConnected) {
      throw Exception('Not connected to WebSocket server');
    }

    final participantData = {
      'type': 'participant_added',
      'sessionId': sessionId,
      'participantId': participantId,
      'participantType': participantType,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(participantData);
  }

  /// Send participant removed notification
  Future<void> sendParticipantRemoved({
    required String sessionId,
    required String participantId,
    required String participantType, // 'user' or 'helpy'
  }) async {
    if (!_isConnected) {
      throw Exception('Not connected to WebSocket server');
    }

    final participantData = {
      'type': 'participant_removed',
      'sessionId': sessionId,
      'participantId': participantId,
      'participantType': participantType,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(participantData);
  }

  /// Handle WebSocket errors
  void _handleError(Object error) {
    debugPrint('WebSocket error: $error');
    _connectionController?.add(ConnectionState.error);

    // Attempt to reconnect
    _scheduleReconnect();
  }

  /// Handle WebSocket disconnection
  void _handleDisconnect() {
    debugPrint('WebSocket disconnected');
    _isConnected = false;
    _connectionController?.add(ConnectionState.disconnected);

    // Attempt to reconnect
    _scheduleReconnect();
  }

  /// Send message through WebSocket channel
  void _sendMessage(Map<String, dynamic> data) {
    try {
      final jsonString = jsonEncode(data);
      _channel?.sink.add(jsonString);
    } catch (e) {
      debugPrint('Error sending WebSocket message: $e');
    }
  }

  /// Start heartbeat timer
  void _startHeartbeat() {
    _stopHeartbeat(); // Clear any existing timer

    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected) {
        final heartbeatMessage = {
          'type': 'heartbeat',
          'timestamp': DateTime.now().toIso8601String(),
        };
        _sendMessage(heartbeatMessage);
      }
    });
  }

  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    _stopReconnectTimer();

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      debugPrint(
        'Scheduling reconnection attempt $_reconnectAttempts/$_maxReconnectAttempts in ${_reconnectDelay.inSeconds} seconds',
      );

      _reconnectTimer = Timer(_reconnectDelay, () {
        // Try to reconnect
        // Note: We would need the userId to reconnect, which should be stored
        // This is a simplified implementation
        debugPrint('Attempting to reconnect...');
        // In a real implementation, we would call connect() with the stored userId
      });
    } else {
      debugPrint('Max reconnection attempts reached');
      _connectionController?.add(ConnectionState.disconnected);
    }
  }

  /// Stop reconnection timer
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Dispose of resources
  void dispose() {
    disconnect();
    _messageController?.close();
    _connectionController?.close();
    _participantChangeController?.close();
    _typingIndicatorController?.close();
    _acknowledgmentController?.close();
    _stopHeartbeat();
    _stopReconnectTimer();

    // Clean up acknowledgment timers
    for (final timer in _ackTimeoutTimers.values) {
      timer.cancel();
    }
    _ackTimeoutTimers.clear();

    // Clear pending messages
    _pendingMessages.clear();
  }

  /// Set up acknowledgment timeout for a message
  void _setupAckTimeout(String messageId) {
    // Cancel any existing timer for this message
    _ackTimeoutTimers[messageId]?.cancel();

    // Set up new timeout timer
    _ackTimeoutTimers[messageId] = Timer(_ackTimeout, () {
      final pendingMessage = _pendingMessages[messageId];
      if (pendingMessage != null) {
        // Check if we should retry
        if (pendingMessage.retries < _maxRetries) {
          // Retry the message
          _retryMessage(messageId);
        } else {
          // Mark as failed
          _handleMessageFailure(messageId, 'Acknowledgment timeout');
        }
      }
    });
  }

  /// Retry sending a message
  void _retryMessage(String messageId) {
    final pendingMessage = _pendingMessages[messageId];
    if (pendingMessage == null) return;

    final updatedPendingMessage = _PendingMessage(
      message: pendingMessage.message,
      retries: pendingMessage.retries + 1,
      sentAt: DateTime.now(),
    );

    _pendingMessages[messageId] = updatedPendingMessage;

    // Resend the message
    final messageData = {
      'type': 'message',
      'message': updatedPendingMessage.message.toJson(),
      'sequenceNumber': updatedPendingMessage.message.sequenceNumber,
      'retry': true,
      'retryCount': updatedPendingMessage.retries,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(messageData);

    // Reset the acknowledgment timeout
    _setupAckTimeout(messageId);
  }

  /// Handle message failure
  void _handleMessageFailure(String messageId, String error) {
    // Remove the pending message from tracking
    _pendingMessages.remove(messageId);
    _ackTimeoutTimers[messageId]?.cancel();
    _ackTimeoutTimers.remove(messageId);

    // Send acknowledgment with failure status
    final acknowledgment = MessageAcknowledgment(
      messageId: messageId,
      conversationId: '', // We don't have the conversation ID in this context
      status: MessageDeliveryStatus.failed,
      timestamp: DateTime.now(),
      error: error,
    );

    _acknowledgmentController?.add(acknowledgment);
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic data) {
    try {
      final jsonString = data is String ? data : utf8.decode(data);
      final Map<String, dynamic> messageData = jsonDecode(jsonString);

      final messageType = messageData['type'] as String?;

      switch (messageType) {
        case 'message':
          final messageJson = messageData['message'] as Map<String, dynamic>;
          final message = Message.fromJson(messageJson);
          _messageController?.add(message);

          // Send acknowledgment for received messages
          if (message.messageId.isNotEmpty) {
            _sendAcknowledgment(message.messageId, message.conversationId,
                MessageDeliveryStatus.delivered);
          }
          break;

        case 'message_ack':
          // Handle message acknowledgment
          final ackJson = messageData['acknowledgment'] as Map<String, dynamic>;
          final acknowledgment = MessageAcknowledgment.fromJson(ackJson);

          // Cancel timeout timer
          _ackTimeoutTimers[acknowledgment.messageId]?.cancel();
          _ackTimeoutTimers.remove(acknowledgment.messageId);

          // Remove from pending messages
          _pendingMessages.remove(acknowledgment.messageId);

          // Forward acknowledgment
          _acknowledgmentController?.add(acknowledgment);
          break;

        case 'typing':
          // Handle typing indicators
          final typingEvent = TypingIndicatorEvent.fromJson(messageData);
          _typingIndicatorController?.add(typingEvent);
          debugPrint(
            'Typing indicator received: ${messageData['userId']} is ${messageData['isTyping'] ? 'typing' : 'not typing'}',
          );
          break;

        case 'presence':
          // Handle presence updates
          debugPrint(
            'Presence update received: ${messageData['userId']} is ${messageData['isOnline'] ? 'online' : 'offline'}',
          );
          break;

        case 'participant_added':
          // Handle participant added event
          final participantChangeEvent =
              ParticipantChangeEvent.fromJson(messageData);
          _participantChangeController?.add(participantChangeEvent);
          debugPrint(
            'Participant added: ${messageData['participantId']} to session ${messageData['sessionId']}',
          );
          break;

        case 'participant_removed':
          // Handle participant removed event
          final participantChangeEvent =
              ParticipantChangeEvent.fromJson(messageData);
          _participantChangeController?.add(participantChangeEvent);
          debugPrint(
            'Participant removed: ${messageData['participantId']} from session ${messageData['sessionId']}',
          );
          break;

        case 'heartbeat':
          // Heartbeat response
          debugPrint('Heartbeat received from server');
          break;

        case 'error':
          debugPrint('WebSocket error: ${messageData['message']}');
          break;

        default:
          debugPrint('Unknown message type: $messageType');
      }
    } catch (e) {
      debugPrint('Error handling WebSocket message: $e');
    }
  }

  /// Send message acknowledgment
  void _sendAcknowledgment(
      String messageId, String conversationId, MessageDeliveryStatus status) {
    if (!_isConnected) return;

    final acknowledgment = MessageAcknowledgment(
      messageId: messageId,
      conversationId: conversationId,
      status: status,
      timestamp: DateTime.now(),
    );

    final ackData = {
      'type': 'message_ack',
      'acknowledgment': acknowledgment.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    _sendMessage(ackData);
  }
}

/// Connection state enum
enum ConnectionState { connecting, connected, disconnected, error }

/// Participant change event
class ParticipantChangeEvent {
  final String type; // 'participant_added' or 'participant_removed'
  final String sessionId;
  final String participantId;
  final String participantType; // 'user' or 'helpy'
  final DateTime timestamp;

  ParticipantChangeEvent({
    required this.type,
    required this.sessionId,
    required this.participantId,
    required this.participantType,
    required this.timestamp,
  });

  factory ParticipantChangeEvent.fromJson(Map<String, dynamic> json) {
    return ParticipantChangeEvent(
      type: json['type'] as String,
      sessionId: json['sessionId'] as String,
      participantId: json['participantId'] as String,
      participantType: json['participantType'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'sessionId': sessionId,
      'participantId': participantId,
      'participantType': participantType,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isParticipantAdded => type == 'participant_added';
  bool get isParticipantRemoved => type == 'participant_removed';
}

/// Typing indicator event
class TypingIndicatorEvent {
  final String userId;
  final String sessionId;
  final bool isTyping;
  final DateTime timestamp;

  TypingIndicatorEvent({
    required this.userId,
    required this.sessionId,
    required this.isTyping,
    required this.timestamp,
  });

  factory TypingIndicatorEvent.fromJson(Map<String, dynamic> json) {
    return TypingIndicatorEvent(
      userId: json['userId'] as String,
      sessionId: json['sessionId'] as String,
      isTyping: json['isTyping'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sessionId': sessionId,
      'isTyping': isTyping,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Message acknowledgment event
class MessageAcknowledgment {
  final String messageId;
  final String conversationId;
  final MessageDeliveryStatus status;
  final DateTime timestamp;
  final String? error;

  MessageAcknowledgment({
    required this.messageId,
    required this.conversationId,
    required this.status,
    required this.timestamp,
    this.error,
  });

  factory MessageAcknowledgment.fromJson(Map<String, dynamic> json) {
    return MessageAcknowledgment(
      messageId: json['messageId'] as String,
      conversationId: json['conversationId'] as String,
      status: MessageDeliveryStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => MessageDeliveryStatus.sent,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'error': error,
    };
  }
}

/// Internal class to track pending messages
class _PendingMessage {
  final Message message;
  final int retries;
  final DateTime sentAt;

  _PendingMessage({
    required this.message,
    required this.retries,
    required this.sentAt,
  });
}
