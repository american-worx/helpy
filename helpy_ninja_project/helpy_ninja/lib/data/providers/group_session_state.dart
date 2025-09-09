import 'package:helpy_ninja/domain/entities/group_session.dart';
import 'package:helpy_ninja/domain/entities/message.dart';
import 'package:helpy_ninja/domain/entities/shared_enums.dart';

/// Group session state model
class GroupSessionState {
  final List<GroupSession> sessions;
  final GroupSession? currentSession;
  final List<Message> currentMessages;
  final bool isLoading;
  final bool isInitialized;
  final String? error;
  final DateTime? lastUpdated;
  final Map<String, Map<String, DateTime>> typingIndicators;

  const GroupSessionState({
    this.sessions = const [],
    this.currentSession,
    this.currentMessages = const [],
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
    this.lastUpdated,
    this.typingIndicators = const {},
  });

  GroupSessionState copyWith({
    List<GroupSession>? sessions,
    GroupSession? currentSession,
    List<Message>? currentMessages,
    bool? isLoading,
    bool? isInitialized,
    String? error,
    DateTime? lastUpdated,
    Map<String, Map<String, DateTime>>? typingIndicators,
  }) {
    return GroupSessionState(
      sessions: sessions ?? this.sessions,
      currentSession: currentSession ?? this.currentSession,
      currentMessages: currentMessages ?? this.currentMessages,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      typingIndicators: typingIndicators ?? this.typingIndicators,
    );
  }

  /// Check if group session system is ready
  bool get isReady => isInitialized && !isLoading && error == null;

  /// Get total number of active sessions
  int get activeSessionCount {
    return sessions
        .where((session) => session.status == GroupSessionStatus.active)
        .length;
  }

  /// Get total number of participants across all sessions
  int get totalParticipantCount {
    return sessions.fold(0, (sum, session) => sum + session.participantCount);
  }

  /// Get typing users for a specific session
  List<String> getTypingUsers(String sessionId) {
    final sessionTyping = typingIndicators[sessionId] ?? {};
    // Filter out typing indicators older than 10 seconds
    final now = DateTime.now();
    return sessionTyping.entries
        .where((entry) => now.difference(entry.value).inSeconds < 10)
        .map((entry) => entry.key)
        .toList();
  }
}
