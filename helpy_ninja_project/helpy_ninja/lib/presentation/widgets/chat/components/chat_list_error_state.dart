import 'package:flutter/material.dart';
import 'package:helpy_ninja/presentation/widgets/common/gradient_button.dart';
import 'package:helpy_ninja/presentation/widgets/layout/modern_layout.dart';

import '../../../../config/design_tokens.dart';

import 'package:helpy_ninja/l10n/app_localizations.dart';

/// Error state component for chat list
class ChatListErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ChatListErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: ModernSection(
        showGlassmorphism: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: DesignTokens.error,
            ),
            Space.m,
            Text(
              l10n.oopsSomethingWentWrong,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Space.s,
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            Space.l,
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
