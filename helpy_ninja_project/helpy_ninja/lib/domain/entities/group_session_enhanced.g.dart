// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_session_enhanced.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnhancedGroupSessionAdapter extends TypeAdapter<EnhancedGroupSession> {
  @override
  final int typeId = 20;

  @override
  EnhancedGroupSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnhancedGroupSession(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      ownerId: fields[3] as String,
      participantIds: (fields[4] as List).cast<String>(),
      participants: (fields[5] as List).cast<GroupParticipant>(),
      helpyParticipants: (fields[6] as List).cast<HelpyPersonality>(),
      messages: (fields[7] as List).cast<Message>(),
      status: fields[8] as GroupSessionStatus,
      settings: fields[9] as GroupSessionSettings,
      progress: fields[10] as GroupLearningProgress,
      invitations: (fields[11] as List).cast<GroupInvitation>(),
      moderation: fields[12] as ModerationSettings,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
      metadata: (fields[15] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, EnhancedGroupSession obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.ownerId)
      ..writeByte(4)
      ..write(obj.participantIds)
      ..writeByte(5)
      ..write(obj.participants)
      ..writeByte(6)
      ..write(obj.helpyParticipants)
      ..writeByte(7)
      ..write(obj.messages)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.settings)
      ..writeByte(10)
      ..write(obj.progress)
      ..writeByte(11)
      ..write(obj.invitations)
      ..writeByte(12)
      ..write(obj.moderation)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnhancedGroupSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GroupParticipantAdapter extends TypeAdapter<GroupParticipant> {
  @override
  final int typeId = 21;

  @override
  GroupParticipant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupParticipant(
      id: fields[0] as String,
      name: fields[1] as String,
      avatarUrl: fields[2] as String?,
      role: fields[3] as ParticipantRole,
      status: fields[4] as ParticipantStatus,
      joinedAt: fields[5] as DateTime,
      lastActiveAt: fields[6] as DateTime?,
      progress: fields[7] as ParticipantProgress,
      participationScore: fields[8] as double,
      metadata: (fields[9] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, GroupParticipant obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.avatarUrl)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.joinedAt)
      ..writeByte(6)
      ..write(obj.lastActiveAt)
      ..writeByte(7)
      ..write(obj.progress)
      ..writeByte(8)
      ..write(obj.participationScore)
      ..writeByte(9)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupParticipantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ParticipantProgressAdapter extends TypeAdapter<ParticipantProgress> {
  @override
  final int typeId = 22;

  @override
  ParticipantProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParticipantProgress(
      messagesContributed: fields[0] as int,
      questionsAsked: fields[1] as int,
      questionsAnswered: fields[2] as int,
      engagementScore: fields[3] as double,
      topicsEngaged: (fields[4] as List).cast<String>(),
      skillPoints: (fields[5] as Map).cast<String, int>(),
      achievements: (fields[6] as List).cast<Achievement>(),
    );
  }

  @override
  void write(BinaryWriter writer, ParticipantProgress obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.messagesContributed)
      ..writeByte(1)
      ..write(obj.questionsAsked)
      ..writeByte(2)
      ..write(obj.questionsAnswered)
      ..writeByte(3)
      ..write(obj.engagementScore)
      ..writeByte(4)
      ..write(obj.topicsEngaged)
      ..writeByte(5)
      ..write(obj.skillPoints)
      ..writeByte(6)
      ..write(obj.achievements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParticipantProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GroupSessionSettingsAdapter extends TypeAdapter<GroupSessionSettings> {
  @override
  final int typeId = 23;

  @override
  GroupSessionSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupSessionSettings(
      maxParticipants: fields[0] as int,
      isPublic: fields[1] as bool,
      allowGuestAccess: fields[2] as bool,
      requireApproval: fields[3] as bool,
      mode: fields[4] as SessionMode,
      subject: fields[5] as String?,
      topic: fields[6] as String?,
      difficulty: fields[7] as DifficultyLevel,
      sessionDuration: fields[8] as Duration?,
      features: (fields[9] as Map).cast<String, bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, GroupSessionSettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.maxParticipants)
      ..writeByte(1)
      ..write(obj.isPublic)
      ..writeByte(2)
      ..write(obj.allowGuestAccess)
      ..writeByte(3)
      ..write(obj.requireApproval)
      ..writeByte(4)
      ..write(obj.mode)
      ..writeByte(5)
      ..write(obj.subject)
      ..writeByte(6)
      ..write(obj.topic)
      ..writeByte(7)
      ..write(obj.difficulty)
      ..writeByte(8)
      ..write(obj.sessionDuration)
      ..writeByte(9)
      ..write(obj.features);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupSessionSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GroupLearningProgressAdapter extends TypeAdapter<GroupLearningProgress> {
  @override
  final int typeId = 24;

  @override
  GroupLearningProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupLearningProgress(
      sessionId: fields[0] as String,
      topicCoverage: (fields[1] as Map).cast<String, double>(),
      objectives: (fields[2] as List).cast<LearningObjective>(),
      skillPointsEarned: (fields[3] as Map).cast<String, int>(),
      achievements: (fields[4] as List).cast<GroupAchievement>(),
      overallProgress: fields[5] as double,
      participantContributions: (fields[6] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<String>())),
      milestones: (fields[7] as List).cast<CollaborativeMilestone>(),
    );
  }

  @override
  void write(BinaryWriter writer, GroupLearningProgress obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.topicCoverage)
      ..writeByte(2)
      ..write(obj.objectives)
      ..writeByte(3)
      ..write(obj.skillPointsEarned)
      ..writeByte(4)
      ..write(obj.achievements)
      ..writeByte(5)
      ..write(obj.overallProgress)
      ..writeByte(6)
      ..write(obj.participantContributions)
      ..writeByte(7)
      ..write(obj.milestones);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupLearningProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LearningObjectiveAdapter extends TypeAdapter<LearningObjective> {
  @override
  final int typeId = 25;

  @override
  LearningObjective read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LearningObjective(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      isCompleted: fields[3] as bool,
      completedAt: fields[4] as DateTime?,
      completedBy: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, LearningObjective obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.completedAt)
      ..writeByte(5)
      ..write(obj.completedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningObjectiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GroupInvitationAdapter extends TypeAdapter<GroupInvitation> {
  @override
  final int typeId = 26;

  @override
  GroupInvitation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupInvitation(
      id: fields[0] as String,
      sessionId: fields[1] as String,
      invitedBy: fields[2] as String,
      inviteeId: fields[3] as String,
      inviteeEmail: fields[4] as String?,
      status: fields[5] as InvitationStatus,
      createdAt: fields[6] as DateTime,
      respondedAt: fields[7] as DateTime?,
      message: fields[8] as String?,
      type: fields[9] as InvitationType,
    );
  }

  @override
  void write(BinaryWriter writer, GroupInvitation obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.invitedBy)
      ..writeByte(3)
      ..write(obj.inviteeId)
      ..writeByte(4)
      ..write(obj.inviteeEmail)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.respondedAt)
      ..writeByte(8)
      ..write(obj.message)
      ..writeByte(9)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupInvitationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ModerationSettingsAdapter extends TypeAdapter<ModerationSettings> {
  @override
  final int typeId = 27;

  @override
  ModerationSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ModerationSettings(
      moderatorIds: (fields[0] as List).cast<String>(),
      enableWordFilter: fields[1] as bool,
      blockedWords: (fields[2] as List).cast<String>(),
      requireMessageApproval: fields[3] as bool,
      allowParticipantMuting: fields[4] as bool,
      allowParticipantRemoval: fields[5] as bool,
      participantActions: (fields[6] as Map).cast<String, ModerationAction>(),
      logs: (fields[7] as List).cast<ModerationLog>(),
    );
  }

  @override
  void write(BinaryWriter writer, ModerationSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.moderatorIds)
      ..writeByte(1)
      ..write(obj.enableWordFilter)
      ..writeByte(2)
      ..write(obj.blockedWords)
      ..writeByte(3)
      ..write(obj.requireMessageApproval)
      ..writeByte(4)
      ..write(obj.allowParticipantMuting)
      ..writeByte(5)
      ..write(obj.allowParticipantRemoval)
      ..writeByte(6)
      ..write(obj.participantActions)
      ..writeByte(7)
      ..write(obj.logs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ModerationActionAdapter extends TypeAdapter<ModerationAction> {
  @override
  final int typeId = 28;

  @override
  ModerationAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ModerationAction(
      participantId: fields[0] as String,
      type: fields[1] as ModerationType,
      reason: fields[2] as String,
      timestamp: fields[3] as DateTime,
      moderatorId: fields[4] as String,
      duration: fields[5] as Duration?,
    );
  }

  @override
  void write(BinaryWriter writer, ModerationAction obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.participantId)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.reason)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.moderatorId)
      ..writeByte(5)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationActionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ModerationLogAdapter extends TypeAdapter<ModerationLog> {
  @override
  final int typeId = 29;

  @override
  ModerationLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ModerationLog(
      id: fields[0] as String,
      action: fields[1] as String,
      details: fields[2] as String,
      timestamp: fields[3] as DateTime,
      performedBy: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ModerationLog obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.action)
      ..writeByte(2)
      ..write(obj.details)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.performedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 30;

  @override
  Achievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Achievement(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      iconUrl: fields[3] as String,
      earnedAt: fields[4] as DateTime,
      points: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconUrl)
      ..writeByte(4)
      ..write(obj.earnedAt)
      ..writeByte(5)
      ..write(obj.points);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GroupAchievementAdapter extends TypeAdapter<GroupAchievement> {
  @override
  final int typeId = 31;

  @override
  GroupAchievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupAchievement(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      earnedAt: fields[3] as DateTime,
      contributorIds: (fields[4] as List).cast<String>(),
      groupPoints: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GroupAchievement obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.earnedAt)
      ..writeByte(4)
      ..write(obj.contributorIds)
      ..writeByte(5)
      ..write(obj.groupPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupAchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CollaborativeMilestoneAdapter
    extends TypeAdapter<CollaborativeMilestone> {
  @override
  final int typeId = 32;

  @override
  CollaborativeMilestone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CollaborativeMilestone(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      isReached: fields[3] as bool,
      reachedAt: fields[4] as DateTime?,
      progress: fields[5] as double,
      participantContributions: (fields[6] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, CollaborativeMilestone obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isReached)
      ..writeByte(4)
      ..write(obj.reachedAt)
      ..writeByte(5)
      ..write(obj.progress)
      ..writeByte(6)
      ..write(obj.participantContributions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollaborativeMilestoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnhancedGroupSession _$EnhancedGroupSessionFromJson(
        Map<String, dynamic> json) =>
    EnhancedGroupSession(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      ownerId: json['ownerId'] as String,
      participantIds: (json['participantIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      participants: (json['participants'] as List<dynamic>)
          .map((e) => GroupParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
      helpyParticipants: (json['helpyParticipants'] as List<dynamic>)
          .map((e) => HelpyPersonality.fromJson(e as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: $enumDecode(_$GroupSessionStatusEnumMap, json['status']),
      settings: GroupSessionSettings.fromJson(
          json['settings'] as Map<String, dynamic>),
      progress: GroupLearningProgress.fromJson(
          json['progress'] as Map<String, dynamic>),
      invitations: (json['invitations'] as List<dynamic>)
          .map((e) => GroupInvitation.fromJson(e as Map<String, dynamic>))
          .toList(),
      moderation: ModerationSettings.fromJson(
          json['moderation'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$EnhancedGroupSessionToJson(
        EnhancedGroupSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'ownerId': instance.ownerId,
      'participantIds': instance.participantIds,
      'participants': instance.participants,
      'helpyParticipants': instance.helpyParticipants,
      'messages': instance.messages,
      'status': _$GroupSessionStatusEnumMap[instance.status]!,
      'settings': instance.settings,
      'progress': instance.progress,
      'invitations': instance.invitations,
      'moderation': instance.moderation,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$GroupSessionStatusEnumMap = {
  GroupSessionStatus.active: 'active',
  GroupSessionStatus.paused: 'paused',
  GroupSessionStatus.completed: 'completed',
  GroupSessionStatus.cancelled: 'cancelled',
};

GroupParticipant _$GroupParticipantFromJson(Map<String, dynamic> json) =>
    GroupParticipant(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      role: $enumDecode(_$ParticipantRoleEnumMap, json['role']),
      status: $enumDecode(_$ParticipantStatusEnumMap, json['status']),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
      progress: ParticipantProgress.fromJson(
          json['progress'] as Map<String, dynamic>),
      participationScore: (json['participationScore'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$GroupParticipantToJson(GroupParticipant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'role': _$ParticipantRoleEnumMap[instance.role]!,
      'status': _$ParticipantStatusEnumMap[instance.status]!,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
      'progress': instance.progress,
      'participationScore': instance.participationScore,
      'metadata': instance.metadata,
    };

const _$ParticipantRoleEnumMap = {
  ParticipantRole.owner: 'owner',
  ParticipantRole.moderator: 'moderator',
  ParticipantRole.member: 'member',
  ParticipantRole.observer: 'observer',
  ParticipantRole.helper: 'helper',
};

const _$ParticipantStatusEnumMap = {
  ParticipantStatus.active: 'active',
  ParticipantStatus.inactive: 'inactive',
  ParticipantStatus.left: 'left',
  ParticipantStatus.disconnected: 'disconnected',
};

ParticipantProgress _$ParticipantProgressFromJson(Map<String, dynamic> json) =>
    ParticipantProgress(
      messagesContributed: (json['messagesContributed'] as num).toInt(),
      questionsAsked: (json['questionsAsked'] as num).toInt(),
      questionsAnswered: (json['questionsAnswered'] as num).toInt(),
      engagementScore: (json['engagementScore'] as num).toDouble(),
      topicsEngaged: (json['topicsEngaged'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      skillPoints: Map<String, int>.from(json['skillPoints'] as Map),
      achievements: (json['achievements'] as List<dynamic>)
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ParticipantProgressToJson(
        ParticipantProgress instance) =>
    <String, dynamic>{
      'messagesContributed': instance.messagesContributed,
      'questionsAsked': instance.questionsAsked,
      'questionsAnswered': instance.questionsAnswered,
      'engagementScore': instance.engagementScore,
      'topicsEngaged': instance.topicsEngaged,
      'skillPoints': instance.skillPoints,
      'achievements': instance.achievements,
    };

GroupSessionSettings _$GroupSessionSettingsFromJson(
        Map<String, dynamic> json) =>
    GroupSessionSettings(
      maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 10,
      isPublic: json['isPublic'] as bool? ?? false,
      allowGuestAccess: json['allowGuestAccess'] as bool? ?? false,
      requireApproval: json['requireApproval'] as bool? ?? true,
      mode: $enumDecodeNullable(_$SessionModeEnumMap, json['mode']) ??
          SessionMode.collaborative,
      subject: json['subject'] as String?,
      topic: json['topic'] as String?,
      difficulty:
          $enumDecodeNullable(_$DifficultyLevelEnumMap, json['difficulty']) ??
              DifficultyLevel.intermediate,
      sessionDuration: json['sessionDuration'] == null
          ? null
          : Duration(microseconds: (json['sessionDuration'] as num).toInt()),
      features: (json['features'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
    );

Map<String, dynamic> _$GroupSessionSettingsToJson(
        GroupSessionSettings instance) =>
    <String, dynamic>{
      'maxParticipants': instance.maxParticipants,
      'isPublic': instance.isPublic,
      'allowGuestAccess': instance.allowGuestAccess,
      'requireApproval': instance.requireApproval,
      'mode': _$SessionModeEnumMap[instance.mode]!,
      'subject': instance.subject,
      'topic': instance.topic,
      'difficulty': _$DifficultyLevelEnumMap[instance.difficulty]!,
      'sessionDuration': instance.sessionDuration?.inMicroseconds,
      'features': instance.features,
    };

const _$SessionModeEnumMap = {
  SessionMode.collaborative: 'collaborative',
  SessionMode.tutoring: 'tutoring',
  SessionMode.peerLearning: 'peerLearning',
  SessionMode.competition: 'competition',
  SessionMode.presentation: 'presentation',
};

const _$DifficultyLevelEnumMap = {
  DifficultyLevel.beginner: 'beginner',
  DifficultyLevel.intermediate: 'intermediate',
  DifficultyLevel.advanced: 'advanced',
  DifficultyLevel.expert: 'expert',
};

GroupLearningProgress _$GroupLearningProgressFromJson(
        Map<String, dynamic> json) =>
    GroupLearningProgress(
      sessionId: json['sessionId'] as String,
      topicCoverage: (json['topicCoverage'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      objectives: (json['objectives'] as List<dynamic>)
          .map((e) => LearningObjective.fromJson(e as Map<String, dynamic>))
          .toList(),
      skillPointsEarned:
          Map<String, int>.from(json['skillPointsEarned'] as Map),
      achievements: (json['achievements'] as List<dynamic>)
          .map((e) => GroupAchievement.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallProgress: (json['overallProgress'] as num).toDouble(),
      participantContributions:
          (json['participantContributions'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      milestones: (json['milestones'] as List<dynamic>)
          .map(
              (e) => CollaborativeMilestone.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GroupLearningProgressToJson(
        GroupLearningProgress instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'topicCoverage': instance.topicCoverage,
      'objectives': instance.objectives,
      'skillPointsEarned': instance.skillPointsEarned,
      'achievements': instance.achievements,
      'overallProgress': instance.overallProgress,
      'participantContributions': instance.participantContributions,
      'milestones': instance.milestones,
    };

LearningObjective _$LearningObjectiveFromJson(Map<String, dynamic> json) =>
    LearningObjective(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      completedBy: (json['completedBy'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$LearningObjectiveToJson(LearningObjective instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
      'completedBy': instance.completedBy,
    };

GroupInvitation _$GroupInvitationFromJson(Map<String, dynamic> json) =>
    GroupInvitation(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      invitedBy: json['invitedBy'] as String,
      inviteeId: json['inviteeId'] as String,
      inviteeEmail: json['inviteeEmail'] as String?,
      status: $enumDecode(_$InvitationStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
      message: json['message'] as String?,
      type: $enumDecode(_$InvitationTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$GroupInvitationToJson(GroupInvitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'invitedBy': instance.invitedBy,
      'inviteeId': instance.inviteeId,
      'inviteeEmail': instance.inviteeEmail,
      'status': _$InvitationStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'respondedAt': instance.respondedAt?.toIso8601String(),
      'message': instance.message,
      'type': _$InvitationTypeEnumMap[instance.type]!,
    };

const _$InvitationStatusEnumMap = {
  InvitationStatus.pending: 'pending',
  InvitationStatus.accepted: 'accepted',
  InvitationStatus.declined: 'declined',
  InvitationStatus.expired: 'expired',
  InvitationStatus.cancelled: 'cancelled',
};

const _$InvitationTypeEnumMap = {
  InvitationType.direct: 'direct',
  InvitationType.link: 'link',
  InvitationType.email: 'email',
  InvitationType.qrCode: 'qrCode',
};

ModerationSettings _$ModerationSettingsFromJson(Map<String, dynamic> json) =>
    ModerationSettings(
      moderatorIds: (json['moderatorIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      enableWordFilter: json['enableWordFilter'] as bool? ?? false,
      blockedWords: (json['blockedWords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      requireMessageApproval: json['requireMessageApproval'] as bool? ?? false,
      allowParticipantMuting: json['allowParticipantMuting'] as bool? ?? true,
      allowParticipantRemoval: json['allowParticipantRemoval'] as bool? ?? true,
      participantActions:
          (json['participantActions'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(
                    k, ModerationAction.fromJson(e as Map<String, dynamic>)),
              ) ??
              const {},
      logs: (json['logs'] as List<dynamic>?)
              ?.map((e) => ModerationLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ModerationSettingsToJson(ModerationSettings instance) =>
    <String, dynamic>{
      'moderatorIds': instance.moderatorIds,
      'enableWordFilter': instance.enableWordFilter,
      'blockedWords': instance.blockedWords,
      'requireMessageApproval': instance.requireMessageApproval,
      'allowParticipantMuting': instance.allowParticipantMuting,
      'allowParticipantRemoval': instance.allowParticipantRemoval,
      'participantActions': instance.participantActions,
      'logs': instance.logs,
    };

ModerationAction _$ModerationActionFromJson(Map<String, dynamic> json) =>
    ModerationAction(
      participantId: json['participantId'] as String,
      type: $enumDecode(_$ModerationTypeEnumMap, json['type']),
      reason: json['reason'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      moderatorId: json['moderatorId'] as String,
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: (json['duration'] as num).toInt()),
    );

Map<String, dynamic> _$ModerationActionToJson(ModerationAction instance) =>
    <String, dynamic>{
      'participantId': instance.participantId,
      'type': _$ModerationTypeEnumMap[instance.type]!,
      'reason': instance.reason,
      'timestamp': instance.timestamp.toIso8601String(),
      'moderatorId': instance.moderatorId,
      'duration': instance.duration?.inMicroseconds,
    };

const _$ModerationTypeEnumMap = {
  ModerationType.mute: 'mute',
  ModerationType.unmute: 'unmute',
  ModerationType.kick: 'kick',
  ModerationType.ban: 'ban',
  ModerationType.warn: 'warn',
  ModerationType.promote: 'promote',
  ModerationType.demote: 'demote',
};

ModerationLog _$ModerationLogFromJson(Map<String, dynamic> json) =>
    ModerationLog(
      id: json['id'] as String,
      action: json['action'] as String,
      details: json['details'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      performedBy: json['performedBy'] as String,
    );

Map<String, dynamic> _$ModerationLogToJson(ModerationLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'action': instance.action,
      'details': instance.details,
      'timestamp': instance.timestamp.toIso8601String(),
      'performedBy': instance.performedBy,
    };

Achievement _$AchievementFromJson(Map<String, dynamic> json) => Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      points: (json['points'] as num).toInt(),
    );

Map<String, dynamic> _$AchievementToJson(Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'earnedAt': instance.earnedAt.toIso8601String(),
      'points': instance.points,
    };

GroupAchievement _$GroupAchievementFromJson(Map<String, dynamic> json) =>
    GroupAchievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      contributorIds: (json['contributorIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      groupPoints: (json['groupPoints'] as num).toInt(),
    );

Map<String, dynamic> _$GroupAchievementToJson(GroupAchievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'earnedAt': instance.earnedAt.toIso8601String(),
      'contributorIds': instance.contributorIds,
      'groupPoints': instance.groupPoints,
    };

CollaborativeMilestone _$CollaborativeMilestoneFromJson(
        Map<String, dynamic> json) =>
    CollaborativeMilestone(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isReached: json['isReached'] as bool,
      reachedAt: json['reachedAt'] == null
          ? null
          : DateTime.parse(json['reachedAt'] as String),
      progress: (json['progress'] as num).toDouble(),
      participantContributions:
          (json['participantContributions'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$CollaborativeMilestoneToJson(
        CollaborativeMilestone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'isReached': instance.isReached,
      'reachedAt': instance.reachedAt?.toIso8601String(),
      'progress': instance.progress,
      'participantContributions': instance.participantContributions,
    };
