import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/learning_stats.dart';

/// Dashboard state notifier for managing learning statistics
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState()) {
    _initializeDashboard();
  }

  late Box _dashboardBox;

  /// Initialize dashboard data
  Future<void> _initializeDashboard() async {
    state = state.copyWith(isLoading: true);

    try {
      _dashboardBox = await Hive.openBox('dashboard');

      // Load cached learning stats
      final cachedStats = _dashboardBox.get('learning_stats');
      LearningStats stats;

      if (cachedStats != null) {
        stats = LearningStats.fromJson(Map<String, dynamic>.from(cachedStats));
      } else {
        // Create initial stats for new users
        stats = _createMockLearningStats();
        await _saveLearningStats(stats);
      }

      // Load daily tip
      final dailyTip = _generateDailyTip();

      state = state.copyWith(
        learningStats: stats,
        dailyTip: dailyTip,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard data: $e',
      );
    }
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
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

      await _saveLearningStats(updatedStats);
    } catch (e) {
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
    final currentStats = state.learningStats;
    if (currentStats == null) return;

    try {
      // Update lesson completion
      int newLessonsCompleted = currentStats.totalLessonsCompleted;
      if (completedLessonId != null) {
        newLessonsCompleted += 1;
      }

      // Update study time
      double newStudyTime = currentStats.totalStudyTimeHours;
      if (studyTimeMinutes != null) {
        newStudyTime += studyTimeMinutes / 60;
      }

      // Update streak
      final now = DateTime.now();
      final lastStudy = currentStats.lastStudyDate;
      int newStreak = currentStats.currentStreak;

      if (_isSameDay(now, lastStudy)) {
        // Same day, keep streak
      } else if (_isConsecutiveDay(now, lastStudy)) {
        // Next day, increment streak
        newStreak += 1;
      } else {
        // Streak broken, reset to 1
        newStreak = 1;
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
    } catch (e) {
      // Handle error silently in production, log in debug
      debugPrint('Failed to update progress: $e');
    }
  }

  /// Mark achievement as unlocked
  Future<void> unlockAchievement(
    String achievementId,
    String title,
    String description,
  ) async {
    final currentStats = state.learningStats;
    if (currentStats == null) return;

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
    } catch (e) {
      debugPrint('Failed to unlock achievement: $e');
    }
  }

  /// Save learning stats to local storage
  Future<void> _saveLearningStats(LearningStats stats) async {
    try {
      await _dashboardBox.put('learning_stats', stats.toJson());
    } catch (e) {
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

    // Rotate tips based on day of year
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year))
        .inDays;
    return tips[dayOfYear % tips.length];
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
    state = state.copyWith(error: null);
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
