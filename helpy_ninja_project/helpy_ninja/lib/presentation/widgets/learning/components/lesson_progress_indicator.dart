import 'package:flutter/material.dart';

import '../../../../config/design_tokens.dart';
import '../../../../domain/entities/lesson.dart';

/// Progress indicator for lesson reading progress
class LessonProgressIndicator extends StatelessWidget {
  const LessonProgressIndicator({
    super.key,
    required this.lesson,
    required this.currentSectionIndex,
    required this.readingProgress,
    required this.progressAnimation,
  });

  final Lesson lesson;
  final int currentSectionIndex;
  final double readingProgress;
  final Animation<double> progressAnimation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Section progress
          if (lesson.sections.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Section ${currentSectionIndex + 1} of ${lesson.sections.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  lesson.sections.isNotEmpty
                      ? lesson.sections[currentSectionIndex].title
                      : '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spaceS),
          ],

          // Progress bar
          AnimatedBuilder(
            animation: progressAnimation,
            builder: (context, child) {
              final totalProgress = lesson.sections.isNotEmpty
                  ? (currentSectionIndex + readingProgress) /
                        lesson.sections.length
                  : readingProgress;

              return LinearProgressIndicator(
                value: totalProgress * progressAnimation.value,
                backgroundColor: DesignTokens.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(DesignTokens.primary),
                minHeight: 4,
              );
            },
          ),

          const SizedBox(height: DesignTokens.spaceS),

          // Reading time estimate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    lesson.formattedDuration,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              Text(
                '${(readingProgress * 100).round()}% complete',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: DesignTokens.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
