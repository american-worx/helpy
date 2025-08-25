import 'lesson.dart';

/// Progress tracking entity for user learning advancement
class UserProgress {
  final String id;
  final String userId;
  final String subjectId;
  final String? lessonId;
  final ProgressType type;
  final double completionPercentage;
  final int totalTimeSpent; // in minutes
  final int sessionsCompleted;
  final int questionsAnswered;
  final int correctAnswers;
  final double averageScore;
  final List<String> completedLessons;
  final List<String> unlockedLessons;
  final List<Achievement> achievements;
  final Map<String, SkillProgress> skillProgress;
  final DateTime lastUpdated;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const UserProgress({
    required this.id,
    required this.userId,
    required this.subjectId,
    this.lessonId,
    required this.type,
    this.completionPercentage = 0.0,
    this.totalTimeSpent = 0,
    this.sessionsCompleted = 0,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.averageScore = 0.0,
    this.completedLessons = const [],
    this.unlockedLessons = const [],
    this.achievements = const [],
    this.skillProgress = const {},
    required this.lastUpdated,
    required this.createdAt,
    this.metadata,
  });

  UserProgress copyWith({
    String? id,
    String? userId,
    String? subjectId,
    String? lessonId,
    ProgressType? type,
    double? completionPercentage,
    int? totalTimeSpent,
    int? sessionsCompleted,
    int? questionsAnswered,
    int? correctAnswers,
    double? averageScore,
    List<String>? completedLessons,
    List<String>? unlockedLessons,
    List<Achievement>? achievements,
    Map<String, SkillProgress>? skillProgress,
    DateTime? lastUpdated,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subjectId: subjectId ?? this.subjectId,
      lessonId: lessonId ?? this.lessonId,
      type: type ?? this.type,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      averageScore: averageScore ?? this.averageScore,
      completedLessons: completedLessons ?? this.completedLessons,
      unlockedLessons: unlockedLessons ?? this.unlockedLessons,
      achievements: achievements ?? this.achievements,
      skillProgress: skillProgress ?? this.skillProgress,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get accuracy percentage
  double get accuracy {
    return questionsAnswered > 0
        ? (correctAnswers / questionsAnswered) * 100
        : 0.0;
  }

  /// Get formatted time spent
  String get formattedTimeSpent {
    final hours = totalTimeSpent ~/ 60;
    final minutes = totalTimeSpent % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Get current level based on progress
  int get currentLevel {
    return (completionPercentage / 10).floor() + 1;
  }

  /// Get progress to next level
  double get progressToNextLevel {
    final currentLevelProgress = (currentLevel - 1) * 10.0;
    final nextLevelProgress = currentLevel * 10.0;
    final progressInLevel = completionPercentage - currentLevelProgress;
    return (progressInLevel / 10.0).clamp(0.0, 1.0);
  }

  /// Get performance rating
  PerformanceRating get performanceRating {
    if (averageScore >= 90) return PerformanceRating.excellent;
    if (averageScore >= 80) return PerformanceRating.good;
    if (averageScore >= 70) return PerformanceRating.average;
    if (averageScore >= 60) return PerformanceRating.needsImprovement;
    return PerformanceRating.struggling;
  }

  /// Check if lesson is unlocked
  bool isLessonUnlocked(String lessonId) {
    return unlockedLessons.contains(lessonId);
  }

  /// Check if lesson is completed
  bool isLessonCompleted(String lessonId) {
    return completedLessons.contains(lessonId);
  }

  /// Add completed lesson
  UserProgress completeLesson(String lessonId, double score, int timeSpent) {
    final updatedCompletedLessons = [...completedLessons];
    if (!updatedCompletedLessons.contains(lessonId)) {
      updatedCompletedLessons.add(lessonId);
    }

    final newTotalSessions = sessionsCompleted + 1;
    final newAverageScore =
        ((averageScore * sessionsCompleted) + score) / newTotalSessions;

    return copyWith(
      completedLessons: updatedCompletedLessons,
      sessionsCompleted: newTotalSessions,
      totalTimeSpent: totalTimeSpent + timeSpent,
      averageScore: newAverageScore,
      lastUpdated: DateTime.now(),
    );
  }

  /// Convert to JSON for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subjectId': subjectId,
      'lessonId': lessonId,
      'type': type.name,
      'completionPercentage': completionPercentage,
      'totalTimeSpent': totalTimeSpent,
      'sessionsCompleted': sessionsCompleted,
      'questionsAnswered': questionsAnswered,
      'correctAnswers': correctAnswers,
      'averageScore': averageScore,
      'completedLessons': completedLessons,
      'unlockedLessons': unlockedLessons,
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'skillProgress': skillProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'lastUpdated': lastUpdated.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      subjectId: json['subjectId'] ?? '',
      lessonId: json['lessonId'],
      type: ProgressType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => ProgressType.subject,
      ),
      completionPercentage: (json['completionPercentage'] ?? 0.0).toDouble(),
      totalTimeSpent: json['totalTimeSpent'] ?? 0,
      sessionsCompleted: json['sessionsCompleted'] ?? 0,
      questionsAnswered: json['questionsAnswered'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      completedLessons: List<String>.from(json['completedLessons'] ?? []),
      unlockedLessons: List<String>.from(json['unlockedLessons'] ?? []),
      achievements:
          (json['achievements'] as List?)
              ?.map((a) => Achievement.fromJson(a))
              .toList() ??
          [],
      skillProgress:
          (json['skillProgress'] as Map?)?.map(
            (key, value) => MapEntry(key, SkillProgress.fromJson(value)),
          ) ??
          {},
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      metadata: json['metadata'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProgress && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Types of progress tracking
enum ProgressType { subject, lesson, skill, chapter }

/// Performance rating levels
enum PerformanceRating {
  excellent,
  good,
  average,
  needsImprovement,
  struggling,
}

/// Achievement entity for gamification
class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final String iconUrl;
  final String badgeColor;
  final int points;
  final DateTime unlockedAt;
  final Map<String, dynamic>? metadata;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.iconUrl,
    this.badgeColor = '#FFD700',
    this.points = 10,
    required this.unlockedAt,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'iconUrl': iconUrl,
      'badgeColor': badgeColor,
      'points': points,
      'unlockedAt': unlockedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: AchievementType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => AchievementType.progress,
      ),
      iconUrl: json['iconUrl'] ?? '',
      badgeColor: json['badgeColor'] ?? '#FFD700',
      points: json['points'] ?? 10,
      unlockedAt: DateTime.parse(
        json['unlockedAt'] ?? DateTime.now().toIso8601String(),
      ),
      metadata: json['metadata'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Types of achievements
enum AchievementType { progress, performance, streak, time, special }

/// Skill progress tracking
class SkillProgress {
  final String skillId;
  final String skillName;
  final double proficiency;
  final int practiceCount;
  final DateTime lastPracticed;

  const SkillProgress({
    required this.skillId,
    required this.skillName,
    this.proficiency = 0.0,
    this.practiceCount = 0,
    required this.lastPracticed,
  });

  Map<String, dynamic> toJson() {
    return {
      'skillId': skillId,
      'skillName': skillName,
      'proficiency': proficiency,
      'practiceCount': practiceCount,
      'lastPracticed': lastPracticed.toIso8601String(),
    };
  }

  factory SkillProgress.fromJson(Map<String, dynamic> json) {
    return SkillProgress(
      skillId: json['skillId'] ?? '',
      skillName: json['skillName'] ?? '',
      proficiency: (json['proficiency'] ?? 0.0).toDouble(),
      practiceCount: json['practiceCount'] ?? 0,
      lastPracticed: DateTime.parse(
        json['lastPracticed'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SkillProgress && other.skillId == skillId;
  }

  @override
  int get hashCode => skillId.hashCode;
}
