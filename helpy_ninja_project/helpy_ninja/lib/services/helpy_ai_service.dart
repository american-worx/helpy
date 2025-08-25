import 'dart:math' as math;

import '../domain/entities/message.dart';
import '../domain/entities/helpy_personality.dart';

/// Helpy AI response service for generating personality-based responses
class HelpyAIService {
  static const Map<String, List<String>> _responseTemplates = {
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
    'error_correction': [
      'Not quite, but you\'re on the right track! Let me help you adjust...',
      'Good attempt! Here\'s where we can improve...',
      'Almost there! Let\'s refine your understanding...',
      'I can see your thinking process. Let\'s make a small correction...',
    ],
  };

  static const Map<String, List<String>> _subjectResponses = {
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

  /// Generate a response based on personality and context
  static String generateResponse(
    String userInput,
    HelpyPersonality personality,
    List<Message> conversationHistory, {
    String? subject,
  }) {
    final cleanInput = userInput.toLowerCase().trim();

    // Determine response type based on input analysis
    final responseType = _analyzeInputType(cleanInput);

    // Get base response
    String baseResponse = _getBaseResponse(responseType, cleanInput, subject);

    // Apply personality modifications
    String personalizedResponse = _applyPersonalityStyle(
      baseResponse,
      personality,
      conversationHistory,
    );

    // Add context awareness
    personalizedResponse = _addContextualElements(
      personalizedResponse,
      personality,
      conversationHistory,
      userInput,
    );

    return personalizedResponse;
  }

  /// Analyze the type of user input
  static String _analyzeInputType(String input) {
    // Greeting patterns
    if (_containsAny(input, [
      'hello',
      'hi',
      'hey',
      'good morning',
      'good afternoon',
      'good evening',
    ])) {
      return 'greeting';
    }

    // Question patterns
    if (_containsAny(input, [
      '?',
      'what',
      'how',
      'why',
      'when',
      'where',
      'which',
      'who',
    ])) {
      return 'question';
    }

    // Help requests
    if (_containsAny(input, [
      'help',
      'stuck',
      'confused',
      'don\'t understand',
      'explain',
      'clarify',
    ])) {
      return 'help';
    }

    // Math-specific patterns
    if (_containsAny(input, [
      'solve',
      'calculate',
      'equation',
      'formula',
      'number',
    ])) {
      return 'mathematics';
    }

    // Science patterns
    if (_containsAny(input, [
      'experiment',
      'theory',
      'hypothesis',
      'observe',
      'analyze',
    ])) {
      return 'science';
    }

    // Positive expressions
    if (_containsAny(input, [
      'thank',
      'thanks',
      'great',
      'awesome',
      'cool',
      'amazing',
    ])) {
      return 'encouragement';
    }

    // Default to explanation
    return 'explanation';
  }

  /// Check if input contains any of the given patterns
  static bool _containsAny(String input, List<String> patterns) {
    return patterns.any((pattern) => input.contains(pattern));
  }

  /// Get base response for the determined type
  static String _getBaseResponse(
    String responseType,
    String input,
    String? subject,
  ) {
    // Check if we have specific subject responses
    if (subject != null &&
        _subjectResponses.containsKey(subject.toLowerCase())) {
      final subjectTemplates = _subjectResponses[subject.toLowerCase()]!;
      return subjectTemplates[math.Random().nextInt(subjectTemplates.length)];
    }

    // Use general response templates
    if (_responseTemplates.containsKey(responseType)) {
      final templates = _responseTemplates[responseType]!;
      return templates[math.Random().nextInt(templates.length)];
    }

    // Fallback responses
    return _generateFallbackResponse(input);
  }

  /// Generate fallback response when no template matches
  static String _generateFallbackResponse(String input) {
    final fallbacks = [
      'That\'s interesting! Tell me more about what you\'re thinking.',
      'I see what you\'re getting at. Let\'s explore this further.',
      'Good point! Let\'s dive deeper into this topic.',
      'I understand. Let me help you work through this.',
      'Excellent! Let\'s continue building on that idea.',
    ];

    return fallbacks[math.Random().nextInt(fallbacks.length)];
  }

  /// Apply personality-specific styling to the response
  static String _applyPersonalityStyle(
    String baseResponse,
    HelpyPersonality personality,
    List<Message> history,
  ) {
    String response = baseResponse;

    // Apply personality traits
    switch (personality.type) {
      case PersonalityType.friendly:
        response = _applyFriendlyStyle(response, personality.traits);
        break;
      case PersonalityType.professional:
        response = _applyProfessionalStyle(response, personality.traits);
        break;
      case PersonalityType.playful:
        response = _applyPlayfulStyle(response, personality.traits);
        break;
      case PersonalityType.wise:
        response = _applyWiseStyle(response, personality.traits);
        break;
      case PersonalityType.encouraging:
        response = _applyEncouragingStyle(response, personality.traits);
        break;
      case PersonalityType.patient:
        response = _applyPatientStyle(response, personality.traits);
        break;
    }

    // Apply response style preferences
    response = _applyResponseStyle(response, personality.responseStyle);

    return response;
  }

  /// Apply friendly personality style
  static String _applyFriendlyStyle(String response, PersonalityTraits traits) {
    if (traits.enthusiasm > 0.7) {
      response = response.replaceFirst(response[0], response[0].toUpperCase());
      if (!response.contains('!') && math.Random().nextBool()) {
        response = response.replaceAll('.', '!');
      }
    }

    if (traits.empathy > 0.8) {
      final warmPhrases = ['I understand', 'I hear you', 'That makes sense'];
      if (math.Random().nextDouble() < 0.3) {
        response =
            '${warmPhrases[math.Random().nextInt(warmPhrases.length)]}. $response';
      }
    }

    return response;
  }

  /// Apply professional personality style
  static String _applyProfessionalStyle(
    String response,
    PersonalityTraits traits,
  ) {
    if (traits.formality > 0.7) {
      response = response.replaceAll('!', '.');
      response = response.replaceAll('awesome', 'excellent');
      response = response.replaceAll('cool', 'interesting');
    }

    if (traits.directness > 0.8) {
      final directPhrases = ['To clarify:', 'Specifically:', 'In summary:'];
      if (math.Random().nextDouble() < 0.4) {
        response =
            '${directPhrases[math.Random().nextInt(directPhrases.length)]} $response';
      }
    }

    return response;
  }

  /// Apply playful personality style
  static String _applyPlayfulStyle(String response, PersonalityTraits traits) {
    if (traits.humor > 0.7) {
      final playfulPhrases = [
        'Woohoo!',
        'Awesome!',
        'Let\'s go!',
        'This is fun!',
      ];
      if (math.Random().nextDouble() < 0.3) {
        response =
            '${playfulPhrases[math.Random().nextInt(playfulPhrases.length)]} $response';
      }
    }

    if (traits.enthusiasm > 0.8) {
      response = response.replaceAll('.', '!');
    }

    return response;
  }

  /// Apply wise personality style
  static String _applyWiseStyle(String response, PersonalityTraits traits) {
    if (traits.patience > 0.8) {
      final thoughtfulPhrases = [
        'Consider this:',
        'Reflect on this:',
        'Think about it this way:',
      ];
      if (math.Random().nextDouble() < 0.4) {
        response =
            '${thoughtfulPhrases[math.Random().nextInt(thoughtfulPhrases.length)]} $response';
      }
    }

    return response;
  }

  /// Apply encouraging personality style
  static String _applyEncouragingStyle(
    String response,
    PersonalityTraits traits,
  ) {
    if (traits.enthusiasm > 0.7) {
      final encouragingPhrases = [
        'You\'ve got this!',
        'Great job!',
        'Keep going!',
        'Excellent work!',
      ];
      if (math.Random().nextDouble() < 0.4) {
        response =
            '$response ${encouragingPhrases[math.Random().nextInt(encouragingPhrases.length)]}';
      }
    }

    return response;
  }

  /// Apply patient personality style
  static String _applyPatientStyle(String response, PersonalityTraits traits) {
    if (traits.patience > 0.8) {
      final patientPhrases = [
        'Take your time with this.',
        'No rush.',
        'We\'ll work through this together.',
      ];
      if (math.Random().nextDouble() < 0.3) {
        response =
            '$response ${patientPhrases[math.Random().nextInt(patientPhrases.length)]}';
      }
    }

    return response;
  }

  /// Apply response style preferences
  static String _applyResponseStyle(String response, ResponseStyle style) {
    // Add emojis if enabled
    if (style.useEmojis) {
      response = _addEmojis(response, style.tone);
    }

    // Add examples if enabled and response is explanatory
    if (style.useExamples && _isExplanatory(response)) {
      response = _addExample(response);
    }

    // Add follow-up questions if enabled
    if (style.askFollowUpQuestions && math.Random().nextDouble() < 0.6) {
      response = _addFollowUpQuestion(response);
    }

    // Adjust length based on preference
    response = _adjustResponseLength(
      response,
      style.length,
      style.maxResponseLength,
    );

    return response;
  }

  /// Add appropriate emojis based on tone
  static String _addEmojis(String response, ResponseTone tone) {
    final emojiMap = {
      ResponseTone.enthusiastic: ['🎉', '✨', '🚀', '💫', '🌟'],
      ResponseTone.casual: ['😊', '👍', '💡', '🎯', '✅'],
      ResponseTone.neutral: ['💭', '🤔', '📚', '📝', '🔍'],
      ResponseTone.formal: ['📋', '📊', '🎓', '📖', '✓'],
    };

    final emojis = emojiMap[tone] ?? emojiMap[ResponseTone.neutral]!;
    final emoji = emojis[math.Random().nextInt(emojis.length)];

    if (math.Random().nextDouble() < 0.4) {
      if (response.endsWith('!') || response.endsWith('.')) {
        response =
            '${response.substring(0, response.length - 1)} $emoji${response.substring(response.length - 1)}';
      } else {
        response = '$response $emoji';
      }
    }

    return response;
  }

  /// Check if response is explanatory
  static bool _isExplanatory(String response) {
    return response.contains('explain') ||
        response.contains('understand') ||
        response.contains('step') ||
        response.contains('because') ||
        response.contains('approach');
  }

  /// Add an example to explanatory responses
  static String _addExample(String response) {
    final examples = [
      'For example, think of it like...',
      'Here\'s a simple example:',
      'To illustrate this:',
      'Consider this example:',
    ];

    if (math.Random().nextDouble() < 0.3) {
      final exampleIntro = examples[math.Random().nextInt(examples.length)];
      response = '$response $exampleIntro';
    }

    return response;
  }

  /// Add follow-up questions to engage the user
  static String _addFollowUpQuestion(String response) {
    final questions = [
      'What do you think about that?',
      'Does this make sense to you?',
      'Would you like me to explain anything further?',
      'What part would you like to explore more?',
      'How does this connect to what you already know?',
      'What questions do you have about this?',
    ];

    final question = questions[math.Random().nextInt(questions.length)];
    return '$response $question';
  }

  /// Adjust response length based on preferences
  static String _adjustResponseLength(
    String response,
    ResponseLength length,
    int maxLength,
  ) {
    switch (length) {
      case ResponseLength.short:
        if (response.length > 100) {
          final sentences = response.split('. ');
          response = sentences.first;
          if (!response.endsWith('.') &&
              !response.endsWith('!') &&
              !response.endsWith('?')) {
            response += '.';
          }
        }
        break;
      case ResponseLength.long:
        // For long responses, we might add more detail in a real implementation
        // For now, we'll keep the response as is
        break;
      case ResponseLength.medium:
        // Medium is the default, no adjustment needed
        break;
    }

    // Ensure we don't exceed max length
    if (response.length > maxLength) {
      response = '${response.substring(0, maxLength - 3)}...';
    }

    return response;
  }

  /// Add contextual elements based on conversation history
  static String _addContextualElements(
    String response,
    HelpyPersonality personality,
    List<Message> history,
    String userInput,
  ) {
    // Add user name if this is not the first message
    if (history.length > 2 && math.Random().nextDouble() < 0.2) {
      // We would need to get the user's name from context
      // For now, we'll use a generic approach
    }

    // Reference previous conversation if relevant
    if (history.length > 1 && _shouldReferencePrevious(userInput, history)) {
      final referencePhrase = _getPreviousReference();
      response = '$referencePhrase $response';
    }

    // Add time-based greetings
    if (history.isEmpty) {
      final timeGreeting = _getTimeBasedGreeting();
      if (timeGreeting.isNotEmpty) {
        response = '$timeGreeting $response';
      }
    }

    return response;
  }

  /// Determine if we should reference previous conversation
  static bool _shouldReferencePrevious(
    String userInput,
    List<Message> history,
  ) {
    final recentMessages = history.take(3).toList();
    return recentMessages.any(
      (msg) => userInput.toLowerCase().contains(
        msg.content.toLowerCase().substring(
          0,
          math.min(10, msg.content.length),
        ),
      ),
    );
  }

  /// Get a phrase to reference previous conversation
  static String _getPreviousReference() {
    final references = [
      'Building on what we discussed,',
      'Following up on that,',
      'Continuing from before,',
      'As we were talking about,',
    ];

    return references[math.Random().nextInt(references.length)];
  }

  /// Get time-based greeting
  static String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning!';
    } else if (hour < 17) {
      return 'Good afternoon!';
    } else if (hour < 21) {
      return 'Good evening!';
    } else {
      return 'Hope you\'re having a great night!';
    }
  }
}
