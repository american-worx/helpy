import 'message.dart';
import 'helpy_personality.dart';

/// Generic LLM request that works with any LLM provider
class LlmRequest {
  final String prompt;
  final String? systemPrompt;
  final List<Message> conversationHistory;
  final HelpyPersonality? personality;
  final LlmRequestSettings settings;
  final Map<String, dynamic>? metadata;

  const LlmRequest({
    required this.prompt,
    this.systemPrompt,
    required this.conversationHistory,
    this.personality,
    required this.settings,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
        'systemPrompt': systemPrompt,
        'conversationHistory': conversationHistory.map((m) => m.toJson()).toList(),
        'personality': personality?.toJson(),
        'settings': settings.toJson(),
        'metadata': metadata,
      };

  factory LlmRequest.fromJson(Map<String, dynamic> json) => LlmRequest(
        prompt: json['prompt'],
        systemPrompt: json['systemPrompt'],
        conversationHistory: (json['conversationHistory'] as List)
            .map((m) => Message.fromJson(m))
            .toList(),
        personality: json['personality'] != null
            ? HelpyPersonality.fromJson(json['personality'])
            : null,
        settings: LlmRequestSettings.fromJson(json['settings']),
        metadata: json['metadata'],
      );

  LlmRequest copyWith({
    String? prompt,
    String? systemPrompt,
    List<Message>? conversationHistory,
    HelpyPersonality? personality,
    LlmRequestSettings? settings,
    Map<String, dynamic>? metadata,
  }) {
    return LlmRequest(
      prompt: prompt ?? this.prompt,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      conversationHistory: conversationHistory ?? this.conversationHistory,
      personality: personality ?? this.personality,
      settings: settings ?? this.settings,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Settings for LLM requests
class LlmRequestSettings {
  final double temperature;
  final int maxTokens;
  final double topP;
  final double frequencyPenalty;
  final double presencePenalty;
  final List<String>? stopSequences;
  final bool stream;
  final String? model;
  final int? seed; // For reproducible outputs
  final Map<String, dynamic>? providerSpecificSettings;

  const LlmRequestSettings({
    this.temperature = 0.7,
    this.maxTokens = 1000,
    this.topP = 1.0,
    this.frequencyPenalty = 0.0,
    this.presencePenalty = 0.0,
    this.stopSequences,
    this.stream = false,
    this.model,
    this.seed,
    this.providerSpecificSettings,
  });

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'maxTokens': maxTokens,
        'topP': topP,
        'frequencyPenalty': frequencyPenalty,
        'presencePenalty': presencePenalty,
        'stopSequences': stopSequences,
        'stream': stream,
        'model': model,
        'seed': seed,
        'providerSpecificSettings': providerSpecificSettings,
      };

  factory LlmRequestSettings.fromJson(Map<String, dynamic> json) => LlmRequestSettings(
        temperature: json['temperature']?.toDouble() ?? 0.7,
        maxTokens: json['maxTokens'] ?? 1000,
        topP: json['topP']?.toDouble() ?? 1.0,
        frequencyPenalty: json['frequencyPenalty']?.toDouble() ?? 0.0,
        presencePenalty: json['presencePenalty']?.toDouble() ?? 0.0,
        stopSequences: json['stopSequences']?.cast<String>(),
        stream: json['stream'] ?? false,
        model: json['model'],
        seed: json['seed'],
        providerSpecificSettings: json['providerSpecificSettings'],
      );

  LlmRequestSettings copyWith({
    double? temperature,
    int? maxTokens,
    double? topP,
    double? frequencyPenalty,
    double? presencePenalty,
    List<String>? stopSequences,
    bool? stream,
    String? model,
    int? seed,
    Map<String, dynamic>? providerSpecificSettings,
  }) {
    return LlmRequestSettings(
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      topP: topP ?? this.topP,
      frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
      presencePenalty: presencePenalty ?? this.presencePenalty,
      stopSequences: stopSequences ?? this.stopSequences,
      stream: stream ?? this.stream,
      model: model ?? this.model,
      seed: seed ?? this.seed,
      providerSpecificSettings: providerSpecificSettings ?? this.providerSpecificSettings,
    );
  }

  /// Default settings for educational chat
  static const LlmRequestSettings educational = LlmRequestSettings(
    temperature: 0.7,
    maxTokens: 800,
    topP: 0.9,
    frequencyPenalty: 0.1,
    presencePenalty: 0.1,
  );

  /// Settings for creative responses
  static const LlmRequestSettings creative = LlmRequestSettings(
    temperature: 0.9,
    maxTokens: 1200,
    topP: 0.95,
    frequencyPenalty: 0.0,
    presencePenalty: 0.0,
  );

  /// Settings for factual/precise responses
  static const LlmRequestSettings factual = LlmRequestSettings(
    temperature: 0.3,
    maxTokens: 600,
    topP: 0.8,
    frequencyPenalty: 0.2,
    presencePenalty: 0.1,
  );

  /// Settings for short/concise responses
  static const LlmRequestSettings concise = LlmRequestSettings(
    temperature: 0.5,
    maxTokens: 300,
    topP: 0.85,
    frequencyPenalty: 0.3,
    presencePenalty: 0.2,
  );
}

/// Context for educational conversations
class EducationalContext {
  final String? subject;
  final String? topic;
  final String? difficultyLevel;
  final List<String>? learningObjectives;
  final String? studentAge;
  final List<String>? previousTopics;

  const EducationalContext({
    this.subject,
    this.topic,
    this.difficultyLevel,
    this.learningObjectives,
    this.studentAge,
    this.previousTopics,
  });

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'topic': topic,
        'difficultyLevel': difficultyLevel,
        'learningObjectives': learningObjectives,
        'studentAge': studentAge,
        'previousTopics': previousTopics,
      };

  factory EducationalContext.fromJson(Map<String, dynamic> json) => EducationalContext(
        subject: json['subject'],
        topic: json['topic'],
        difficultyLevel: json['difficultyLevel'],
        learningObjectives: json['learningObjectives']?.cast<String>(),
        studentAge: json['studentAge'],
        previousTopics: json['previousTopics']?.cast<String>(),
      );
}