import 'package:flutter/material.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';
import 'package:helpy_ninja/presentation/widgets/navigation/components/modern_app_bar.dart';

import '../../../../config/design_tokens.dart';

/// App bar for the chat list screen
class ChatListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int totalUnreadCount;
  final VoidCallback onNewChatPressed;

  const ChatListAppBar({
    super.key,
    required this.totalUnreadCount,
    required this.onNewChatPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ModernAppBar(
      title: l10n.chat,
      subtitle: totalUnreadCount > 0
          ? '$totalUnreadCount ${l10n.unreadMessages}'
          : null,
      showProfile: true,
      showNotifications: false,
      actions: [
        IconButton(
          onPressed: onNewChatPressed,
          icon: const Icon(Icons.add_rounded),
          style: IconButton.styleFrom(
            backgroundColor: DesignTokens.primary.withValues(alpha: 0.1),
            foregroundColor: DesignTokens.primary,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
