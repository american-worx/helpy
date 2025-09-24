import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/analytics/learning_analytics_service.dart';

/// Provider for performance trends analysis
class PerformanceTrendsNotifier extends StateNotifier<PerformanceTrendsState> {
  final Logger _logger = Logger();
  final LearningAnalyticsService _analyticsService;

  PerformanceTrendsNotifier(this._analyticsService) : super(const PerformanceTrendsState());

  /// Generate performance trends for a user
  Future<void> generateTrends(String userId, {Duration period = const Duration(days: 90)}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final trends = await _analyticsService.analyzePerformanceTrends(userId, period: period);
      
      state = state.copyWith(
        isLoading: false,
        trends: trends,
        lastUpdated: DateTime.now(),
      );

      _logger.d('Generated performance trends for user: $userId');
    } catch (e) {
      _logger.e('Failed to generate performance trends: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to generate performance trends: $e',
      );
    }
  }

  /// Get learning report for a user
  Future<void> generateReport(String userId, {DateTime? startDate, DateTime? endDate}) async {
    state = state.copyWith(isLoadingReport: true);

    try {
      final report = await _analyticsService.generateUserReport(userId, startDate: startDate, endDate: endDate);
      
      state = state.copyWith(
        isLoadingReport: false,
        currentReport: report,
      );

      _logger.d('Generated learning report for user: $userId');
    } catch (e) {
      _logger.e('Failed to generate learning report: $e');
      state = state.copyWith(
        isLoadingReport: false,
        error: 'Failed to generate learning report: $e',
      );
    }
  }

  /// Get personalized recommendations
  Future<void> generateRecommendations(String userId) async {
    try {
      final recommendations = await _analyticsService.generatePersonalizedRecommendations(userId);
      
      state = state.copyWith(
        recommendations: recommendations,
      );

      _logger.d('Generated ${recommendations.length} recommendations for user: $userId');
    } catch (e) {
      _logger.e('Failed to generate recommendations: $e');
    }
  }

  /// Track learning activity
  Future<void> trackActivity({
    required String userId,
    required String sessionId,
    required LearningActivity activity,
  }) async {
    try {
      await _analyticsService.trackLearningActivity(
        userId: userId,
        sessionId: sessionId,
        activity: activity,
      );

      _logger.d('Tracked learning activity for user: $userId');

      // Update trends if we have current data
      if (state.trends?.userId == userId) {
        await generateTrends(userId);
      }
    } catch (e) {
      _logger.e('Failed to track learning activity: $e');
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh all data for a user
  Future<void> refreshData(String userId) async {
    await Future.wait([
      generateTrends(userId),
      generateReport(userId),
      generateRecommendations(userId),
    ]);
  }
}

/// State for performance trends
class PerformanceTrendsState {
  final bool isLoading;
  final bool isLoadingReport;
  final PerformanceTrends? trends;
  final LearningReport? currentReport;
  final List<PersonalizedRecommendation> recommendations;
  final String? error;
  final DateTime? lastUpdated;

  const PerformanceTrendsState({
    this.isLoading = false,
    this.isLoadingReport = false,
    this.trends,
    this.currentReport,
    this.recommendations = const [],
    this.error,
    this.lastUpdated,
  });

  PerformanceTrendsState copyWith({
    bool? isLoading,
    bool? isLoadingReport,
    PerformanceTrends? trends,
    LearningReport? currentReport,
    List<PersonalizedRecommendation>? recommendations,
    String? error,
    DateTime? lastUpdated,
  }) {
    return PerformanceTrendsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingReport: isLoadingReport ?? this.isLoadingReport,
      trends: trends ?? this.trends,
      currentReport: currentReport ?? this.currentReport,
      recommendations: recommendations ?? this.recommendations,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Get overall performance score
  double get overallScore {
    if (trends == null) return 0.0;
    final lastPerformance = trends!.monthlyPerformance.isNotEmpty ? trends!.monthlyPerformance.last : 0.0;
    return (trends!.consistencyScore + 
            (trends!.improvementRate + 1) / 2 + 
            lastPerformance) / 3;
  }

  /// Check if data is stale (older than 1 hour)
  bool get isDataStale {
    if (lastUpdated == null) return true;
    return DateTime.now().difference(lastUpdated!).inHours > 1;
  }

  /// Get current learning streak
  int get currentStreak {
    if (currentReport == null) return 0;
    
    // Simple calculation - in real implementation this would be more sophisticated
    return currentReport!.totalSessions > 0 ? 
           (currentReport!.totalSessions / 7).round() : 0;
  }
}

/// Analytics service provider
final analyticsServiceProvider = Provider<LearningAnalyticsService>((ref) {
  return LearningAnalyticsService();
});

/// Performance trends provider
final performanceTrendsProvider = StateNotifierProvider<PerformanceTrendsNotifier, PerformanceTrendsState>((ref) {
  final analyticsService = ref.read(analyticsServiceProvider);
  return PerformanceTrendsNotifier(analyticsService);
});

/// Convenience providers

/// Provider for current user's trends
final userTrendsProvider = Provider.family<PerformanceTrends?, String>((ref, userId) {
  final state = ref.watch(performanceTrendsProvider);
  return state.trends?.userId == userId ? state.trends : null;
});

/// Provider for current user's report
final userReportProvider = Provider.family<LearningReport?, String>((ref, userId) {
  final state = ref.watch(performanceTrendsProvider);
  return state.currentReport?.userId == userId ? state.currentReport : null;
});

/// Provider for recommendations
final userRecommendationsProvider = Provider<List<PersonalizedRecommendation>>((ref) {
  return ref.watch(performanceTrendsProvider).recommendations;
});

/// Provider for loading states
final isTrendsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(performanceTrendsProvider).isLoading;
});

final isReportLoadingProvider = Provider<bool>((ref) {
  return ref.watch(performanceTrendsProvider).isLoadingReport;
});

/// Provider for error state
final trendsErrorProvider = Provider<String?>((ref) {
  return ref.watch(performanceTrendsProvider).error;
});

/// Provider for overall performance score
final overallPerformanceScoreProvider = Provider<double>((ref) {
  return ref.watch(performanceTrendsProvider).overallScore;
});

/// Provider for learning streak
final learningStreakProvider = Provider<int>((ref) {
  return ref.watch(performanceTrendsProvider).currentStreak;
});

/// Extension for list helper methods
extension ListExtension<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}