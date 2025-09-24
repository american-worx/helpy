/// Shared enums used across multiple entities
import 'package:hive/hive.dart';

part 'shared_enums.g.dart';

/// Difficulty levels for lessons and questions
@HiveType(typeId: 20)
enum DifficultyLevel {
  @HiveField(0)
  beginner,
  @HiveField(1)
  intermediate,
  @HiveField(2)
  advanced,
  @HiveField(3)
  expert
}

/// Theme mode options
@HiveType(typeId: 21)
enum ThemeMode {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
  @HiveField(2)
  system
}

/// Types of attachments
@HiveType(typeId: 22)
enum AttachmentType {
  @HiveField(0)
  image,
  @HiveField(1)
  video,
  @HiveField(2)
  audio,
  @HiveField(3)
  document,
  @HiveField(4)
  file
}

/// Attachment processing status
@HiveType(typeId: 23)
enum AttachmentStatus {
  @HiveField(0)
  uploading,
  @HiveField(1)
  uploaded,
  @HiveField(2)
  failed,
  @HiveField(3)
  processing,
  @HiveField(4)
  compressed,
  @HiveField(5)
  encrypted,
}

/// Message priority levels
@HiveType(typeId: 24)
enum MessagePriority {
  @HiveField(0)
  low,
  @HiveField(1)
  normal,
  @HiveField(2)
  high,
  @HiveField(3)
  urgent
}

/// AI response formats
enum ResponseFormat { text, json, markdown, html }

/// Creativity levels for AI responses
enum CreativityLevel { conservative, balanced, creative, experimental }

/// Focus levels for AI responses
enum FocusLevel { focused, balanced, diverse }

/// Message display styles
enum MessageDisplayStyle { bubbles, compact, list, minimal }

/// Group session status
enum GroupSessionStatus {
  active, // Session is active and ongoing
  paused, // Session is temporarily paused
  completed, // Session has been completed
  cancelled, // Session was cancelled
}

/// Participant status in a group session
enum ParticipantStatus {
  active, // Participant is active in the session
  inactive, // Participant is temporarily inactive
  left, // Participant has left the session
  disconnected, // Participant is disconnected
}

/// Message reaction class for emoji reactions
@HiveType(typeId: 26)
class MessageReaction {
  @HiveField(0)
  final String emoji;
  @HiveField(1)
  final List<String> userIds;
  @HiveField(2)
  final int count;
  @HiveField(3)
  final DateTime timestamp;
  @HiveField(4)
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
@HiveType(typeId: 27)
class CompressionInfo {
  @HiveField(0)
  final int originalSize;
  @HiveField(1)
  final int compressedSize;
  @HiveField(2)
  final double compressionRatio;
  @HiveField(3)
  final String algorithm;
  @HiveField(4)
  final Duration processingTime;
  @HiveField(5)
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

/// Message delivery status for WebSocket tracking
@HiveType(typeId: 25)
enum MessageDeliveryStatus {
  @HiveField(0)
  sending, // Message is being sent
  @HiveField(1)
  sent, // Message sent to server
  @HiveField(2)
  delivered, // Message delivered to recipients
  @HiveField(3)
  read, // Message read by recipients
  @HiveField(4)
  failed, // Message failed to send
  @HiveField(5)
  acknowledged, // Message acknowledged by recipients
}
