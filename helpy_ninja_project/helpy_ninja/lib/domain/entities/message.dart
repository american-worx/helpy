import 'shared_enums.dart';

/// Message entity for chat conversations
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;
  final String? replyToMessageId;
  final List<MessageAttachment>? attachments;
  final List<MessageReaction>? reactions;
  final bool isEdited;
  final DateTime? editedAt;
  final MessagePriority priority;
  final Map<String, dynamic>? aiSettings;

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
        final updatedUserIds = existingReaction.userIds
            .where((id) => id != userId)
            .toList();

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
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
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
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt'])
          : null,
      priority: MessagePriority.values.firstWhere(
        (priority) => priority.name == json['priority'],
        orElse: () => MessagePriority.normal,
      ),
      aiSettings: json['aiSettings'],
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
enum MessageType {
  text, // Regular text message
  image, // Image attachment
  file, // File attachment
  audio, // Audio message
  video, // Video message
  document, // Document file
  system, // System notification
  typing, // Typing indicator
  quiz, // Interactive quiz
  lesson, // Lesson content
  achievement, // Achievement notification
  suggestion, // AI suggestion
  emoji, // Emoji-only message
  sticker, // Sticker message
  location, // Location sharing
  contact, // Contact sharing
}

/// Message delivery and read status
enum MessageStatus {
  sending, // Message is being sent
  sent, // Message delivered to server
  delivered, // Message delivered to recipient
  read, // Message has been read
  failed, // Message failed to send
  encrypted, // Message is encrypted
  deleted, // Message was deleted
}

/// Message attachments with advanced file handling
class MessageAttachment {
  final String id;
  final String fileName;
  final String originalFileName;
  final String fileType;
  final int fileSize;
  final int? originalFileSize;
  final String url;
  final String? localPath;
  final String? thumbnail;
  final AttachmentType type;
  final AttachmentStatus status;
  final CompressionInfo? compressionInfo;
  final Map<String, dynamic>? metadata;
  final DateTime uploadedAt;
  final String? uploadedBy;
  final bool isEncrypted;
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
  }) : originalFileName = originalFileName ?? fileName,
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
