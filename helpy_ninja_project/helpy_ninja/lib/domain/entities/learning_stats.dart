/// Learning statistics entities for dashboard
class LearningStats {
  final int totalLessonsCompleted;
  final int currentStreak;
  final int longestStreak;
  final double totalStudyTimeHours;
  final int achievementsUnlocked;
  final int totalAchievements;
  final Map<String, SubjectProgress> subjectProgress;
  final List<RecentActivity> recentActivities;
  final DateTime lastStudyDate;
  final int weeklyGoalLessons;
  final int weeklyCompletedLessons;

  const LearningStats({
    required this.totalLessonsCompleted,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalStudyTimeHours,
    required this.achievementsUnlocked,
    required this.totalAchievements,
    required this.subjectProgress,
    required this.recentActivities,
    required this.lastStudyDate,
    required this.weeklyGoalLessons,
    required this.weeklyCompletedLessons,
  });

  LearningStats copyWith({
    int? totalLessonsCompleted,
    int? currentStreak,
    int? longestStreak,
    double? totalStudyTimeHours,
    int? achievementsUnlocked,
    int? totalAchievements,
    Map<String, SubjectProgress>? subjectProgress,
    List<RecentActivity>? recentActivities,
    DateTime? lastStudyDate,
    int? weeklyGoalLessons,
    int? weeklyCompletedLessons,
  }) {
    return LearningStats(
      totalLessonsCompleted:
          totalLessonsCompleted ?? this.totalLessonsCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalStudyTimeHours: totalStudyTimeHours ?? this.totalStudyTimeHours,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
      totalAchievements: totalAchievements ?? this.totalAchievements,
      subjectProgress: subjectProgress ?? this.subjectProgress,
      recentActivities: recentActivities ?? this.recentActivities,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      weeklyGoalLessons: weeklyGoalLessons ?? this.weeklyGoalLessons,
      weeklyCompletedLessons:
          weeklyCompletedLessons ?? this.weeklyCompletedLessons,
    );
  }

  /// Calculate overall learning progress (0.0 to 1.0)
  double get overallProgress {
    if (subjectProgress.isEmpty) return 0.0;
    final totalProgress = subjectProgress.values
        .map((progress) => progress.completionPercentage)
        .reduce((a, b) => a + b);
    return totalProgress / subjectProgress.length / 100;
  }

  /// Get weekly progress percentage
  double get weeklyProgress {
    if (weeklyGoalLessons == 0) return 0.0;
    return (weeklyCompletedLessons / weeklyGoalLessons).clamp(0.0, 1.0);
  }

  /// Check if user is on track for weekly goal
  bool get isOnTrackWeekly {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final daysPassed = now.difference(weekStart).inDays + 1;
    final expectedProgress = (daysPassed / 7) * weeklyGoalLessons;
    return weeklyCompletedLessons >= expectedProgress;
  }

  /// Get study streak status
  StreakStatus get streakStatus {
    final now = DateTime.now();
    final daysSinceLastStudy = now.difference(lastStudyDate).inDays;

    if (daysSinceLastStudy == 0) {
      return StreakStatus.active;
    } else if (daysSinceLastStudy == 1) {
      return StreakStatus.pending;
    } else {
      return StreakStatus.broken;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'totalLessonsCompleted': totalLessonsCompleted,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalStudyTimeHours': totalStudyTimeHours,
      'achievementsUnlocked': achievementsUnlocked,
      'totalAchievements': totalAchievements,
      'subjectProgress': subjectProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'recentActivities': recentActivities
          .map((activity) => activity.toJson())
          .toList(),
      'lastStudyDate': lastStudyDate.toIso8601String(),
      'weeklyGoalLessons': weeklyGoalLessons,
      'weeklyCompletedLessons': weeklyCompletedLessons,
    };
  }

  factory LearningStats.fromJson(Map<String, dynamic> json) {
    return LearningStats(
      totalLessonsCompleted: json['totalLessonsCompleted'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalStudyTimeHours: (json['totalStudyTimeHours'] ?? 0.0).toDouble(),
      achievementsUnlocked: json['achievementsUnlocked'] ?? 0,
      totalAchievements: json['totalAchievements'] ?? 0,
      subjectProgress: Map<String, SubjectProgress>.from(
        (json['subjectProgress'] ?? {}).map(
          (key, value) => MapEntry(key, SubjectProgress.fromJson(value)),
        ),
      ),
      recentActivities: (json['recentActivities'] as List<dynamic>? ?? [])
          .map((activity) => RecentActivity.fromJson(activity))
          .toList(),
      lastStudyDate: DateTime.parse(
        json['lastStudyDate'] ?? DateTime.now().toIso8601String(),
      ),
      weeklyGoalLessons: json['weeklyGoalLessons'] ?? 5,
      weeklyCompletedLessons: json['weeklyCompletedLessons'] ?? 0,
    );
  }

  /// Create empty stats for new users
  factory LearningStats.empty() {
    return LearningStats(
      totalLessonsCompleted: 0,
      currentStreak: 0,
      longestStreak: 0,
      totalStudyTimeHours: 0.0,
      achievementsUnlocked: 0,
      totalAchievements: 24, // Total available achievements
      subjectProgress: {},
      recentActivities: [],
      lastStudyDate: DateTime.now().subtract(const Duration(days: 1)),
      weeklyGoalLessons: 5,
      weeklyCompletedLessons: 0,
    );
  }
}

/// Progress tracking for individual subjects
class SubjectProgress {
  final String subjectId;
  final String subjectName;
  final int totalLessons;
  final int completedLessons;
  final double timeSpentHours;
  final double averageScore;
  final DateTime lastStudied;
  final int currentLevel;
  final double nextLevelProgress;

  const SubjectProgress({
    required this.subjectId,
    required this.subjectName,
    required this.totalLessons,
    required this.completedLessons,
    required this.timeSpentHours,
    required this.averageScore,
    required this.lastStudied,
    required this.currentLevel,
    required this.nextLevelProgress,
  });

  /// Calculate completion percentage
  double get completionPercentage {
    if (totalLessons == 0) return 0.0;
    return (completedLessons / totalLessons * 100).clamp(0.0, 100.0);
  }

  /// Check if recently studied (within 7 days)
  bool get isRecentlyStudied {
    return DateTime.now().difference(lastStudied).inDays <= 7;
  }

  SubjectProgress copyWith({
    String? subjectId,
    String? subjectName,
    int? totalLessons,
    int? completedLessons,
    double? timeSpentHours,
    double? averageScore,
    DateTime? lastStudied,
    int? currentLevel,
    double? nextLevelProgress,
  }) {
    return SubjectProgress(
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      totalLessons: totalLessons ?? this.totalLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      timeSpentHours: timeSpentHours ?? this.timeSpentHours,
      averageScore: averageScore ?? this.averageScore,
      lastStudied: lastStudied ?? this.lastStudied,
      currentLevel: currentLevel ?? this.currentLevel,
      nextLevelProgress: nextLevelProgress ?? this.nextLevelProgress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'timeSpentHours': timeSpentHours,
      'averageScore': averageScore,
      'lastStudied': lastStudied.toIso8601String(),
      'currentLevel': currentLevel,
      'nextLevelProgress': nextLevelProgress,
    };
  }

  factory SubjectProgress.fromJson(Map<String, dynamic> json) {
    return SubjectProgress(
      subjectId: json['subjectId'] ?? '',
      subjectName: json['subjectName'] ?? '',
      totalLessons: json['totalLessons'] ?? 0,
      completedLessons: json['completedLessons'] ?? 0,
      timeSpentHours: (json['timeSpentHours'] ?? 0.0).toDouble(),
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      lastStudied: DateTime.parse(
        json['lastStudied'] ?? DateTime.now().toIso8601String(),
      ),
      currentLevel: json['currentLevel'] ?? 1,
      nextLevelProgress: (json['nextLevelProgress'] ?? 0.0).toDouble(),
    );
  }
}

/// Recent learning activities for timeline
class RecentActivity {
  final String id;
  final RecentActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String? subjectId;
  final String? lessonId;
  final String? achievementId;
  final Map<String, dynamic>? metadata;

  const RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.subjectId,
    this.lessonId,
    this.achievementId,
    this.metadata,
  });

  RecentActivity copyWith({
    String? id,
    RecentActivityType? type,
    String? title,
    String? description,
    DateTime? timestamp,
    String? subjectId,
    String? lessonId,
    String? achievementId,
    Map<String, dynamic>? metadata,
  }) {
    return RecentActivity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      subjectId: subjectId ?? this.subjectId,
      lessonId: lessonId ?? this.lessonId,
      achievementId: achievementId ?? this.achievementId,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'subjectId': subjectId,
      'lessonId': lessonId,
      'achievementId': achievementId,
      'metadata': metadata,
    };
  }

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'] ?? '',
      type: RecentActivityType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => RecentActivityType.other,
      ),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      subjectId: json['subjectId'],
      lessonId: json['lessonId'],
      achievementId: json['achievementId'],
      metadata: json['metadata'],
    );
  }
}

/// Types of recent activities
enum RecentActivityType {
  lessonCompleted,
  achievementUnlocked,
  streakMilestone,
  levelUp,
  quizPassed,
  practiceSession,
  helpyInteraction,
  goalReached,
  other,
}

/// Study streak status
enum StreakStatus {
  active, // Studied today
  pending, // Haven't studied today but streak not broken
  broken, // Streak is broken
}

/// Daily tips from Helpy
class DailyTip {
  final String id;
  final String title;
  final String content;
  final String category;
  final DateTime date;
  final String helpyPersonality;
  final String? iconName;

  const DailyTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.date,
    required this.helpyPersonality,
    this.iconName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'date': date.toIso8601String(),
      'helpyPersonality': helpyPersonality,
      'iconName': iconName,
    };
  }

  factory DailyTip.fromJson(Map<String, dynamic> json) {
    return DailyTip(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      helpyPersonality: json['helpyPersonality'] ?? 'friendly',
      iconName: json['iconName'],
    );
  }
}
