import '../../domain/entities/helpy_personality.dart';
import '../../domain/entities/llm_request.dart';
import '../../domain/entities/llm_response.dart';
import '../../domain/entities/message.dart';

/// System for managing personality-based AI responses
class PersonalitySystem {
  static const Map<PersonalityType, PersonalityPromptTemplate> _personalityPrompts = {
    PersonalityType.friendly: PersonalityPromptTemplate(
      systemPrompt: """You are a friendly and warm AI tutor named Helpy. Your personality traits:
- Enthusiastic and encouraging
- Empathetic and understanding
- Uses warm, supportive language
- Shows genuine interest in the student's progress
- Celebrates achievements and provides comfort during challenges
- Uses appropriate emojis and informal language when suitable""",
      responseStyle: ResponseStyleGuide(
        tone: 'warm and encouraging',
        language: 'informal but respectful',
        punctuation: 'use exclamation marks for enthusiasm',
        examples: true,
        personalReferences: true,
      ),
    ),
    PersonalityType.professional: PersonalityPromptTemplate(
      systemPrompt: """You are a professional and knowledgeable AI tutor. Your personality traits:
- Clear and direct communication
- Structured and organized responses
- Formal but approachable tone
- Focus on facts and accuracy
- Methodical problem-solving approach
- Maintains academic standards""",
      responseStyle: ResponseStyleGuide(
        tone: 'professional and authoritative',
        language: 'formal and precise',
        punctuation: 'proper punctuation, avoid excessive exclamations',
        examples: true,
        personalReferences: false,
      ),
    ),
    PersonalityType.playful: PersonalityPromptTemplate(
      systemPrompt: """You are a playful and energetic AI tutor who makes learning fun. Your personality traits:
- Creative and imaginative
- Uses analogies and metaphors
- Incorporates games and interactive elements
- High energy and enthusiasm
- Makes learning engaging and enjoyable
- Uses humor appropriately""",
      responseStyle: ResponseStyleGuide(
        tone: 'energetic and fun',
        language: 'creative and expressive',
        punctuation: 'varied punctuation for emphasis',
        examples: true,
        personalReferences: true,
      ),
    ),
    PersonalityType.wise: PersonalityPromptTemplate(
      systemPrompt: """You are a wise and thoughtful AI tutor with deep knowledge. Your personality traits:
- Patient and reflective
- Provides deep insights and connections
- Encourages critical thinking
- Shares wisdom through stories and examples
- Considers multiple perspectives
- Guides students to discover answers themselves""",
      responseStyle: ResponseStyleGuide(
        tone: 'thoughtful and contemplative',
        language: 'measured and insightful',
        punctuation: 'thoughtful pauses and proper structure',
        examples: true,
        personalReferences: false,
      ),
    ),
    PersonalityType.encouraging: PersonalityPromptTemplate(
      systemPrompt: """You are an encouraging and supportive AI tutor who builds confidence. Your personality traits:
- Always positive and optimistic
- Recognizes effort and progress
- Helps students overcome challenges
- Builds self-confidence
- Celebrates small victories
- Provides hope and motivation""",
      responseStyle: ResponseStyleGuide(
        tone: 'uplifting and motivational',
        language: 'positive and affirming',
        punctuation: 'emphasize achievements with enthusiasm',
        examples: true,
        personalReferences: true,
      ),
    ),
    PersonalityType.patient: PersonalityPromptTemplate(
      systemPrompt: """You are a patient and understanding AI tutor who never rushes. Your personality traits:
- Takes time to explain thoroughly
- Never shows frustration or impatience
- Breaks down complex concepts slowly
- Repeats information when needed
- Adapts to different learning paces
- Creates a safe learning environment""",
      responseStyle: ResponseStyleGuide(
        tone: 'calm and reassuring',
        language: 'gentle and understanding',
        punctuation: 'calm, measured responses',
        examples: true,
        personalReferences: false,
      ),
    ),
  };

  /// Generate system prompt based on personality
  static String generateSystemPrompt(
    HelpyPersonality personality, {
    String? subject,
    String? additionalContext,
  }) {
    final template = _personalityPrompts[personality.type];
    if (template == null) {
      return _getDefaultSystemPrompt();
    }

    String systemPrompt = template.systemPrompt;

    // Add subject-specific context
    if (subject != null) {
      systemPrompt += _getSubjectContext(subject);
    }

    // Add personality trait modifications
    systemPrompt += _generateTraitModifications(personality.traits);

    // Add response style preferences
    systemPrompt += _generateResponseStyleInstructions(personality.responseStyle);

    // Add additional context
    if (additionalContext != null) {
      systemPrompt += "\n\nAdditional context: $additionalContext";
    }

    return systemPrompt;
  }

  /// Modify LLM request to include personality context
  static LlmRequest enhanceRequestWithPersonality(
    LlmRequest request,
    HelpyPersonality personality,
  ) {
    // Generate enhanced system prompt
    final systemPrompt = generateSystemPrompt(
      personality,
      subject: _extractSubjectFromRequest(request),
      additionalContext: _generateConversationContext(request.conversationHistory),
    );

    // Add personality metadata
    final enhancedMetadata = Map<String, dynamic>.from(request.metadata ?? {});
    enhancedMetadata['personality'] = personality.toJson();
    enhancedMetadata['personalitySystemPrompt'] = systemPrompt;

    // Modify settings based on personality
    final personalitySettings = _getPersonalitySettings(personality);
    final enhancedSettings = request.settings.copyWith(
      temperature: personalitySettings['temperature'],
      maxTokens: personalitySettings['maxTokens'],
      topP: personalitySettings['topP'],
    );

    return request.copyWith(
      systemPrompt: systemPrompt,
      settings: enhancedSettings,
      metadata: enhancedMetadata,
    );
  }

  /// Post-process LLM response based on personality
  static LlmResponse enhanceResponseWithPersonality(
    LlmResponse response,
    HelpyPersonality personality,
  ) {
    String enhancedContent = response.content;

    // Apply personality-specific post-processing
    enhancedContent = _applyPersonalityPostProcessing(enhancedContent, personality);

    // Add personality metadata to response
    final enhancedMetadata = LlmResponseMetadata(
      requestId: response.metadata.requestId,
      model: response.metadata.model,
      provider: response.metadata.provider,
      timestamp: response.metadata.timestamp,
      processingTimeMs: response.metadata.processingTimeMs,
      additionalData: {
        ...response.metadata.additionalData ?? {},
        'personalityType': personality.type.name,
        'personalityTraits': personality.traits.toJson(),
        'postProcessingApplied': true,
      },
    );

    return response.copyWith(
      content: enhancedContent,
      metadata: enhancedMetadata,
    );
  }

  /// Generate context from conversation history
  static String _generateConversationContext(List<Message> history) {
    if (history.isEmpty) return '';

    final recentMessages = history.take(5).toList();
    final topics = <String>{};
    final userQuestions = <String>[];

    for (final message in recentMessages) {
      if (message.senderId != 'ai') { // Assuming non-AI messages are from users
        if (message.content.contains('?')) {
          userQuestions.add(message.content);
        }
      }
      
      // Extract topics (simple keyword detection)
      final content = message.content.toLowerCase();
      if (content.contains('math') || content.contains('calculation')) topics.add('mathematics');
      if (content.contains('science') || content.contains('experiment')) topics.add('science');
      if (content.contains('history') || content.contains('historical')) topics.add('history');
      if (content.contains('english') || content.contains('literature')) topics.add('english');
    }

    String context = '';
    if (topics.isNotEmpty) {
      context += '\nConversation topics: ${topics.join(', ')}';
    }
    if (userQuestions.isNotEmpty) {
      context += '\nRecent student questions show interest in: ${userQuestions.length} topics';
    }

    return context;
  }

  /// Extract subject from request context
  static String? _extractSubjectFromRequest(LlmRequest request) {
    // Check metadata first
    final metadata = request.metadata;
    if (metadata?['subject'] != null) {
      return metadata!['subject'] as String;
    }

    // Try to infer from prompt
    final prompt = request.prompt.toLowerCase();
    if (prompt.contains('math') || prompt.contains('calculation')) return 'mathematics';
    if (prompt.contains('science') || prompt.contains('physics')) return 'science';
    if (prompt.contains('history') || prompt.contains('historical')) return 'history';
    if (prompt.contains('english') || prompt.contains('literature')) return 'english';

    return null;
  }

  /// Get subject-specific context
  static String _getSubjectContext(String subject) {
    final contexts = {
      'mathematics': '\n\nYou are tutoring mathematics. Focus on logical problem-solving, step-by-step explanations, and helping students understand mathematical concepts and patterns.',
      'science': '\n\nYou are tutoring science. Encourage curiosity, scientific thinking, observations, and help students understand how the natural world works.',
      'english': '\n\nYou are tutoring English/Literature. Focus on reading comprehension, writing skills, grammar, and helping students appreciate language and literature.',
      'history': '\n\nYou are tutoring history. Help students understand historical events, their causes and effects, and connect past events to present understanding.',
      'general': '\n\nYou are providing general educational support. Adapt your teaching style to the subject matter as needed.',
    };

    return contexts[subject.toLowerCase()] ?? contexts['general']!;
  }

  /// Generate trait-specific modifications
  static String _generateTraitModifications(PersonalityTraits traits) {
    String modifications = '\n\nPersonality trait adjustments:';

    if (traits.enthusiasm > 0.8) {
      modifications += '\n- Show high enthusiasm and energy in your responses';
    } else if (traits.enthusiasm < 0.3) {
      modifications += '\n- Keep responses calm and measured';
    }

    if (traits.empathy > 0.8) {
      modifications += '\n- Be very empathetic and emotionally supportive';
    }

    if (traits.patience > 0.8) {
      modifications += '\n- Take extra time to explain concepts thoroughly';
    }

    if (traits.humor > 0.7) {
      modifications += '\n- Use appropriate humor and light-hearted examples when suitable';
    }

    if (traits.formality > 0.7) {
      modifications += '\n- Maintain formal language and professional tone';
    } else if (traits.formality < 0.3) {
      modifications += '\n- Use casual, friendly language';
    }

    return modifications;
  }

  /// Generate response style instructions
  static String _generateResponseStyleInstructions(ResponseStyle style) {
    String instructions = '\n\nResponse style preferences:';

    if (style.useEmojis) {
      instructions += '\n- Use emojis appropriately to enhance communication';
    }

    if (style.useExamples) {
      instructions += '\n- Provide concrete examples to illustrate concepts';
    }

    if (style.askFollowUpQuestions) {
      instructions += '\n- Ask follow-up questions to engage the student';
    }

    instructions += '\n- Response length: ${style.length.name}';
    instructions += '\n- Max length: ${style.maxResponseLength} characters';
    instructions += '\n- Tone: ${style.tone.name}';

    return instructions;
  }

  /// Get personality-specific LLM settings
  static Map<String, dynamic> _getPersonalitySettings(HelpyPersonality personality) {
    switch (personality.type) {
      case PersonalityType.playful:
        return {
          'temperature': 0.8,
          'maxTokens': 1000,
          'topP': 0.9,
        };
      case PersonalityType.professional:
        return {
          'temperature': 0.3,
          'maxTokens': 800,
          'topP': 0.8,
        };
      case PersonalityType.wise:
        return {
          'temperature': 0.6,
          'maxTokens': 1200,
          'topP': 0.85,
        };
      default:
        return {
          'temperature': 0.7,
          'maxTokens': 900,
          'topP': 0.9,
        };
    }
  }

  /// Apply personality-specific post-processing
  static String _applyPersonalityPostProcessing(String content, HelpyPersonality personality) {
    String processed = content;

    // Apply response style modifications
    if (personality.responseStyle.useEmojis && !_hasEmojis(processed)) {
      processed = _addAppropriateEmojis(processed, personality.type);
    }

    // Apply length constraints
    if (processed.length > personality.responseStyle.maxResponseLength) {
      processed = _truncateResponse(processed, personality.responseStyle.maxResponseLength);
    }

    // Apply personality-specific formatting
    switch (personality.type) {
      case PersonalityType.encouraging:
        if (!processed.contains('!') && personality.traits.enthusiasm > 0.5) {
          processed = processed.replaceAll('.', '!');
        }
        break;
      case PersonalityType.professional:
        processed = processed.replaceAll('!', '.');
        break;
      default:
        break;
    }

    return processed;
  }

  /// Check if text contains emojis
  static bool _hasEmojis(String text) {
    final emojiRegex = RegExp(r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]', unicode: true);
    return emojiRegex.hasMatch(text);
  }

  /// Add appropriate emojis based on personality
  static String _addAppropriateEmojis(String text, PersonalityType type) {
    final emojiMap = {
      PersonalityType.friendly: ['😊', '👍', '💡', '🌟'],
      PersonalityType.playful: ['🎉', '✨', '🚀', '💫'],
      PersonalityType.encouraging: ['💪', '🎯', '⭐', '🏆'],
      PersonalityType.wise: ['🤔', '💭', '📚', '🔍'],
    };

    final emojis = emojiMap[type] ?? ['😊'];
    final emoji = emojis[0]; // Use first emoji for simplicity

    // Add emoji at the end if text doesn't already have one
    if (!text.trim().endsWith('!') && !text.trim().endsWith('?')) {
      return '$text $emoji';
    }
    
    return text;
  }

  /// Truncate response while preserving sentence structure
  static String _truncateResponse(String text, int maxLength) {
    if (text.length <= maxLength) return text;

    // Find last complete sentence within limit
    final truncated = text.substring(0, maxLength - 3);
    final lastSentenceEnd = truncated.lastIndexOf('.');
    
    if (lastSentenceEnd > maxLength * 0.7) {
      return text.substring(0, lastSentenceEnd + 1);
    }
    
    return '${truncated.trim()}...';
  }

  /// Get default system prompt
  static String _getDefaultSystemPrompt() {
    return """You are Helpy, an AI tutor designed to help students learn effectively. You are knowledgeable, patient, and supportive. Your goal is to guide students to understanding rather than just providing answers.""";
  }
}

/// Template for personality-specific prompts
class PersonalityPromptTemplate {
  final String systemPrompt;
  final ResponseStyleGuide responseStyle;

  const PersonalityPromptTemplate({
    required this.systemPrompt,
    required this.responseStyle,
  });
}

/// Guide for response styling
class ResponseStyleGuide {
  final String tone;
  final String language;
  final String punctuation;
  final bool examples;
  final bool personalReferences;

  const ResponseStyleGuide({
    required this.tone,
    required this.language,
    required this.punctuation,
    required this.examples,
    required this.personalReferences,
  });
}