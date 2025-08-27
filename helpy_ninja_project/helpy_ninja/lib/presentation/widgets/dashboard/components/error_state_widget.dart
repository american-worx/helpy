import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

import '../../../../config/design_tokens.dart';
import '../../../widgets/common/gradient_button.dart';
import '../../../widgets/layout/modern_layout.dart';

/// Reusable error state widget component
class ErrorStateWidget extends ConsumerWidget {
  const ErrorStateWidget({
    super.key,
    required this.error,
    required this.onRetry,
    this.title,
    this.icon = Icons.error_outline_rounded,
  });

  final String error;
  final VoidCallback onRetry;
  final String? title;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: ModernSection(
        showGlassmorphism: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: DesignTokens.error),
            const SizedBox(height: DesignTokens.spaceM),
            Text(
              title ?? l10n.oopsSomethingWentWrong,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: DesignTokens.spaceS),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.spaceL),
            GradientButton(
              onPressed: onRetry,
              text: l10n.tryAgain,
              icon: Icons.refresh_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
