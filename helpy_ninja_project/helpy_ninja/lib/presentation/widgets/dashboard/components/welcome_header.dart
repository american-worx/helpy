import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

import '../../../../config/design_tokens.dart';
import '../../../../data/providers/dashboard_provider.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/entities/learning_stats.dart';
import '../../../widgets/auth/glassmorphic_container.dart';
import '../../../widgets/layout/modern_layout.dart';
import 'streak_display.dart';

/// Welcome header component with user greeting and streak display
class WelcomeHeader extends ConsumerWidget {
  const WelcomeHeader({
    super.key,
    required this.user,
    required this.learningStats,
    this.fadeAnimation,
    this.slideAnimation,
  });

  final User? user;
  final LearningStats? learningStats;
  final Animation<double>? fadeAnimation;
  final Animation<double>? slideAnimation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final greeting = ref.read(dashboardProvider.notifier).getGreeting(l10n);
    final userName = user?.name ?? 'Student';

    Widget child = GlassmorphicContainer(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: Row(
        children: [
          // Welcome text section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXS),
                Text(
                  userName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceS),
                Text(
                  l10n.readyToContinueLearning,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Streak display
          const SizedBox(width: DesignTokens.spaceM),
          StreakDisplay(streak: learningStats?.currentStreak ?? 0),
        ],
      ),
    );

    // Apply animations if provided
    if (slideAnimation != null) {
      child = Transform.translate(
        offset: Offset(0, slideAnimation!.value),
        child: child,
      );
    }

    if (fadeAnimation != null) {
      child = FadeTransition(opacity: fadeAnimation!, child: child);
    }

    return child;
  }
}
