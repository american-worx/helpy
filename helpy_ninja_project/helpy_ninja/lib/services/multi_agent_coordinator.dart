import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:helpy_ninja/domain/entities/group_session.dart';

/// Multi-agent coordinator for managing AI tutor interactions in group sessions
class MultiAgentCoordinator {
  final Map<String, GroupSession> _activeSessions = {};
  final Map<String, Set<String>> _recentSpeakers = {};
  final Map<String, DateTime> _lastResponseTime = {};
  final Map<String, ResponseQueue> _responseQueues = {};

  /// Time window for turn-taking (in seconds)
  final int turnTakingWindow = 30;

  /// Minimum time between responses from the same Helpy (in seconds)
  final int minResponseInterval = 5;

  /// Maximum number of queued responses per session
  final int maxQueueSize = 5;

  /// Add a session to be coordinated
  void addSession(GroupSession session) {
    _activeSessions[session.id] = session;
    _recentSpeakers[session.id] = <String>{};
    _lastResponseTime[session.id] =
        DateTime.now().subtract(Duration(seconds: minResponseInterval + 1));
    _responseQueues[session.id] = ResponseQueue(maxSize: maxQueueSize);
  }

  /// Remove a session from coordination
  void removeSession(String sessionId) {
    _activeSessions.remove(sessionId);
    _recentSpeakers.remove(sessionId);
    _lastResponseTime.remove(sessionId);
    _responseQueues.remove(sessionId);
  }

  /// Check if a Helpy can respond in a session
  Future<bool> canRespond(String sessionId, String helpyId) async {
    final session = _activeSessions[sessionId];
    if (session == null) return false;

    // Check if Helpy is a participant
    final isParticipant = session.helpyParticipants.any(
      (helpy) => helpy.id == helpyId,
    );
    if (!isParticipant) return false;

    // Check minimum response interval
    final lastResponse = _lastResponseTime[sessionId];
    if (lastResponse != null) {
      final elapsed = DateTime.now().difference(lastResponse).inSeconds;
      if (elapsed < minResponseInterval) {
        return false;
      }
    }

    // Check if Helpy has spoken recently (turn-taking)
    final recentSpeakers = _recentSpeakers[sessionId];
    if (recentSpeakers != null && recentSpeakers.contains(helpyId)) {
      return false;
    }

    return true;
  }

  /// Request permission for a Helpy to respond
  Future<bool> requestResponsePermission(
    String sessionId,
    String helpyId,
    String messageContent,
  ) async {
    // Check if Helpy can respond
    if (!await canRespond(sessionId, helpyId)) {
      debugPrint('Helpy $helpyId cannot respond');
      return false;
    }

    debugPrint('Helpy $helpyId can respond, checking queue status');

    // Check if there are already queued responses or active responses
    final queue = _responseQueues[sessionId];
    if (queue != null && !queue.isEmpty) {
      debugPrint('Queue is not empty, adding Helpy $helpyId to queue');
      // Add to response queue
      queue.add(
        ResponseRequest(
          helpyId: helpyId,
          content: messageContent,
          timestamp: DateTime.now(),
        ),
      );
      return false; // Queued, not immediate permission
    }

    // Check if there's already an active response (recent speaker)
    final recentSpeakers = _recentSpeakers[sessionId];
    debugPrint('Recent speakers: ${recentSpeakers?.toList()}');
    if (recentSpeakers != null && recentSpeakers.isNotEmpty) {
      debugPrint('Recent speakers exist, adding Helpy $helpyId to queue');
      // Add to response queue
      if (queue != null) {
        queue.add(
          ResponseRequest(
            helpyId: helpyId,
            content: messageContent,
            timestamp: DateTime.now(),
          ),
        );
      }
      return false; // Queued, not immediate permission
    }

    debugPrint('Granting immediate permission to Helpy $helpyId');
    // Grant permission for immediate response
    _recordResponse(sessionId, helpyId);
    return true;
  }

  /// Record that a Helpy has responded
  void _recordResponse(String sessionId, String helpyId) {
    // Update last response time
    _lastResponseTime[sessionId] = DateTime.now();

    // Add to recent speakers
    final recentSpeakers = _recentSpeakers[sessionId];
    if (recentSpeakers != null) {
      recentSpeakers.add(helpyId);

      // Clear old speakers after turn-taking window
      Future.delayed(Duration(seconds: turnTakingWindow), () {
        recentSpeakers.remove(helpyId);
      });
    }
  }

  /// Process queued responses
  Future<void> processQueuedResponses(String sessionId) async {
    final queue = _responseQueues[sessionId];
    if (queue == null || queue.isEmpty) return;

    final nextRequest = queue.peek();
    if (nextRequest == null) return;

    // Check if the requesting Helpy can respond now
    if (await canRespond(sessionId, nextRequest.helpyId)) {
      // Remove from queue and grant permission
      queue.remove();
      _recordResponse(sessionId, nextRequest.helpyId);

      // In a real implementation, this would trigger the Helpy to respond
      debugPrint(
        'Granted permission to Helpy ${nextRequest.helpyId} to respond',
      );
    }
  }

  /// Resolve conflicts between simultaneous response requests
  Future<String?> resolveConflict(
    String sessionId,
    List<String> conflictingHelpyIds,
  ) async {
    final session = _activeSessions[sessionId];
    if (session == null) return null;

    // Simple priority-based conflict resolution
    // In a real implementation, this could consider:
    // - Helpy specialization relevance
    // - Participant attention/focus
    // - Previous contribution balance
    // - Personality traits

    // For now, we'll just return the first available Helpy that can respond
    for (final helpyId in conflictingHelpyIds) {
      if (await canRespond(sessionId, helpyId)) {
        return helpyId;
      }
    }

    return null; // No Helpy can respond right now
  }

  /// Manage conversation flow and attention
  Future<void> manageConversationFlow(String sessionId) async {
    // Process any queued responses
    await processQueuedResponses(sessionId);

    // In a real implementation, this could:
    // - Monitor conversation engagement
    // - Identify quiet participants to encourage
    // - Detect dominant personalities and balance
    // - Suggest topic changes if conversation stalls
  }

  /// Get session status for monitoring
  Map<String, dynamic> getSessionStatus(String sessionId) {
    return {
      'activeSessions': _activeSessions.length,
      'recentSpeakers': _recentSpeakers[sessionId]?.toList() ?? [],
      'lastResponseTime': _lastResponseTime[sessionId]?.toIso8601String(),
      'queuedResponses': _responseQueues[sessionId]?.length ?? 0,
    };
  }
}

/// Queue for managing response requests
class ResponseQueue {
  final int maxSize;
  final List<ResponseRequest> _queue = [];

  ResponseQueue({required this.maxSize});

  bool get isEmpty => _queue.isEmpty;
  bool get isFull => _queue.length >= maxSize;
  int get length => _queue.length;

  /// Add a response request to the queue
  void add(ResponseRequest request) {
    if (!isFull) {
      _queue.add(request);
      // Sort by priority/timestamp if needed
      _queue.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
  }

  /// Remove and return the next response request
  ResponseRequest? remove() {
    if (isEmpty) return null;
    return _queue.removeAt(0);
  }

  /// Peek at the next response request without removing it
  ResponseRequest? peek() {
    if (isEmpty) return null;
    return _queue.first;
  }

  /// Check if new requests should be queued
  bool shouldQueue() {
    // For simplicity, we'll queue if there are any pending requests
    // In a more sophisticated implementation, we might check for active responses
    return !isEmpty;
  }
}

/// Request for a Helpy to respond
class ResponseRequest {
  final String helpyId;
  final String content;
  final DateTime timestamp;

  ResponseRequest({
    required this.helpyId,
    required this.content,
    required this.timestamp,
  });
}
