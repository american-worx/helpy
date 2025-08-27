import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../config/design_tokens.dart';
import '../../../data/providers/dashboard_provider.dart';
import '../../../domain/entities/learning_stats.dart';
import '../../widgets/auth/glassmorphic_container.dart';

/// Progress analytics screen displaying detailed learning statistics and charts
class ProgressAnalyticsScreen extends ConsumerWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final learningStats = dashboardState.learningStats;

    if (learningStats == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly progress chart
            _buildWeeklyProgressChart(context, learningStats),

            const SizedBox(height: DesignTokens.spaceXL),

            // Subject progress charts
            _buildSubjectProgressCharts(context, learningStats),

            const SizedBox(height: DesignTokens.spaceXL),

            // Study time analytics
            _buildStudyTimeAnalytics(context, learningStats),

            const SizedBox(height: DesignTokens.spaceXL),

            // Streak analytics
            _buildStreakAnalytics(context, learningStats),
          ],
        ),
      ),
    );
  }

  /// Build weekly progress chart
  Widget _buildWeeklyProgressChart(BuildContext context, LearningStats stats) {
    // Sample weekly data - in a real app, this would come from the provider
    final weeklyData = [
      WeeklyProgressData('Mon', 3),
      WeeklyProgressData('Tue', 5),
      WeeklyProgressData('Wed', 2),
      WeeklyProgressData('Thu', 4),
      WeeklyProgressData('Fri', 6),
      WeeklyProgressData('Sat', 1),
      WeeklyProgressData('Sun', 3),
    ];

    return GlassmorphicContainer(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      borderRadius: DesignTokens.radiusL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: DesignTokens.spaceM),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelStyle: Theme.of(context).textTheme.bodySmall,
              ),
              primaryYAxis: NumericAxis(
                labelFormat: '{value}',
                labelStyle: Theme.of(context).textTheme.bodySmall,
              ),
              series: <CartesianSeries>[
                ColumnSeries<WeeklyProgressData, String>(
                  dataSource: weeklyData,
                  xValueMapper: (WeeklyProgressData data, _) => data.day,
                  yValueMapper: (WeeklyProgressData data, _) => data.lessons,
                  name: 'Lessons',
                  color: DesignTokens.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
              tooltipBehavior: TooltipBehavior(enable: true),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatChip(
                context,
                'Weekly Goal',
                '${stats.weeklyCompletedLessons}/${stats.weeklyGoalLessons}',
                stats.weeklyCompletedLessons >= stats.weeklyGoalLessons
                    ? DesignTokens.success
                    : DesignTokens.primary,
              ),
              _buildStatChip(
                context,
                'Average Per Day',
                '${(stats.weeklyCompletedLessons / 7).toStringAsFixed(1)} Lessons',
                DesignTokens.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build subject progress charts
  Widget _buildSubjectProgressCharts(
    BuildContext context,
    LearningStats stats,
  ) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      borderRadius: DesignTokens.radiusL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject Progress',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: DesignTokens.spaceM),
          ...stats.subjectProgress.values.map((subjectProgress) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subjectProgress.subjectName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${subjectProgress.completedLessons}/${subjectProgress.totalLessons}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spaceS),
                LinearProgressIndicator(
                  value:
                      subjectProgress.completedLessons /
                      subjectProgress.totalLessons,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(
                      subjectProgress.completedLessons /
                          subjectProgress.totalLessons,
                    ),
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: DesignTokens.spaceM),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Build study time analytics
  Widget _buildStudyTimeAnalytics(BuildContext context, LearningStats stats) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      borderRadius: DesignTokens.radiusL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Study Time Analytics',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: DesignTokens.spaceM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeStat(
                context,
                'Total Study Time',
                '${stats.totalStudyTimeHours.toStringAsFixed(1)}h',
                Icons.access_time,
                DesignTokens.primary,
              ),
              _buildTimeStat(
                context,
                'Average Per Session',
                '~32m',
                Icons.timer,
                DesignTokens.accent,
              ),
              _buildTimeStat(
                context,
                'Most Active',
                'Evening',
                Icons.nights_stay,
                DesignTokens.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build streak analytics
  Widget _buildStreakAnalytics(BuildContext context, LearningStats stats) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      borderRadius: DesignTokens.radiusL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Streak Analytics',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: DesignTokens.spaceM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStreakStat(
                context,
                'Current Streak',
                '${stats.currentStreak} Days',
                Icons.local_fire_department,
                DesignTokens.warning,
              ),
              _buildStreakStat(
                context,
                'Longest Streak',
                '${stats.longestStreak} Days',
                Icons.emoji_events,
                DesignTokens.accent,
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceM),
          Text(
            stats.currentStreak > 0
                ? 'Keep going, you\'re on fire! 🚒'
                : 'Start studying to build your streak',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build stat chip
  Widget _buildStatChip(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceM,
        vertical: DesignTokens.spaceS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build time stat
  Widget _buildTimeStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: DesignTokens.spaceXS),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build streak stat
  Widget _buildStreakStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: DesignTokens.spaceXS),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Get progress color based on completion percentage
  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return DesignTokens.success;
    if (progress >= 0.5) return DesignTokens.primary;
    if (progress >= 0.3) return DesignTokens.warning;
    return DesignTokens.error;
  }
}

/// Weekly progress data model
class WeeklyProgressData {
  final String day;
  final int lessons;

  WeeklyProgressData(this.day, this.lessons);
}
