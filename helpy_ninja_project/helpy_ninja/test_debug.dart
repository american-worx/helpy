import 'package:helpy_ninja/services/multi_agent_coordinator.dart';
import 'package:helpy_ninja/domain/entities/group_session.dart';
import 'package:helpy_ninja/domain/entities/helpy_personality.dart';
import 'package:helpy_ninja/domain/entities/shared_enums.dart';

void main() async {
  final coordinator = MultiAgentCoordinator();

  final helpy1 = HelpyPersonality(
    id: 'helpy_001',
    name: 'Helpy One',
    description: 'First test Helpy',
    avatar: 'avatar1.png',
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

  final helpy2 = HelpyPersonality(
    id: 'helpy_002',
    name: 'Helpy Two',
    description: 'Second test Helpy',
    avatar: 'avatar2.png',
    type: PersonalityType.professional,
    traits: PersonalityTraits(
      enthusiasm: 0.6,
      patience: 0.8,
      humor: 0.3,
      formality: 0.9,
      empathy: 0.7,
      directness: 0.8,
    ),
    responseStyle: ResponseStyle(
      length: ResponseLength.long,
      tone: ResponseTone.formal,
      useEmojis: false,
      useExamples: true,
      askFollowUpQuestions: false,
      maxResponseLength: 800,
    ),
    specializations: ['literature', 'history'],
    createdAt: DateTime.now(),
  );

  final testSession = GroupSession(
    id: 'session_001',
    name: 'Test Session',
    ownerId: 'user_001',
    participantIds: ['user_001', 'user_002'],
    helpyParticipants: [helpy1, helpy2],
    messages: const [],
    status: GroupSessionStatus.active,
    createdAt: DateTime.now(),
    settings: {},
    participantStatuses: {
      'user_001': ParticipantStatus.active,
      'user_002': ParticipantStatus.active,
    },
  );

  coordinator.addSession(testSession);

  print('Testing first Helpy request...');
  final permission1 = await coordinator.requestResponsePermission(
    'session_001',
    'helpy_001',
    'Test message 1',
  );
  print('First permission: $permission1');

  final status1 = coordinator.getSessionStatus('session_001');
  print('Status after first request: $status1');

  print('Testing second Helpy request...');
  final permission2 = await coordinator.requestResponsePermission(
    'session_001',
    'helpy_002',
    'Test message 2',
  );
  print('Second permission: $permission2');

  final status2 = coordinator.getSessionStatus('session_001');
  print('Status after second request: $status2');
}
