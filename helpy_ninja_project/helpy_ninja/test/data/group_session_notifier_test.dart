import 'package:flutter_test/flutter_test.dart';
import 'package:helpy_ninja/data/providers/group_session_notifier.dart';
import 'package:helpy_ninja/data/providers/group_session_state.dart';
import 'package:helpy_ninja/domain/entities/group_session.dart';
import 'package:helpy_ninja/domain/entities/helpy_personality.dart';

import 'package:mockito/annotations.dart';
import '../helpers/test_helpers.dart';

// Generate mocks
@GenerateMocks([])
void main() {
  group('GroupSessionNotifier Tests', () {
    late GroupSessionNotifier notifier;
    late HelpyPersonality testHelpy;

    setUp(() async {
      // Setup test environment
      await TestHelpers.setupTestEnvironment();

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
    });

    tearDown(() async {
      await TestHelpers.tearDownTestEnvironment();
    });

    test('should initialize with default state', () async {
      notifier = GroupSessionNotifier();

      // Wait for initialization to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, const TypeMatcher<GroupSessionState>());
      expect(notifier.state.sessions, isEmpty);
      expect(notifier.state.currentSession, isNull);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.isInitialized,
          true); // Should be true after initialization
      expect(notifier.state.error, isNull);
    });

    test('should create a new group session', () async {
      notifier = GroupSessionNotifier();

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      final session = await notifier.createSession(
        name: 'Test Session',
        ownerId: 'user_001',
        participantIds: ['user_001', 'user_002'],
        helpyParticipants: [testHelpy],
      );

      expect(session, isA<GroupSession>());
      expect(session.name, 'Test Session');
      expect(session.ownerId, 'user_001');
      expect(session.participantIds, ['user_001', 'user_002']);
      expect(session.helpyParticipants, [testHelpy]);

      // Check that state was updated
      expect(notifier.state.sessions, isNotEmpty);
      expect(notifier.state.currentSession, isNotNull);
      expect(notifier.state.currentSession!.id, session.id);
    });

    test('should join an existing group session', () async {
      notifier = GroupSessionNotifier();

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // First create a session
      final session = await notifier.createSession(
        name: 'Test Session',
        ownerId: 'user_001',
        participantIds: ['user_001', 'user_002'],
        helpyParticipants: [testHelpy],
      );

      // Then join it (this is a simplified test - in reality,
      // joining would involve a different user)
      await notifier.joinSession(session.id);

      // Verify state was updated
      expect(notifier.state.error, isNull);
      expect(notifier.state.currentSession, isNotNull);
      expect(notifier.state.currentSession!.id, session.id);
    });

    test('should leave a group session', () async {
      notifier = GroupSessionNotifier();

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // First create a session
      final session = await notifier.createSession(
        name: 'Test Session',
        ownerId: 'user_001',
        participantIds: ['user_001', 'user_002'],
        helpyParticipants: [testHelpy],
      );

      // Then leave it
      await notifier.leaveSession(session.id);

      // Verify state was updated
      expect(notifier.state.error, isNull);
    });

    test('should send a message to a group session', () async {
      notifier = GroupSessionNotifier();

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // First create a session
      final session = await notifier.createSession(
        name: 'Test Session',
        ownerId: 'user_001',
        participantIds: ['user_001', 'user_002'],
        helpyParticipants: [testHelpy],
      );

      // Then send a message
      await notifier.sendMessage(
        sessionId: session.id,
        senderId: 'user_001',
        senderName: 'Test User',
        content: 'Hello, group!',
      );

      // Verify message was sent
      expect(notifier.state.error, isNull);
    });

    test('should update session settings', () async {
      notifier = GroupSessionNotifier();

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // First create a session
      final session = await notifier.createSession(
        name: 'Test Session',
        ownerId: 'user_001',
        participantIds: ['user_001', 'user_002'],
        helpyParticipants: [testHelpy],
      );

      // Then update settings
      final newSettings = {'maxParticipants': 20, 'allowHelpys': true};
      await notifier.updateSessionSettings(session.id, newSettings);

      // Verify settings were updated
      expect(notifier.state.error, isNull);
      expect(notifier.state.currentSession!.settings, newSettings);
    });

    test('should clear error state', () async {
      notifier = GroupSessionNotifier();

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // Trigger an error by trying to join a non-existent session
      try {
        await notifier.joinSession('non-existent-session-id');
      } catch (e) {
        // Expected to catch an exception
      }

      // Verify that an error was set
      // Wait a bit for the state to update after the exception
      await Future.delayed(const Duration(milliseconds: 10));
      expect(notifier.state.error, isNotNull);

      // Clear error
      notifier.clearError();
      // Wait a bit for the state to update
      await Future.delayed(const Duration(milliseconds: 50)); // Increased delay

      // Check the state directly
      final errorAfterClear = notifier.state.error;
      expect(errorAfterClear, isNull);
    });

    test('should refresh group session data', () async {
      notifier = GroupSessionNotifier();

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // Create a session
      await notifier.createSession(
        name: 'Test Session',
        ownerId: 'user_001',
        participantIds: ['user_001'],
        helpyParticipants: [testHelpy],
      );

      // Refresh
      await notifier.refresh();

      // Verify refresh completed
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
    });
  });
}
