import 'package:flutter/material.dart';

import '../../../../config/design_tokens.dart';
import '../../../../domain/entities/learning_stats.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

/// Individual subject progress item component
class SubjectProgressItem extends StatelessWidget {
  const SubjectProgressItem({super.key, required this.subject});

  final SubjectProgress subject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = subject.completedLessons / subject.totalLessons;

    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  subject.subjectName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${subject.completedLessons}/${subject.totalLessons}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceXS),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: DesignTokens.primary.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(DesignTokens.primary),
            minHeight: 6,
          ),
          const SizedBox(height: DesignTokens.spaceXS),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.percentComplete((progress * 100).round()),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                '${subject.timeSpentHours.toStringAsFixed(1)}h',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
