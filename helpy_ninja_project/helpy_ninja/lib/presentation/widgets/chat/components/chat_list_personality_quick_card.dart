import 'package:flutter/material.dart';

import '../../../../config/design_tokens.dart';
import '../../../../domain/entities/helpy_personality.dart';

/// Quick personality selection card for chat list
class ChatListPersonalityQuickCard extends StatelessWidget {
  final HelpyPersonality personality;
  final VoidCallback onTap;

  const ChatListPersonalityQuickCard({
    super.key,
    required this.personality,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceM),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spaceM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(
                  int.parse(personality.colorTheme.substring(1), radix: 16) |
                      0xFF000000,
                ).withValues(alpha: 0.1),
                Color(
                  int.parse(personality.colorTheme.substring(1), radix: 16) |
                      0xFF000000,
                ).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            border: Border.all(
              color: Color(
                int.parse(personality.colorTheme.substring(1), radix: 16) |
                    0xFF000000,
              ).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(personality.colorTheme.substring(1), radix: 16) |
                        0xFF000000,
                  ),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
                child: Center(
                  child: Text(
                    personality.icon,
                    style: const TextStyle(fontSize: 24),
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
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: DesignTokens.spaceXS),
                    Text(
                      personality.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(
                  int.parse(personality.colorTheme.substring(1), radix: 16) |
                      0xFF000000,
                ),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
