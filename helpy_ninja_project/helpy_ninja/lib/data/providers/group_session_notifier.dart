import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpy_ninja/domain/entities/shared_enums.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/group_session.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/helpy_personality.dart';
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
  WebSocketService? _websocketService;

  // Threshold for conflict detection (milliseconds)
  static const int _conflictThreshold = 100;

  /// Set the WebSocket service for real-time communication
  void setWebSocketService(WebSocketService websocketService) {
    _websocketService = websocketService;

    // Listen for participant change events
    _websocketService?.participantChangeStream.listen(_handleParticipantChange);

    // Listen for incoming messages
    _websocketService?.messageStream.listen(_handleIncomingMessage);

    // Listen for typing indicators
    _websocketService?.typingIndicatorStream.listen(_handleTypingIndicator);
  }

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
        // Assign sequence number for ordering
        sequenceNumber: DateTime.now().millisecondsSinceEpoch,
      );

      // Save message to storage
      await _groupMessagesBox.put(newMessage.id, newMessage.toJson());
      _logger.d('Message saved to storage');

      // Update session with new message
      final sessionIndex = state.sessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex != -1) {
        final session = state.sessions[sessionIndex];
        final updatedMessages = [...session.messages, newMessage];
        // Sort messages by timestamp and sequence number
        updatedMessages.sort(_compareMessages);
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
      typingIndicators: state.typingIndicators,
    );
  }

  /// Add a participant to a group session
  Future<void> addParticipant({
    required String sessionId,
    required String participantId,
    String participantType = 'helpy', // 'user' or 'helpy'
    ParticipantStatus status = ParticipantStatus.active,
  }) async {
    _logger.d('Adding participant $participantId to session: $sessionId');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sessionIndex = state.sessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex == -1) {
        throw Exception('Session not found: $sessionId');
      }

      final session = state.sessions[sessionIndex];

      // Check if participant is already in the session
      if (session.participantIds.contains(participantId)) {
        _logger
            .w('Participant $participantId is already in session $sessionId');
        state = state.copyWith(isLoading: false);
        return;
      }

      // Update participant lists and statuses
      final updatedParticipantIds = [...session.participantIds, participantId];
      final updatedParticipantStatuses = Map<String, ParticipantStatus>.from(
        session.participantStatuses,
      );
      updatedParticipantStatuses[participantId] = status;

      final updatedSession = session.copyWith(
        participantIds: updatedParticipantIds,
        participantStatuses: updatedParticipantStatuses,
      );

      // Save to storage
      await _sessionsBox.put(sessionId, updatedSession.toJson());
      _logger.d('Participant added to session in storage');

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

      // Send WebSocket notification
      try {
        await _websocketService?.sendParticipantAdded(
          sessionId: sessionId,
          participantId: participantId,
          participantType: participantType,
        );
      } catch (e) {
        _logger.e('Failed to send participant added notification: $e');
      }

      _logger.d('Participant added successfully');
    } catch (e) {
      _logger.e('Failed to add participant: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add participant: $e',
      );
      rethrow;
    }
  }

  /// Remove a participant from a group session
  Future<void> removeParticipant({
    required String sessionId,
    required String participantId,
    String participantType = 'helpy', // 'user' or 'helpy'
  }) async {
    _logger.d('Removing participant $participantId from session: $sessionId');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sessionIndex = state.sessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex == -1) {
        throw Exception('Session not found: $sessionId');
      }

      final session = state.sessions[sessionIndex];

      // Check if participant is in the session
      if (!session.participantIds.contains(participantId)) {
        _logger.w('Participant $participantId is not in session $sessionId');
        state = state.copyWith(isLoading: false);
        return;
      }

      // Update participant lists and statuses
      final updatedParticipantIds = List<String>.from(session.participantIds)
        ..remove(participantId);
      final updatedParticipantStatuses = Map<String, ParticipantStatus>.from(
        session.participantStatuses,
      )..remove(participantId);

      final updatedSession = session.copyWith(
        participantIds: updatedParticipantIds,
        participantStatuses: updatedParticipantStatuses,
      );

      // Save to storage
      await _sessionsBox.put(sessionId, updatedSession.toJson());
      _logger.d('Participant removed from session in storage');

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

      // Send WebSocket notification
      try {
        await _websocketService?.sendParticipantRemoved(
          sessionId: sessionId,
          participantId: participantId,
          participantType: participantType,
        );
      } catch (e) {
        _logger.e('Failed to send participant removed notification: $e');
      }

      _logger.d('Participant removed successfully');
    } catch (e) {
      _logger.e('Failed to remove participant: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to remove participant: $e',
      );
      rethrow;
    }
  }

  /// Handle incoming participant change events from WebSocket
  void _handleParticipantChange(ParticipantChangeEvent event) {
    _logger.d('Handling participant change event: ${event.type}');

    try {
      final sessionIndex =
          state.sessions.indexWhere((s) => s.id == event.sessionId);
      if (sessionIndex == -1) {
        _logger.w(
            'Session not found for participant change event: ${event.sessionId}');
        return;
      }

      final session = state.sessions[sessionIndex];

      if (event.isParticipantAdded) {
        // Add participant if not already in session
        if (!session.participantIds.contains(event.participantId)) {
          final updatedParticipantIds = [
            ...session.participantIds,
            event.participantId
          ];
          final updatedParticipantStatuses =
              Map<String, ParticipantStatus>.from(
            session.participantStatuses,
          );
          updatedParticipantStatuses[event.participantId] =
              ParticipantStatus.active;

          final updatedSession = session.copyWith(
            participantIds: updatedParticipantIds,
            participantStatuses: updatedParticipantStatuses,
          );

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

          _logger.d(
              'Participant ${event.participantId} added to session ${event.sessionId}');
        }
      } else if (event.isParticipantRemoved) {
        // Remove participant if in session
        if (session.participantIds.contains(event.participantId)) {
          final updatedParticipantIds =
              List<String>.from(session.participantIds)
                ..remove(event.participantId);
          final updatedParticipantStatuses =
              Map<String, ParticipantStatus>.from(
            session.participantStatuses,
          )..remove(event.participantId);

          final updatedSession = session.copyWith(
            participantIds: updatedParticipantIds,
            participantStatuses: updatedParticipantStatuses,
          );

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

          _logger.d(
              'Participant ${event.participantId} removed from session ${event.sessionId}');
        }
      }
    } catch (e) {
      _logger.e('Failed to handle participant change event: $e');
    }
  }

  /// Handle incoming messages from WebSocket
  void _handleIncomingMessage(Message message) {
    _logger.d('Handling incoming message: ${message.id}');

    try {
      final sessionIndex =
          state.sessions.indexWhere((s) => s.id == message.conversationId);
      if (sessionIndex == -1) {
        _logger.w(
            'Session not found for incoming message: ${message.conversationId}');
        return;
      }

      final session = state.sessions[sessionIndex];

      // Check if message already exists to prevent duplicates
      if (session.messages.any((m) => m.id == message.id)) {
        _logger.d('Message ${message.id} already exists, skipping');
        return;
      }

      // Check for conflicts with existing messages
      final conflictingMessages =
          _findConflictingMessages(session.messages, message);

      Message processedMessage = message;
      if (conflictingMessages.isNotEmpty) {
        _logger.d(
            'Found ${conflictingMessages.length} conflicting messages for message ${message.id}');

        // Mark message as conflict and add conflicting message IDs
        final conflictingIds = conflictingMessages.map((m) => m.id).toList();
        processedMessage = message.copyWith(
          isConflict: true,
          conflictingMessageIds: conflictingIds,
        );

        // Try to resolve conflicts automatically
        final resolvedMessage =
            _resolveConflicts(processedMessage, conflictingMessages, session);
        if (resolvedMessage != null) {
          processedMessage = resolvedMessage;
        }
      }

      // Add message to session
      final updatedMessages = [...session.messages, processedMessage];
      // Sort messages by timestamp and sequence number
      updatedMessages.sort(_compareMessages);
      final updatedSession = session.copyWith(messages: updatedMessages);

      // Save to storage
      _sessionsBox.put(message.conversationId, updatedSession.toJson());
      _logger.d('Message saved to storage');

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

      _logger
          .d('Message added successfully to session ${message.conversationId}');
    } catch (e) {
      _logger.e('Failed to handle incoming message: $e');
    }
  }

  /// Find conflicting messages based on timestamp proximity
  List<Message> _findConflictingMessages(
      List<Message> existingMessages, Message newMessage) {
    final conflicts = <Message>[];

    for (final existingMessage in existingMessages) {
      // Skip if message is already marked as conflict
      if (existingMessage.isConflict) continue;

      // Check if timestamps are within conflict threshold
      final timeDifference =
          existingMessage.timestamp.difference(newMessage.timestamp).abs();
      if (timeDifference.inMilliseconds <= _conflictThreshold) {
        conflicts.add(existingMessage);
      }
    }

    return conflicts;
  }

  /// Resolve conflicts automatically based on participant roles and other factors
  Message? _resolveConflicts(Message newMessage,
      List<Message> conflictingMessages, GroupSession session) {
    _logger.d('Attempting to resolve conflicts for message ${newMessage.id}');

    // If there are no conflicting messages, no resolution needed
    if (conflictingMessages.isEmpty) {
      return null;
    }

    // Simple resolution strategy: Keep the message from Helpy participants over user messages
    // In a more complex system, we might use priority levels, participant roles, etc.

    // Check if new message is from a Helpy
    final isNewMessageFromHelpy = newMessage.senderId.startsWith('helpy_');

    // Count how many conflicting messages are from Helpy participants
    final helpyConflictCount = conflictingMessages
        .where((m) => m.senderId.startsWith('helpy_'))
        .length;

    // If new message is from Helpy and all conflicts are from users, keep the new message
    if (isNewMessageFromHelpy && helpyConflictCount == 0) {
      _logger.d(
          'Resolving conflict: New Helpy message takes precedence over user messages');
      return newMessage
          .copyWith(isConflict: false, conflictingMessageIds: const []);
    }

    // If new message is from user and there are Helpy conflicts, discard the new message
    if (!isNewMessageFromHelpy && helpyConflictCount > 0) {
      _logger.d(
          'Resolving conflict: Discarding user message in favor of Helpy messages');
      return null; // This will prevent the message from being added
    }

    // If all messages are from the same type of participant, use timestamp to resolve
    // Keep the earliest message
    final allMessages = [newMessage, ...conflictingMessages];
    allMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final earliestMessage = allMessages.first;

    // If the earliest message is the new message, keep it and mark others as conflicts
    if (earliestMessage.id == newMessage.id) {
      _logger.d('Resolving conflict: New message is earliest, keeping it');
      return newMessage
          .copyWith(isConflict: false, conflictingMessageIds: const []);
    }

    // Otherwise, the new message should be discarded
    _logger.d(
        'Resolving conflict: Earlier message exists, discarding new message');
    return null;
  }

  /// Compare messages for sorting by timestamp and sequence number
  int _compareMessages(Message a, Message b) {
    // First compare by timestamp
    final timestampComparison = a.timestamp.compareTo(b.timestamp);
    if (timestampComparison != 0) {
      return timestampComparison;
    }

    // If timestamps are equal, compare by sequence number
    return a.sequenceNumber.compareTo(b.sequenceNumber);
  }

  /// Handle typing indicator events from WebSocket
  void _handleTypingIndicator(TypingIndicatorEvent event) {
    _logger.d(
        'Handling typing indicator: ${event.userId} is ${event.isTyping ? 'typing' : 'not typing'}');

    try {
      // Update state with typing indicator
      state = state.copyWith(
        typingIndicators: {
          ...state.typingIndicators,
          if (event.isTyping)
            event.sessionId: {
              ...state.typingIndicators[event.sessionId] ?? {},
              event.userId: event.timestamp,
            }
          else
            event.sessionId: {
              ...state.typingIndicators[event.sessionId] ?? {},
            }..remove(event.userId),
        },
        lastUpdated: DateTime.now(),
      );

      _logger.d('Typing indicator updated for session ${event.sessionId}');
    } catch (e) {
      _logger.e('Failed to handle typing indicator: $e');
    }
  }

  /// Refresh group session data
  Future<void> refresh() async {
    _logger.d('Refreshing group session data');
    state = state.copyWith(isLoading: true, error: null);
    await _loadSessions();
    state = state.copyWith(isLoading: false, lastUpdated: DateTime.now());
    _logger.d('Group session data refreshed successfully');
  }

  /// Send typing indicator for a session
  Future<void> sendTypingIndicator({
    required String sessionId,
    required String userId,
    required bool isTyping,
  }) async {
    _logger.d(
        'Sending typing indicator for session: $sessionId, user: $userId, typing: $isTyping');

    try {
      // Send through WebSocket if connected
      if (_websocketService?.isConnected == true) {
        await _websocketService?.sendTypingIndicator(
          userId: userId,
          sessionId: sessionId,
          isTyping: isTyping,
        );
      }

      // Update local state immediately for responsive UI
      state = state.copyWith(
        typingIndicators: {
          ...state.typingIndicators,
          if (isTyping)
            sessionId: {
              ...state.typingIndicators[sessionId] ?? {},
              userId: DateTime.now(),
            }
          else
            sessionId: {
              ...state.typingIndicators[sessionId] ?? {},
            }..remove(userId),
        },
        lastUpdated: DateTime.now(),
      );

      _logger.d('Typing indicator sent successfully');
    } catch (e) {
      _logger.e('Failed to send typing indicator: $e');
    }
  }
}
