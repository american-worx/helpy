import 'package:flutter/material.dart';
import 'package:helpy_ninja/presentation/widgets/dashboard/components/activity_item.dart';

import '../../../../config/design_tokens.dart';
import '../../../../domain/entities/learning_stats.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';
import '../../../widgets/layout/modern_layout.dart';

/// Recent activity section showing learning timeline
class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key, required this.activities});

  final List<RecentActivity> activities;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (activities.isEmpty) {
      return ModernSection(
        title: l10n.recentActivity,
        showGlassmorphism: true,
        child: Column(
          children: [
            Icon(
              Icons.history_rounded,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: DesignTokens.spaceM),
            Text(
              l10n.noRecentActivityYet,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: DesignTokens.spaceS),
            Text(
              l10n.startLearningToSeeProgress,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ModernSection(
      title: l10n.recentActivity,
      subtitle: l10n.yourLearningTimeline,
      headerAction: TextButton(
        onPressed: () {
          final l10n = AppLocalizations.of(context)!;
          // Navigate to full activity page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.fullActivityHistoryComingSoon),
              backgroundColor: DesignTokens.primary,
            ),
          );
        },
        child: Text(
          l10n.viewAll,
          style: TextStyle(
            color: DesignTokens.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      showGlassmorphism: true,
      child: Column(
        children: [
          // Take only the first 5 activities for dashboard
          ...activities
              .take(5)
              .map((activity) => ActivityItem(activity: activity))
              .toList(),

          if (activities.length > 5) ...[
            const SizedBox(height: DesignTokens.spaceM),
            Center(
              child: TextButton(
                onPressed: () {
                  final l10n = AppLocalizations.of(context)!;
                  // Navigate to full activity page
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.viewAllActivitiesComingSoon),
                      backgroundColor: DesignTokens.primary,
                    ),
                  );
                },
                child: Text(
                  '${l10n.view} ${activities.length - 5} ${l10n.moreActivities}',
                  style: TextStyle(
                    color: DesignTokens.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
