import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpy_ninja/domain/entities/shared_enums.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/group_session.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/helpy_personality.dart';
import '../../domain/entities/user.dart';
import '../../services/websocket_service.dart';
import 'group_session_state.dart';

/// Group session notifier for managing group sessions and messages
class GroupSessionNotifier extends StateNotifier<GroupSessionState> {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 100,
      colors: false,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  GroupSessionNotifier() : super(const GroupSessionState()) {
    _logger.d('GroupSessionNotifier initialized');
    _initializeGroupSessions();
  }

  late Box _sessionsBox;
  late Box _groupMessagesBox;

  /// Initialize group session system
  Future<void> _initializeGroupSessions() async {
    _logger.d('Initializing group session system');
    state = state.copyWith(isLoading: true);

    try {
      // Open Hive boxes
      _sessionsBox = await Hive.openBox('group_sessions');
      _groupMessagesBox = await Hive.openBox('group_messages');
      _logger.d('All Hive boxes opened successfully');

      // Load cached data
      await _loadSessions();

      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        lastUpdated: DateTime.now(),
      );
      _logger.d('Group session system initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize group sessions: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize group sessions: $e',
      );
    }
  }

  /// Load sessions from storage
  Future<void> _loadSessions() async {
    _logger.d('Loading group sessions from storage');
    try {
      final sessionMaps = _sessionsBox.values.toList();
      _logger.d('Found ${sessionMaps.length} session maps in storage');

      final sessions = sessionMaps
          .map((map) => GroupSession.fromJson(Map<String, dynamic>.from(map)))
          .toList();

      // Sort by creation time
      sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = state.copyWith(sessions: sessions);
      _logger.d('Loaded ${sessions.length} sessions');
    } catch (e) {
      _logger.e('Failed to load sessions: $e');
      debugPrint('Failed to load sessions: $e');
    }
  }

  /// Create a new group session
  Future<GroupSession> createSession({
    required String name,
    required String ownerId,
    required List<String> participantIds,
    required List<HelpyPersonality> helpyParticipants,
  }) async {
    _logger.d('Creating new group session: $name');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newSession = GroupSession(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        ownerId: ownerId,
        participantIds: participantIds,
        helpyParticipants: helpyParticipants,
        messages: const [],
        status: GroupSessionStatus.active,
        createdAt: DateTime.now(),
        settings: {},
        participantStatuses: {
          for (final participantId in participantIds)
            participantId: ParticipantStatus.active,
        },
      );

      // Save to storage
      await _sessionsBox.put(newSession.id, newSession.toJson());
      _logger.d('Group session saved to storage');

      // Update state
      final updatedSessions = [...state.sessions, newSession];
      state = state.copyWith(
        sessions: updatedSessions,
        currentSession: newSession,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      _logger.d('Group session created successfully');
      return newSession;
    } catch (e) {
      _logger.e('Failed to create group session: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create group session: $e',
      );
      rethrow;
    }
  }

  /// Join an existing group session
  Future<void> joinSession(String sessionId) async {
    _logger.d('Joining group session: $sessionId');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sessionIndex = state.sessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex == -1) {
        throw Exception('Session not found: $sessionId');
      }

      final session = state.sessions[sessionIndex];

      // Update participant status
      final updatedParticipantStatuses = Map<String, ParticipantStatus>.from(
        session.participantStatuses,
      );
      // Note: In a real implementation, we would get the current user ID
      // For now, we'll just update the first participant as an example
      if (session.participantIds.isNotEmpty) {
        updatedParticipantStatuses[session.participantIds.first] =
            ParticipantStatus.active;
      }

      final updatedSession = session.copyWith(
        participantStatuses: updatedParticipantStatuses,
        status: GroupSessionStatus.active,
      );

      // Save to storage
      await _sessionsBox.put(sessionId, updatedSession.toJson());
      _logger.d('Group session updated in storage');

      // Update state
      final updatedSessions = [...state.sessions];
      updatedSessions[sessionIndex] = updatedSession;

      state = state.copyWith(
        sessions: updatedSessions,
        currentSession: updatedSession,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      _logger.d('Successfully joined group session');
    } catch (e) {
      _logger.e('Failed to join group session: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to join group session: $e',
      );
      rethrow;
    }
  }

  /// Leave a group session
  Future<void> leaveSession(String sessionId) async {
    _logger.d('Leaving group session: $sessionId');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sessionIndex = state.sessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex == -1) {
        throw Exception('Session not found: $sessionId');
      }

      final session = state.sessions[sessionIndex];

      // Update participant status
      final updatedParticipantStatuses = Map<String, ParticipantStatus>.from(
        session.participantStatuses,
      );
      // Note: In a real implementation, we would get the current user ID
      // For now, we'll just update the first participant as an example
      if (session.participantIds.isNotEmpty) {
        updatedParticipantStatuses[session.participantIds.first] =
            ParticipantStatus.left;
      }

      final updatedSession = session.copyWith(
        participantStatuses: updatedParticipantStatuses,
      );

      // Save to storage
      await _sessionsBox.put(sessionId, updatedSession.toJson());
      _logger.d('Group session updated in storage');

      // Update state
      final updatedSessions = [...state.sessions];
      updatedSessions[sessionIndex] = updatedSession;

      state = state.copyWith(
        sessions: updatedSessions,
        currentSession: updatedSession == state.currentSession
            ? null
            : state.currentSession,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      _logger.d('Successfully left group session');
    } catch (e) {
      _logger.e('Failed to leave group session: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to leave group session: $e',
      );
      rethrow;
    }
  }

  /// Send a message to a group session
  Future<void> sendMessage({
    required String sessionId,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    _logger.d('Sending message to group session: $sessionId');

    try {
      final newMessage = Message(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: sessionId,
        senderId: senderId,
        senderName: senderName,
        content: content,
        type: MessageType.text,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
      );

      // Save message to storage
      await _groupMessagesBox.put(newMessage.id, newMessage.toJson());
      _logger.d('Message saved to storage');

      // Update session with new message
      final sessionIndex = state.sessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex != -1) {
        final session = state.sessions[sessionIndex];
        final updatedMessages = [...session.messages, newMessage];
        final updatedSession = session.copyWith(messages: updatedMessages);

        // Save updated session
        await _sessionsBox.put(sessionId, updatedSession.toJson());

        // Update state
        final updatedSessions = [...state.sessions];
        updatedSessions[sessionIndex] = updatedSession;

        state = state.copyWith(
          sessions: updatedSessions,
          currentSession: updatedSession.id == state.currentSession?.id
              ? updatedSession
              : state.currentSession,
          lastUpdated: DateTime.now(),
        );
      }

      _logger.d('Message sent successfully');
    } catch (e) {
      _logger.e('Failed to send message: $e');
      state = state.copyWith(error: 'Failed to send message: $e');
      rethrow;
    }
  }

  /// Load messages for a specific session
  Future<List<Message>> loadMessagesForSession(String sessionId) async {
    _logger.d('Loading messages for session: $sessionId');

    try {
      final session = state.sessions.firstWhere((s) => s.id == sessionId);
      return session.messages;
    } catch (e) {
      _logger.e('Failed to load messages for session: $e');
      return [];
    }
  }

  /// Update session settings
  Future<void> updateSessionSettings(
    String sessionId,
    Map<String, dynamic> settings,
  ) async {
    _logger.d('Updating settings for session: $sessionId');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sessionIndex = state.sessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex == -1) {
        throw Exception('Session not found: $sessionId');
      }

      final session = state.sessions[sessionIndex];
      final updatedSession = session.copyWith(settings: settings);

      // Save to storage
      await _sessionsBox.put(sessionId, updatedSession.toJson());
      _logger.d('Session settings updated in storage');

      // Update state
      final updatedSessions = [...state.sessions];
      updatedSessions[sessionIndex] = updatedSession;

      state = state.copyWith(
        sessions: updatedSessions,
        currentSession: updatedSession.id == state.currentSession?.id
            ? updatedSession
            : state.currentSession,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      _logger.d('Session settings updated successfully');
    } catch (e) {
      _logger.e('Failed to update session settings: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update session settings: $e',
      );
      rethrow;
    }
  }

  /// Clear error state
  void clearError() {
    state = GroupSessionState(
      sessions: state.sessions,
      currentSession: state.currentSession,
      currentMessages: state.currentMessages,
      isLoading: state.isLoading,
      isInitialized: state.isInitialized,
      error: null, // Explicitly set to null
      lastUpdated: state.lastUpdated,
    );
  }

  /// Refresh group session data
  Future<void> refresh() async {
    _logger.d('Refreshing group session data');
    state = state.copyWith(isLoading: true, error: null);
    await _loadSessions();
    state = state.copyWith(isLoading: false, lastUpdated: DateTime.now());
    _logger.d('Group session data refreshed successfully');
  }
}
