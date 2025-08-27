import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

import '../../../config/design_tokens.dart';
import '../../../data/providers/dashboard_provider.dart';
import '../../widgets/cards/modern_cards.dart';
import '../../widgets/auth/glassmorphic_container.dart';

/// Achievements screen displaying user's unlocked achievements and progress analytics
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dashboardState = ref.watch(dashboardProvider);
    final learningStats = dashboardState.learningStats;

    if (learningStats == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final achievements =
        _generateSampleAchievements(); // In a real app, this would come from the provider
    final unlockedAchievements = achievements
        .where((a) => a.isUnlocked)
        .toList();
    final lockedAchievements = achievements
        .where((a) => !a.isUnlocked)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.achievements),
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
            // Header with achievement stats
            _buildAchievementStats(context, learningStats),

            const SizedBox(height: DesignTokens.spaceXL),

            // Unlocked achievements section
            if (unlockedAchievements.isNotEmpty) ...[
              Text(
                l10n.unlockedAchievements,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceM),
              _buildAchievementsGrid(context, unlockedAchievements),
              const SizedBox(height: DesignTokens.spaceXL),
            ],

            // Locked achievements section
            if (lockedAchievements.isNotEmpty) ...[
              Text(
                l10n.lockedAchievements,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceM),
              _buildAchievementsGrid(context, lockedAchievements),
            ],
          ],
        ),
      ),
    );
  }

  /// Build achievement stats header
  Widget _buildAchievementStats(BuildContext context, learningStats) {
    final l10n = AppLocalizations.of(context)!;
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      borderRadius: DesignTokens.radiusL,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context,
                learningStats.achievementsUnlocked.toString(),
                l10n.achievements,
                Icons.emoji_events_rounded,
                DesignTokens.accent,
              ),
              _buildStatItem(
                context,
                '${learningStats.achievementsUnlocked}/${learningStats.totalAchievements}',
                l10n.progressLabel,
                Icons.trending_up,
                DesignTokens.primary,
              ),
              _buildStatItem(
                context,
                '${((learningStats.achievementsUnlocked / learningStats.totalAchievements) * 100).round()}%',
                l10n.completionLabel,
                Icons.percent,
                DesignTokens.success,
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceM),
          LinearProgressIndicator(
            value:
                learningStats.achievementsUnlocked /
                learningStats.totalAchievements,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(
              DesignTokens.primary,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  /// Build individual stat item
  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: DesignTokens.spaceXS),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
        ),
      ],
    );
  }

  /// Build achievements grid
  Widget _buildAchievementsGrid(
    BuildContext context,
    List<SampleAchievement> achievements,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: DesignTokens.spaceM,
        mainAxisSpacing: DesignTokens.spaceM,
        childAspectRatio: 1.2,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return AchievementCard(
          title: achievement.title,
          description: achievement.description,
          icon: achievement.icon,
          color: achievement.color,
          isUnlocked: achievement.isUnlocked,
          progress: achievement.progress.toDouble(),
          maxProgress: achievement.maxProgress,
        );
      },
    );
  }

  /// Generate sample achievements for demonstration
  /// In a real app, these would come from the provider
  List<SampleAchievement> _generateSampleAchievements() {
    return [
      SampleAchievement(
        title: 'First Steps',
        description: 'Complete your first lesson',
        icon: Icons.directions_run,
        color: DesignTokens.primary,
        isUnlocked: true,
        progress: 1,
        maxProgress: 1,
      ),
      SampleAchievement(
        title: 'Quick Learner',
        description: 'Complete 5 lessons in one day',
        icon: Icons.bolt,
        color: DesignTokens.accent,
        isUnlocked: true,
        progress: 5,
        maxProgress: 5,
      ),
      SampleAchievement(
        title: 'Streak Master',
        description: 'Maintain a 7-day study streak',
        icon: Icons.local_fire_department,
        color: DesignTokens.success,
        isUnlocked: false,
        progress: 3,
        maxProgress: 7,
      ),
      SampleAchievement(
        title: 'Quiz Champion',
        description: 'Score 100% on 3 quizzes',
        icon: Icons.quiz,
        color: DesignTokens.warning,
        isUnlocked: false,
        progress: 1,
        maxProgress: 3,
      ),
      SampleAchievement(
        title: 'Night Owl',
        description: 'Study between 10 PM and 5 AM',
        icon: Icons.nights_stay,
        color: DesignTokens.success,
        isUnlocked: true,
        progress: 1,
        maxProgress: 1,
      ),
      SampleAchievement(
        title: 'Subject Master',
        description: 'Complete all lessons in one subject',
        icon: Icons.school,
        color: DesignTokens.error,
        isUnlocked: false,
        progress: 2,
        maxProgress: 15,
      ),
    ];
  }
}

/// Sample achievement model for demonstration
class SampleAchievement {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final int progress;
  final int maxProgress;

  SampleAchievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
    required this.progress,
    required this.maxProgress,
  });
}
