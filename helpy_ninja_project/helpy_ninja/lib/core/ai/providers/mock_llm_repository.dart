import 'dart:async';
import 'dart:math' as math;

import '../../../domain/repositories/i_llm_repository.dart';
import '../../../domain/entities/llm_request.dart';
import '../../../domain/entities/llm_response.dart';
import '../../../domain/entities/helpy_personality.dart';

/// Mock LLM repository for development and testing
/// This implementation provides realistic educational responses
class MockLlmRepository implements ILlmRepository {
  final Map<String, dynamic> config;
  final Map<String, List<String>> _responseTemplates;
  final Map<String, List<String>> _subjectResponses;

  MockLlmRepository({this.config = const {}})
      : _responseTemplates = _buildResponseTemplates(),
        _subjectResponses = _buildSubjectResponses();

  @override
  Future<LlmResponse> generateResponse(LlmRequest request) async {
    // Simulate processing delay
    await Future.delayed(Duration(milliseconds: 300 + math.Random().nextInt(700)));

    try {
      final response = _generateMockResponse(request);
      final requestId = _generateRequestId();

      return LlmResponse(
        content: response,
        metadata: LlmResponseMetadata(
          requestId: requestId,
          model: config['model'] ?? 'mock-educational-v1',
          provider: 'mock',
          timestamp: DateTime.now(),
          processingTimeMs: 300 + math.Random().nextInt(700),
        ),
        usage: LlmUsageInfo(
          promptTokens: _estimateTokens(request.prompt),
          completionTokens: _estimateTokens(response),
          totalTokens: _estimateTokens(request.prompt) + _estimateTokens(response),
          estimatedCost: 0.0, // Mock is free
        ),
        status: LlmResponseStatus.success,
      );
    } catch (e) {
      return LlmResponse.error(
        errorMessage: 'Mock LLM error: $e',
        requestId: _generateRequestId(),
      );
    }
  }

  @override
  Stream<LlmResponse> generateStreamingResponse(LlmRequest request) async* {
    final response = _generateMockResponse(request);
    final words = response.split(' ');
    final requestId = _generateRequestId();
    
    // Simulate streaming by yielding chunks
    String currentChunk = '';
    
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(Duration(milliseconds: 50 + math.Random().nextInt(150)));
      
      currentChunk += (currentChunk.isEmpty ? '' : ' ') + words[i];
      
      yield LlmResponse.streamingChunk(
        content: currentChunk,
        requestId: requestId,
        model: config['model'] ?? 'mock-educational-v1',
        isComplete: i == words.length - 1,
      );
    }
  }

  @override
  Future<bool> isAvailable() async {
    return true; // Mock is always available
  }

  @override
  LlmProviderInfo getProviderInfo() {
    return const LlmProviderInfo(
      name: 'Mock LLM',
      version: '1.0.0',
      supportedModels: ['mock-educational-v1', 'mock-creative-v1', 'mock-factual-v1'],
      supportsStreaming: true,
      supportsSystemPrompts: true,
      supportsTools: false,
      maxTokens: 4096,
      costPerToken: 0.0,
    );
  }

  @override
  Future<bool> validateCredentials() async {
    return true; // Mock doesn't need credentials
  }

  @override
  Future<LlmUsageStats> getUsageStats() async {
    final now = DateTime.now();
    return LlmUsageStats(
      totalTokensUsed: math.Random().nextInt(10000),
      promptTokens: math.Random().nextInt(5000),
      completionTokens: math.Random().nextInt(5000),
      totalCost: 0.0,
      requestCount: math.Random().nextInt(100),
      lastUsed: now.subtract(Duration(minutes: math.Random().nextInt(60))),
    );
  }

  @override
  Future<bool> testConnection() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  /// Generate a mock response based on the request
  String _generateMockResponse(LlmRequest request) {
    final prompt = request.prompt.toLowerCase().trim();
    final personality = request.personality;
    final context = _extractEducationalContext(request);
    
    // Analyze input type
    final responseType = _analyzeInputType(prompt);
    
    // Get base response
    String baseResponse = _getBaseResponse(responseType, prompt, context.subject);
    
    // Apply personality if provided
    if (personality != null) {
      baseResponse = _applyPersonalityStyle(baseResponse, personality);
    }
    
    // Add educational context
    baseResponse = _addEducationalContext(baseResponse, context);
    
    return baseResponse;
  }

  /// Extract educational context from the request
  EducationalContext _extractEducationalContext(LlmRequest request) {
    // Check metadata for context
    final metadata = request.metadata;
    if (metadata != null && metadata['educationalContext'] != null) {
      return EducationalContext.fromJson(metadata['educationalContext']);
    }
    
    // Try to infer from conversation history
    String? subject;
    String? topic;
    
    for (final message in request.conversationHistory.take(5)) {
      final content = message.content.toLowerCase();
      
      // Subject detection
      if (content.contains('math') || content.contains('mathematics')) {
        subject = 'mathematics';
      } else if (content.contains('science') || content.contains('physics') || content.contains('chemistry')) {
        subject = 'science';
      } else if (content.contains('english') || content.contains('literature') || content.contains('writing')) {
        subject = 'english';
      } else if (content.contains('history') || content.contains('historical')) {
        subject = 'history';
      }
      
      if (subject != null) break;
    }
    
    return EducationalContext(
      subject: subject,
      topic: topic,
      difficultyLevel: 'intermediate',
    );
  }

  /// Analyze the type of user input
  String _analyzeInputType(String input) {
    if (_containsAny(input, ['hello', 'hi', 'hey', 'good morning', 'good afternoon'])) {
      return 'greeting';
    }
    if (_containsAny(input, ['?', 'what', 'how', 'why', 'when', 'where', 'which', 'who'])) {
      return 'question';
    }
    if (_containsAny(input, ['help', 'stuck', 'confused', 'explain', 'clarify'])) {
      return 'help';
    }
    if (_containsAny(input, ['solve', 'calculate', 'equation', 'formula'])) {
      return 'mathematics';
    }
    if (_containsAny(input, ['experiment', 'theory', 'hypothesis', 'observe'])) {
      return 'science';
    }
    if (_containsAny(input, ['thank', 'thanks', 'great', 'awesome', 'cool'])) {
      return 'encouragement';
    }
    
    return 'explanation';
  }

  /// Check if input contains any of the given patterns
  bool _containsAny(String input, List<String> patterns) {
    return patterns.any((pattern) => input.contains(pattern));
  }

  /// Get base response for the determined type
  String _getBaseResponse(String responseType, String input, String? subject) {
    // Check subject-specific responses first
    if (subject != null && _subjectResponses.containsKey(subject)) {
      final templates = _subjectResponses[subject]!;
      return templates[math.Random().nextInt(templates.length)];
    }
    
    // Use general templates
    if (_responseTemplates.containsKey(responseType)) {
      final templates = _responseTemplates[responseType]!;
      return templates[math.Random().nextInt(templates.length)];
    }
    
    // Fallback
    return "That's an interesting question! Let me help you understand this better. Can you tell me more about what specifically you'd like to explore?";
  }

  /// Apply personality styling to the response
  String _applyPersonalityStyle(String response, HelpyPersonality personality) {
    switch (personality.type) {
      case PersonalityType.friendly:
        if (personality.traits.enthusiasm > 0.7) {
          response = response.replaceAll('.', '!');
        }
        if (personality.traits.empathy > 0.8) {
          response = "I understand how you feel. $response";
        }
        break;
      case PersonalityType.professional:
        response = response.replaceAll('!', '.');
        response = "To clarify: $response";
        break;
      case PersonalityType.playful:
        if (personality.traits.humor > 0.7) {
          response = "Awesome! $response";
        }
        break;
      case PersonalityType.wise:
        response = "Consider this: $response";
        break;
      case PersonalityType.encouraging:
        response = "$response You're doing great!";
        break;
      case PersonalityType.patient:
        response = "$response Take your time with this.";
        break;
    }
    
    return response;
  }

  /// Add educational context to the response
  String _addEducationalContext(String response, EducationalContext context) {
    if (context.subject != null) {
      final subjectContext = _getSubjectContext(context.subject!);
      if (subjectContext.isNotEmpty && math.Random().nextDouble() < 0.3) {
        response = "$response $subjectContext";
      }
    }
    
    return response;
  }

  /// Get subject-specific contextual information
  String _getSubjectContext(String subject) {
    final contexts = {
      'mathematics': 'Remember, math is all about patterns and logical thinking.',
      'science': 'Science helps us understand the world around us through observation.',
      'english': 'Language is a powerful tool for expression and communication.',
      'history': 'History teaches us valuable lessons from the past.',
    };
    
    return contexts[subject] ?? '';
  }

  /// Estimate token count (rough approximation)
  int _estimateTokens(String text) {
    return (text.split(' ').length * 1.3).round();
  }

  /// Generate a mock request ID
  String _generateRequestId() {
    return 'mock_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(9999)}';
  }

  /// Build response templates
  static Map<String, List<String>> _buildResponseTemplates() {
    return {
      'greeting': [
        'Hello! How can I help you learn today?',
        'Hi there! What would you like to explore?',
        'Hey! I\'m excited to help you with your studies!',
        'Welcome! What learning adventure shall we embark on?',
      ],
      'question': [
        'That\'s a great question! Let me help you understand this better.',
        'Excellent question! Here\'s how I would approach this...',
        'I love your curiosity! Let\'s dive into this together.',
        'Great thinking! This is exactly the kind of question that leads to deep learning.',
      ],
      'help': [
        'I\'m here to help! Let me break this down for you.',
        'No problem! I\'ll guide you through this step by step.',
        'Of course! Let\'s work through this together.',
        'I\'d be happy to help you understand this better.',
      ],
      'encouragement': [
        'You\'re doing great! Keep up the good work!',
        'Excellent progress! I\'m proud of how far you\'ve come.',
        'You\'ve got this! Trust in your abilities.',
        'Amazing effort! Your dedication is really showing.',
      ],
      'explanation': [
        'Let me explain this concept in a simple way...',
        'Here\'s a clear way to think about this...',
        'I\'ll break this down into easy-to-understand parts...',
        'Let\'s approach this step by step...',
      ],
    };
  }

  /// Build subject-specific responses
  static Map<String, List<String>> _buildSubjectResponses() {
    return {
      'mathematics': [
        'Math is like solving puzzles - let\'s find the pattern together!',
        'Numbers tell stories. What story is this problem telling us?',
        'Let\'s approach this mathematically, step by step.',
        'Math is all about logical thinking. Let\'s think through this logically.',
      ],
      'science': [
        'Science is about discovering how the world works!',
        'Let\'s explore this scientific concept together.',
        'Great observation! That\'s exactly how scientists think.',
        'Science is everywhere around us. Let\'s investigate!',
      ],
      'english': [
        'Language is a powerful tool for expression!',
        'Let\'s explore the beauty of words and their meanings.',
        'Reading and writing open doors to infinite worlds.',
        'Communication is key - let\'s improve your language skills!',
      ],
      'history': [
        'History teaches us about the past to understand the present.',
        'Every historical event has fascinating stories behind it.',
        'Let\'s travel back in time and explore this era together.',
        'History is full of incredible human stories and achievements.',
      ],
    };
  }
}