import 'package:helpy_ninja/domain/entities/helpy_personality.dart';
import 'package:helpy_ninja/domain/entities/message.dart';
import 'package:helpy_ninja/domain/entities/shared_enums.dart';
import 'package:helpy_ninja/domain/entities/user.dart';

/// Group session entity representing a multi-agent chat session
class GroupSession {
  final String id;
  final String name;
  final String ownerId;
  final List<String> participantIds;
  final List<HelpyPersonality> helpyParticipants;
  final List<Message> messages;
  final GroupSessionStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final Map<String, dynamic> settings;
  final Map<String, ParticipantStatus> participantStatuses;

  const GroupSession({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.participantIds,
    required this.helpyParticipants,
    required this.messages,
    this.status = GroupSessionStatus.active,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.settings = const {},
    this.participantStatuses = const {},
  });

  GroupSession copyWith({
    String? id,
    String? name,
    String? ownerId,
    List<String>? participantIds,
    List<HelpyPersonality>? helpyParticipants,
    List<Message>? messages,
    GroupSessionStatus? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
    Map<String, dynamic>? settings,
    Map<String, ParticipantStatus>? participantStatuses,
  }) {
    return GroupSession(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      participantIds: participantIds ?? this.participantIds,
      helpyParticipants: helpyParticipants ?? this.helpyParticipants,
      messages: messages ?? this.messages,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      settings: settings ?? this.settings,
      participantStatuses: participantStatuses ?? this.participantStatuses,
    );
  }

  /// Check if a user is the owner of the session
  bool isOwner(String userId) => ownerId == userId;

  /// Check if a user is a participant
  bool isParticipant(String userId) => participantIds.contains(userId);

  /// Get the number of participants
  int get participantCount => participantIds.length;

  /// Get the number of Helpy participants
  int get helpyCount => helpyParticipants.length;

  /// Get active participants
  List<String> get activeParticipants {
    return participantStatuses.entries
        .where((entry) => entry.value == ParticipantStatus.active)
        .map((entry) => entry.key)
        .toList();
  }

  /// Get the most recent messages
  List<Message> getRecentMessages(int count) {
    if (messages.length <= count) return messages;
    return messages.sublist(messages.length - count);
  }

  /// Convert to JSON for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'participantIds': participantIds,
      'helpyParticipants': helpyParticipants.map((h) => h.toJson()).toList(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'settings': settings,
      'participantStatuses': participantStatuses.map(
        (key, value) => MapEntry(key, value.name),
      ),
    };
  }

  /// Create from JSON
  factory GroupSession.fromJson(Map<String, dynamic> json) {
    return GroupSession(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      ownerId: json['ownerId'] ?? '',
      participantIds: List<String>.from(json['participantIds'] ?? []),
      helpyParticipants: (json['helpyParticipants'] as List)
          .map((h) => HelpyPersonality.fromJson(h))
          .toList(),
      messages:
          (json['messages'] as List).map((m) => Message.fromJson(m)).toList(),
      status: GroupSessionStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => GroupSessionStatus.active,
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      startedAt:
          json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      participantStatuses: (json['participantStatuses'] as Map).map(
        (key, value) => MapEntry(
          key,
          ParticipantStatus.values.firstWhere(
            (status) => status.name == value,
            orElse: () => ParticipantStatus.active,
          ),
        ),
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'GroupSession(id: $id, name: $name, participants: ${participantIds.length}, helpys: ${helpyParticipants.length})';
  }
}
