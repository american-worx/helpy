import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/learning_stats.dart';

/// Dashboard state notifier for managing learning statistics
class DashboardNotifier extends StateNotifier<DashboardState> {
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

  DashboardNotifier() : super(const DashboardState()) {
    _logger.d('DashboardNotifier initialized');
    _initializeDashboard();
  }

  late Box _dashboardBox;

  /// Initialize dashboard data
  Future<void> _initializeDashboard() async {
    _logger.d('Initializing dashboard data');
    state = state.copyWith(isLoading: true);

    try {
      _dashboardBox = await Hive.openBox('dashboard');
      _logger.d('Dashboard box opened successfully');

      // Load cached learning stats
      final cachedStats = _dashboardBox.get('learning_stats');
      LearningStats stats;

      if (cachedStats != null) {
        stats = LearningStats.fromJson(Map<String, dynamic>.from(cachedStats));
        _logger.d('Loaded cached learning stats');
      } else {
        // Create initial stats for new users
        stats = _createMockLearningStats();
        await _saveLearningStats(stats);
        _logger.d('Created mock learning stats for new user');
      }

      // Load daily tip
      final dailyTip = _generateDailyTip();

      state = state.copyWith(
        learningStats: stats,
        dailyTip: dailyTip,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
      _logger.d('Dashboard state updated successfully');
    } catch (e) {
      _logger.e('Failed to load dashboard data: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard data: $e',
      );
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    _logger.d('Refreshing dashboard data');
    state = state.copyWith(isLoading: true, error: null);

    try {
      // In a real app, this would fetch from API
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      final updatedStats = state.learningStats ?? _createMockLearningStats();
      final dailyTip = _generateDailyTip();

      state = state.copyWith(
        learningStats: updatedStats,
        dailyTip: dailyTip,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
      _logger.d('Dashboard data refreshed successfully');

      await _saveLearningStats(updatedStats);
    } catch (e) {
      _logger.e('Failed to refresh dashboard: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to refresh dashboard: $e',
      );
    }
  }

  /// Update learning progress (e.g., when completing a lesson)
  Future<void> updateProgress({
    String? completedLessonId,
    String? subjectId,
    double? studyTimeMinutes,
    double? quizScore,
  }) async {
    _logger.d(
      'Updating learning progress - completedLessonId: $completedLessonId, subjectId: $subjectId, studyTimeMinutes: $studyTimeMinutes, quizScore: $quizScore',
    );

    final currentStats = state.learningStats;
    if (currentStats == null) {
      _logger.w('Current stats are null, cannot update progress');
      return;
    }

    try {
      // Update lesson completion
      int newLessonsCompleted = currentStats.totalLessonsCompleted;
      if (completedLessonId != null) {
        newLessonsCompleted += 1;
        _logger.d('Incremented lessons completed to $newLessonsCompleted');
      }

      // Update study time
      double newStudyTime = currentStats.totalStudyTimeHours;
      if (studyTimeMinutes != null) {
        newStudyTime += studyTimeMinutes / 60;
        _logger.d('Updated study time to $newStudyTime hours');
      }

      // Update streak
      final now = DateTime.now();
      final lastStudy = currentStats.lastStudyDate;
      int newStreak = currentStats.currentStreak;

      if (_isSameDay(now, lastStudy)) {
        // Same day, keep streak
        _logger.d('Same day study, keeping streak of $newStreak');
      } else if (_isConsecutiveDay(now, lastStudy)) {
        // Next day, increment streak
        newStreak += 1;
        _logger.d('Consecutive day study, incremented streak to $newStreak');
      } else {
        // Streak broken, reset to 1
        newStreak = 1;
        _logger.d('Streak broken, resetting to $newStreak');
      }

      // Update subject progress
      final updatedSubjectProgress = Map<String, SubjectProgress>.from(
        currentStats.subjectProgress,
      );
      if (subjectId != null && updatedSubjectProgress.containsKey(subjectId)) {
        final subjectProgress = updatedSubjectProgress[subjectId]!;
        updatedSubjectProgress[subjectId] = subjectProgress.copyWith(
          completedLessons: subjectProgress.completedLessons + 1,
          timeSpentHours:
              subjectProgress.timeSpentHours + (studyTimeMinutes ?? 0) / 60,
          lastStudied: now,
        );
        _logger.d('Updated subject progress for $subjectId');
      }

      // Add recent activity
      final newActivities = List<RecentActivity>.from(
        currentStats.recentActivities,
      );
      if (completedLessonId != null) {
        newActivities.insert(
          0,
          RecentActivity(
            id: 'activity_${DateTime.now().millisecondsSinceEpoch}',
            type: RecentActivityType.lessonCompleted,
            title: 'Lesson Completed',
            description: 'Great job finishing your lesson!',
            timestamp: now,
            lessonId: completedLessonId,
            subjectId: subjectId,
          ),
        );
        // Keep only last 20 activities
        if (newActivities.length > 20) {
          newActivities.removeRange(20, newActivities.length);
        }
        _logger.d('Added recent activity for completed lesson');
      }

      final updatedStats = currentStats.copyWith(
        totalLessonsCompleted: newLessonsCompleted,
        totalStudyTimeHours: newStudyTime,
        currentStreak: newStreak,
        longestStreak: newStreak > currentStats.longestStreak
            ? newStreak
            : currentStats.longestStreak,
        subjectProgress: updatedSubjectProgress,
        recentActivities: newActivities,
        lastStudyDate: now,
      );

      state = state.copyWith(learningStats: updatedStats);
      await _saveLearningStats(updatedStats);
      _logger.d('Progress updated successfully');
    } catch (e) {
      _logger.e('Failed to update progress: $e');
      // Handle error silently in production, log in debug
      debugPrint('Failed to update progress: $e');
    }
  }

  /// Mark achievement as unlocked
  Future<void> unlockAchievement(
    String achievementId,
    String title,
    String description, {
    String? category,
    int points = 10,
  }) async {
    _logger.d(
      'Unlocking achievement - achievementId: $achievementId, title: $title, category: $category, points: $points',
    );

    final currentStats = state.learningStats;
    if (currentStats == null) {
      _logger.w('Current stats are null, cannot unlock achievement');
      return;
    }

    try {
      final newActivities = List<RecentActivity>.from(
        currentStats.recentActivities,
      );
      newActivities.insert(
        0,
        RecentActivity(
          id: 'achievement_${DateTime.now().millisecondsSinceEpoch}',
          type: RecentActivityType.achievementUnlocked,
          title: 'Achievement Unlocked: $title',
          description: description,
          timestamp: DateTime.now(),
          achievementId: achievementId,
        ),
      );

      final updatedStats = currentStats.copyWith(
        achievementsUnlocked: currentStats.achievementsUnlocked + 1,
        recentActivities: newActivities,
      );

      state = state.copyWith(learningStats: updatedStats);
      await _saveLearningStats(updatedStats);
      _logger.d('Achievement unlocked successfully');
    } catch (e) {
      _logger.e('Failed to unlock achievement: $e');
      debugPrint('Failed to unlock achievement: $e');
    }
  }

  /// Check if user has earned a specific achievement
  bool hasAchievement(String achievementId) {
    final currentStats = state.learningStats;
    if (currentStats == null) return false;

    // In a real implementation, we would check against stored achievements
    // For now, we'll use a simple mock implementation
    final unlockedAchievements = ['first_steps', 'quick_learner', 'night_owl'];

    return unlockedAchievements.contains(achievementId);
  }

  /// Get progress toward earning an achievement
  double getAchievementProgress(String achievementId) {
    final currentStats = state.learningStats;
    if (currentStats == null) return 0.0;

    // Mock implementation - in a real app, this would check actual progress
    switch (achievementId) {
      case 'streak_master':
        return (currentStats.currentStreak / 7).clamp(0.0, 1.0);
      case 'quiz_champion':
        // Mock: 1 out of 3 quizzes completed
        return (1 / 3).clamp(0.0, 1.0);
      case 'subject_master':
        // Mock: 2 out of 15 lessons completed in a subject
        return (2 / 15).clamp(0.0, 1.0);
      default:
        return 0.0;
    }
  }

  /// Track study time for analytics
  Future<void> trackStudyTime({
    required String subjectId,
    required double minutes,
  }) async {
    _logger.d('Tracking study time - subjectId: $subjectId, minutes: $minutes');
    final currentStats = state.learningStats;
    if (currentStats == null) {
      _logger.w('Cannot track study time: learning stats are null');
      return;
    }

    try {
      // Update subject progress with study time
      final updatedSubjectProgress = Map<String, SubjectProgress>.from(
        currentStats.subjectProgress,
      );

      if (updatedSubjectProgress.containsKey(subjectId)) {
        final subjectProgress = updatedSubjectProgress[subjectId]!;
        updatedSubjectProgress[subjectId] = subjectProgress.copyWith(
          timeSpentHours: subjectProgress.timeSpentHours + (minutes / 60),
          lastStudied: DateTime.now(),
        );
        _logger.d('Updated subject progress for: $subjectId');
      }

      final updatedStats = currentStats.copyWith(
        totalStudyTimeHours: currentStats.totalStudyTimeHours + (minutes / 60),
        subjectProgress: updatedSubjectProgress,
      );

      state = state.copyWith(learningStats: updatedStats);
      await _saveLearningStats(updatedStats);
      _logger.d('Study time tracked successfully');
    } catch (e) {
      _logger.e('Failed to track study time: $e');
      debugPrint('Failed to track study time: $e');
    }
  }

  /// Track quiz performance for analytics
  Future<void> trackQuizPerformance({
    required String subjectId,
    required double score,
    required int questionsAnswered,
    required int correctAnswers,
  }) async {
    _logger.d(
      'Tracking quiz performance - subjectId: $subjectId, score: $score, questions: $questionsAnswered, correct: $correctAnswers',
    );
    final currentStats = state.learningStats;
    if (currentStats == null) {
      _logger.w('Cannot track quiz performance: learning stats are null');
      return;
    }

    try {
      // Update subject progress with quiz performance
      final updatedSubjectProgress = Map<String, SubjectProgress>.from(
        currentStats.subjectProgress,
      );

      if (updatedSubjectProgress.containsKey(subjectId)) {
        final subjectProgress = updatedSubjectProgress[subjectId]!;
        final newAverageScore =
            ((subjectProgress.averageScore * subjectProgress.completedLessons) +
                score) /
            (subjectProgress.completedLessons + 1);

        updatedSubjectProgress[subjectId] = subjectProgress.copyWith(
          averageScore: newAverageScore,
        );
        _logger.d(
          'Updated quiz performance for subject: $subjectId, new average: $newAverageScore',
        );
      }

      final updatedStats = currentStats.copyWith(
        subjectProgress: updatedSubjectProgress,
      );

      state = state.copyWith(learningStats: updatedStats);
      await _saveLearningStats(updatedStats);
      _logger.d('Quiz performance tracked successfully');
    } catch (e) {
      _logger.e('Failed to track quiz performance: $e');
      debugPrint('Failed to track quiz performance: $e');
    }
  }

  /// Update weekly goal progress
  Future<void> updateWeeklyGoalProgress(int lessonsCompleted) async {
    _logger.d(
      'Updating weekly goal progress - lessonsCompleted: $lessonsCompleted',
    );
    final currentStats = state.learningStats;
    if (currentStats == null) {
      _logger.w('Cannot update weekly goal progress: learning stats are null');
      return;
    }

    try {
      final updatedStats = currentStats.copyWith(
        weeklyCompletedLessons: lessonsCompleted,
      );

      state = state.copyWith(learningStats: updatedStats);
      await _saveLearningStats(updatedStats);
      _logger.d('Weekly goal progress updated successfully');
    } catch (e) {
      _logger.e('Failed to update weekly goal progress: $e');
      debugPrint('Failed to update weekly goal progress: $e');
    }
  }

  /// Save learning stats to local storage
  Future<void> _saveLearningStats(LearningStats stats) async {
    _logger.d('Saving learning stats to local storage');
    try {
      await _dashboardBox.put('learning_stats', stats.toJson());
      _logger.d('Learning stats saved successfully');
    } catch (e) {
      _logger.e('Failed to save learning stats: $e');
      debugPrint('Failed to save learning stats: $e');
    }
  }

  /// Generate daily tip from Helpy
  DailyTip _generateDailyTip() {
    final tips = [
      DailyTip(
        id: 'tip_1',
        title: 'Study Smart! 🧠',
        content:
            'Break your study sessions into 25-minute focused chunks with 5-minute breaks. This technique helps maintain concentration and prevents burnout.',
        category: 'study_tips',
        date: DateTime.now(),
        helpyPersonality: 'friendly',
        iconName: 'brain',
      ),
      DailyTip(
        id: 'tip_2',
        title: 'Practice Makes Perfect! 💪',
        content:
            'Regular practice is more effective than cramming. Try to study a little bit every day rather than long sessions once in a while.',
        category: 'motivation',
        date: DateTime.now(),
        helpyPersonality: 'encouraging',
        iconName: 'muscle',
      ),
      DailyTip(
        id: 'tip_3',
        title: 'Ask Questions! ❓',
        content:
            'Don\'t hesitate to ask me questions when you\'re stuck. I\'m here to help you understand concepts, not just memorize them.',
        category: 'learning',
        date: DateTime.now(),
        helpyPersonality: 'wise',
        iconName: 'question',
      ),
    ];

    // Select tip based on current day
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    return tips[dayOfYear % tips.length];
  }

  /// Get appropriate greeting based on time of day
  /// Note: This method takes localization as parameter since l10n requires BuildContext
  String getGreeting(dynamic l10n) {
    final currentHour = DateTime.now().hour;
    _logger.d('Getting greeting for hour: $currentHour');

    if (currentHour < 12) {
      _logger.d('Returning morning greeting');
      return l10n.goodMorning;
    } else if (currentHour < 17) {
      _logger.d('Returning afternoon greeting');
      return l10n.goodAfternoon;
    } else {
      _logger.d('Returning evening greeting');
      return l10n.goodEvening;
    }
  }

  /// Create mock learning stats for development/demo
  LearningStats _createMockLearningStats() {
    final now = DateTime.now();

    return LearningStats(
      totalLessonsCompleted: 23,
      currentStreak: 5,
      longestStreak: 12,
      totalStudyTimeHours: 8.5,
      achievementsUnlocked: 6,
      totalAchievements: 24,
      subjectProgress: {
        'mathematics': SubjectProgress(
          subjectId: 'mathematics',
          subjectName: 'Mathematics',
          totalLessons: 15,
          completedLessons: 8,
          timeSpentHours: 3.2,
          averageScore: 87.5,
          lastStudied: now.subtract(const Duration(hours: 2)),
          currentLevel: 3,
          nextLevelProgress: 0.6,
        ),
        'physics': SubjectProgress(
          subjectId: 'physics',
          subjectName: 'Physics',
          totalLessons: 12,
          completedLessons: 5,
          timeSpentHours: 2.1,
          averageScore: 92.0,
          lastStudied: now.subtract(const Duration(days: 1)),
          currentLevel: 2,
          nextLevelProgress: 0.3,
        ),
        'chemistry': SubjectProgress(
          subjectId: 'chemistry',
          subjectName: 'Chemistry',
          totalLessons: 18,
          completedLessons: 10,
          timeSpentHours: 3.2,
          averageScore: 84.3,
          lastStudied: now.subtract(const Duration(hours: 6)),
          currentLevel: 4,
          nextLevelProgress: 0.8,
        ),
      },
      recentActivities: [
        RecentActivity(
          id: 'activity_1',
          type: RecentActivityType.lessonCompleted,
          title: 'Completed: Quadratic Equations',
          description: 'Excellent work on understanding quadratic formulas!',
          timestamp: now.subtract(const Duration(hours: 2)),
          subjectId: 'mathematics',
          lessonId: 'math_lesson_8',
        ),
        RecentActivity(
          id: 'activity_2',
          type: RecentActivityType.achievementUnlocked,
          title: 'Achievement: Math Streak Master',
          description: 'Completed 5 math lessons in a row!',
          timestamp: now.subtract(const Duration(hours: 3)),
          achievementId: 'math_streak_5',
        ),
        RecentActivity(
          id: 'activity_3',
          type: RecentActivityType.streakMilestone,
          title: 'Study Streak: 5 Days',
          description: 'Keep up the great work!',
          timestamp: now.subtract(const Duration(days: 1)),
        ),
      ],
      lastStudyDate: now.subtract(const Duration(hours: 2)),
      weeklyGoalLessons: 7,
      weeklyCompletedLessons: 5,
    );
  }

  /// Helper methods for date comparison
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isConsecutiveDay(DateTime current, DateTime previous) {
    final difference = current.difference(previous).inDays;
    return difference == 1;
  }

  /// Clear error state
  void clearError() {
    _logger.d('Clearing error state');
    state = state.copyWith(error: null);
    _logger.d('Error state cleared');
  }
}

/// Dashboard state model
class DashboardState {
  final LearningStats? learningStats;
  final DailyTip? dailyTip;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const DashboardState({
    this.learningStats,
    this.dailyTip,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  DashboardState copyWith({
    LearningStats? learningStats,
    DailyTip? dailyTip,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return DashboardState(
      learningStats: learningStats ?? this.learningStats,
      dailyTip: dailyTip ?? this.dailyTip,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Dashboard provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      return DashboardNotifier();
    });

/// Convenience providers
final learningStatsProvider = Provider<LearningStats?>((ref) {
  return ref.watch(dashboardProvider).learningStats;
});

final dailyTipProvider = Provider<DailyTip?>((ref) {
  return ref.watch(dashboardProvider).dailyTip;
});

final isDashboardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(dashboardProvider).isLoading;
});

final dashboardErrorProvider = Provider<String?>((ref) {
  return ref.watch(dashboardProvider).error;
});
