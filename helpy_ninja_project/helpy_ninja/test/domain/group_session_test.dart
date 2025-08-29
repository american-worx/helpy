import 'package:flutter_test/flutter_test.dart';
import 'package:helpy_ninja/domain/entities/helpy_personality.dart';
import 'package:helpy_ninja/domain/entities/message.dart';
import 'package:helpy_ninja/domain/entities/shared_enums.dart';

// Import GroupSession from its file but avoid importing the duplicate enums
import 'package:helpy_ninja/domain/entities/group_session.dart'
    show GroupSession;

void main() {
  group('GroupSession Tests', () {
    late GroupSession groupSession;
    late HelpyPersonality testHelpy;
    late Message testMessage;

    setUp(() {
      testHelpy = HelpyPersonality(
        id: 'helpy_001',
        name: 'Test Helpy',
        description: 'A test Helpy personality',
        avatar: 'test_avatar.png',
        type: PersonalityType.friendly,
        traits: PersonalityTraits(
          enthusiasm: 0.8,
          patience: 0.7,
          humor: 0.6,
          formality: 0.5,
          empathy: 0.7,
          directness: 0.6,
        ),
        responseStyle: ResponseStyle(
          length: ResponseLength.medium,
          tone: ResponseTone.neutral,
          useEmojis: true,
          useExamples: true,
          askFollowUpQuestions: true,
          maxResponseLength: 500,
        ),
        specializations: ['math', 'science'],
        createdAt: DateTime.now(),
      );

      testMessage = Message(
        id: 'msg_001',
        conversationId: 'session_001',
        senderId: 'user_001',
        senderName: 'Test User',
        content: 'Hello, group!',
        type: MessageType.text,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
      );

      groupSession = GroupSession(
        id: 'session_001',
        name: 'Test Group Session',
        ownerId: 'user_001',
        participantIds: ['user_001', 'user_002'],
        helpyParticipants: [testHelpy],
        messages: [testMessage],
        status: GroupSessionStatus.active,
        createdAt: DateTime.now(),
        settings: {'maxParticipants': 10},
        participantStatuses: {
          'user_001': ParticipantStatus.active,
          'user_002': ParticipantStatus.inactive,
        },
      );
    });

    test('should create GroupSession with valid data', () {
      expect(groupSession.id, 'session_001');
      expect(groupSession.name, 'Test Group Session');
      expect(groupSession.ownerId, 'user_001');
      expect(groupSession.participantIds, ['user_001', 'user_002']);
      expect(groupSession.helpyParticipants, [testHelpy]);
      expect(groupSession.messages, [testMessage]);
      expect(groupSession.status, GroupSessionStatus.active);
      expect(groupSession.settings, {'maxParticipants': 10});
      expect(groupSession.participantStatuses, {
        'user_001': ParticipantStatus.active,
        'user_002': ParticipantStatus.inactive,
      });
    });

    test('should correctly identify owner', () {
      expect(groupSession.isOwner('user_001'), true);
      expect(groupSession.isOwner('user_002'), false);
    });

    test('should correctly identify participants', () {
      expect(groupSession.isParticipant('user_001'), true);
      expect(groupSession.isParticipant('user_002'), true);
      expect(groupSession.isParticipant('user_003'), false);
    });

    test('should return correct participant count', () {
      expect(groupSession.participantCount, 2);
    });

    test('should return correct Helpy count', () {
      expect(groupSession.helpyCount, 1);
    });

    test('should return active participants', () {
      expect(groupSession.activeParticipants, ['user_001']);
    });

    test('should return recent messages', () {
      final recentMessages = groupSession.getRecentMessages(1);
      expect(recentMessages.length, 1);
      expect(recentMessages.first, testMessage);
    });

    test('should convert to and from JSON', () {
      final json = groupSession.toJson();
      expect(json['id'], 'session_001');
      expect(json['name'], 'Test Group Session');
      expect(json['ownerId'], 'user_001');
      expect(json['status'], 'active');
      expect(json['settings'], {'maxParticipants': 10});

      final fromJson = GroupSession.fromJson(json);
      expect(fromJson.id, groupSession.id);
      expect(fromJson.name, groupSession.name);
      expect(fromJson.ownerId, groupSession.ownerId);
      expect(fromJson.status, groupSession.status);
      expect(fromJson.settings, groupSession.settings);
    });

    test('should create copy with updated properties', () {
      final updatedSession = groupSession.copyWith(
        name: 'Updated Group Session',
        status: GroupSessionStatus.completed,
      );

      expect(updatedSession.id, groupSession.id); // unchanged
      expect(updatedSession.name, 'Updated Group Session'); // updated
      expect(updatedSession.status, GroupSessionStatus.completed); // updated
      expect(updatedSession.ownerId, groupSession.ownerId); // unchanged
    });

    test('should compare GroupSessions correctly', () {
      final session1 = groupSession;
      final session2 = groupSession.copyWith(); // Creates a copy with same id
      final session3 = groupSession.copyWith(id: 'session_002');

      expect(session1, equals(session2));
      expect(session1, isNot(equals(session3)));
    });
  });

  group('GroupSessionStatus Tests', () {
    test('should have all expected values', () {
      expect(GroupSessionStatus.values.length, 4);
      expect(GroupSessionStatus.values, contains(GroupSessionStatus.active));
      expect(GroupSessionStatus.values, contains(GroupSessionStatus.paused));
      expect(GroupSessionStatus.values, contains(GroupSessionStatus.completed));
      expect(GroupSessionStatus.values, contains(GroupSessionStatus.cancelled));
    });
  });

  group('ParticipantStatus Tests', () {
    test('should have all expected values', () {
      expect(ParticipantStatus.values.length, 4);
      expect(ParticipantStatus.values, contains(ParticipantStatus.active));
      expect(ParticipantStatus.values, contains(ParticipantStatus.inactive));
      expect(ParticipantStatus.values, contains(ParticipantStatus.left));
      expect(
          ParticipantStatus.values, contains(ParticipantStatus.disconnected));
    });
  });
}
