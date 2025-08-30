import 'package:flutter/material.dart';
import 'package:helpy_ninja/config/design_tokens.dart';

/// AI coordination cue widget to visualize multi-agent coordination
class AICoordinationCue extends StatelessWidget {
  final String message;
  final Duration duration;
  final VoidCallback? onDismiss;

  const AICoordinationCue({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceS),
      margin: const EdgeInsets.all(DesignTokens.spaceS),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI icon
          Icon(
            Icons.auto_fix_high_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: DesignTokens.spaceXS),
          // Message text
          Flexible(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceXS),
          // Dismiss button
          IconButton(
            onPressed: onDismiss,
            icon: Icon(
              Icons.close_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
