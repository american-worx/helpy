import '../../domain/repositories/i_llm_repository.dart';
import '../../domain/entities/llm_request.dart';
import '../../domain/entities/llm_response.dart';
import '../../domain/entities/helpy_personality.dart';
import '../../domain/entities/message.dart';
import '../../config/constants.dart';
import 'llm_provider_factory.dart';
import 'personality_system.dart';
import 'streaming_service.dart';

/// Enhanced Helpy AI Service that integrates with any LLM provider
/// This replaces the old mock HelpyAIService with real LLM integration
class EnhancedHelpyAIService {
  static ILlmRepository? _llmRepository;
  static StreamingService? _streamingService;
  static LlmProviderConfig? _currentConfig;

  /// Initialize the AI service with a specific LLM provider
  static Future<void> initialize({
    dynamic config, // Changed to dynamic to avoid undefined LlmProviderConfig
  }) async {
    // Force mock provider if LLM requests are disabled for development
    if (!AppConstants.enableLLMRequests) {
      _llmRepository = await LlmProviderFactory.create(provider: 'mock');
      _streamingService = StreamingService(_llmRepository!);
      return;
    }

    // Default to mock for development if no config provided
    final providerType = config?.provider ?? 'mock';
    final configMap = config?.toJson?.call() ?? <String, dynamic>{};

    try {
      _llmRepository = await LlmProviderFactory.create(
        provider: providerType,
        config: configMap,
      );

      _streamingService = StreamingService(_llmRepository!);

      // Test the connection
      final isAvailable = await _llmRepository!.isAvailable();
      if (!isAvailable) {
        throw Exception('LLM provider $providerType is not available');
      }
    } catch (e) {
      // Fallback to mock provider if configured provider fails
      if (providerType != 'mock') {
        _llmRepository = await LlmProviderFactory.create(provider: 'mock');
        _streamingService = StreamingService(_llmRepository!);
      } else {
        rethrow;
      }
    }
  }

  /// Generate a response using the configured LLM provider
  static Future<String> generateResponse(
    String userInput,
    HelpyPersonality personality,
    List<Message> conversationHistory, {
    String? subject,
    Map<String, dynamic>? metadata,
  }) async {
    await _ensureInitialized();

    try {
      // Create LLM request
      final request = LlmRequest(
        prompt: userInput,
        conversationHistory: conversationHistory,
        personality: personality,
        settings: _getSettingsForPersonality(personality),
        metadata: {
          'subject': subject,
          'requestId': 'req_${DateTime.now().millisecondsSinceEpoch}',
          'educationalContext': _buildEducationalContext(subject),
          ...metadata ?? {},
        },
      );

      // Enhance request with personality
      final enhancedRequest = PersonalitySystem.enhanceRequestWithPersonality(
        request,
        personality,
      );

      // Generate response
      final response = await _llmRepository!.generateResponse(enhancedRequest);

      if (response.status != LlmResponseStatus.success) {
        throw Exception('LLM request failed: ${response.errorMessage}');
      }

      // Apply personality post-processing
      final enhancedResponse = PersonalitySystem.enhanceResponseWithPersonality(
        response,
        personality,
      );

      return enhancedResponse.content;
    } catch (e) {
      // Fallback to basic response in case of error
      return _generateFallbackResponse(userInput, personality);
    }
  }

  /// Generate streaming response
  static Stream<String> generateStreamingResponse(
    String userInput,
    HelpyPersonality personality,
    List<Message> conversationHistory, {
    String? subject,
    Map<String, dynamic>? metadata,
  }) async* {
    await _ensureInitialized();

    try {
      // Create LLM request
      final request = LlmRequest(
        prompt: userInput,
        conversationHistory: conversationHistory,
        personality: personality,
        settings: _getSettingsForPersonality(personality).copyWith(stream: true),
        metadata: {
          'subject': subject,
          'requestId': 'req_${DateTime.now().millisecondsSinceEpoch}',
          'educationalContext': _buildEducationalContext(subject),
          ...metadata ?? {},
        },
      );

      // Generate streaming response
      await for (final chunk in _streamingService!.generateStreamingResponse(request, personality)) {
        if (chunk.status == LlmResponseStatus.success && chunk.content.isNotEmpty) {
          yield chunk.content;
        }
        
        if (chunk.isComplete) break;
      }
    } catch (e) {
      // Fallback to non-streaming response
      final response = await generateResponse(
        userInput,
        personality,
        conversationHistory,
        subject: subject,
        metadata: metadata,
      );
      yield response;
    }
  }

  /// Check if the AI service is available
  static Future<bool> isAvailable() async {
    if (_llmRepository == null) return false;
    return await _llmRepository!.isAvailable();
  }

  /// Get provider information
  static LlmProviderInfo? getProviderInfo() {
    return _llmRepository?.getProviderInfo();
  }

  /// Get usage statistics
  static Future<LlmUsageStats?> getUsageStats() async {
    if (_llmRepository == null) return null;
    return await _llmRepository!.getUsageStats();
  }

  /// Switch LLM provider
  static Future<void> switchProvider(LlmProviderConfig config) async {
    await initialize(config: config);
  }

  /// Detect and use the best available provider
  static Future<void> initializeWithBestProvider() async {
    final bestProvider = await LlmProviderFactory.detectBestProvider();
    final config = LlmProviderConfig(provider: bestProvider);
    await initialize(config: config);
  }

  /// Generate response with conversation context analysis
  static Future<String> generateContextualResponse(
    String userInput,
    HelpyPersonality personality,
    List<Message> conversationHistory, {
    String? subject,
    String? learningObjective,
    String? difficultyLevel,
  }) async {
    // Analyze conversation context
    final context = _analyzeConversationContext(conversationHistory);
    
    // Build enhanced metadata
    final metadata = <String, dynamic>{
      'conversationContext': context,
      'learningObjective': learningObjective,
      'difficultyLevel': difficultyLevel,
      'messageCount': conversationHistory.length,
      'userEngagementLevel': _calculateEngagementLevel(conversationHistory),
    };

    return generateResponse(
      userInput,
      personality,
      conversationHistory,
      subject: subject,
      metadata: metadata,
    );
  }

  /// Ensure the service is initialized
  static Future<void> _ensureInitialized() async {
    if (_llmRepository == null) {
      await initialize();
    }
  }

  /// Get LLM settings optimized for personality
  static LlmRequestSettings _getSettingsForPersonality(HelpyPersonality personality) {
    switch (personality.type) {
      case PersonalityType.friendly:
        return LlmRequestSettings.educational.copyWith(
          temperature: 0.8,
          maxTokens: 800,
        );
      case PersonalityType.professional:
        return LlmRequestSettings.factual.copyWith(
          temperature: 0.4,
          maxTokens: 1000,
        );
      case PersonalityType.playful:
        return LlmRequestSettings.creative.copyWith(
          temperature: 0.9,
          maxTokens: 700,
        );
      case PersonalityType.wise:
        return LlmRequestSettings.educational.copyWith(
          temperature: 0.6,
          maxTokens: 1200,
        );
      case PersonalityType.encouraging:
        return LlmRequestSettings.educational.copyWith(
          temperature: 0.7,
          maxTokens: 600,
        );
      case PersonalityType.patient:
        return LlmRequestSettings.educational.copyWith(
          temperature: 0.5,
          maxTokens: 1000,
        );
    }
  }

  /// Build educational context for the request
  static EducationalContext _buildEducationalContext(String? subject) {
    return EducationalContext(
      subject: subject,
      difficultyLevel: 'intermediate', // Could be dynamic based on user progress
      learningObjectives: _getSubjectObjectives(subject),
    );
  }

  /// Get learning objectives for a subject
  static List<String>? _getSubjectObjectives(String? subject) {
    if (subject == null) return null;
    
    final objectives = {
      'mathematics': [
        'Problem-solving skills',
        'Logical thinking',
        'Mathematical reasoning',
      ],
      'science': [
        'Scientific method',
        'Critical observation',
        'Hypothesis testing',
      ],
      'english': [
        'Reading comprehension',
        'Writing skills',
        'Language mastery',
      ],
      'history': [
        'Historical understanding',
        'Cause and effect analysis',
        'Critical thinking',
      ],
    };

    return objectives[subject.toLowerCase()];
  }

  /// Analyze conversation context
  static Map<String, dynamic> _analyzeConversationContext(List<Message> history) {
    final recentMessages = history.take(10).toList();
    final topics = <String>{};
    final userQuestions = <String>[];
    final aiResponses = <String>[];

    for (final message in recentMessages) {
      if (message.senderId != 'ai') {
        if (message.content.contains('?')) {
          userQuestions.add(message.content);
        }
      } else {
        aiResponses.add(message.content);
      }

      // Topic extraction (simple keyword-based)
      final content = message.content.toLowerCase();
      if (content.contains('math') || content.contains('calculation')) {
        topics.add('mathematics');
      }
      if (content.contains('science') || content.contains('experiment')) {
        topics.add('science');
      }
      if (content.contains('history') || content.contains('historical')) {
        topics.add('history');
      }
      if (content.contains('english') || content.contains('literature')) {
        topics.add('english');
      }
    }

    return {
      'topics': topics.toList(),
      'userQuestionCount': userQuestions.length,
      'aiResponseCount': aiResponses.length,
      'conversationLength': recentMessages.length,
      'lastMessageTimestamp': recentMessages.isNotEmpty 
          ? recentMessages.last.timestamp.toIso8601String()
          : null,
    };
  }

  /// Calculate user engagement level
  static String _calculateEngagementLevel(List<Message> history) {
    final userMessages = history.where((m) => m.senderId != 'ai').length;
    final totalMessages = history.length;
    
    if (totalMessages == 0) return 'unknown';
    
    final engagementRatio = userMessages / totalMessages;
    
    if (engagementRatio > 0.6) return 'high';
    if (engagementRatio > 0.4) return 'medium';
    return 'low';
  }

  /// Generate fallback response when LLM fails
  static String _generateFallbackResponse(String userInput, HelpyPersonality personality) {
    final fallbacks = [
      "I'm having some technical difficulties right now, but I'm still here to help! Can you rephrase your question?",
      "My connection to the learning network is a bit slow today. Let me try to help you in a different way.",
      "I'm experiencing some temporary issues, but don't worry - we can work through this together!",
      "Technical hiccup on my end! Let me give you a simplified response while I get back to full capacity.",
    ];

    // Apply basic personality styling
    String response = fallbacks[DateTime.now().millisecond % fallbacks.length];
    
    switch (personality.type) {
      case PersonalityType.friendly:
        response = "Hey! $response 😊";
        break;
      case PersonalityType.professional:
        response = "I apologize for the inconvenience. $response";
        break;
      case PersonalityType.playful:
        response = "Oops! $response Let's keep the learning adventure going! 🚀";
        break;
      case PersonalityType.encouraging:
        response = "$response You're doing great, and we'll figure this out together!";
        break;
      default:
        break;
    }

    return response;
  }

  /// Get current provider configuration
  static LlmProviderConfig? get currentConfig => _currentConfig;

  /// Check if service is initialized
  static bool get isInitialized => _llmRepository != null;
}

/// Configuration for the enhanced AI service
class AIServiceConfig {
  final LlmProviderConfig providerConfig;
  final bool enableStreaming;
  final bool enableFallback;
  final Duration responseTimeout;

  const AIServiceConfig({
    required this.providerConfig,
    this.enableStreaming = true,
    this.enableFallback = true,
    this.responseTimeout = const Duration(seconds: 30),
  });

  static const AIServiceConfig development = AIServiceConfig(
    providerConfig: LlmProviderConfig.development,
    enableStreaming: true,
    enableFallback: true,
  );
}