import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/websocket_manager.dart';
import '../../core/di/injection.dart';
import '../../data/models/websocket/websocket_event.dart';
import '../../data/repositories/offline_chat_repository_impl.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/conversation.dart';

/// Provider for WebSocket manager
final webSocketManagerProvider = Provider<WebSocketManager>((ref) {
  return getIt<WebSocketManager>();
});

/// Provider for offline chat repository
final offlineChatRepositoryProvider = Provider<OfflineChatRepositoryImpl>((ref) {
  return OfflineChatRepositoryImpl();
});

/// State for real-time chat
class RealtimeChatState {
  final bool isConnected;
  final List<Message> messages;
  final List<Conversation> conversations;
  final Map<String, Set<String>> typingUsers;
  final Map<String, UserPresenceEvent> userPresence;
  final String? error;

  const RealtimeChatState({
    this.isConnected = false,
    this.messages = const [],
    this.conversations = const [],
    this.typingUsers = const {},
    this.userPresence = const {},
    this.error,
  });

  RealtimeChatState copyWith({
    bool? isConnected,
    List<Message>? messages,
    List<Conversation>? conversations,
    Map<String, Set<String>>? typingUsers,
    Map<String, UserPresenceEvent>? userPresence,
    String? error,
  }) {
    return RealtimeChatState(
      isConnected: isConnected ?? this.isConnected,
      messages: messages ?? this.messages,
      conversations: conversations ?? this.conversations,
      typingUsers: typingUsers ?? this.typingUsers,
      userPresence: userPresence ?? this.userPresence,
      error: error,
    );
  }
}

/// Notifier for real-time chat
class RealtimeChatNotifier extends StateNotifier<RealtimeChatState> {
  final WebSocketManager _webSocketManager;
  final OfflineChatRepositoryImpl _chatRepository;
  
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _presenceSubscription;

  RealtimeChatNotifier(this._webSocketManager, this._chatRepository) 
      : super(const RealtimeChatState()) {
    _initialize();
  }

  /// Initialize the notifier and set up listeners
  void _initialize() async {
    await _webSocketManager.initialize();
    _setupListeners();
    _loadOfflineData();
  }

  /// Connect to WebSocket
  Future<void> connect() async {
    try {
      await _webSocketManager.connect();
    } catch (e) {
      state = state.copyWith(error: 'Failed to connect: ${e.toString()}');
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    try {
      await _webSocketManager.disconnect();
    } catch (e) {
      state = state.copyWith(error: 'Failed to disconnect: ${e.toString()}');
    }
  }

  /// Send a message
  Future<void> sendMessage({
    required String conversationId,
    required String content,
    String contentType = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _webSocketManager.sendMessage(
        conversationId: conversationId,
        content: content,
        contentType: contentType,
        metadata: metadata,
      );
      
      // Reload messages to show the new message
      _loadMessages();
      
    } catch (e) {
      state = state.copyWith(error: 'Failed to send message: ${e.toString()}');
    }
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator({
    required String conversationId,
    required bool isTyping,
  }) async {
    try {
      await _webSocketManager.sendTypingIndicator(
        conversationId: conversationId,
        isTyping: isTyping,
      );
    } catch (e) {
      // Don't update error state for typing indicators as they're not critical
    }
  }

  /// Join a conversation
  Future<void> joinConversation(String conversationId) async {
    try {
      await _webSocketManager.joinConversation(conversationId);
    } catch (e) {
      state = state.copyWith(error: 'Failed to join conversation: ${e.toString()}');
    }
  }

  /// Leave a conversation
  Future<void> leaveConversation(String conversationId) async {
    try {
      await _webSocketManager.leaveConversation(conversationId);
    } catch (e) {
      state = state.copyWith(error: 'Failed to leave conversation: ${e.toString()}');
    }
  }

  /// Get messages for a specific conversation
  List<Message> getMessagesForConversation(String conversationId) {
    return state.messages
        .where((message) => message.conversationId == conversationId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Get typing users for a conversation
  Set<String> getTypingUsers(String conversationId) {
    return state.typingUsers[conversationId] ?? {};
  }

  /// Get user presence
  UserPresenceEvent? getUserPresence(String userId) {
    return state.userPresence[userId];
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Setup event listeners
  void _setupListeners() {
    // Connection status
    _connectionSubscription = _webSocketManager.connectionStatus.listen(
      (isConnected) {
        state = state.copyWith(isConnected: isConnected);
        if (isConnected) {
          state = state.copyWith(error: null);
        }
      },
    );

    // New messages
    _messageSubscription = _webSocketManager.messageStream.listen(
      (messageEvent) {
        _handleNewMessage(messageEvent);
      },
    );

    // Typing indicators
    _typingSubscription = _webSocketManager.typingStream.listen(
      (typingEvent) {
        _handleTypingIndicator(typingEvent);
      },
    );

    // User presence
    _presenceSubscription = _webSocketManager.presenceStream.listen(
      (presenceEvent) {
        _handlePresenceUpdate(presenceEvent);
      },
    );
  }

  /// Handle new message event
  void _handleNewMessage(MessageEvent event) {
    // Reload messages from local storage (WebSocketManager already saved it)
    _loadMessages();
  }

  /// Handle typing indicator
  void _handleTypingIndicator(TypingEvent event) {
    final updatedTypingUsers = Map<String, Set<String>>.from(state.typingUsers);
    final conversationUsers = updatedTypingUsers[event.conversationId] ?? <String>{};
    
    if (event.isTyping) {
      conversationUsers.add(event.userId);
    } else {
      conversationUsers.remove(event.userId);
    }
    
    updatedTypingUsers[event.conversationId] = conversationUsers;
    state = state.copyWith(typingUsers: updatedTypingUsers);
  }

  /// Handle presence update
  void _handlePresenceUpdate(UserPresenceEvent event) {
    final updatedPresence = Map<String, UserPresenceEvent>.from(state.userPresence);
    updatedPresence[event.userId] = event;
    state = state.copyWith(userPresence: updatedPresence);
  }

  /// Load offline data from Hive
  void _loadOfflineData() {
    _loadConversations();
    _loadMessages();
  }

  /// Load conversations from local storage
  void _loadConversations() {
    try {
      final conversations = _chatRepository.getAllConversations();
      state = state.copyWith(conversations: conversations);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load conversations: ${e.toString()}');
    }
  }

  /// Load messages from local storage
  void _loadMessages() {
    try {
      final allMessages = <Message>[];
      for (final conversation in state.conversations) {
        final messages = _chatRepository.getMessagesForConversation(conversation.id);
        allMessages.addAll(messages);
      }
      state = state.copyWith(messages: allMessages);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load messages: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _presenceSubscription?.cancel();
    _webSocketManager.dispose();
    super.dispose();
  }
}

/// Provider for real-time chat notifier
final realtimeChatProvider = StateNotifierProvider<RealtimeChatNotifier, RealtimeChatState>((ref) {
  final webSocketManager = ref.read(webSocketManagerProvider);
  final chatRepository = ref.read(offlineChatRepositoryProvider);
  
  return RealtimeChatNotifier(webSocketManager, chatRepository);
});

/// Provider for connection status
final connectionStatusProvider = Provider<bool>((ref) {
  return ref.watch(realtimeChatProvider).isConnected;
});

/// Provider for messages in a specific conversation
final conversationMessagesProvider = Provider.family<List<Message>, String>((ref, conversationId) {
  final notifier = ref.read(realtimeChatProvider.notifier);
  return notifier.getMessagesForConversation(conversationId);
});

/// Provider for typing users in a conversation
final typingUsersProvider = Provider.family<Set<String>, String>((ref, conversationId) {
  final notifier = ref.read(realtimeChatProvider.notifier);
  return notifier.getTypingUsers(conversationId);
});

/// Provider for user presence
final userPresenceProvider = Provider.family<UserPresenceEvent?, String>((ref, userId) {
  final notifier = ref.read(realtimeChatProvider.notifier);
  return notifier.getUserPresence(userId);
});