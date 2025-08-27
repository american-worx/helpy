import 'package:flutter/material.dart';

import '../../../../config/design_tokens.dart';
import '../../../../domain/entities/lesson.dart';
import '../../../widgets/common/gradient_button.dart';

/// Navigation controls for lesson viewer
class LessonNavigationControls extends StatelessWidget {
  const LessonNavigationControls({
    super.key,
    required this.lesson,
    required this.currentSectionIndex,
    required this.canGoBack,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onComplete,
  });

  final Lesson lesson;
  final int currentSectionIndex;
  final bool canGoBack;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final isLastSection = lesson.sections.isNotEmpty
        ? currentSectionIndex >= lesson.sections.length - 1
        : true;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Previous button
            if (canGoBack)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              )
            else
              const Expanded(child: SizedBox()),

            const SizedBox(width: DesignTokens.spaceM),

            // Next/Complete button
            Expanded(
              flex: 2,
              child: isLastSection
                  ? GradientButton(
                      onPressed: onComplete,
                      text: 'Complete Lesson',
                      icon: Icons.check_circle_rounded,
                    )
                  : GradientButton(
                      onPressed: canGoNext ? onNext : null,
                      text: 'Next',
                      icon: Icons.arrow_forward_rounded,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
