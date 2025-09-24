// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageRequest _$MessageRequestFromJson(Map<String, dynamic> json) =>
    MessageRequest(
      conversationId: json['conversationId'] as String,
      content: json['content'] as String,
      contentType: json['contentType'] as String? ?? 'text',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MessageRequestToJson(MessageRequest instance) =>
    <String, dynamic>{
      'conversationId': instance.conversationId,
      'content': instance.content,
      'contentType': instance.contentType,
      'metadata': instance.metadata,
    };

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      senderType: json['senderType'] as String,
      content: json['content'] as String,
      contentType: json['contentType'] as String? ?? 'text',
      timestamp: json['timestamp'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      reactions: json['reactions'] as Map<String, dynamic>?,
      edited: json['edited'] as bool? ?? false,
      editedAt: json['editedAt'] as String?,
      sequenceNumber: (json['sequenceNumber'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MessageResponseToJson(MessageResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'senderId': instance.senderId,
      'senderType': instance.senderType,
      'content': instance.content,
      'contentType': instance.contentType,
      'timestamp': instance.timestamp,
      'metadata': instance.metadata,
      'reactions': instance.reactions,
      'edited': instance.edited,
      'editedAt': instance.editedAt,
      'sequenceNumber': instance.sequenceNumber,
    };

ConversationRequest _$ConversationRequestFromJson(Map<String, dynamic> json) =>
    ConversationRequest(
      title: json['title'] as String,
      type: json['type'] as String,
      participantIds: (json['participantIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      subject: json['subject'] as String?,
    );

Map<String, dynamic> _$ConversationRequestToJson(
        ConversationRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'type': instance.type,
      'participantIds': instance.participantIds,
      'subject': instance.subject,
    };

ConversationResponse _$ConversationResponseFromJson(
        Map<String, dynamic> json) =>
    ConversationResponse(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      participantIds: (json['participantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      subject: json['subject'] as String?,
      createdAt: json['createdAt'] as String,
      lastMessageAt: json['lastMessageAt'] as String?,
      messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ConversationResponseToJson(
        ConversationResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': instance.type,
      'participantIds': instance.participantIds,
      'subject': instance.subject,
      'createdAt': instance.createdAt,
      'lastMessageAt': instance.lastMessageAt,
      'messageCount': instance.messageCount,
      'isActive': instance.isActive,
      'metadata': instance.metadata,
    };

GroupSessionRequest _$GroupSessionRequestFromJson(Map<String, dynamic> json) =>
    GroupSessionRequest(
      name: json['name'] as String,
      subject: json['subject'] as String,
      participantIds: (json['participantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      helpyIds: (json['helpyIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      sessionType: json['sessionType'] as String? ?? 'study',
      settings: json['settings'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GroupSessionRequestToJson(
        GroupSessionRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'subject': instance.subject,
      'participantIds': instance.participantIds,
      'helpyIds': instance.helpyIds,
      'sessionType': instance.sessionType,
      'settings': instance.settings,
    };

GroupSessionResponse _$GroupSessionResponseFromJson(
        Map<String, dynamic> json) =>
    GroupSessionResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      subject: json['subject'] as String,
      participants: json['participants'] as Map<String, dynamic>? ?? const {},
      helpys: json['helpys'] as Map<String, dynamic>? ?? const {},
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      sessionType: json['sessionType'] as String? ?? 'study',
      metrics: json['metrics'] as Map<String, dynamic>?,
      recordingUrl: json['recordingUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$GroupSessionResponseToJson(
        GroupSessionResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'subject': instance.subject,
      'participants': instance.participants,
      'helpys': instance.helpys,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'sessionType': instance.sessionType,
      'metrics': instance.metrics,
      'recordingUrl': instance.recordingUrl,
      'isActive': instance.isActive,
    };

TypingIndicator _$TypingIndicatorFromJson(Map<String, dynamic> json) =>
    TypingIndicator(
      conversationId: json['conversationId'] as String,
      userId: json['userId'] as String,
      isTyping: json['isTyping'] as bool,
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$TypingIndicatorToJson(TypingIndicator instance) =>
    <String, dynamic>{
      'conversationId': instance.conversationId,
      'userId': instance.userId,
      'isTyping': instance.isTyping,
      'timestamp': instance.timestamp,
    };

MessageReaction _$MessageReactionFromJson(Map<String, dynamic> json) =>
    MessageReaction(
      messageId: json['messageId'] as String,
      userId: json['userId'] as String,
      reaction: json['reaction'] as String,
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$MessageReactionToJson(MessageReaction instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'userId': instance.userId,
      'reaction': instance.reaction,
      'timestamp': instance.timestamp,
    };
