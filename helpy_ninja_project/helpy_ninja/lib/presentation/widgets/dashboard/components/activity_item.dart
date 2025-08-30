import 'package:flutter/material.dart';

import '../../../../config/design_tokens.dart';
import '../../../../domain/entities/learning_stats.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

/// Individual activity item component
class ActivityItem extends StatelessWidget {
  const ActivityItem({super.key, required this.activity});

  final RecentActivity activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceM),
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Activity icon based on type
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceS),
            decoration: BoxDecoration(
              color: _getActivityColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            child: Icon(
              _getActivityIcon(),
              color: _getActivityColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: DesignTokens.spaceM),

          // Activity content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(context, activity.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon() {
    switch (activity.type) {
      case RecentActivityType.lessonCompleted:
        return Icons.school_rounded;
      case RecentActivityType.achievementUnlocked:
        return Icons.emoji_events_rounded;
      case RecentActivityType.streakMilestone:
        return Icons.local_fire_department_rounded;
      case RecentActivityType.quizCompleted:
        return Icons.quiz_rounded;
      case RecentActivityType.subjectStarted:
        return Icons.explore_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _getActivityColor() {
    switch (activity.type) {
      case RecentActivityType.lessonCompleted:
        return DesignTokens.success;
      case RecentActivityType.achievementUnlocked:
        return DesignTokens.accent;
      case RecentActivityType.streakMilestone:
        return DesignTokens.primary;
      case RecentActivityType.quizCompleted:
        return DesignTokens.success;
      case RecentActivityType.subjectStarted:
        return DesignTokens.primary;
      default:
        return DesignTokens.primary;
    }
  }

  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inHours < 1) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }
}
