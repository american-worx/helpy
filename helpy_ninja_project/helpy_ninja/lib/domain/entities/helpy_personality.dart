/// Helpy personality entity representing different AI tutor personalities
class HelpyPersonality {
  final String id;
  final String name;
  final String description;
  final String avatar;
  final PersonalityType type;
  final PersonalityTraits traits;
  final ResponseStyle responseStyle;
  final List<String> specializations;
  final Map<String, String> greetingMessages;
  final Map<String, String> responseTemplates;
  final PersonalitySettings settings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const HelpyPersonality({
    required this.id,
    required this.name,
    required this.description,
    required this.avatar,
    required this.type,
    required this.traits,
    required this.responseStyle,
    this.specializations = const [],
    this.greetingMessages = const {},
    this.responseTemplates = const {},
    this.settings = const PersonalitySettings(),
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  HelpyPersonality copyWith({
    String? id,
    String? name,
    String? description,
    String? avatar,
    PersonalityType? type,
    PersonalityTraits? traits,
    ResponseStyle? responseStyle,
    List<String>? specializations,
    Map<String, String>? greetingMessages,
    Map<String, String>? responseTemplates,
    PersonalitySettings? settings,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HelpyPersonality(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      type: type ?? this.type,
      traits: traits ?? this.traits,
      responseStyle: responseStyle ?? this.responseStyle,
      specializations: specializations ?? this.specializations,
      greetingMessages: greetingMessages ?? this.greetingMessages,
      responseTemplates: responseTemplates ?? this.responseTemplates,
      settings: settings ?? this.settings,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get greeting message for specific context
  String getGreeting(String context) {
    return greetingMessages[context] ??
        greetingMessages['default'] ??
        'Hi! I\'m $name, ready to help you learn!';
  }

  /// Get response template for specific type
  String? getResponseTemplate(String templateType) {
    return responseTemplates[templateType];
  }

  /// Check if personality specializes in a subject
  bool specializesIn(String subject) {
    return specializations.contains(subject.toLowerCase());
  }

  /// Get personality color theme
  String get colorTheme {
    switch (type) {
      case PersonalityType.friendly:
        return '#4CAF50'; // Green
      case PersonalityType.professional:
        return '#2196F3'; // Blue
      case PersonalityType.playful:
        return '#FF9800'; // Orange
      case PersonalityType.wise:
        return '#9C27B0'; // Purple
      case PersonalityType.encouraging:
        return '#F44336'; // Red
      case PersonalityType.patient:
        return '#607D8B'; // Blue Grey
    }
  }

  /// Get personality icon
  String get icon {
    switch (type) {
      case PersonalityType.friendly:
        return '😊';
      case PersonalityType.professional:
        return '🎓';
      case PersonalityType.playful:
        return '🎮';
      case PersonalityType.wise:
        return '🦉';
      case PersonalityType.encouraging:
        return '💪';
      case PersonalityType.patient:
        return '🧘';
    }
  }

  /// Convert to JSON for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatar': avatar,
      'type': type.name,
      'traits': traits.toJson(),
      'responseStyle': responseStyle.toJson(),
      'specializations': specializations,
      'greetingMessages': greetingMessages,
      'responseTemplates': responseTemplates,
      'settings': settings.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory HelpyPersonality.fromJson(Map<String, dynamic> json) {
    return HelpyPersonality(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      avatar: json['avatar'] ?? '',
      type: PersonalityType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => PersonalityType.friendly,
      ),
      traits: PersonalityTraits.fromJson(json['traits'] ?? {}),
      responseStyle: ResponseStyle.fromJson(json['responseStyle'] ?? {}),
      specializations: List<String>.from(json['specializations'] ?? []),
      greetingMessages: Map<String, String>.from(
        json['greetingMessages'] ?? {},
      ),
      responseTemplates: Map<String, String>.from(
        json['responseTemplates'] ?? {},
      ),
      settings: PersonalitySettings.fromJson(json['settings'] ?? {}),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HelpyPersonality && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'HelpyPersonality(id: $id, name: $name, type: $type)';
  }
}

/// Types of Helpy personalities
enum PersonalityType {
  friendly, // Warm and approachable
  professional, // Formal and structured
  playful, // Fun and energetic
  wise, // Knowledgeable and thoughtful
  encouraging, // Motivational and supportive
  patient, // Calm and understanding
}

/// Personality traits that influence behavior
class PersonalityTraits {
  final double enthusiasm; // 0.0 to 1.0
  final double formality; // 0.0 to 1.0
  final double patience; // 0.0 to 1.0
  final double humor; // 0.0 to 1.0
  final double empathy; // 0.0 to 1.0
  final double directness; // 0.0 to 1.0

  const PersonalityTraits({
    this.enthusiasm = 0.5,
    this.formality = 0.5,
    this.patience = 0.5,
    this.humor = 0.5,
    this.empathy = 0.5,
    this.directness = 0.5,
  });

  PersonalityTraits copyWith({
    double? enthusiasm,
    double? formality,
    double? patience,
    double? humor,
    double? empathy,
    double? directness,
  }) {
    return PersonalityTraits(
      enthusiasm: enthusiasm ?? this.enthusiasm,
      formality: formality ?? this.formality,
      patience: patience ?? this.patience,
      humor: humor ?? this.humor,
      empathy: empathy ?? this.empathy,
      directness: directness ?? this.directness,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enthusiasm': enthusiasm,
      'formality': formality,
      'patience': patience,
      'humor': humor,
      'empathy': empathy,
      'directness': directness,
    };
  }

  factory PersonalityTraits.fromJson(Map<String, dynamic> json) {
    return PersonalityTraits(
      enthusiasm: (json['enthusiasm'] ?? 0.5).toDouble(),
      formality: (json['formality'] ?? 0.5).toDouble(),
      patience: (json['patience'] ?? 0.5).toDouble(),
      humor: (json['humor'] ?? 0.5).toDouble(),
      empathy: (json['empathy'] ?? 0.5).toDouble(),
      directness: (json['directness'] ?? 0.5).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PersonalityTraits &&
        other.enthusiasm == enthusiasm &&
        other.formality == formality &&
        other.patience == patience &&
        other.humor == humor &&
        other.empathy == empathy &&
        other.directness == directness;
  }

  @override
  int get hashCode {
    return Object.hash(
      enthusiasm,
      formality,
      patience,
      humor,
      empathy,
      directness,
    );
  }
}

/// Response style configuration
class ResponseStyle {
  final ResponseLength length;
  final ResponseTone tone;
  final bool useEmojis;
  final bool useExamples;
  final bool askFollowUpQuestions;
  final int maxResponseLength;

  const ResponseStyle({
    this.length = ResponseLength.medium,
    this.tone = ResponseTone.neutral,
    this.useEmojis = true,
    this.useExamples = true,
    this.askFollowUpQuestions = true,
    this.maxResponseLength = 500,
  });

  ResponseStyle copyWith({
    ResponseLength? length,
    ResponseTone? tone,
    bool? useEmojis,
    bool? useExamples,
    bool? askFollowUpQuestions,
    int? maxResponseLength,
  }) {
    return ResponseStyle(
      length: length ?? this.length,
      tone: tone ?? this.tone,
      useEmojis: useEmojis ?? this.useEmojis,
      useExamples: useExamples ?? this.useExamples,
      askFollowUpQuestions: askFollowUpQuestions ?? this.askFollowUpQuestions,
      maxResponseLength: maxResponseLength ?? this.maxResponseLength,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'length': length.name,
      'tone': tone.name,
      'useEmojis': useEmojis,
      'useExamples': useExamples,
      'askFollowUpQuestions': askFollowUpQuestions,
      'maxResponseLength': maxResponseLength,
    };
  }

  factory ResponseStyle.fromJson(Map<String, dynamic> json) {
    return ResponseStyle(
      length: ResponseLength.values.firstWhere(
        (length) => length.name == json['length'],
        orElse: () => ResponseLength.medium,
      ),
      tone: ResponseTone.values.firstWhere(
        (tone) => tone.name == json['tone'],
        orElse: () => ResponseTone.neutral,
      ),
      useEmojis: json['useEmojis'] ?? true,
      useExamples: json['useExamples'] ?? true,
      askFollowUpQuestions: json['askFollowUpQuestions'] ?? true,
      maxResponseLength: json['maxResponseLength'] ?? 500,
    );
  }
}

/// Response length preferences
enum ResponseLength {
  short, // Brief, concise responses
  medium, // Balanced length
  long, // Detailed explanations
}

/// Response tone
enum ResponseTone {
  casual, // Informal and relaxed
  neutral, // Balanced tone
  formal, // Professional and structured
  enthusiastic, // Energetic and excited
}

/// Personality-specific settings
class PersonalitySettings {
  final double responseDelay; // Simulated thinking time in seconds
  final bool showTypingIndicator;
  final int maxContextMessages; // How many previous messages to consider
  final bool personalizeResponses;
  final Map<String, dynamic>? customSettings;

  const PersonalitySettings({
    this.responseDelay = 1.0,
    this.showTypingIndicator = true,
    this.maxContextMessages = 10,
    this.personalizeResponses = true,
    this.customSettings,
  });

  PersonalitySettings copyWith({
    double? responseDelay,
    bool? showTypingIndicator,
    int? maxContextMessages,
    bool? personalizeResponses,
    Map<String, dynamic>? customSettings,
  }) {
    return PersonalitySettings(
      responseDelay: responseDelay ?? this.responseDelay,
      showTypingIndicator: showTypingIndicator ?? this.showTypingIndicator,
      maxContextMessages: maxContextMessages ?? this.maxContextMessages,
      personalizeResponses: personalizeResponses ?? this.personalizeResponses,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'responseDelay': responseDelay,
      'showTypingIndicator': showTypingIndicator,
      'maxContextMessages': maxContextMessages,
      'personalizeResponses': personalizeResponses,
      'customSettings': customSettings,
    };
  }

  factory PersonalitySettings.fromJson(Map<String, dynamic> json) {
    return PersonalitySettings(
      responseDelay: (json['responseDelay'] ?? 1.0).toDouble(),
      showTypingIndicator: json['showTypingIndicator'] ?? true,
      maxContextMessages: json['maxContextMessages'] ?? 10,
      personalizeResponses: json['personalizeResponses'] ?? true,
      customSettings: json['customSettings'],
    );
  }
}
