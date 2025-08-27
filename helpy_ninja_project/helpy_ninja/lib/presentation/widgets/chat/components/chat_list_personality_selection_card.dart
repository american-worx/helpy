import 'package:flutter/material.dart';
import 'package:helpy_ninja/presentation/widgets/auth/glassmorphic_container.dart';

import '../../../../config/design_tokens.dart';
import '../../../../domain/entities/helpy_personality.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

/// Personality selection card for new chat options
class ChatListPersonalitySelectionCard extends StatelessWidget {
  final HelpyPersonality personality;
  final VoidCallback onTap;

  const ChatListPersonalitySelectionCard({
    super.key,
    required this.personality,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceM),
      child: GestureDetector(
        onTap: onTap,
        child: GlassmorphicCard(
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(personality.colorTheme.substring(1), radix: 16) |
                        0xFF000000,
                  ),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                ),
                child: Center(
                  child: Text(
                    personality.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personality.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceXS),
                    Text(
                      personality.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    if (personality.specializations.isNotEmpty) ...[
                      const SizedBox(height: DesignTokens.spaceS),
                      Wrap(
                        spacing: DesignTokens.spaceXS,
                        children: personality.specializations
                            .take(3)
                            .map(
                              (spec) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DesignTokens.spaceS,
                                  vertical: DesignTokens.spaceXS,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(
                                    int.parse(
                                          personality.colorTheme.substring(1),
                                          radix: 16,
                                        ) |
                                        0xFF000000,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusS,
                                  ),
                                ),
                                child: Text(
                                  spec,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Color(
                                          int.parse(
                                                personality.colorTheme
                                                    .substring(1),
                                                radix: 16,
                                              ) |
                                              0xFF000000,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(
                  int.parse(personality.colorTheme.substring(1), radix: 16) |
                      0xFF000000,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
