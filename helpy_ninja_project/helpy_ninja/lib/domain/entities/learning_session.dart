/// Learning session entity representing a user's learning activity
class LearningSession {
  final String id;
  final String userId;
  final String lessonId;
  final SessionType type;
  final SessionStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime? pausedAt;
  final Duration totalTimeSpent;
  final double progressPercentage;
  final int currentSectionIndex;
  final Map<String, dynamic> sessionData;
  final List<SessionEvent> events;
  final SessionScore? score;
  final Map<String, dynamic>? metadata;

  const LearningSession({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.type,
    this.status = SessionStatus.active,
    required this.startedAt,
    this.completedAt,
    this.pausedAt,
    this.totalTimeSpent = Duration.zero,
    this.progressPercentage = 0.0,
    this.currentSectionIndex = 0,
    this.sessionData = const {},
    this.events = const [],
    this.score,
    this.metadata,
  });

  LearningSession copyWith({
    String? id,
    String? userId,
    String? lessonId,
    SessionType? type,
    SessionStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? pausedAt,
    Duration? totalTimeSpent,
    double? progressPercentage,
    int? currentSectionIndex,
    Map<String, dynamic>? sessionData,
    List<SessionEvent>? events,
    SessionScore? score,
    Map<String, dynamic>? metadata,
  }) {
    return LearningSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      type: type ?? this.type,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      currentSectionIndex: currentSectionIndex ?? this.currentSectionIndex,
      sessionData: sessionData ?? this.sessionData,
      events: events ?? this.events,
      score: score ?? this.score,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if session is completed
  bool get isCompleted => status == SessionStatus.completed;

  /// Check if session is active
  bool get isActive => status == SessionStatus.active;

  /// Check if session is paused
  bool get isPaused => status == SessionStatus.paused;

  /// Get session duration
  Duration get sessionDuration {
    if (completedAt != null) {
      return completedAt!.difference(startedAt);
    } else if (pausedAt != null) {
      return pausedAt!.difference(startedAt);
    } else if (status == SessionStatus.active) {
      return DateTime.now().difference(startedAt);
    }
    return Duration.zero;
  }

  /// Get formatted time spent
  String get formattedTimeSpent {
    final minutes = totalTimeSpent.inMinutes;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Get completion rate
  double get completionRate {
    return (progressPercentage / 100.0).clamp(0.0, 1.0);
  }

  /// Add event to session
  LearningSession addEvent(SessionEvent event) {
    return copyWith(events: [...events, event]);
  }

  /// Update progress
  LearningSession updateProgress(double progress, int sectionIndex) {
    return copyWith(
      progressPercentage: progress.clamp(0.0, 100.0),
      currentSectionIndex: sectionIndex,
    );
  }

  /// Mark as completed
  LearningSession complete(SessionScore? finalScore) {
    return copyWith(
      status: SessionStatus.completed,
      completedAt: DateTime.now(),
      progressPercentage: 100.0,
      score: finalScore,
    );
  }

  /// Pause session
  LearningSession pause() {
    return copyWith(status: SessionStatus.paused, pausedAt: DateTime.now());
  }

  /// Resume session
  LearningSession resume() {
    return copyWith(status: SessionStatus.active, pausedAt: null);
  }

  /// Convert to JSON for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'lessonId': lessonId,
      'type': type.name,
      'status': status.name,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'pausedAt': pausedAt?.toIso8601String(),
      'totalTimeSpent': totalTimeSpent.inSeconds,
      'progressPercentage': progressPercentage,
      'currentSectionIndex': currentSectionIndex,
      'sessionData': sessionData,
      'events': events.map((event) => event.toJson()).toList(),
      'score': score?.toJson(),
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory LearningSession.fromJson(Map<String, dynamic> json) {
    return LearningSession(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      lessonId: json['lessonId'] ?? '',
      type: SessionType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => SessionType.lesson,
      ),
      status: SessionStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => SessionStatus.active,
      ),
      startedAt: DateTime.parse(
        json['startedAt'] ?? DateTime.now().toIso8601String(),
      ),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      pausedAt:
          json['pausedAt'] != null ? DateTime.parse(json['pausedAt']) : null,
      totalTimeSpent: Duration(seconds: json['totalTimeSpent'] ?? 0),
      progressPercentage: (json['progressPercentage'] ?? 0.0).toDouble(),
      currentSectionIndex: json['currentSectionIndex'] ?? 0,
      sessionData: Map<String, dynamic>.from(json['sessionData'] ?? {}),
      events: (json['events'] as List?)
              ?.map((event) => SessionEvent.fromJson(event))
              .toList() ??
          [],
      score:
          json['score'] != null ? SessionScore.fromJson(json['score']) : null,
      metadata: json['metadata'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LearningSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LearningSession(id: $id, lessonId: $lessonId, status: $status, progress: ${progressPercentage.toStringAsFixed(1)}%)';
  }
}

/// Types of learning sessions
enum SessionType {
  lesson, // Regular lesson session
  practice, // Practice session
  quiz, // Quiz session
  review, // Review session
  project, // Project session
}

/// Session status
enum SessionStatus {
  active, // Currently in progress
  paused, // Temporarily paused
  completed, // Successfully completed
  abandoned, // Left incomplete
  expired, // Timed out
}

/// Session event for tracking user interactions
class SessionEvent {
  final String id;
  final SessionEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  const SessionEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    this.data = const {},
  });

  SessionEvent copyWith({
    String? id,
    SessionEventType? type,
    DateTime? timestamp,
    Map<String, dynamic>? data,
  }) {
    return SessionEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
    };
  }

  factory SessionEvent.fromJson(Map<String, dynamic> json) {
    return SessionEvent(
      id: json['id'] ?? '',
      type: SessionEventType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => SessionEventType.interaction,
      ),
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Types of session events
enum SessionEventType {
  start, // Session started
  pause, // Session paused
  resume, // Session resumed
  complete, // Session completed
  sectionStart, // Started new section
  sectionComplete, // Completed section
  interaction, // User interaction
  answer, // Answer submitted
  hint, // Hint requested
  error, // Error occurred
}

/// Session score for tracking performance
class SessionScore {
  final double totalScore;
  final double maxScore;
  final int correctAnswers;
  final int totalAnswers;
  final int hintsUsed;
  final Duration timeToComplete;
  final Map<String, double> sectionScores;

  const SessionScore({
    required this.totalScore,
    required this.maxScore,
    this.correctAnswers = 0,
    this.totalAnswers = 0,
    this.hintsUsed = 0,
    this.timeToComplete = Duration.zero,
    this.sectionScores = const {},
  });

  SessionScore copyWith({
    double? totalScore,
    double? maxScore,
    int? correctAnswers,
    int? totalAnswers,
    int? hintsUsed,
    Duration? timeToComplete,
    Map<String, double>? sectionScores,
  }) {
    return SessionScore(
      totalScore: totalScore ?? this.totalScore,
      maxScore: maxScore ?? this.maxScore,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAnswers: totalAnswers ?? this.totalAnswers,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      timeToComplete: timeToComplete ?? this.timeToComplete,
      sectionScores: sectionScores ?? this.sectionScores,
    );
  }

  /// Get percentage score
  double get percentage => maxScore > 0 ? (totalScore / maxScore) * 100 : 0.0;

  /// Get accuracy percentage
  double get accuracy =>
      totalAnswers > 0 ? (correctAnswers / totalAnswers) * 100 : 0.0;

  /// Get performance grade
  String get grade {
    final perc = percentage;
    if (perc >= 90) return 'A+';
    if (perc >= 85) return 'A';
    if (perc >= 80) return 'A-';
    if (perc >= 75) return 'B+';
    if (perc >= 70) return 'B';
    if (perc >= 65) return 'B-';
    if (perc >= 60) return 'C+';
    if (perc >= 55) return 'C';
    if (perc >= 50) return 'C-';
    return 'F';
  }

  Map<String, dynamic> toJson() {
    return {
      'totalScore': totalScore,
      'maxScore': maxScore,
      'correctAnswers': correctAnswers,
      'totalAnswers': totalAnswers,
      'hintsUsed': hintsUsed,
      'timeToComplete': timeToComplete.inSeconds,
      'sectionScores': sectionScores,
    };
  }

  factory SessionScore.fromJson(Map<String, dynamic> json) {
    return SessionScore(
      totalScore: (json['totalScore'] ?? 0.0).toDouble(),
      maxScore: (json['maxScore'] ?? 0.0).toDouble(),
      correctAnswers: json['correctAnswers'] ?? 0,
      totalAnswers: json['totalAnswers'] ?? 0,
      hintsUsed: json['hintsUsed'] ?? 0,
      timeToComplete: Duration(seconds: json['timeToComplete'] ?? 0),
      sectionScores: Map<String, double>.from(
        (json['sectionScores'] ?? {}).map(
          (key, value) => MapEntry(key, value.toDouble()),
        ),
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionScore &&
        other.totalScore == totalScore &&
        other.maxScore == maxScore;
  }

  @override
  int get hashCode => Object.hash(totalScore, maxScore);

  @override
  String toString() {
    return 'SessionScore(score: ${totalScore.toStringAsFixed(1)}/${maxScore.toStringAsFixed(1)}, percentage: ${percentage.toStringAsFixed(1)}%)';
  }
}
