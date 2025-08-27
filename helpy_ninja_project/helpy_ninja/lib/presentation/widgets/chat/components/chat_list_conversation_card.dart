import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpy_ninja/data/providers/chat_provider.dart';
import 'package:helpy_ninja/presentation/widgets/auth/glassmorphic_container.dart';

import '../../../../config/design_tokens.dart';
import '../../../../domain/entities/conversation.dart';
import '../../../../domain/entities/helpy_personality.dart';
import '../../../../data/providers/providers.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

/// Conversation card for chat list
class ChatListConversationCard extends ConsumerWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final Function(String) onActionSelected;

  const ChatListConversationCard({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personality = ref.watch(
      helpyPersonalityProvider(conversation.helpyPersonalityId),
    );
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceM),
      child: GlassmorphicCard(
        onTap: onTap,
        child: Row(
          children: [
            // Personality avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: personality != null
                      ? [
                          Color(
                            int.parse(
                                  personality.colorTheme.substring(1),
                                  radix: 16,
                                ) |
                                0xFF000000,
                          ),
                          Color(
                            int.parse(
                                  personality.colorTheme.substring(1),
                                  radix: 16,
                                ) |
                                0xFF000000,
                          ).withValues(alpha: 0.8),
                        ]
                      : [DesignTokens.primary, DesignTokens.accent],
                ),
                borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              ),
              child: Center(
                child: Text(
                  personality?.icon ?? '🤖',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spaceM),

            // Conversation info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.displayTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessageTime != null)
                        Text(
                          conversation.formattedLastMessageTime,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceXS),
                  if (conversation.lastMessagePreview != null)
                    Text(
                      conversation.lastMessagePreview!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

            // Unread badge and actions
            Column(
              children: [
                if (conversation.hasUnreadMessages)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceS,
                      vertical: DesignTokens.spaceXS,
                    ),
                    decoration: BoxDecoration(
                      color: DesignTokens.accent,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                    ),
                    child: Text(
                      '${conversation.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: DesignTokens.spaceS),
                PopupMenuButton<String>(
                  onSelected: onActionSelected,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          const Icon(Icons.mark_email_read_rounded),
                          const SizedBox(width: 8),
                          Text(l10n.markAsRead),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'archive',
                      child: Row(
                        children: [
                          const Icon(Icons.archive_rounded),
                          const SizedBox(width: 8),
                          Text(l10n.archive),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_rounded,
                            color: DesignTokens.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.delete,
                            style: const TextStyle(color: DesignTokens.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
