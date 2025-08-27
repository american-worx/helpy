import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../../../config/design_tokens.dart';
import '../../../../config/routes.dart';
import '../../../../data/providers/providers.dart';

/// Modern glassmorphic app bar with customizable design
class ModernAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ModernAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.showProfile = true,
    this.showNotifications = true,
    this.elevation = 0,
  });

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final bool showProfile;
  final bool showNotifications;
  final double elevation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color:
                backgroundColor ?? colorScheme.surface.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceM,
                vertical: DesignTokens.spaceS,
              ),
              child: Row(
                children: [
                  // Leading widget or back button
                  if (leading != null)
                    leading!
                  else if (context.canPop())
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surface.withValues(
                          alpha: 0.1,
                        ),
                        foregroundColor: colorScheme.onSurface,
                      ),
                    ),

                  // Title section
                  if (title != null) ...[
                    if (leading != null || context.canPop())
                      const SizedBox(width: DesignTokens.spaceM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: centerTitle
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title!,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ] else
                    const Spacer(),

                  // Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (actions != null) ...actions!,
                      if (showNotifications) ...[
                        const SizedBox(width: DesignTokens.spaceS),
                        _buildNotificationButton(context),
                      ],
                      if (showProfile && user != null) ...[
                        const SizedBox(width: DesignTokens.spaceS),
                        _buildProfileButton(context, user.name),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            // TODO: Navigate to notifications
          },
          icon: const Icon(Icons.notifications_outlined),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.1),
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        // Notification badge
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: DesignTokens.error,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileButton(BuildContext context, String userName) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.profile),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [DesignTokens.primary, DesignTokens.accent],
            ),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
