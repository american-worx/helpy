import 'package:hive/hive.dart';
import 'shared_enums.dart';

part 'message.g.dart';

/// Message entity for chat conversations
@HiveType(typeId: 2)
class Message {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String conversationId;
  @HiveField(2)
  final String senderId;
  @HiveField(3)
  final String senderName;
  @HiveField(4)
  final String content;
  @HiveField(5)
  final MessageType type;
  @HiveField(6)
  final MessageStatus status;
  @HiveField(7)
  final DateTime timestamp;
  @HiveField(8)
  final DateTime? updatedAt;
  @HiveField(9)
  final Map<String, dynamic>? metadata;
  @HiveField(10)
  final String? replyToMessageId;
  @HiveField(11)
  final List<MessageAttachment>? attachments;
  @HiveField(12)
  final List<MessageReaction>? reactions;
  @HiveField(13)
  final bool isEdited;
  @HiveField(14)
  final DateTime? editedAt;
  @HiveField(15)
  final MessagePriority priority;
  @HiveField(16)
  final Map<String, dynamic>? aiSettings;
  // New fields for message ordering and conflict resolution
  @HiveField(17)
  final int sequenceNumber;
  @HiveField(18)
  final bool isConflict;
  @HiveField(19)
  final List<String> conflictingMessageIds;
  // New fields for WebSocket sequencing and acknowledgment
  @HiveField(20)
  final String messageId;
  @HiveField(21)
  final DateTime? sentAt;
  @HiveField(22)
  final DateTime? deliveredAt;
  @HiveField(23)
  final DateTime? readAt;
  @HiveField(24)
  final MessageDeliveryStatus deliveryStatus;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.status,
    required this.timestamp,
    this.updatedAt,
    this.metadata,
    this.replyToMessageId,
    this.attachments,
    this.reactions,
    this.isEdited = false,
    this.editedAt,
    this.priority = MessagePriority.normal,
    this.aiSettings,
    // New parameters with default values
    this.sequenceNumber = 0,
    this.isConflict = false,
    this.conflictingMessageIds = const [],
    // WebSocket-specific parameters with default values
    this.messageId = '',
    this.sentAt, // Default to null
    this.deliveredAt,
    this.readAt,
    this.deliveryStatus = MessageDeliveryStatus.sent,
  });

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    String? replyToMessageId,
    List<MessageAttachment>? attachments,
    List<MessageReaction>? reactions,
    bool? isEdited,
    DateTime? editedAt,
    MessagePriority? priority,
    Map<String, dynamic>? aiSettings,
    int? sequenceNumber,
    bool? isConflict,
    List<String>? conflictingMessageIds,
    String? messageId,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    MessageDeliveryStatus? deliveryStatus,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      attachments: attachments ?? this.attachments,
      reactions: reactions ?? this.reactions,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      priority: priority ?? this.priority,
      aiSettings: aiSettings ?? this.aiSettings,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      isConflict: isConflict ?? this.isConflict,
      conflictingMessageIds:
          conflictingMessageIds ?? this.conflictingMessageIds,
      messageId: messageId ?? this.messageId,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }

  /// Check if this message is from Helpy
  bool get isFromHelpy => senderId.startsWith('helpy_');

  /// Check if this message is from the current user
  bool isFromUser(String userId) => senderId == userId;

  /// Check if message has attachments
  bool get hasAttachments => attachments != null && attachments!.isNotEmpty;

  /// Check if message has reactions
  bool get hasReactions => reactions != null && reactions!.isNotEmpty;

  /// Get file attachments only
  List<MessageAttachment> get fileAttachments {
    return attachments?.where((a) => a.type == AttachmentType.file).toList() ??
        [];
  }

  /// Get image attachments only
  List<MessageAttachment> get imageAttachments {
    return attachments?.where((a) => a.type == AttachmentType.image).toList() ??
        [];
  }

  /// Get total reactions count
  int get totalReactions {
    return reactions?.fold<int>(0, (sum, reaction) => sum + reaction.count) ??
        0;
  }

  /// Check if user has reacted with specific emoji
  bool hasUserReaction(String userId, String emoji) {
    return reactions?.any(
          (r) => r.emoji == emoji && r.userIds.contains(userId),
        ) ??
        false;
  }

  /// Add reaction to message
  Message addReaction(String userId, String emoji) {
    final updatedReactions = List<MessageReaction>.from(reactions ?? []);

    final existingReactionIndex = updatedReactions.indexWhere(
      (r) => r.emoji == emoji,
    );

    if (existingReactionIndex != -1) {
      final existingReaction = updatedReactions[existingReactionIndex];
      if (!existingReaction.userIds.contains(userId)) {
        updatedReactions[existingReactionIndex] = existingReaction.copyWith(
          userIds: [...existingReaction.userIds, userId],
          count: existingReaction.count + 1,
        );
      }
    } else {
      updatedReactions.add(
        MessageReaction(emoji: emoji, userIds: [userId], count: 1),
      );
    }

    return copyWith(reactions: updatedReactions);
  }

  /// Remove reaction from message
  Message removeReaction(String userId, String emoji) {
    final updatedReactions = List<MessageReaction>.from(reactions ?? []);

    final existingReactionIndex = updatedReactions.indexWhere(
      (r) => r.emoji == emoji,
    );

    if (existingReactionIndex != -1) {
      final existingReaction = updatedReactions[existingReactionIndex];
      if (existingReaction.userIds.contains(userId)) {
        final updatedUserIds =
            existingReaction.userIds.where((id) => id != userId).toList();

        if (updatedUserIds.isEmpty) {
          updatedReactions.removeAt(existingReactionIndex);
        } else {
          updatedReactions[existingReactionIndex] = existingReaction.copyWith(
            userIds: updatedUserIds,
            count: updatedUserIds.length,
          );
        }
      }
    }

    return copyWith(reactions: updatedReactions);
  }

  /// Get formatted timestamp for display
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  /// Convert to JSON for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
      'replyToMessageId': replyToMessageId,
      'attachments': attachments?.map((a) => a.toJson()).toList(),
      'reactions': reactions?.map((r) => r.toJson()).toList(),
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'priority': priority.name,
      'aiSettings': aiSettings,
      // New fields for message ordering and conflict resolution
      'sequenceNumber': sequenceNumber,
      'isConflict': isConflict,
      'conflictingMessageIds': conflictingMessageIds,
      // New fields for WebSocket sequencing and acknowledgment
      'messageId': messageId,
      'sentAt': sentAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'deliveryStatus': deliveryStatus.name,
    };
  }

  /// Create from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      metadata: json['metadata'],
      replyToMessageId: json['replyToMessageId'],
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((a) => MessageAttachment.fromJson(a))
              .toList()
          : null,
      reactions: json['reactions'] != null
          ? (json['reactions'] as List)
              .map((r) => MessageReaction.fromJson(r))
              .toList()
          : null,
      isEdited: json['isEdited'] ?? false,
      editedAt:
          json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
      priority: MessagePriority.values.firstWhere(
        (priority) => priority.name == json['priority'],
        orElse: () => MessagePriority.normal,
      ),
      aiSettings: json['aiSettings'],
      // New fields for message ordering and conflict resolution
      sequenceNumber: json['sequenceNumber'] ?? 0,
      isConflict: json['isConflict'] ?? false,
      conflictingMessageIds: json['conflictingMessageIds'] != null
          ? List<String>.from(json['conflictingMessageIds'])
          : const [],
      // New fields for WebSocket sequencing and acknowledgment
      messageId: json['messageId'] ?? '',
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      deliveryStatus: MessageDeliveryStatus.values.firstWhere(
        (status) => status.name == json['deliveryStatus'],
        orElse: () => MessageDeliveryStatus.sent,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Message(id: $id, content: $content, type: $type, status: $status)';
  }
}

/// Types of messages in chat
@HiveType(typeId: 3)
enum MessageType {
  @HiveField(0)
  text, // Regular text message
  @HiveField(1)
  image, // Image attachment
  @HiveField(2)
  file, // File attachment
  @HiveField(3)
  audio, // Audio message
  @HiveField(4)
  video, // Video message
  @HiveField(5)
  document, // Document file
  @HiveField(6)
  system, // System notification
  @HiveField(7)
  typing, // Typing indicator
  @HiveField(8)
  quiz, // Interactive quiz
  @HiveField(9)
  lesson, // Lesson content
  @HiveField(10)
  achievement, // Achievement notification
  @HiveField(11)
  suggestion, // AI suggestion
  @HiveField(12)
  emoji, // Emoji-only message
  @HiveField(13)
  sticker, // Sticker message
  @HiveField(14)
  location, // Location sharing
  @HiveField(15)
  contact, // Contact sharing
}

/// Message delivery and read status
@HiveType(typeId: 4)
enum MessageStatus {
  @HiveField(0)
  sending, // Message is being sent
  @HiveField(1)
  sent, // Message delivered to server
  @HiveField(2)
  delivered, // Message delivered to recipient
  @HiveField(3)
  read, // Message has been read
  @HiveField(4)
  failed, // Message failed to send
  @HiveField(5)
  encrypted, // Message is encrypted
  @HiveField(6)
  deleted, // Message was deleted
}

/// Message attachments with advanced file handling
@HiveType(typeId: 5)
class MessageAttachment {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String fileName;
  @HiveField(2)
  final String originalFileName;
  @HiveField(3)
  final String fileType;
  @HiveField(4)
  final int fileSize;
  @HiveField(5)
  final int? originalFileSize;
  @HiveField(6)
  final String url;
  @HiveField(7)
  final String? localPath;
  @HiveField(8)
  final String? thumbnail;
  @HiveField(9)
  final AttachmentType type;
  @HiveField(10)
  final AttachmentStatus status;
  @HiveField(11)
  final CompressionInfo? compressionInfo;
  @HiveField(12)
  final Map<String, dynamic>? metadata;
  @HiveField(13)
  final DateTime uploadedAt;
  @HiveField(14)
  final String? uploadedBy;
  @HiveField(15)
  final bool isEncrypted;
  @HiveField(16)
  final String? encryptionKey;

  MessageAttachment({
    required this.id,
    required this.fileName,
    String? originalFileName,
    required this.fileType,
    required this.fileSize,
    this.originalFileSize,
    required this.url,
    this.localPath,
    this.thumbnail,
    required this.type,
    this.status = AttachmentStatus.uploaded,
    this.compressionInfo,
    this.metadata,
    DateTime? uploadedAt,
    this.uploadedBy,
    this.isEncrypted = false,
    this.encryptionKey,
  })  : originalFileName = originalFileName ?? fileName,
        uploadedAt = uploadedAt ?? DateTime.now();

  MessageAttachment copyWith({
    String? id,
    String? fileName,
    String? originalFileName,
    String? fileType,
    int? fileSize,
    int? originalFileSize,
    String? url,
    String? localPath,
    String? thumbnail,
    AttachmentType? type,
    AttachmentStatus? status,
    CompressionInfo? compressionInfo,
    Map<String, dynamic>? metadata,
    DateTime? uploadedAt,
    String? uploadedBy,
    bool? isEncrypted,
    String? encryptionKey,
  }) {
    return MessageAttachment(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      originalFileName: originalFileName ?? this.originalFileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      originalFileSize: originalFileSize ?? this.originalFileSize,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      thumbnail: thumbnail ?? this.thumbnail,
      type: type ?? this.type,
      status: status ?? this.status,
      compressionInfo: compressionInfo ?? this.compressionInfo,
      metadata: metadata ?? this.metadata,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      encryptionKey: encryptionKey ?? this.encryptionKey,
    );
  }

  /// Get file size in human readable format
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '${fileSize}B';
    }
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Get compression ratio if available
  double? get compressionRatio {
    if (originalFileSize != null && originalFileSize! > 0) {
      return (originalFileSize! - fileSize) / originalFileSize!;
    }
    return null;
  }

  /// Get compression percentage
  String get compressionPercentage {
    final ratio = compressionRatio;
    if (ratio != null) {
      return '${(ratio * 100).toStringAsFixed(1)}%';
    }
    return 'No compression';
  }

  /// Check if attachment is an image
  bool get isImage =>
      type == AttachmentType.image || fileType.startsWith('image/');

  /// Check if attachment is audio
  bool get isAudio =>
      type == AttachmentType.audio || fileType.startsWith('audio/');

  /// Check if attachment is video
  bool get isVideo =>
      type == AttachmentType.video || fileType.startsWith('video/');

  /// Check if attachment is document
  bool get isDocument => type == AttachmentType.document;

  /// Check if file is compressed
  bool get isCompressed => compressionInfo != null;

  /// Get file extension
  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Get attachment icon based on type
  String get typeIcon {
    switch (type) {
      case AttachmentType.image:
        return '🖼️';
      case AttachmentType.video:
        return '🎥';
      case AttachmentType.audio:
        return '🎵';
      case AttachmentType.document:
        return '📄';
      case AttachmentType.file:
        return '📎';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'originalFileName': originalFileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'originalFileSize': originalFileSize,
      'url': url,
      'localPath': localPath,
      'thumbnail': thumbnail,
      'type': type.name,
      'status': status.name,
      'compressionInfo': compressionInfo?.toJson(),
      'metadata': metadata,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
      'isEncrypted': isEncrypted,
      'encryptionKey': encryptionKey,
    };
  }

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      id: json['id'] ?? '',
      fileName: json['fileName'] ?? '',
      originalFileName: json['originalFileName'],
      fileType: json['fileType'] ?? '',
      fileSize: json['fileSize'] ?? 0,
      originalFileSize: json['originalFileSize'],
      url: json['url'] ?? '',
      localPath: json['localPath'],
      thumbnail: json['thumbnail'],
      type: AttachmentType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => AttachmentType.file,
      ),
      status: AttachmentStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => AttachmentStatus.uploaded,
      ),
      compressionInfo: json['compressionInfo'] != null
          ? CompressionInfo.fromJson(json['compressionInfo'])
          : null,
      metadata: json['metadata'],
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : DateTime.now(),
      uploadedBy: json['uploadedBy'],
      isEncrypted: json['isEncrypted'] ?? false,
      encryptionKey: json['encryptionKey'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageAttachment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MessageAttachment(id: $id, fileName: $fileName, fileType: $fileType)';
  }
}
