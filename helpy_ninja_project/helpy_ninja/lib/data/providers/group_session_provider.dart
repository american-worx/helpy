import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/group_session.dart';
import '../../domain/entities/message.dart';
import 'group_session_notifier.dart';
import 'group_session_state.dart';

/// Group session provider
final groupSessionProvider =
    StateNotifierProvider<GroupSessionNotifier, GroupSessionState>((ref) {
      return GroupSessionNotifier();
    });

/// Convenience providers

/// Provider for all group sessions
final groupSessionsProvider = Provider<List<GroupSession>>((ref) {
  return ref.watch(groupSessionProvider).sessions;
});

/// Provider for current group session
final currentGroupSessionProvider = Provider<GroupSession?>((ref) {
  return ref.watch(groupSessionProvider).currentSession;
});

/// Provider for messages in current group session
final currentGroupSessionMessagesProvider = Provider<List<Message>>((ref) {
  return ref.watch(groupSessionProvider).currentMessages;
});

/// Provider for group session loading state
final isGroupSessionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(groupSessionProvider).isLoading;
});

/// Provider for group session error state
final groupSessionErrorProvider = Provider<String?>((ref) {
  return ref.watch(groupSessionProvider).error;
});

/// Provider for group session readiness
final isGroupSessionReadyProvider = Provider<bool>((ref) {
  return ref.watch(groupSessionProvider).isReady;
});

/// Provider for active session count
final activeGroupSessionCountProvider = Provider<int>((ref) {
  return ref.watch(groupSessionProvider).activeSessionCount;
});

/// Provider for total participant count
final totalGroupParticipantCountProvider = Provider<int>((ref) {
  return ref.watch(groupSessionProvider).totalParticipantCount;
});

/// Provider for messages in a specific group session
final groupSessionMessagesProvider = Provider.family<List<Message>, String>((
  ref,
  sessionId,
) {
  final sessions = ref.watch(groupSessionsProvider);
  try {
    final session = sessions.firstWhere((s) => s.id == sessionId);
    return session.messages;
  } catch (e) {
    return [];
  }
});

/// Provider for a specific group session
final specificGroupSessionProvider = Provider.family<GroupSession?, String>((
  ref,
  sessionId,
) {
  final sessions = ref.watch(groupSessionsProvider);
  try {
    return sessions.firstWhere((s) => s.id == sessionId);
  } catch (e) {
    return null;
  }
});
