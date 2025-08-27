import 'package:flutter/material.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

import '../../../../config/design_tokens.dart';
import '../../../../domain/entities/learning_stats.dart';
import '../../../widgets/layout/modern_layout.dart';
import 'progress_card.dart';

/// Progress overview section with learning statistics cards
class ProgressOverviewSection extends StatelessWidget {
  const ProgressOverviewSection({super.key, required this.learningStats});

  final LearningStats? learningStats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = learningStats;

    if (stats == null) {
      return const SizedBox.shrink();
    }

    return ModernSection(
      title: l10n.yourProgress,
      subtitle: l10n.keepUpTheGreatWork,
      showGlassmorphism: true,
      child: Column(
        children: [
          // First row - Lessons and Achievements
          Row(
            children: [
              Expanded(
                child: ProgressCard(
                  title: l10n.lessonsCompleted,
                  value: '${stats.totalLessonsCompleted}',
                  icon: Icons.school_rounded,
                  color: DesignTokens.primary,
                  trendIcon: Icons.trending_up,
                  onTap: () {
                    // Navigate to lessons
                  },
                ),
              ),
              const SizedBox(width: DesignTokens.spaceM),
              Expanded(
                child: ProgressCard(
                  title: l10n.achievements,
                  value:
                      '${stats.achievementsUnlocked}/${stats.totalAchievements}',
                  icon: Icons.emoji_events_rounded,
                  color: DesignTokens.accent,
                  progress:
                      stats.achievementsUnlocked / stats.totalAchievements,
                  onTap: () {
                    // Navigate to achievements
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceM),

          // Second row - Study Time and Weekly Goal
          Row(
            children: [
              Expanded(
                child: ProgressCard(
                  title: l10n.studyTime,
                  value: '${stats.totalStudyTimeHours.toStringAsFixed(1)}h',
                  icon: Icons.access_time_rounded,
                  color: DesignTokens.success,
                  trendIcon: Icons.schedule,
                  onTap: () {
                    // Navigate to time tracking
                  },
                ),
              ),
              const SizedBox(width: DesignTokens.spaceM),
              Expanded(
                child: ProgressCard(
                  title: l10n.weeklyGoal,
                  value:
                      '${stats.weeklyCompletedLessons}/${stats.weeklyGoalLessons}',
                  icon: Icons.flag_rounded,
                  color: stats.isOnTrackWeekly
                      ? DesignTokens.success
                      : DesignTokens.warning,
                  progress: stats.weeklyProgress,
                  subtitle: stats.isOnTrackWeekly
                      ? l10n.onTrack
                      : l10n.behindGoal,
                  onTap: () {
                    // Navigate to goals
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
