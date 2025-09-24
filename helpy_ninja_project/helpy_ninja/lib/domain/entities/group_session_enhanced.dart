import 'package:hive/hive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'message.dart';
import 'helpy_personality.dart';
import 'shared_enums.dart';

part 'group_session_enhanced.g.dart';

/// Enhanced group session with advanced features
@HiveType(typeId: 20)
@JsonSerializable()
class EnhancedGroupSession {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String ownerId;

  @HiveField(4)
  final List<String> participantIds;

  @HiveField(5)
  final List<GroupParticipant> participants;

  @HiveField(6)
  final List<HelpyPersonality> helpyParticipants;

  @HiveField(7)
  final List<Message> messages;

  @HiveField(8)
  final GroupSessionStatus status;

  @HiveField(9)
  final GroupSessionSettings settings;

  @HiveField(10)
  final GroupLearningProgress progress;

  @HiveField(11)
  final List<GroupInvitation> invitations;

  @HiveField(12)
  final ModerationSettings moderation;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  @HiveField(15)
  final Map<String, dynamic> metadata;

  const EnhancedGroupSession({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.participantIds,
    required this.participants,
    required this.helpyParticipants,
    required this.messages,
    required this.status,
    required this.settings,
    required this.progress,
    required this.invitations,
    required this.moderation,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => _$EnhancedGroupSessionToJson(this);
  factory EnhancedGroupSession.fromJson(Map<String, dynamic> json) =>
      _$EnhancedGroupSessionFromJson(json);

  /// Get active participants
  List<GroupParticipant> get activeParticipants =>
      participants.where((p) => p.status == ParticipantStatus.active).toList();

  /// Get pending invitations
  List<GroupInvitation> get pendingInvitations =>
      invitations.where((i) => i.status == InvitationStatus.pending).toList();

  /// Check if user is moderator
  bool isUserModerator(String userId) {
    return moderation.moderatorIds.contains(userId) || userId == ownerId;
  }

  /// Get session duration
  Duration get sessionDuration => updatedAt.difference(createdAt);

  /// Calculate average participation score
  double get averageParticipationScore {
    if (participants.isEmpty) return 0.0;
    final total = participants.fold<double>(
      0.0,
      (sum, p) => sum + p.participationScore,
    );
    return total / participants.length;
  }
}

/// Individual participant in a group session
@HiveType(typeId: 21)
@JsonSerializable()
class GroupParticipant {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? avatarUrl;

  @HiveField(3)
  final ParticipantRole role;

  @HiveField(4)
  final ParticipantStatus status;

  @HiveField(5)
  final DateTime joinedAt;

  @HiveField(6)
  final DateTime? lastActiveAt;

  @HiveField(7)
  final ParticipantProgress progress;

  @HiveField(8)
  final double participationScore;

  @HiveField(9)
  final Map<String, dynamic> metadata;

  const GroupParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.lastActiveAt,
    required this.progress,
    required this.participationScore,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => _$GroupParticipantToJson(this);
  factory GroupParticipant.fromJson(Map<String, dynamic> json) =>
      _$GroupParticipantFromJson(json);

  /// Check if participant is online (active within last 5 minutes)
  bool get isOnline {
    if (lastActiveAt == null) return false;
    return DateTime.now().difference(lastActiveAt!).inMinutes < 5;
  }
}

/// Participant role in group session
enum ParticipantRole {
  owner,
  moderator,
  member,
  observer,
  helper, // For AI assistants
}

/// Individual participant progress
@HiveType(typeId: 22)
@JsonSerializable()
class ParticipantProgress {
  @HiveField(0)
  final int messagesContributed;

  @HiveField(1)
  final int questionsAsked;

  @HiveField(2)
  final int questionsAnswered;

  @HiveField(3)
  final double engagementScore;

  @HiveField(4)
  final List<String> topicsEngaged;

  @HiveField(5)
  final Map<String, int> skillPoints;

  @HiveField(6)
  final List<Achievement> achievements;

  const ParticipantProgress({
    required this.messagesContributed,
    required this.questionsAsked,
    required this.questionsAnswered,
    required this.engagementScore,
    required this.topicsEngaged,
    required this.skillPoints,
    required this.achievements,
  });

  Map<String, dynamic> toJson() => _$ParticipantProgressToJson(this);
  factory ParticipantProgress.fromJson(Map<String, dynamic> json) =>
      _$ParticipantProgressFromJson(json);
}

/// Group session settings
@HiveType(typeId: 23)
@JsonSerializable()
class GroupSessionSettings {
  @HiveField(0)
  final int maxParticipants;

  @HiveField(1)
  final bool isPublic;

  @HiveField(2)
  final bool allowGuestAccess;

  @HiveField(3)
  final bool requireApproval;

  @HiveField(4)
  final SessionMode mode;

  @HiveField(5)
  final String? subject;

  @HiveField(6)
  final String? topic;

  @HiveField(7)
  final DifficultyLevel difficulty;

  @HiveField(8)
  final Duration? sessionDuration;

  @HiveField(9)
  final Map<String, bool> features;

  const GroupSessionSettings({
    this.maxParticipants = 10,
    this.isPublic = false,
    this.allowGuestAccess = false,
    this.requireApproval = true,
    this.mode = SessionMode.collaborative,
    this.subject,
    this.topic,
    this.difficulty = DifficultyLevel.intermediate,
    this.sessionDuration,
    this.features = const {},
  });

  Map<String, dynamic> toJson() => _$GroupSessionSettingsToJson(this);
  factory GroupSessionSettings.fromJson(Map<String, dynamic> json) =>
      _$GroupSessionSettingsFromJson(json);
}

/// Session mode types
enum SessionMode {
  collaborative, // All participants can contribute
  tutoring, // One-to-many teaching
  peerLearning, // Peer-to-peer learning
  competition, // Competitive learning
  presentation, // Presentation mode
}

/// Difficulty levels
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

/// Group learning progress tracking
@HiveType(typeId: 24)
@JsonSerializable()
class GroupLearningProgress {
  @HiveField(0)
  final String sessionId;

  @HiveField(1)
  final Map<String, double> topicCoverage;

  @HiveField(2)
  final List<LearningObjective> objectives;

  @HiveField(3)
  final Map<String, int> skillPointsEarned;

  @HiveField(4)
  final List<GroupAchievement> achievements;

  @HiveField(5)
  final double overallProgress;

  @HiveField(6)
  final Map<String, List<String>> participantContributions;

  @HiveField(7)
  final List<CollaborativeMilestone> milestones;

  const GroupLearningProgress({
    required this.sessionId,
    required this.topicCoverage,
    required this.objectives,
    required this.skillPointsEarned,
    required this.achievements,
    required this.overallProgress,
    required this.participantContributions,
    required this.milestones,
  });

  Map<String, dynamic> toJson() => _$GroupLearningProgressToJson(this);
  factory GroupLearningProgress.fromJson(Map<String, dynamic> json) =>
      _$GroupLearningProgressFromJson(json);

  /// Get completed objectives
  List<LearningObjective> get completedObjectives =>
      objectives.where((o) => o.isCompleted).toList();

  /// Calculate completion percentage
  double get completionPercentage {
    if (objectives.isEmpty) return 0.0;
    return (completedObjectives.length / objectives.length) * 100;
  }
}

/// Learning objective
@HiveType(typeId: 25)
@JsonSerializable()
class LearningObjective {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final bool isCompleted;

  @HiveField(4)
  final DateTime? completedAt;

  @HiveField(5)
  final List<String> completedBy;

  const LearningObjective({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    this.completedAt,
    required this.completedBy,
  });

  Map<String, dynamic> toJson() => _$LearningObjectiveToJson(this);
  factory LearningObjective.fromJson(Map<String, dynamic> json) =>
      _$LearningObjectiveFromJson(json);
}

/// Group invitation system
@HiveType(typeId: 26)
@JsonSerializable()
class GroupInvitation {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sessionId;

  @HiveField(2)
  final String invitedBy;

  @HiveField(3)
  final String inviteeId;

  @HiveField(4)
  final String? inviteeEmail;

  @HiveField(5)
  final InvitationStatus status;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? respondedAt;

  @HiveField(8)
  final String? message;

  @HiveField(9)
  final InvitationType type;

  const GroupInvitation({
    required this.id,
    required this.sessionId,
    required this.invitedBy,
    required this.inviteeId,
    this.inviteeEmail,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.message,
    required this.type,
  });

  Map<String, dynamic> toJson() => _$GroupInvitationToJson(this);
  factory GroupInvitation.fromJson(Map<String, dynamic> json) =>
      _$GroupInvitationFromJson(json);

  /// Check if invitation is expired (24 hours)
  bool get isExpired {
    return DateTime.now().difference(createdAt).inHours > 24;
  }
}

/// Invitation status
enum InvitationStatus {
  pending,
  accepted,
  declined,
  expired,
  cancelled,
}

/// Invitation type
enum InvitationType {
  direct, // Direct invitation to specific user
  link, // Shareable link invitation
  email, // Email invitation
  qrCode, // QR code invitation
}

/// Moderation settings for group session
@HiveType(typeId: 27)
@JsonSerializable()
class ModerationSettings {
  @HiveField(0)
  final List<String> moderatorIds;

  @HiveField(1)
  final bool enableWordFilter;

  @HiveField(2)
  final List<String> blockedWords;

  @HiveField(3)
  final bool requireMessageApproval;

  @HiveField(4)
  final bool allowParticipantMuting;

  @HiveField(5)
  final bool allowParticipantRemoval;

  @HiveField(6)
  final Map<String, ModerationAction> participantActions;

  @HiveField(7)
  final List<ModerationLog> logs;

  const ModerationSettings({
    required this.moderatorIds,
    this.enableWordFilter = false,
    this.blockedWords = const [],
    this.requireMessageApproval = false,
    this.allowParticipantMuting = true,
    this.allowParticipantRemoval = true,
    this.participantActions = const {},
    this.logs = const [],
  });

  Map<String, dynamic> toJson() => _$ModerationSettingsToJson(this);
  factory ModerationSettings.fromJson(Map<String, dynamic> json) =>
      _$ModerationSettingsFromJson(json);
}

/// Moderation action taken on a participant
@HiveType(typeId: 28)
@JsonSerializable()
class ModerationAction {
  @HiveField(0)
  final String participantId;

  @HiveField(1)
  final ModerationType type;

  @HiveField(2)
  final String reason;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String moderatorId;

  @HiveField(5)
  final Duration? duration;

  const ModerationAction({
    required this.participantId,
    required this.type,
    required this.reason,
    required this.timestamp,
    required this.moderatorId,
    this.duration,
  });

  Map<String, dynamic> toJson() => _$ModerationActionToJson(this);
  factory ModerationAction.fromJson(Map<String, dynamic> json) =>
      _$ModerationActionFromJson(json);
}

/// Type of moderation action
enum ModerationType {
  mute,
  unmute,
  kick,
  ban,
  warn,
  promote, // Promote to moderator
  demote, // Remove moderator status
}

/// Moderation log entry
@HiveType(typeId: 29)
@JsonSerializable()
class ModerationLog {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String action;

  @HiveField(2)
  final String details;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String performedBy;

  const ModerationLog({
    required this.id,
    required this.action,
    required this.details,
    required this.timestamp,
    required this.performedBy,
  });

  Map<String, dynamic> toJson() => _$ModerationLogToJson(this);
  factory ModerationLog.fromJson(Map<String, dynamic> json) =>
      _$ModerationLogFromJson(json);
}

/// Achievement for individual participants
@HiveType(typeId: 30)
@JsonSerializable()
class Achievement {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String iconUrl;

  @HiveField(4)
  final DateTime earnedAt;

  @HiveField(5)
  final int points;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.earnedAt,
    required this.points,
  });

  Map<String, dynamic> toJson() => _$AchievementToJson(this);
  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

/// Group achievement for collaborative efforts
@HiveType(typeId: 31)
@JsonSerializable()
class GroupAchievement {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime earnedAt;

  @HiveField(4)
  final List<String> contributorIds;

  @HiveField(5)
  final int groupPoints;

  const GroupAchievement({
    required this.id,
    required this.name,
    required this.description,
    required this.earnedAt,
    required this.contributorIds,
    required this.groupPoints,
  });

  Map<String, dynamic> toJson() => _$GroupAchievementToJson(this);
  factory GroupAchievement.fromJson(Map<String, dynamic> json) =>
      _$GroupAchievementFromJson(json);
}

/// Collaborative milestone
@HiveType(typeId: 32)
@JsonSerializable()
class CollaborativeMilestone {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final bool isReached;

  @HiveField(4)
  final DateTime? reachedAt;

  @HiveField(5)
  final double progress;

  @HiveField(6)
  final Map<String, double> participantContributions;

  const CollaborativeMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.isReached,
    this.reachedAt,
    required this.progress,
    required this.participantContributions,
  });

  Map<String, dynamic> toJson() => _$CollaborativeMilestoneToJson(this);
  factory CollaborativeMilestone.fromJson(Map<String, dynamic> json) =>
      _$CollaborativeMilestoneFromJson(json);
}