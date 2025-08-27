import 'package:flutter/material.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

import '../../../../config/design_tokens.dart';

/// Animated streak display component
class StreakDisplay extends StatefulWidget {
  const StreakDisplay({super.key, required this.streak, this.scaleAnimation});

  final int streak;
  final Animation<double>? scaleAnimation;

  @override
  State<StreakDisplay> createState() => _StreakDisplayState();
}

class _StreakDisplayState extends State<StreakDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Create internal animation if none provided
    if (widget.scaleAnimation == null) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );

      _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
      );

      // Start animation with delay
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _animationController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.scaleAnimation == null) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final animation = widget.scaleAnimation ?? _scaleAnimation;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.spaceM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DesignTokens.primary.withValues(alpha: 0.1),
                  DesignTokens.accent.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              border: Border.all(
                color: DesignTokens.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [DesignTokens.primary, DesignTokens.accent],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceS),
                Text(
                  '${widget.streak}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.primary,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXS),
                Text(
                  widget.streak == 1 ? 'Day' : 'Days',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXS),
                Text(
                  l10n.streak,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
