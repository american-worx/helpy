import '../entities/llm_request.dart';
import '../entities/llm_response.dart';

/// Abstract repository interface for LLM providers
/// This interface supports any LLM provider (OpenAI, Anthropic Claude, local models, etc.)
abstract class ILlmRepository {
  /// Generate a response using the configured LLM provider
  Future<LlmResponse> generateResponse(LlmRequest request);

  /// Generate a streaming response for real-time chat experience
  Stream<LlmResponse> generateStreamingResponse(LlmRequest request);

  /// Check if the LLM provider is available and properly configured
  Future<bool> isAvailable();

  /// Get provider information (name, version, capabilities)
  LlmProviderInfo getProviderInfo();

  /// Validate API key or credentials (if required)
  Future<bool> validateCredentials();

  /// Get usage statistics (tokens used, cost, etc.)
  Future<LlmUsageStats> getUsageStats();

  /// Test the connection with a simple request
  Future<bool> testConnection();
}

/// LLM provider information
class LlmProviderInfo {
  final String name;
  final String version;
  final List<String> supportedModels;
  final bool supportsStreaming;
  final bool supportsSystemPrompts;
  final bool supportsTools;
  final int maxTokens;
  final double costPerToken;

  const LlmProviderInfo({
    required this.name,
    required this.version,
    required this.supportedModels,
    required this.supportsStreaming,
    required this.supportsSystemPrompts,
    required this.supportsTools,
    required this.maxTokens,
    required this.costPerToken,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'version': version,
        'supportedModels': supportedModels,
        'supportsStreaming': supportsStreaming,
        'supportsSystemPrompts': supportsSystemPrompts,
        'supportsTools': supportsTools,
        'maxTokens': maxTokens,
        'costPerToken': costPerToken,
      };

  factory LlmProviderInfo.fromJson(Map<String, dynamic> json) => LlmProviderInfo(
        name: json['name'],
        version: json['version'],
        supportedModels: List<String>.from(json['supportedModels']),
        supportsStreaming: json['supportsStreaming'],
        supportsSystemPrompts: json['supportsSystemPrompts'],
        supportsTools: json['supportsTools'],
        maxTokens: json['maxTokens'],
        costPerToken: json['costPerToken'],
      );
}

/// LLM usage statistics
class LlmUsageStats {
  final int totalTokensUsed;
  final int promptTokens;
  final int completionTokens;
  final double totalCost;
  final int requestCount;
  final DateTime lastUsed;

  const LlmUsageStats({
    required this.totalTokensUsed,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalCost,
    required this.requestCount,
    required this.lastUsed,
  });

  Map<String, dynamic> toJson() => {
        'totalTokensUsed': totalTokensUsed,
        'promptTokens': promptTokens,
        'completionTokens': completionTokens,
        'totalCost': totalCost,
        'requestCount': requestCount,
        'lastUsed': lastUsed.toIso8601String(),
      };

  factory LlmUsageStats.fromJson(Map<String, dynamic> json) => LlmUsageStats(
        totalTokensUsed: json['totalTokensUsed'],
        promptTokens: json['promptTokens'],
        completionTokens: json['completionTokens'],
        totalCost: json['totalCost'],
        requestCount: json['requestCount'],
        lastUsed: DateTime.parse(json['lastUsed']),
      );

  LlmUsageStats copyWith({
    int? totalTokensUsed,
    int? promptTokens,
    int? completionTokens,
    double? totalCost,
    int? requestCount,
    DateTime? lastUsed,
  }) {
    return LlmUsageStats(
      totalTokensUsed: totalTokensUsed ?? this.totalTokensUsed,
      promptTokens: promptTokens ?? this.promptTokens,
      completionTokens: completionTokens ?? this.completionTokens,
      totalCost: totalCost ?? this.totalCost,
      requestCount: requestCount ?? this.requestCount,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}