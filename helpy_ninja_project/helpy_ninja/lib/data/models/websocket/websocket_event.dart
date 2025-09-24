/// Base class for all WebSocket events
abstract class WebSocketEvent {
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const WebSocketEvent({
    required this.type,
    required this.timestamp,
    required this.data,
  });

  /// Create event from JSON
  factory WebSocketEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    switch (type) {
      case 'message':
        return MessageEvent.fromJson(json);
      case 'message_update':
        return MessageUpdateEvent.fromJson(json);
      case 'message_delete':
        return MessageDeleteEvent.fromJson(json);
      case 'typing':
        return TypingEvent.fromJson(json);
      case 'user_presence':
        return UserPresenceEvent.fromJson(json);
      case 'participant_joined':
        return ParticipantJoinedEvent.fromJson(json);
      case 'participant_left':
        return ParticipantLeftEvent.fromJson(json);
      case 'participant_update':
        return ParticipantUpdateEvent.fromJson(json);
      case 'message_ack':
        return MessageAcknowledgmentEvent.fromJson(json);
      case 'conversation_update':
        return ConversationUpdateEvent.fromJson(json);
      case 'error':
        return ErrorEvent.fromJson(json);
      default:
        return UnknownEvent.fromJson(json);
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
    };
  }
}

/// New message event
class MessageEvent extends WebSocketEvent {
  final String conversationId;
  final String messageId;
  final String senderId;
  final String senderName;
  final String content;
  final String contentType;
  final Map<String, dynamic>? metadata;

  const MessageEvent({
    required this.conversationId,
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.contentType = 'text',
    this.metadata,
    required DateTime timestamp,
  }) : super(
          type: 'message',
          timestamp: timestamp,
          data: const {},
        );

  factory MessageEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return MessageEvent(
      conversationId: data['conversationId'] as String,
      messageId: data['messageId'] as String,
      senderId: data['senderId'] as String,
      senderName: data['senderName'] as String,
      content: data['content'] as String,
      contentType: data['contentType'] as String? ?? 'text',
      metadata: data['metadata'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'data': {
        'conversationId': conversationId,
        'messageId': messageId,
        'senderId': senderId,
        'senderName': senderName,
        'content': content,
        'contentType': contentType,
        if (metadata != null) 'metadata': metadata,
      },
    };
  }
}

/// Message update event
class MessageUpdateEvent extends WebSocketEvent {
  final String messageId;
  final String conversationId;
  final String content;
  final bool isEdited;
  final DateTime editedAt;

  const MessageUpdateEvent({
    required this.messageId,
    required this.conversationId,
    required this.content,
    required this.isEdited,
    required this.editedAt,
    required DateTime timestamp,
  }) : super(
          type: 'message_update',
          timestamp: timestamp,
          data: const {},
        );

  factory MessageUpdateEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return MessageUpdateEvent(
      messageId: data['messageId'] as String,
      conversationId: data['conversationId'] as String,
      content: data['content'] as String,
      isEdited: data['isEdited'] as bool? ?? true,
      editedAt: DateTime.parse(data['editedAt'] as String),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Message delete event
class MessageDeleteEvent extends WebSocketEvent {
  final String messageId;
  final String conversationId;
  final String deletedBy;

  const MessageDeleteEvent({
    required this.messageId,
    required this.conversationId,
    required this.deletedBy,
    required DateTime timestamp,
  }) : super(
          type: 'message_delete',
          timestamp: timestamp,
          data: const {},
        );

  factory MessageDeleteEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return MessageDeleteEvent(
      messageId: data['messageId'] as String,
      conversationId: data['conversationId'] as String,
      deletedBy: data['deletedBy'] as String,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Typing indicator event
class TypingEvent extends WebSocketEvent {
  final String conversationId;
  final String userId;
  final String userName;
  final bool isTyping;

  const TypingEvent({
    required this.conversationId,
    required this.userId,
    required this.userName,
    required this.isTyping,
    required DateTime timestamp,
  }) : super(
          type: 'typing',
          timestamp: timestamp,
          data: const {},
        );

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return TypingEvent(
      conversationId: data['conversationId'] as String,
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      isTyping: data['isTyping'] as bool,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// User presence event
class UserPresenceEvent extends WebSocketEvent {
  final String userId;
  final String userName;
  final String status; // 'online', 'offline', 'away'
  final DateTime lastSeen;

  const UserPresenceEvent({
    required this.userId,
    required this.userName,
    required this.status,
    required this.lastSeen,
    required DateTime timestamp,
  }) : super(
          type: 'user_presence',
          timestamp: timestamp,
          data: const {},
        );

  factory UserPresenceEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return UserPresenceEvent(
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      status: data['status'] as String,
      lastSeen: DateTime.parse(data['lastSeen'] as String),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Participant joined event
class ParticipantJoinedEvent extends WebSocketEvent {
  final String conversationId;
  final String userId;
  final String userName;
  final String role;

  const ParticipantJoinedEvent({
    required this.conversationId,
    required this.userId,
    required this.userName,
    this.role = 'participant',
    required DateTime timestamp,
  }) : super(
          type: 'participant_joined',
          timestamp: timestamp,
          data: const {},
        );

  factory ParticipantJoinedEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ParticipantJoinedEvent(
      conversationId: data['conversationId'] as String,
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      role: data['role'] as String? ?? 'participant',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Participant left event
class ParticipantLeftEvent extends WebSocketEvent {
  final String conversationId;
  final String userId;
  final String userName;
  final String reason; // 'left', 'disconnected', 'removed'

  const ParticipantLeftEvent({
    required this.conversationId,
    required this.userId,
    required this.userName,
    this.reason = 'left',
    required DateTime timestamp,
  }) : super(
          type: 'participant_left',
          timestamp: timestamp,
          data: const {},
        );

  factory ParticipantLeftEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ParticipantLeftEvent(
      conversationId: data['conversationId'] as String,
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      reason: data['reason'] as String? ?? 'left',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Participant update event
class ParticipantUpdateEvent extends WebSocketEvent {
  final String conversationId;
  final String userId;
  final String userName;
  final Map<String, dynamic> updates;

  const ParticipantUpdateEvent({
    required this.conversationId,
    required this.userId,
    required this.userName,
    required this.updates,
    required DateTime timestamp,
  }) : super(
          type: 'participant_update',
          timestamp: timestamp,
          data: const {},
        );

  factory ParticipantUpdateEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ParticipantUpdateEvent(
      conversationId: data['conversationId'] as String,
      userId: data['userId'] as String,
      userName: data['userName'] as String,
      updates: data['updates'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Message acknowledgment event
class MessageAcknowledgmentEvent extends WebSocketEvent {
  final String messageId;
  final String userId;
  final String status; // 'delivered', 'read'

  const MessageAcknowledgmentEvent({
    required this.messageId,
    required this.userId,
    required this.status,
    required DateTime timestamp,
  }) : super(
          type: 'message_ack',
          timestamp: timestamp,
          data: const {},
        );

  factory MessageAcknowledgmentEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return MessageAcknowledgmentEvent(
      messageId: data['messageId'] as String,
      userId: data['userId'] as String,
      status: data['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Conversation update event
class ConversationUpdateEvent extends WebSocketEvent {
  final String conversationId;
  final Map<String, dynamic> updates;

  const ConversationUpdateEvent({
    required this.conversationId,
    required this.updates,
    required DateTime timestamp,
  }) : super(
          type: 'conversation_update',
          timestamp: timestamp,
          data: const {},
        );

  factory ConversationUpdateEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ConversationUpdateEvent(
      conversationId: data['conversationId'] as String,
      updates: data['updates'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Error event
class ErrorEvent extends WebSocketEvent {
  final String errorType;
  final String message;
  final int? code;

  const ErrorEvent({
    required this.errorType,
    required this.message,
    this.code,
    required DateTime timestamp,
  }) : super(
          type: 'error',
          timestamp: timestamp,
          data: const {},
        );

  factory ErrorEvent.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return ErrorEvent(
      errorType: data['errorType'] as String,
      message: data['message'] as String,
      code: data['code'] as int?,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Unknown event (fallback)
class UnknownEvent extends WebSocketEvent {
  const UnknownEvent({
    required String type,
    required DateTime timestamp,
    required Map<String, dynamic> data,
  }) : super(
          type: type,
          timestamp: timestamp,
          data: data,
        );

  factory UnknownEvent.fromJson(Map<String, dynamic> json) {
    return UnknownEvent(
      type: json['type'] as String,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }
}