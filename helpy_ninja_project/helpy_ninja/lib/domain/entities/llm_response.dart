/// Generic LLM response that works with any LLM provider
class LlmResponse {
  final String content;
  final LlmResponseMetadata metadata;
  final LlmUsageInfo usage;
  final LlmResponseStatus status;
  final String? errorMessage;
  final bool isStreaming;
  final bool isComplete;

  const LlmResponse({
    required this.content,
    required this.metadata,
    required this.usage,
    required this.status,
    this.errorMessage,
    this.isStreaming = false,
    this.isComplete = true,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'metadata': metadata.toJson(),
        'usage': usage.toJson(),
        'status': status.name,
        'errorMessage': errorMessage,
        'isStreaming': isStreaming,
        'isComplete': isComplete,
      };

  factory LlmResponse.fromJson(Map<String, dynamic> json) => LlmResponse(
        content: json['content'],
        metadata: LlmResponseMetadata.fromJson(json['metadata']),
        usage: LlmUsageInfo.fromJson(json['usage']),
        status: LlmResponseStatus.values.byName(json['status']),
        errorMessage: json['errorMessage'],
        isStreaming: json['isStreaming'] ?? false,
        isComplete: json['isComplete'] ?? true,
      );

  LlmResponse copyWith({
    String? content,
    LlmResponseMetadata? metadata,
    LlmUsageInfo? usage,
    LlmResponseStatus? status,
    String? errorMessage,
    bool? isStreaming,
    bool? isComplete,
  }) {
    return LlmResponse(
      content: content ?? this.content,
      metadata: metadata ?? this.metadata,
      usage: usage ?? this.usage,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isStreaming: isStreaming ?? this.isStreaming,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  /// Create a streaming response chunk
  factory LlmResponse.streamingChunk({
    required String content,
    required String requestId,
    required String model,
    bool isComplete = false,
  }) {
    return LlmResponse(
      content: content,
      metadata: LlmResponseMetadata(
        requestId: requestId,
        model: model,
        provider: 'unknown',
        timestamp: DateTime.now(),
        processingTimeMs: 0,
      ),
      usage: const LlmUsageInfo(
        promptTokens: 0,
        completionTokens: 0,
        totalTokens: 0,
        estimatedCost: 0.0,
      ),
      status: LlmResponseStatus.success,
      isStreaming: true,
      isComplete: isComplete,
    );
  }

  /// Create an error response
  factory LlmResponse.error({
    required String errorMessage,
    required String requestId,
    LlmResponseStatus status = LlmResponseStatus.error,
  }) {
    return LlmResponse(
      content: '',
      metadata: LlmResponseMetadata(
        requestId: requestId,
        model: 'unknown',
        provider: 'unknown',
        timestamp: DateTime.now(),
        processingTimeMs: 0,
      ),
      usage: const LlmUsageInfo(
        promptTokens: 0,
        completionTokens: 0,
        totalTokens: 0,
        estimatedCost: 0.0,
      ),
      status: status,
      errorMessage: errorMessage,
    );
  }
}

/// Response status enum
enum LlmResponseStatus {
  success,
  error,
  timeout,
  rateLimited,
  quotaExceeded,
  invalidRequest,
  unauthorized,
  modelUnavailable,
}

/// Metadata about the LLM response
class LlmResponseMetadata {
  final String requestId;
  final String model;
  final String provider;
  final DateTime timestamp;
  final int processingTimeMs;
  final Map<String, dynamic>? additionalData;

  const LlmResponseMetadata({
    required this.requestId,
    required this.model,
    required this.provider,
    required this.timestamp,
    required this.processingTimeMs,
    this.additionalData,
  });

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'model': model,
        'provider': provider,
        'timestamp': timestamp.toIso8601String(),
        'processingTimeMs': processingTimeMs,
        'additionalData': additionalData,
      };

  factory LlmResponseMetadata.fromJson(Map<String, dynamic> json) => LlmResponseMetadata(
        requestId: json['requestId'],
        model: json['model'],
        provider: json['provider'],
        timestamp: DateTime.parse(json['timestamp']),
        processingTimeMs: json['processingTimeMs'],
        additionalData: json['additionalData'],
      );
}

/// Token usage information
class LlmUsageInfo {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  final double estimatedCost;

  const LlmUsageInfo({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    required this.estimatedCost,
  });

  Map<String, dynamic> toJson() => {
        'promptTokens': promptTokens,
        'completionTokens': completionTokens,
        'totalTokens': totalTokens,
        'estimatedCost': estimatedCost,
      };

  factory LlmUsageInfo.fromJson(Map<String, dynamic> json) => LlmUsageInfo(
        promptTokens: json['promptTokens'] ?? 0,
        completionTokens: json['completionTokens'] ?? 0,
        totalTokens: json['totalTokens'] ?? 0,
        estimatedCost: json['estimatedCost']?.toDouble() ?? 0.0,
      );

  LlmUsageInfo operator +(LlmUsageInfo other) {
    return LlmUsageInfo(
      promptTokens: promptTokens + other.promptTokens,
      completionTokens: completionTokens + other.completionTokens,
      totalTokens: totalTokens + other.totalTokens,
      estimatedCost: estimatedCost + other.estimatedCost,
    );
  }
}

/// Quality metrics for LLM responses
class LlmResponseQuality {
  final double relevanceScore; // 0.0 to 1.0
  final double coherenceScore; // 0.0 to 1.0
  final double educationalValue; // 0.0 to 1.0
  final double personalityAlignment; // 0.0 to 1.0
  final List<String> detectedTopics;
  final List<String> suggestedFollowUps;

  const LlmResponseQuality({
    required this.relevanceScore,
    required this.coherenceScore,
    required this.educationalValue,
    required this.personalityAlignment,
    required this.detectedTopics,
    required this.suggestedFollowUps,
  });

  Map<String, dynamic> toJson() => {
        'relevanceScore': relevanceScore,
        'coherenceScore': coherenceScore,
        'educationalValue': educationalValue,
        'personalityAlignment': personalityAlignment,
        'detectedTopics': detectedTopics,
        'suggestedFollowUps': suggestedFollowUps,
      };

  factory LlmResponseQuality.fromJson(Map<String, dynamic> json) => LlmResponseQuality(
        relevanceScore: json['relevanceScore']?.toDouble() ?? 0.0,
        coherenceScore: json['coherenceScore']?.toDouble() ?? 0.0,
        educationalValue: json['educationalValue']?.toDouble() ?? 0.0,
        personalityAlignment: json['personalityAlignment']?.toDouble() ?? 0.0,
        detectedTopics: json['detectedTopics']?.cast<String>() ?? [],
        suggestedFollowUps: json['suggestedFollowUps']?.cast<String>() ?? [],
      );

  /// Overall quality score (weighted average)
  double get overallScore {
    return (relevanceScore * 0.3 +
            coherenceScore * 0.25 +
            educationalValue * 0.3 +
            personalityAlignment * 0.15);
  }
}