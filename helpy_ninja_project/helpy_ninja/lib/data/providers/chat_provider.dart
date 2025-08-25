import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/helpy_personality.dart';
import '../../services/helpy_ai_service.dart';

/// Chat state notifier for managing conversations and messages
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState()) {
    _initializeChat();
  }

  late Box _chatBox;
  late Box _messagesBox;
  late Box _personalitiesBox;

  /// Initialize chat system
  Future<void> _initializeChat() async {
    state = state.copyWith(isLoading: true);

    try {
      // Open Hive boxes
      _chatBox = await Hive.openBox('conversations');
      _messagesBox = await Hive.openBox('messages');
      _personalitiesBox = await Hive.openBox('personalities');

      // Load cached data
      await _loadConversations();
      await _loadPersonalities();

      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize chat: $e',
      );
    }
  }

  /// Load conversations from storage
  Future<void> _loadConversations() async {
    try {
      final conversationMaps = _chatBox.values.toList();
      final conversations = conversationMaps
          .map((map) => Conversation.fromJson(Map<String, dynamic>.from(map)))
          .toList();

      // Sort by last message time
      conversations.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });

      state = state.copyWith(conversations: conversations);
    } catch (e) {
      debugPrint('Failed to load conversations: $e');
    }
  }

  /// Load Helpy personalities
  Future<void> _loadPersonalities() async {
    try {
      final personalityMaps = _personalitiesBox.values.toList();
      if (personalityMaps.isEmpty) {
        // Create default personalities
        await _createDefaultPersonalities();
        return;
      }

      final personalities = personalityMaps
          .map(
            (map) => HelpyPersonality.fromJson(Map<String, dynamic>.from(map)),
          )
          .where((p) => p.isActive)
          .toList();

      state = state.copyWith(availablePersonalities: personalities);
    } catch (e) {
      debugPrint('Failed to load personalities: $e');
    }
  }

  /// Create default Helpy personalities
  Future<void> _createDefaultPersonalities() async {
    final defaultPersonalities = [
      HelpyPersonality(
        id: 'helpy_friendly',
        name: 'Friendly Helpy',
        description:
            'Your warm and encouraging study buddy who makes learning fun!',
        avatar: '😊',
        type: PersonalityType.friendly,
        traits: const PersonalityTraits(
          enthusiasm: 0.8,
          formality: 0.3,
          patience: 0.9,
          humor: 0.7,
          empathy: 0.9,
          directness: 0.6,
        ),
        responseStyle: const ResponseStyle(
          length: ResponseLength.medium,
          tone: ResponseTone.casual,
          useEmojis: true,
          useExamples: true,
          askFollowUpQuestions: true,
        ),
        specializations: ['general', 'motivation', 'study_tips'],
        greetingMessages: {
          'default': 'Hey there! 😊 I\'m excited to help you learn today!',
          'morning': 'Good morning! ☀️ Ready to tackle some awesome learning?',
          'afternoon':
              'Hey! 👋 Hope you\'re having a great day! What shall we explore?',
          'evening': 'Good evening! 🌙 Perfect time for some relaxed learning!',
        },
        createdAt: DateTime.now(),
      ),

      HelpyPersonality(
        id: 'helpy_professional',
        name: 'Professional Helpy',
        description:
            'Your structured and methodical learning assistant for serious study sessions.',
        avatar: '🎓',
        type: PersonalityType.professional,
        traits: const PersonalityTraits(
          enthusiasm: 0.6,
          formality: 0.8,
          patience: 0.8,
          humor: 0.3,
          empathy: 0.7,
          directness: 0.9,
        ),
        responseStyle: const ResponseStyle(
          length: ResponseLength.long,
          tone: ResponseTone.formal,
          useEmojis: false,
          useExamples: true,
          askFollowUpQuestions: true,
        ),
        specializations: ['mathematics', 'science', 'academic_writing'],
        greetingMessages: {
          'default':
              'Good day. I am here to assist you with your educational objectives.',
          'study_session':
              'Welcome to your study session. Let us proceed systematically.',
        },
        createdAt: DateTime.now(),
      ),

      HelpyPersonality(
        id: 'helpy_playful',
        name: 'Playful Helpy',
        description:
            'Your energetic gaming buddy who turns learning into an adventure!',
        avatar: '🎮',
        type: PersonalityType.playful,
        traits: const PersonalityTraits(
          enthusiasm: 1.0,
          formality: 0.1,
          patience: 0.7,
          humor: 1.0,
          empathy: 0.8,
          directness: 0.5,
        ),
        responseStyle: const ResponseStyle(
          length: ResponseLength.short,
          tone: ResponseTone.enthusiastic,
          useEmojis: true,
          useExamples: true,
          askFollowUpQuestions: true,
        ),
        specializations: ['games', 'creative_learning', 'puzzles'],
        greetingMessages: {
          'default': 'Woohoo! 🎉 Ready for an epic learning adventure?',
          'game': 'Let\'s turn this into a game! 🎯 Challenge accepted?',
        },
        createdAt: DateTime.now(),
      ),

      HelpyPersonality(
        id: 'helpy_wise',
        name: 'Wise Helpy',
        description:
            'Your thoughtful mentor who provides deep insights and philosophical perspectives.',
        avatar: '🦉',
        type: PersonalityType.wise,
        traits: const PersonalityTraits(
          enthusiasm: 0.5,
          formality: 0.6,
          patience: 1.0,
          humor: 0.4,
          empathy: 0.9,
          directness: 0.7,
        ),
        responseStyle: const ResponseStyle(
          length: ResponseLength.long,
          tone: ResponseTone.neutral,
          useEmojis: false,
          useExamples: true,
          askFollowUpQuestions: true,
        ),
        specializations: ['philosophy', 'critical_thinking', 'deep_learning'],
        greetingMessages: {
          'default':
              'Greetings, young scholar. What wisdom shall we seek today?',
          'reflection': 'Let us pause and reflect on the deeper meaning...',
        },
        createdAt: DateTime.now(),
      ),
    ];

    for (final personality in defaultPersonalities) {
      await _personalitiesBox.put(personality.id, personality.toJson());
    }

    state = state.copyWith(availablePersonalities: defaultPersonalities);
  }

  /// Create a new conversation
  Future<Conversation> createConversation({
    required String title,
    required String userId,
    required String helpyPersonalityId,
    ConversationType type = ConversationType.general,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final conversation = Conversation(
        id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        userId: userId,
        helpyPersonalityId: helpyPersonalityId,
        type: type,
        status: ConversationStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        participants: [userId, helpyPersonalityId],
        metadata: metadata,
      );

      // Save to storage
      await _chatBox.put(conversation.id, conversation.toJson());

      // Update state
      final updatedConversations = [conversation, ...state.conversations];
      state = state.copyWith(conversations: updatedConversations);

      // Send welcome message from Helpy
      await _sendWelcomeMessage(conversation);

      return conversation;
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  /// Send welcome message from Helpy
  Future<void> _sendWelcomeMessage(Conversation conversation) async {
    final personality = state.availablePersonalities.firstWhere(
      (p) => p.id == conversation.helpyPersonalityId,
    );

    final welcomeMessage = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversation.id,
      senderId: personality.id,
      senderName: personality.name,
      content: personality.getGreeting('default'),
      type: MessageType.text,
      status: MessageStatus.delivered,
      timestamp: DateTime.now(),
    );

    await _saveMessage(welcomeMessage);
    await _updateConversationLastMessage(conversation.id, welcomeMessage);
  }

  /// Send a message
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    List<MessageAttachment>? attachments,
  }) async {
    try {
      final message = Message(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        content: content,
        type: type,
        status: MessageStatus.sending,
        timestamp: DateTime.now(),
        replyToMessageId: replyToMessageId,
        attachments: attachments,
      );

      // Save message
      await _saveMessage(message);

      // Update conversation
      await _updateConversationLastMessage(conversationId, message);

      // Mark as sent
      final sentMessage = message.copyWith(status: MessageStatus.sent);
      await _updateMessage(sentMessage);

      // If this is a user message, trigger Helpy response
      if (!message.isFromHelpy) {
        _scheduleHelpyResponse(conversationId, message);
      }

      return sentMessage;
    } catch (e) {
      // Mark as failed
      final failedMessage = Message(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        content: content,
        type: type,
        status: MessageStatus.failed,
        timestamp: DateTime.now(),
        replyToMessageId: replyToMessageId,
        attachments: attachments,
      );

      await _saveMessage(failedMessage);
      throw Exception('Failed to send message: $e');
    }
  }

  /// Schedule Helpy response (simulated AI response)
  void _scheduleHelpyResponse(String conversationId, Message userMessage) {
    final conversation = state.conversations.firstWhere(
      (c) => c.id == conversationId,
    );

    final personality = state.availablePersonalities.firstWhere(
      (p) => p.id == conversation.helpyPersonalityId,
    );

    // Show typing indicator
    if (personality.settings.showTypingIndicator) {
      _showTypingIndicator(conversationId, personality.id);
    }

    // Generate response after delay
    Future.delayed(
      Duration(seconds: personality.settings.responseDelay.round()),
      () {
        _generateHelpyResponse(conversationId, userMessage, personality);
      },
    );
  }

  /// Show typing indicator
  void _showTypingIndicator(String conversationId, String helpyId) {
    final typingMessage = Message(
      id: 'typing_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: helpyId,
      senderName: 'Helpy',
      content: '',
      type: MessageType.typing,
      status: MessageStatus.delivered,
      timestamp: DateTime.now(),
    );

    // Add typing message to current messages
    final conversationMessages = state.currentMessages[conversationId] ?? [];
    state = state.copyWith(
      currentMessages: {
        ...state.currentMessages,
        conversationId: [...conversationMessages, typingMessage],
      },
    );
  }

  /// Generate Helpy response (enhanced AI response)
  Future<void> _generateHelpyResponse(
    String conversationId,
    Message userMessage,
    HelpyPersonality personality,
  ) async {
    // Remove typing indicator
    _removeTypingIndicator(conversationId);

    // Get conversation history for context
    final conversationMessages = state.currentMessages[conversationId] ?? [];
    final recentMessages = conversationMessages
        .where((m) => m.type != MessageType.typing)
        .take(personality.settings.maxContextMessages)
        .toList();

    // Get conversation for subject context
    final conversation = state.conversations.firstWhere(
      (c) => c.id == conversationId,
    );

    final subject = conversation.metadata?['subject'];

    // Generate response using enhanced AI service
    final response = HelpyAIService.generateResponse(
      userMessage.content,
      personality,
      recentMessages,
      subject: subject,
    );

    final helpyMessage = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: personality.id,
      senderName: personality.name,
      content: response,
      type: MessageType.text,
      status: MessageStatus.delivered,
      timestamp: DateTime.now(),
      replyToMessageId: userMessage.id,
    );

    await _saveMessage(helpyMessage);
    await _updateConversationLastMessage(conversationId, helpyMessage);
  }

  /// Remove typing indicator
  void _removeTypingIndicator(String conversationId) {
    final conversationMessages = state.currentMessages[conversationId] ?? [];
    final filteredMessages = conversationMessages
        .where((m) => m.type != MessageType.typing)
        .toList();

    state = state.copyWith(
      currentMessages: {
        ...state.currentMessages,
        conversationId: filteredMessages,
      },
    );
  }

  /// Generate response content based on personality
  String _generateResponseContent(
    Message userMessage,
    HelpyPersonality personality,
  ) {
    final content = userMessage.content.toLowerCase();

    // Simple response generation based on personality type
    if (content.contains('hello') || content.contains('hi')) {
      return personality.getGreeting('default');
    }

    if (content.contains('help') || content.contains('?')) {
      switch (personality.type) {
        case PersonalityType.friendly:
          return "I'd love to help you with that! 😊 Let me break it down for you step by step.";
        case PersonalityType.professional:
          return "I shall provide you with a systematic approach to address your inquiry.";
        case PersonalityType.playful:
          return "Ooh, a challenge! 🎯 Let's tackle this together like a boss level!";
        case PersonalityType.wise:
          return "Ah, an excellent question. Let us explore this matter thoughtfully.";
        case PersonalityType.encouraging:
          return "You've got this! 💪 I believe in you! Let me guide you through it.";
        case PersonalityType.patient:
          return "Take your time. I'm here to support you through this learning journey.";
      }
    }

    // Default responses
    final responses = [
      "That's a great point! Tell me more about what you're thinking.",
      "I understand what you're asking. Let me help you explore this further.",
      "Interesting! Have you considered looking at it from this angle?",
      "That's exactly the kind of question that leads to deeper understanding!",
    ];

    return responses[DateTime.now().millisecond % responses.length];
  }

  /// Save message to storage
  Future<void> _saveMessage(Message message) async {
    await _messagesBox.put(message.id, message.toJson());

    // Update current messages in state
    final conversationMessages =
        state.currentMessages[message.conversationId] ?? [];
    final updatedMessages = [...conversationMessages, message];

    state = state.copyWith(
      currentMessages: {
        ...state.currentMessages,
        message.conversationId: updatedMessages,
      },
    );
  }

  /// Update existing message
  Future<void> _updateMessage(Message message) async {
    await _messagesBox.put(message.id, message.toJson());

    // Update in current messages
    final conversationMessages =
        state.currentMessages[message.conversationId] ?? [];
    final updatedMessages = conversationMessages
        .map((m) => m.id == message.id ? message : m)
        .toList();

    state = state.copyWith(
      currentMessages: {
        ...state.currentMessages,
        message.conversationId: updatedMessages,
      },
    );
  }

  /// Update conversation's last message
  Future<void> _updateConversationLastMessage(
    String conversationId,
    Message message,
  ) async {
    final conversationIndex = state.conversations.indexWhere(
      (c) => c.id == conversationId,
    );

    if (conversationIndex != -1) {
      final conversation = state.conversations[conversationIndex];
      final updatedConversation = conversation.copyWith(
        lastMessageId: message.id,
        lastMessagePreview: message.content,
        lastMessageTime: message.timestamp,
        updatedAt: DateTime.now(),
      );

      // Save to storage
      await _chatBox.put(conversationId, updatedConversation.toJson());

      // Update state
      final updatedConversations = [...state.conversations];
      updatedConversations[conversationIndex] = updatedConversation;
      updatedConversations.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });

      state = state.copyWith(conversations: updatedConversations);
    }
  }

  /// Load messages for a conversation
  Future<List<Message>> loadMessagesForConversation(
    String conversationId,
  ) async {
    try {
      if (state.currentMessages.containsKey(conversationId)) {
        return state.currentMessages[conversationId]!;
      }

      // Load from storage
      final allMessages = _messagesBox.values
          .map((map) => Message.fromJson(Map<String, dynamic>.from(map)))
          .where((message) => message.conversationId == conversationId)
          .toList();

      // Sort by timestamp
      allMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Update state
      state = state.copyWith(
        currentMessages: {
          ...state.currentMessages,
          conversationId: allMessages,
        },
      );

      return allMessages;
    } catch (e) {
      debugPrint('Failed to load messages: $e');
      return [];
    }
  }

  /// Mark conversation messages as read
  Future<void> markMessagesAsRead(String conversationId) async {
    final messages = state.currentMessages[conversationId] ?? [];
    bool hasUpdates = false;

    final updatedMessages = messages.map((message) {
      if (message.status != MessageStatus.read && message.isFromHelpy) {
        hasUpdates = true;
        return message.copyWith(status: MessageStatus.read);
      }
      return message;
    }).toList();

    if (hasUpdates) {
      // Update storage
      for (final message in updatedMessages) {
        if (message.status == MessageStatus.read) {
          await _messagesBox.put(message.id, message.toJson());
        }
      }

      // Update state
      state = state.copyWith(
        currentMessages: {
          ...state.currentMessages,
          conversationId: updatedMessages,
        },
      );

      // Update conversation unread count
      await _updateConversationUnreadCount(conversationId);
    }
  }

  /// Update conversation unread count
  Future<void> _updateConversationUnreadCount(String conversationId) async {
    final conversationIndex = state.conversations.indexWhere(
      (c) => c.id == conversationId,
    );

    if (conversationIndex != -1) {
      final conversation = state.conversations[conversationIndex];
      final updatedConversation = conversation.copyWith(unreadCount: 0);

      await _chatBox.put(conversationId, updatedConversation.toJson());

      final updatedConversations = [...state.conversations];
      updatedConversations[conversationIndex] = updatedConversation;
      state = state.copyWith(conversations: updatedConversations);
    }
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Delete conversation
      await _chatBox.delete(conversationId);

      // Delete all messages
      final messages = state.currentMessages[conversationId] ?? [];
      for (final message in messages) {
        await _messagesBox.delete(message.id);
      }

      // Update state
      final updatedConversations = state.conversations
          .where((c) => c.id != conversationId)
          .toList();

      final updatedCurrentMessages = Map<String, List<Message>>.from(
        state.currentMessages,
      );
      updatedCurrentMessages.remove(conversationId);

      state = state.copyWith(
        conversations: updatedConversations,
        currentMessages: updatedCurrentMessages,
      );
    } catch (e) {
      throw Exception('Failed to delete conversation: $e');
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh chat data
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    await _loadConversations();
    state = state.copyWith(isLoading: false, lastUpdated: DateTime.now());
  }
}

/// Chat state model
class ChatState {
  final List<Conversation> conversations;
  final List<HelpyPersonality> availablePersonalities;
  final Map<String, List<Message>> currentMessages;
  final bool isLoading;
  final bool isInitialized;
  final String? error;
  final DateTime? lastUpdated;

  const ChatState({
    this.conversations = const [],
    this.availablePersonalities = const [],
    this.currentMessages = const {},
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
    this.lastUpdated,
  });

  ChatState copyWith({
    List<Conversation>? conversations,
    List<HelpyPersonality>? availablePersonalities,
    Map<String, List<Message>>? currentMessages,
    bool? isLoading,
    bool? isInitialized,
    String? error,
    DateTime? lastUpdated,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      availablePersonalities:
          availablePersonalities ?? this.availablePersonalities,
      currentMessages: currentMessages ?? this.currentMessages,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Get total unread messages count
  int get totalUnreadCount {
    return conversations.fold(0, (sum, conv) => sum + conv.unreadCount);
  }

  /// Check if chat system is ready
  bool get isReady => isInitialized && !isLoading && error == null;
}

/// Chat provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

/// Convenience providers
final conversationsProvider = Provider<List<Conversation>>((ref) {
  return ref.watch(chatProvider).conversations;
});

final availablePersonalitiesProvider = Provider<List<HelpyPersonality>>((ref) {
  return ref.watch(chatProvider).availablePersonalities;
});

final totalUnreadCountProvider = Provider<int>((ref) {
  return ref.watch(chatProvider).totalUnreadCount;
});

final isChatLoadingProvider = Provider<bool>((ref) {
  return ref.watch(chatProvider).isLoading;
});

final chatErrorProvider = Provider<String?>((ref) {
  return ref.watch(chatProvider).error;
});

/// Provider for messages in a specific conversation
final conversationMessagesProvider =
    FutureProvider.family<List<Message>, String>((ref, conversationId) async {
      final chatNotifier = ref.read(chatProvider.notifier);
      return await chatNotifier.loadMessagesForConversation(conversationId);
    });

/// Provider for a specific conversation
final conversationProvider = Provider.family<Conversation?, String>((
  ref,
  conversationId,
) {
  final conversations = ref.watch(conversationsProvider);
  try {
    return conversations.firstWhere((c) => c.id == conversationId);
  } catch (e) {
    return null;
  }
});

/// Provider for a specific Helpy personality
final helpyPersonalityProvider = Provider.family<HelpyPersonality?, String>((
  ref,
  personalityId,
) {
  final personalities = ref.watch(availablePersonalitiesProvider);
  try {
    return personalities.firstWhere((p) => p.id == personalityId);
  } catch (e) {
    return null;
  }
});
