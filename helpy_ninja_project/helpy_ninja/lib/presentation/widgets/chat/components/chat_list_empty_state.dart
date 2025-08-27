import 'package:flutter/material.dart';
import 'package:helpy_ninja/presentation/widgets/common/gradient_button.dart';
import 'package:helpy_ninja/presentation/widgets/layout/modern_layout.dart';

import '../../../../config/design_tokens.dart';
import '../../../../domain/entities/helpy_personality.dart';

import 'chat_list_personality_quick_card.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

/// Empty state component for chat list
class ChatListEmptyState extends StatelessWidget {
  final List<HelpyPersonality> personalities;
  final VoidCallback onStartFirstChat;
  final VoidCallback onSeeAllPersonalities;

  const ChatListEmptyState({
    super.key,
    required this.personalities,
    required this.onStartFirstChat,
    required this.onSeeAllPersonalities,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height -
              (AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  DesignTokens.spaceL * 2),
        ),
        child: Column(
          children: [
            // Animated Helpy illustration
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          DesignTokens.primary.withValues(alpha: 0.2),
                          DesignTokens.accent.withValues(alpha: 0.2),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      size: 60,
                      color: DesignTokens.primary,
                    ),
                  ),
                );
              },
            ),
            Space.xl,
            Text(
              l10n.startYourLearningJourney,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Space.m,
            Text(
              l10n.chooseHelpyPersonality,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            Space.xl,

            // Quick personality selection
            if (personalities.isNotEmpty) ...[
              ModernSection(
                title: l10n.chooseYourHelpy,
                showGlassmorphism: true,
                child: Column(
                  children: [
                    // Show first 3 personalities as quick options
                    ...personalities
                        .take(3)
                        .map(
                          (personality) => ChatListPersonalityQuickCard(
                            personality: personality,
                            onTap: onStartFirstChat,
                          ),
                        )
                        .toList(),
                    Space.m,
                    OutlineButton(
                      onPressed: onSeeAllPersonalities,
                      text: l10n.seeAllPersonalities,
                      icon: Icons.explore_rounded,
                    ),
                  ],
                ),
              ),
            ] else ...[
              GradientButton(
                onPressed: onStartFirstChat,
                text: l10n.startFirstChat,
                icon: Icons.smart_toy_rounded,
                width: double.infinity,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
