import 'shared_enums.dart';

/// Chat settings entity for AI model parameters and user preferences
class ChatSettings {
  final String id;
  final String userId;
  final String? conversationId; // null means global settings
  final AIModelSettings modelSettings;
  final ChatPreferences preferences;
  final SecuritySettings security;
  final Map<String, dynamic>? customSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatSettings({
    required this.id,
    required this.userId,
    this.conversationId,
    required this.modelSettings,
    required this.preferences,
    required this.security,
    this.customSettings,
    required this.createdAt,
    required this.updatedAt,
  });

  ChatSettings copyWith({
    String? id,
    String? userId,
    String? conversationId,
    AIModelSettings? modelSettings,
    ChatPreferences? preferences,
    SecuritySettings? security,
    Map<String, dynamic>? customSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      conversationId: conversationId ?? this.conversationId,
      modelSettings: modelSettings ?? this.modelSettings,
      preferences: preferences ?? this.preferences,
      security: security ?? this.security,
      customSettings: customSettings ?? this.customSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if these are global settings
  bool get isGlobal => conversationId == null;

  /// Check if these are conversation-specific settings
  bool get isConversationSpecific => conversationId != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'conversationId': conversationId,
      'modelSettings': modelSettings.toJson(),
      'preferences': preferences.toJson(),
      'security': security.toJson(),
      'customSettings': customSettings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChatSettings.fromJson(Map<String, dynamic> json) {
    return ChatSettings(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      conversationId: json['conversationId'],
      modelSettings: AIModelSettings.fromJson(json['modelSettings'] ?? {}),
      preferences: ChatPreferences.fromJson(json['preferences'] ?? {}),
      security: SecuritySettings.fromJson(json['security'] ?? {}),
      customSettings: json['customSettings'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatSettings && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatSettings(id: $id, userId: $userId, isGlobal: $isGlobal)';
  }
}

/// AI model parameters and settings
class AIModelSettings {
  final String modelId;
  final double temperature; // 0.0 to 2.0, controls randomness
  final double topP; // 0.0 to 1.0, nucleus sampling
  final int topK; // top-k sampling
  final int maxTokens; // maximum response length
  final double presencePenalty; // -2.0 to 2.0, penalty for new topics
  final double frequencyPenalty; // -2.0 to 2.0, penalty for repetition
  final List<String> stopSequences; // sequences that stop generation
  final String systemPrompt; // system/instruction prompt
  final bool useMemory; // whether to use conversation memory
  final int memoryWindowSize; // number of messages to remember
  final ResponseFormat responseFormat;
  final Map<String, dynamic>? advancedParams;

  const AIModelSettings({
    this.modelId = 'default',
    this.temperature = 0.7,
    this.topP = 0.9,
    this.topK = 50,
    this.maxTokens = 2048,
    this.presencePenalty = 0.0,
    this.frequencyPenalty = 0.0,
    this.stopSequences = const [],
    this.systemPrompt = '',
    this.useMemory = true,
    this.memoryWindowSize = 20,
    this.responseFormat = ResponseFormat.text,
    this.advancedParams,
  });

  AIModelSettings copyWith({
    String? modelId,
    double? temperature,
    double? topP,
    int? topK,
    int? maxTokens,
    double? presencePenalty,
    double? frequencyPenalty,
    List<String>? stopSequences,
    String? systemPrompt,
    bool? useMemory,
    int? memoryWindowSize,
    ResponseFormat? responseFormat,
    Map<String, dynamic>? advancedParams,
  }) {
    return AIModelSettings(
      modelId: modelId ?? this.modelId,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      topK: topK ?? this.topK,
      maxTokens: maxTokens ?? this.maxTokens,
      presencePenalty: presencePenalty ?? this.presencePenalty,
      frequencyPenalty: frequencyPenalty ?? this.frequencyPenalty,
      stopSequences: stopSequences ?? this.stopSequences,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      useMemory: useMemory ?? this.useMemory,
      memoryWindowSize: memoryWindowSize ?? this.memoryWindowSize,
      responseFormat: responseFormat ?? this.responseFormat,
      advancedParams: advancedParams ?? this.advancedParams,
    );
  }

  /// Get creativity level based on temperature
  CreativityLevel get creativityLevel {
    if (temperature <= 0.3) return CreativityLevel.conservative;
    if (temperature <= 0.7) return CreativityLevel.balanced;
    if (temperature <= 1.2) return CreativityLevel.creative;
    return CreativityLevel.experimental;
  }

  /// Get focus level based on topP
  FocusLevel get focusLevel {
    if (topP <= 0.5) return FocusLevel.focused;
    if (topP <= 0.8) return FocusLevel.balanced;
    return FocusLevel.diverse;
  }

  /// Validate model parameters
  bool get isValid {
    return temperature >= 0.0 &&
        temperature <= 2.0 &&
        topP >= 0.0 &&
        topP <= 1.0 &&
        topK > 0 &&
        maxTokens > 0 &&
        presencePenalty >= -2.0 &&
        presencePenalty <= 2.0 &&
        frequencyPenalty >= -2.0 &&
        frequencyPenalty <= 2.0 &&
        memoryWindowSize > 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'modelId': modelId,
      'temperature': temperature,
      'topP': topP,
      'topK': topK,
      'maxTokens': maxTokens,
      'presencePenalty': presencePenalty,
      'frequencyPenalty': frequencyPenalty,
      'stopSequences': stopSequences,
      'systemPrompt': systemPrompt,
      'useMemory': useMemory,
      'memoryWindowSize': memoryWindowSize,
      'responseFormat': responseFormat.name,
      'advancedParams': advancedParams,
    };
  }

  factory AIModelSettings.fromJson(Map<String, dynamic> json) {
    return AIModelSettings(
      modelId: json['modelId'] ?? 'default',
      temperature: (json['temperature'] ?? 0.7).toDouble(),
      topP: (json['topP'] ?? 0.9).toDouble(),
      topK: json['topK'] ?? 50,
      maxTokens: json['maxTokens'] ?? 2048,
      presencePenalty: (json['presencePenalty'] ?? 0.0).toDouble(),
      frequencyPenalty: (json['frequencyPenalty'] ?? 0.0).toDouble(),
      stopSequences: List<String>.from(json['stopSequences'] ?? []),
      systemPrompt: json['systemPrompt'] ?? '',
      useMemory: json['useMemory'] ?? true,
      memoryWindowSize: json['memoryWindowSize'] ?? 20,
      responseFormat: ResponseFormat.values.firstWhere(
        (format) => format.name == json['responseFormat'],
        orElse: () => ResponseFormat.text,
      ),
      advancedParams: json['advancedParams'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIModelSettings &&
        other.modelId == modelId &&
        other.temperature == temperature &&
        other.topP == topP &&
        other.topK == topK;
  }

  @override
  int get hashCode => Object.hash(modelId, temperature, topP, topK);
}

/// Chat preferences and UI settings
class ChatPreferences {
  final ThemeMode themeMode;
  final String language;
  final bool enableNotifications;
  final bool enableSounds;
  final bool enableTypingIndicator;
  final bool enableReadReceipts;
  final bool enableEmojis;
  final bool enableStickers;
  final bool autoSaveAttachments;
  final bool compressImages;
  final bool compressVideos;
  final MessageDisplayStyle messageDisplayStyle;
  final int messagesPerPage;
  final bool enableOfflineMode;
  final Map<String, bool> featureFlags;

  const ChatPreferences({
    this.themeMode = ThemeMode.system,
    this.language = 'en',
    this.enableNotifications = true,
    this.enableSounds = true,
    this.enableTypingIndicator = true,
    this.enableReadReceipts = true,
    this.enableEmojis = true,
    this.enableStickers = true,
    this.autoSaveAttachments = false,
    this.compressImages = true,
    this.compressVideos = true,
    this.messageDisplayStyle = MessageDisplayStyle.bubbles,
    this.messagesPerPage = 50,
    this.enableOfflineMode = true,
    this.featureFlags = const {},
  });

  ChatPreferences copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? enableNotifications,
    bool? enableSounds,
    bool? enableTypingIndicator,
    bool? enableReadReceipts,
    bool? enableEmojis,
    bool? enableStickers,
    bool? autoSaveAttachments,
    bool? compressImages,
    bool? compressVideos,
    MessageDisplayStyle? messageDisplayStyle,
    int? messagesPerPage,
    bool? enableOfflineMode,
    Map<String, bool>? featureFlags,
  }) {
    return ChatPreferences(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSounds: enableSounds ?? this.enableSounds,
      enableTypingIndicator:
          enableTypingIndicator ?? this.enableTypingIndicator,
      enableReadReceipts: enableReadReceipts ?? this.enableReadReceipts,
      enableEmojis: enableEmojis ?? this.enableEmojis,
      enableStickers: enableStickers ?? this.enableStickers,
      autoSaveAttachments: autoSaveAttachments ?? this.autoSaveAttachments,
      compressImages: compressImages ?? this.compressImages,
      compressVideos: compressVideos ?? this.compressVideos,
      messageDisplayStyle: messageDisplayStyle ?? this.messageDisplayStyle,
      messagesPerPage: messagesPerPage ?? this.messagesPerPage,
      enableOfflineMode: enableOfflineMode ?? this.enableOfflineMode,
      featureFlags: featureFlags ?? this.featureFlags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'language': language,
      'enableNotifications': enableNotifications,
      'enableSounds': enableSounds,
      'enableTypingIndicator': enableTypingIndicator,
      'enableReadReceipts': enableReadReceipts,
      'enableEmojis': enableEmojis,
      'enableStickers': enableStickers,
      'autoSaveAttachments': autoSaveAttachments,
      'compressImages': compressImages,
      'compressVideos': compressVideos,
      'messageDisplayStyle': messageDisplayStyle.name,
      'messagesPerPage': messagesPerPage,
      'enableOfflineMode': enableOfflineMode,
      'featureFlags': featureFlags,
    };
  }

  factory ChatPreferences.fromJson(Map<String, dynamic> json) {
    return ChatPreferences(
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      language: json['language'] ?? 'en',
      enableNotifications: json['enableNotifications'] ?? true,
      enableSounds: json['enableSounds'] ?? true,
      enableTypingIndicator: json['enableTypingIndicator'] ?? true,
      enableReadReceipts: json['enableReadReceipts'] ?? true,
      enableEmojis: json['enableEmojis'] ?? true,
      enableStickers: json['enableStickers'] ?? true,
      autoSaveAttachments: json['autoSaveAttachments'] ?? false,
      compressImages: json['compressImages'] ?? true,
      compressVideos: json['compressVideos'] ?? true,
      messageDisplayStyle: MessageDisplayStyle.values.firstWhere(
        (style) => style.name == json['messageDisplayStyle'],
        orElse: () => MessageDisplayStyle.bubbles,
      ),
      messagesPerPage: json['messagesPerPage'] ?? 50,
      enableOfflineMode: json['enableOfflineMode'] ?? true,
      featureFlags: Map<String, bool>.from(json['featureFlags'] ?? {}),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatPreferences &&
        other.themeMode == themeMode &&
        other.language == language;
  }

  @override
  int get hashCode => Object.hash(themeMode, language);
}

/// Security settings for chat
class SecuritySettings {
  final bool enableEncryption;
  final bool enableAutoDelete;
  final Duration autoDeleteDuration;
  final bool enableScreenshotProtection;
  final bool enableBiometricLock;
  final bool enableIncognitoMode;
  final List<String> blockedUsers;
  final Map<String, dynamic>? encryptionSettings;

  const SecuritySettings({
    this.enableEncryption = false,
    this.enableAutoDelete = false,
    this.autoDeleteDuration = const Duration(days: 30),
    this.enableScreenshotProtection = false,
    this.enableBiometricLock = false,
    this.enableIncognitoMode = false,
    this.blockedUsers = const [],
    this.encryptionSettings,
  });

  SecuritySettings copyWith({
    bool? enableEncryption,
    bool? enableAutoDelete,
    Duration? autoDeleteDuration,
    bool? enableScreenshotProtection,
    bool? enableBiometricLock,
    bool? enableIncognitoMode,
    List<String>? blockedUsers,
    Map<String, dynamic>? encryptionSettings,
  }) {
    return SecuritySettings(
      enableEncryption: enableEncryption ?? this.enableEncryption,
      enableAutoDelete: enableAutoDelete ?? this.enableAutoDelete,
      autoDeleteDuration: autoDeleteDuration ?? this.autoDeleteDuration,
      enableScreenshotProtection:
          enableScreenshotProtection ?? this.enableScreenshotProtection,
      enableBiometricLock: enableBiometricLock ?? this.enableBiometricLock,
      enableIncognitoMode: enableIncognitoMode ?? this.enableIncognitoMode,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      encryptionSettings: encryptionSettings ?? this.encryptionSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableEncryption': enableEncryption,
      'enableAutoDelete': enableAutoDelete,
      'autoDeleteDuration': autoDeleteDuration.inDays,
      'enableScreenshotProtection': enableScreenshotProtection,
      'enableBiometricLock': enableBiometricLock,
      'enableIncognitoMode': enableIncognitoMode,
      'blockedUsers': blockedUsers,
      'encryptionSettings': encryptionSettings,
    };
  }

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      enableEncryption: json['enableEncryption'] ?? false,
      enableAutoDelete: json['enableAutoDelete'] ?? false,
      autoDeleteDuration: Duration(days: json['autoDeleteDuration'] ?? 30),
      enableScreenshotProtection: json['enableScreenshotProtection'] ?? false,
      enableBiometricLock: json['enableBiometricLock'] ?? false,
      enableIncognitoMode: json['enableIncognitoMode'] ?? false,
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
      encryptionSettings: json['encryptionSettings'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecuritySettings &&
        other.enableEncryption == enableEncryption &&
        other.enableAutoDelete == enableAutoDelete;
  }

  @override
  int get hashCode => Object.hash(enableEncryption, enableAutoDelete);
}
