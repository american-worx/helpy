/// Shared enums used across multiple entities

/// Difficulty levels for lessons and questions
enum DifficultyLevel { beginner, intermediate, advanced, expert }

/// Theme mode options
enum ThemeMode { light, dark, system }

/// Types of attachments
enum AttachmentType { image, video, audio, document, file }

/// Attachment processing status
enum AttachmentStatus {
  uploading,
  uploaded,
  failed,
  processing,
  compressed,
  encrypted,
}

/// Message priority levels
enum MessagePriority { low, normal, high, urgent }

/// AI response formats
enum ResponseFormat { text, json, markdown, html }

/// Creativity levels for AI responses
enum CreativityLevel { conservative, balanced, creative, experimental }

/// Focus levels for AI responses
enum FocusLevel { focused, balanced, diverse }

/// Message display styles
enum MessageDisplayStyle { bubbles, compact, list, minimal }

/// Message reaction class for emoji reactions
class MessageReaction {
  final String emoji;
  final List<String> userIds;
  final int count;
  final DateTime timestamp;
  final String? userName;

  MessageReaction({
    required this.emoji,
    required this.userIds,
    required this.count,
    DateTime? timestamp,
    this.userName,
  }) : timestamp = timestamp ?? DateTime.now();

  MessageReaction copyWith({
    String? emoji,
    List<String>? userIds,
    int? count,
    DateTime? timestamp,
    String? userName,
  }) {
    return MessageReaction(
      emoji: emoji ?? this.emoji,
      userIds: userIds ?? this.userIds,
      count: count ?? this.count,
      timestamp: timestamp ?? this.timestamp,
      userName: userName ?? this.userName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'userIds': userIds,
      'count': count,
      'timestamp': timestamp.toIso8601String(),
      'userName': userName,
    };
  }

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      emoji: json['emoji'] ?? '',
      userIds: List<String>.from(json['userIds'] ?? []),
      count: json['count'] ?? 0,
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      userName: json['userName'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageReaction &&
        other.emoji == emoji &&
        other.userIds.length == userIds.length &&
        other.userIds.every((id) => userIds.contains(id));
  }

  @override
  int get hashCode => Object.hash(emoji, userIds.length);
}

/// Compression information for file attachments
class CompressionInfo {
  final int originalSize;
  final int compressedSize;
  final double compressionRatio;
  final String algorithm;
  final Duration processingTime;
  final Map<String, dynamic>? metadata;

  const CompressionInfo({
    required this.originalSize,
    required this.compressedSize,
    required this.compressionRatio,
    required this.algorithm,
    required this.processingTime,
    this.metadata,
  });

  CompressionInfo copyWith({
    int? originalSize,
    int? compressedSize,
    double? compressionRatio,
    String? algorithm,
    Duration? processingTime,
    Map<String, dynamic>? metadata,
  }) {
    return CompressionInfo(
      originalSize: originalSize ?? this.originalSize,
      compressedSize: compressedSize ?? this.compressedSize,
      compressionRatio: compressionRatio ?? this.compressionRatio,
      algorithm: algorithm ?? this.algorithm,
      processingTime: processingTime ?? this.processingTime,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalSize': originalSize,
      'compressedSize': compressedSize,
      'compressionRatio': compressionRatio,
      'algorithm': algorithm,
      'processingTime': processingTime.inMilliseconds,
      'metadata': metadata,
    };
  }

  factory CompressionInfo.fromJson(Map<String, dynamic> json) {
    return CompressionInfo(
      originalSize: json['originalSize'] ?? 0,
      compressedSize: json['compressedSize'] ?? 0,
      compressionRatio: (json['compressionRatio'] ?? 0.0).toDouble(),
      algorithm: json['algorithm'] ?? '',
      processingTime: Duration(milliseconds: json['processingTime'] ?? 0),
      metadata: json['metadata'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CompressionInfo &&
        other.originalSize == originalSize &&
        other.compressedSize == compressedSize &&
        other.algorithm == algorithm;
  }

  @override
  int get hashCode => Object.hash(originalSize, compressedSize, algorithm);
}
