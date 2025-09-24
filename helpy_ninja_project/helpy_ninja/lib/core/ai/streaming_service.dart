import 'dart:async';

import '../../domain/repositories/i_llm_repository.dart';
import '../../domain/entities/llm_request.dart';
import '../../domain/entities/llm_response.dart';
import '../../domain/entities/helpy_personality.dart';
import 'personality_system.dart';

/// Service for managing LLM response streaming with personality integration
class StreamingService {
  final ILlmRepository _llmRepository;

  StreamingService(this._llmRepository);

  /// Generate a streaming response with personality integration
  Stream<StreamingResponseChunk> generateStreamingResponse(
    LlmRequest request,
    HelpyPersonality? personality,
  ) async* {
    try {
      // Enhance request with personality if provided
      final enhancedRequest = personality != null
          ? PersonalitySystem.enhanceRequestWithPersonality(request, personality)
          : request;

      // Start streaming from LLM repository
      await for (final response in _llmRepository.generateStreamingResponse(enhancedRequest)) {
        // Create streaming chunk
        final chunk = StreamingResponseChunk(
          content: response.content,
          isComplete: response.isComplete,
          metadata: StreamingMetadata(
            requestId: response.metadata.requestId,
            chunkIndex: _getChunkIndex(response.content),
            timestamp: DateTime.now(),
            personalityApplied: personality != null,
            processingTimeMs: response.metadata.processingTimeMs,
          ),
          usage: response.usage,
          status: response.status,
          errorMessage: response.errorMessage,
        );

        yield chunk;

        // If complete, apply final personality processing
        if (response.isComplete && personality != null) {
          final finalResponse = PersonalitySystem.enhanceResponseWithPersonality(
            response,
            personality,
          );

          yield StreamingResponseChunk(
            content: finalResponse.content,
            isComplete: true,
            metadata: StreamingMetadata(
              requestId: response.metadata.requestId,
              chunkIndex: _getChunkIndex(finalResponse.content),
              timestamp: DateTime.now(),
              personalityApplied: true,
              processingTimeMs: response.metadata.processingTimeMs,
              finalProcessingApplied: true,
            ),
            usage: finalResponse.usage,
            status: finalResponse.status,
          );
        }
      }
    } catch (e, stackTrace) {
      yield StreamingResponseChunk.error(
        errorMessage: 'Streaming failed: $e',
        requestId: request.metadata?['requestId'] ?? 'unknown',
        stackTrace: stackTrace.toString(),
      );
    }
  }

  /// Generate streaming response with typing indicator simulation
  Stream<StreamingResponseChunk> generateTypingResponse(
    LlmRequest request,
    HelpyPersonality? personality, {
    Duration typingDelay = const Duration(milliseconds: 50),
  }) async* {
    // First emit typing indicator
    yield StreamingResponseChunk.typing(
      requestId: request.metadata?['requestId'] ?? 'unknown',
    );

    await for (final chunk in generateStreamingResponse(request, personality)) {
      // Add typing delay between chunks for more natural feel
      if (!chunk.isComplete) {
        await Future.delayed(typingDelay);
      }
      
      yield chunk;
    }
  }

  /// Create a buffered stream that accumulates content
  Stream<StreamingResponseBuffer> generateBufferedStream(
    LlmRequest request,
    HelpyPersonality? personality,
  ) async* {
    String accumulatedContent = '';
    final chunks = <StreamingResponseChunk>[];
    
    await for (final chunk in generateStreamingResponse(request, personality)) {
      accumulatedContent += chunk.content;
      chunks.add(chunk);

      yield StreamingResponseBuffer(
        accumulatedContent: accumulatedContent,
        currentChunk: chunk,
        allChunks: List.from(chunks),
        isComplete: chunk.isComplete,
        wordCount: accumulatedContent.split(' ').length,
        characterCount: accumulatedContent.length,
      );
    }
  }

  /// Get chunk index from content (simple word count)
  int _getChunkIndex(String content) {
    return content.split(' ').length;
  }
}

/// Represents a chunk of streaming response
class StreamingResponseChunk {
  final String content;
  final bool isComplete;
  final StreamingMetadata metadata;
  final LlmUsageInfo usage;
  final LlmResponseStatus status;
  final String? errorMessage;
  final bool isTyping;

  const StreamingResponseChunk({
    required this.content,
    required this.isComplete,
    required this.metadata,
    required this.usage,
    required this.status,
    this.errorMessage,
    this.isTyping = false,
  });

  /// Create a typing indicator chunk
  factory StreamingResponseChunk.typing({
    required String requestId,
  }) {
    return StreamingResponseChunk(
      content: '',
      isComplete: false,
      metadata: StreamingMetadata(
        requestId: requestId,
        chunkIndex: 0,
        timestamp: DateTime.now(),
        personalityApplied: false,
        processingTimeMs: 0,
      ),
      usage: const LlmUsageInfo(
        promptTokens: 0,
        completionTokens: 0,
        totalTokens: 0,
        estimatedCost: 0.0,
      ),
      status: LlmResponseStatus.success,
      isTyping: true,
    );
  }

  /// Create an error chunk
  factory StreamingResponseChunk.error({
    required String errorMessage,
    required String requestId,
    String? stackTrace,
  }) {
    return StreamingResponseChunk(
      content: '',
      isComplete: true,
      metadata: StreamingMetadata(
        requestId: requestId,
        chunkIndex: 0,
        timestamp: DateTime.now(),
        personalityApplied: false,
        processingTimeMs: 0,
        errorDetails: stackTrace,
      ),
      usage: const LlmUsageInfo(
        promptTokens: 0,
        completionTokens: 0,
        totalTokens: 0,
        estimatedCost: 0.0,
      ),
      status: LlmResponseStatus.error,
      errorMessage: errorMessage,
    );
  }

  Map<String, dynamic> toJson() => {
        'content': content,
        'isComplete': isComplete,
        'metadata': metadata.toJson(),
        'usage': usage.toJson(),
        'status': status.name,
        'errorMessage': errorMessage,
        'isTyping': isTyping,
      };

  factory StreamingResponseChunk.fromJson(Map<String, dynamic> json) => StreamingResponseChunk(
        content: json['content'] ?? '',
        isComplete: json['isComplete'] ?? false,
        metadata: StreamingMetadata.fromJson(json['metadata']),
        usage: LlmUsageInfo.fromJson(json['usage']),
        status: LlmResponseStatus.values.byName(json['status']),
        errorMessage: json['errorMessage'],
        isTyping: json['isTyping'] ?? false,
      );
}

/// Metadata specific to streaming responses
class StreamingMetadata {
  final String requestId;
  final int chunkIndex;
  final DateTime timestamp;
  final bool personalityApplied;
  final int processingTimeMs;
  final bool finalProcessingApplied;
  final String? errorDetails;

  const StreamingMetadata({
    required this.requestId,
    required this.chunkIndex,
    required this.timestamp,
    required this.personalityApplied,
    required this.processingTimeMs,
    this.finalProcessingApplied = false,
    this.errorDetails,
  });

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'chunkIndex': chunkIndex,
        'timestamp': timestamp.toIso8601String(),
        'personalityApplied': personalityApplied,
        'processingTimeMs': processingTimeMs,
        'finalProcessingApplied': finalProcessingApplied,
        'errorDetails': errorDetails,
      };

  factory StreamingMetadata.fromJson(Map<String, dynamic> json) => StreamingMetadata(
        requestId: json['requestId'],
        chunkIndex: json['chunkIndex'] ?? 0,
        timestamp: DateTime.parse(json['timestamp']),
        personalityApplied: json['personalityApplied'] ?? false,
        processingTimeMs: json['processingTimeMs'] ?? 0,
        finalProcessingApplied: json['finalProcessingApplied'] ?? false,
        errorDetails: json['errorDetails'],
      );
}

/// Buffer for accumulated streaming content
class StreamingResponseBuffer {
  final String accumulatedContent;
  final StreamingResponseChunk currentChunk;
  final List<StreamingResponseChunk> allChunks;
  final bool isComplete;
  final int wordCount;
  final int characterCount;

  const StreamingResponseBuffer({
    required this.accumulatedContent,
    required this.currentChunk,
    required this.allChunks,
    required this.isComplete,
    required this.wordCount,
    required this.characterCount,
  });

  /// Get streaming statistics
  StreamingStats get stats => StreamingStats(
        totalChunks: allChunks.length,
        averageChunkSize: allChunks.isEmpty ? 0 : characterCount / allChunks.length,
        streamingDuration: _calculateDuration(),
        tokensPerSecond: _calculateTokensPerSecond(),
      );

  Duration _calculateDuration() {
    if (allChunks.isEmpty) return Duration.zero;
    
    final first = allChunks.first.metadata.timestamp;
    final last = allChunks.last.metadata.timestamp;
    return last.difference(first);
  }

  double _calculateTokensPerSecond() {
    final duration = _calculateDuration();
    if (duration.inMilliseconds == 0) return 0.0;
    
    final totalTokens = allChunks.fold<int>(
      0,
      (sum, chunk) => sum + chunk.usage.totalTokens,
    );
    
    return totalTokens / (duration.inMilliseconds / 1000.0);
  }
}

/// Statistics about streaming performance
class StreamingStats {
  final int totalChunks;
  final double averageChunkSize;
  final Duration streamingDuration;
  final double tokensPerSecond;

  const StreamingStats({
    required this.totalChunks,
    required this.averageChunkSize,
    required this.streamingDuration,
    required this.tokensPerSecond,
  });

  Map<String, dynamic> toJson() => {
        'totalChunks': totalChunks,
        'averageChunkSize': averageChunkSize,
        'streamingDuration': streamingDuration.inMilliseconds,
        'tokensPerSecond': tokensPerSecond,
      };
}

/// Configuration for streaming behavior
class StreamingConfig {
  final Duration chunkDelay;
  final int maxChunkSize;
  final bool enableTypingIndicators;
  final bool enablePersonalityProcessing;
  final Duration timeout;

  const StreamingConfig({
    this.chunkDelay = const Duration(milliseconds: 50),
    this.maxChunkSize = 100,
    this.enableTypingIndicators = true,
    this.enablePersonalityProcessing = true,
    this.timeout = const Duration(seconds: 30),
  });

  static const StreamingConfig realtime = StreamingConfig(
    chunkDelay: Duration(milliseconds: 30),
    maxChunkSize: 50,
    enableTypingIndicators: true,
    enablePersonalityProcessing: true,
  );

  static const StreamingConfig efficient = StreamingConfig(
    chunkDelay: Duration(milliseconds: 100),
    maxChunkSize: 200,
    enableTypingIndicators: false,
    enablePersonalityProcessing: false,
  );
}