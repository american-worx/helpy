import 'package:hive/hive.dart';

part 'conversation.g.dart';

/// Conversation entity representing a chat session with Helpy
@HiveType(typeId: 6)
class Conversation {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String userId;
  @HiveField(3)
  final String helpyPersonalityId;
  @HiveField(4)
  final ConversationType type;
  @HiveField(5)
  final ConversationStatus status;
  @HiveField(6)
  final DateTime createdAt;
  @HiveField(7)
  final DateTime updatedAt;
  @HiveField(8)
  final String? lastMessageId;
  @HiveField(9)
  final String? lastMessagePreview;
  @HiveField(10)
  final DateTime? lastMessageTime;
  @HiveField(11)
  final int unreadCount;
  @HiveField(12)
  final List<String> participants;
  @HiveField(13)
  final Map<String, dynamic>? metadata;
  @HiveField(14)
  final ConversationSettings settings;

  const Conversation({
    required this.id,
    required this.title,
    required this.userId,
    required this.helpyPersonalityId,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageId,
    this.lastMessagePreview,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.participants = const [],
    this.metadata,
    this.settings = const ConversationSettings(),
  });

  Conversation copyWith({
    String? id,
    String? title,
    String? userId,
    String? helpyPersonalityId,
    ConversationType? type,
    ConversationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessageId,
    String? lastMessagePreview,
    DateTime? lastMessageTime,
    int? unreadCount,
    List<String>? participants,
    Map<String, dynamic>? metadata,
    ConversationSettings? settings,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      helpyPersonalityId: helpyPersonalityId ?? this.helpyPersonalityId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      participants: participants ?? this.participants,
      metadata: metadata ?? this.metadata,
      settings: settings ?? this.settings,
    );
  }

  /// Check if conversation has unread messages
  bool get hasUnreadMessages => unreadCount > 0;

  /// Check if conversation is active
  bool get isActive => status == ConversationStatus.active;

  /// Get formatted last message time
  String get formattedLastMessageTime {
    if (lastMessageTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(lastMessageTime!);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${lastMessageTime!.day}/${lastMessageTime!.month}';
    }
  }

  /// Get conversation display title
  String get displayTitle {
    if (title.isNotEmpty) return title;

    switch (type) {
      case ConversationType.general:
        return 'Chat with Helpy';
      case ConversationType.subjectHelp:
        return metadata?['subject'] ?? 'Subject Help';
      case ConversationType.homework:
        return 'Homework Help';
      case ConversationType.quiz:
        return 'Quiz Session';
      case ConversationType.lesson:
        return metadata?['lesson'] ?? 'Lesson Chat';
      case ConversationType.group:
        return 'Group Study';
    }
  }

  /// Convert to JSON for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'userId': userId,
      'helpyPersonalityId': helpyPersonalityId,
      'type': type.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastMessageId': lastMessageId,
      'lastMessagePreview': lastMessagePreview,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'participants': participants,
      'metadata': metadata,
      'settings': settings.toJson(),
    };
  }

  /// Create from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      userId: json['userId'] ?? '',
      helpyPersonalityId: json['helpyPersonalityId'] ?? '',
      type: ConversationType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => ConversationType.general,
      ),
      status: ConversationStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => ConversationStatus.active,
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastMessageId: json['lastMessageId'],
      lastMessagePreview: json['lastMessagePreview'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      participants: List<String>.from(json['participants'] ?? []),
      metadata: json['metadata'],
      settings: json['settings'] != null
          ? ConversationSettings.fromJson(json['settings'])
          : const ConversationSettings(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Conversation(id: $id, title: $title, type: $type, status: $status)';
  }
}

/// Types of conversations
@HiveType(typeId: 7)
enum ConversationType {
  @HiveField(0)
  general, // General chat with Helpy
  @HiveField(1)
  subjectHelp, // Help with specific subject
  @HiveField(2)
  homework, // Homework assistance
  @HiveField(3)
  quiz, // Quiz or assessment
  @HiveField(4)
  lesson, // Lesson-related chat
  @HiveField(5)
  group, // Group study session
}

/// Conversation status
@HiveType(typeId: 8)
enum ConversationStatus {
  @HiveField(0)
  active, // Conversation is active
  @HiveField(1)
  paused, // Conversation is paused
  @HiveField(2)
  ended, // Conversation has ended
  @HiveField(3)
  archived, // Conversation is archived
}

/// Conversation settings and preferences
@HiveType(typeId: 9)
class ConversationSettings {
  @HiveField(0)
  final bool notificationsEnabled;
  @HiveField(1)
  final bool soundEnabled;
  @HiveField(2)
  final bool autoSaveEnabled;
  @HiveField(3)
  final int maxMessages;
  @HiveField(4)
  final Duration typingTimeout;
  @HiveField(5)
  final Map<String, dynamic>? customSettings;

  const ConversationSettings({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.autoSaveEnabled = true,
    this.maxMessages = 1000,
    this.typingTimeout = const Duration(seconds: 30),
    this.customSettings,
  });

  ConversationSettings copyWith({
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? autoSaveEnabled,
    int? maxMessages,
    Duration? typingTimeout,
    Map<String, dynamic>? customSettings,
  }) {
    return ConversationSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
      maxMessages: maxMessages ?? this.maxMessages,
      typingTimeout: typingTimeout ?? this.typingTimeout,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'autoSaveEnabled': autoSaveEnabled,
      'maxMessages': maxMessages,
      'typingTimeout': typingTimeout.inSeconds,
      'customSettings': customSettings,
    };
  }

  factory ConversationSettings.fromJson(Map<String, dynamic> json) {
    return ConversationSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      autoSaveEnabled: json['autoSaveEnabled'] ?? true,
      maxMessages: json['maxMessages'] ?? 1000,
      typingTimeout: Duration(seconds: json['typingTimeout'] ?? 30),
      customSettings: json['customSettings'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationSettings &&
        other.notificationsEnabled == notificationsEnabled &&
        other.soundEnabled == soundEnabled &&
        other.autoSaveEnabled == autoSaveEnabled &&
        other.maxMessages == maxMessages &&
        other.typingTimeout == typingTimeout;
  }

  @override
  int get hashCode {
    return Object.hash(
      notificationsEnabled,
      soundEnabled,
      autoSaveEnabled,
      maxMessages,
      typingTimeout,
    );
  }

  @override
  String toString() {
    return 'ConversationSettings(notifications: $notificationsEnabled, sound: $soundEnabled)';
  }
}
