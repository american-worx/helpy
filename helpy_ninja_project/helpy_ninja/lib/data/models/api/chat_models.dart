import 'package:json_annotation/json_annotation.dart';

part 'chat_models.g.dart';

/// Message request model for sending messages
@JsonSerializable()
class MessageRequest {
  final String conversationId;
  final String content;
  final String contentType;
  final Map<String, dynamic>? metadata;

  const MessageRequest({
    required this.conversationId,
    required this.content,
    this.contentType = 'text',
    this.metadata,
  });

  factory MessageRequest.fromJson(Map<String, dynamic> json) =>
      _$MessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MessageRequestToJson(this);
}

/// Message response model from backend
@JsonSerializable()
class MessageResponse {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderType;
  final String content;
  final String contentType;
  final String timestamp;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? reactions;
  final bool edited;
  final String? editedAt;
  final int sequenceNumber;

  const MessageResponse({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.content,
    this.contentType = 'text',
    required this.timestamp,
    this.metadata,
    this.reactions,
    this.edited = false,
    this.editedAt,
    this.sequenceNumber = 0,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MessageResponseToJson(this);
}

/// Conversation request model for creating conversations
@JsonSerializable()
class ConversationRequest {
  final String title;
  final String type;
  final List<String>? participantIds;
  final String? subject;

  const ConversationRequest({
    required this.title,
    required this.type,
    this.participantIds,
    this.subject,
  });

  factory ConversationRequest.fromJson(Map<String, dynamic> json) =>
      _$ConversationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationRequestToJson(this);
}

/// Conversation response model from backend
@JsonSerializable()
class ConversationResponse {
  final String id;
  final String title;
  final String type;
  final List<String> participantIds;
  final String? subject;
  final String createdAt;
  final String? lastMessageAt;
  final int messageCount;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  const ConversationResponse({
    required this.id,
    required this.title,
    required this.type,
    this.participantIds = const [],
    this.subject,
    required this.createdAt,
    this.lastMessageAt,
    this.messageCount = 0,
    this.isActive = true,
    this.metadata,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$ConversationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationResponseToJson(this);
}

/// Group session request model
@JsonSerializable()
class GroupSessionRequest {
  final String name;
  final String subject;
  final List<String> participantIds;
  final List<String> helpyIds;
  final String sessionType;
  final Map<String, dynamic>? settings;

  const GroupSessionRequest({
    required this.name,
    required this.subject,
    this.participantIds = const [],
    this.helpyIds = const [],
    this.sessionType = 'study',
    this.settings,
  });

  factory GroupSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$GroupSessionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GroupSessionRequestToJson(this);
}

/// Group session response model
@JsonSerializable()
class GroupSessionResponse {
  final String id;
  final String name;
  final String subject;
  final Map<String, dynamic> participants;
  final Map<String, dynamic> helpys;
  final String? startTime;
  final String? endTime;
  final String sessionType;
  final Map<String, dynamic>? metrics;
  final String? recordingUrl;
  final bool isActive;

  const GroupSessionResponse({
    required this.id,
    required this.name,
    required this.subject,
    this.participants = const {},
    this.helpys = const {},
    this.startTime,
    this.endTime,
    this.sessionType = 'study',
    this.metrics,
    this.recordingUrl,
    this.isActive = true,
  });

  factory GroupSessionResponse.fromJson(Map<String, dynamic> json) =>
      _$GroupSessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GroupSessionResponseToJson(this);
}

/// Typing indicator model for WebSocket
@JsonSerializable()
class TypingIndicator {
  final String conversationId;
  final String userId;
  final bool isTyping;
  final String timestamp;

  const TypingIndicator({
    required this.conversationId,
    required this.userId,
    required this.isTyping,
    required this.timestamp,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) =>
      _$TypingIndicatorFromJson(json);

  Map<String, dynamic> toJson() => _$TypingIndicatorToJson(this);
}

/// Message reaction model
@JsonSerializable()
class MessageReaction {
  final String messageId;
  final String userId;
  final String reaction;
  final String timestamp;

  const MessageReaction({
    required this.messageId,
    required this.userId,
    required this.reaction,
    required this.timestamp,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) =>
      _$MessageReactionFromJson(json);

  Map<String, dynamic> toJson() => _$MessageReactionToJson(this);
}