import 'package:flutter/material.dart';

import '../../../../config/design_tokens.dart';
import '../../../../domain/entities/learning_stats.dart';
import '../../../widgets/layout/modern_layout.dart';

/// Daily tip card component showing Helpy's advice
class DailyTipCard extends StatelessWidget {
  const DailyTipCard({super.key, required this.tip});

  final DailyTip? tip;

  @override
  Widget build(BuildContext context) {
    if (tip == null) return const SizedBox.shrink();

    return ModernSection(
      title: 'Daily Tip from Helpy',
      showGlassmorphism: true,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DesignTokens.primary, DesignTokens.accent],
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: DesignTokens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip!.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: DesignTokens.spaceXS),
                Text(
                  tip!.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
