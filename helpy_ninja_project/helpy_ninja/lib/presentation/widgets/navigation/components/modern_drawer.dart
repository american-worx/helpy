import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../../../config/design_tokens.dart';
import '../../../../config/routes.dart';
import '../../../../data/providers/providers.dart';
import '../../auth/glassmorphic_container.dart';

/// Modern side drawer with glassmorphic design
class ModernDrawer extends ConsumerWidget {
  const ModernDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(DesignTokens.radiusXL),
        bottomRight: Radius.circular(DesignTokens.radiusXL),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.95),
            border: Border(
              right: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceL),
                  child: Column(
                    children: [
                      // Profile section
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [DesignTokens.primary, DesignTokens.accent],
                          ),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : 'U',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceM),
                      Text(
                        user?.name ?? 'Guest User',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user?.email != null) ...[
                        const SizedBox(height: DesignTokens.spaceXS),
                        Text(
                          user!.email,
                          style: Theme.of(context).textTheme.bodyMedium
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

                // Menu items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceM,
                    ),
                    children: [
                      _buildDrawerItem(
                        context,
                        Icons.home_outlined,
                        'Dashboard',
                        AppRoutes.dashboard,
                      ),
                      _buildDrawerItem(
                        context,
                        Icons.school_outlined,
                        'My Subjects',
                        AppRoutes.subjects,
                      ),
                      _buildDrawerItem(
                        context,
                        Icons.chat_bubble_outline,
                        'Chat with Helpy',
                        AppRoutes.chatList,
                      ),
                      _buildDrawerItem(
                        context,
                        Icons.trending_up_outlined,
                        'Progress',
                        AppRoutes.progress,
                      ),
                      const Divider(height: DesignTokens.spaceL),
                      _buildDrawerItem(
                        context,
                        Icons.settings_outlined,
                        'Settings',
                        AppRoutes.settings,
                      ),
                      _buildDrawerItem(
                        context,
                        Icons.help_outline,
                        'Help & Support',
                        '/help',
                      ),
                      _buildDrawerItem(
                        context,
                        Icons.feedback_outlined,
                        'Feedback',
                        '/feedback',
                      ),
                    ],
                  ),
                ),

                // Bottom section
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.spaceL),
                  child: Column(
                    children: [
                      const Divider(),
                      const SizedBox(height: DesignTokens.spaceM),
                      GlassmorphicCard(
                        onTap: () async {
                          await ref.read(authProvider.notifier).signOut();
                          if (context.mounted) {
                            context.go(AppRoutes.welcome);
                          }
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout_outlined,
                              color: DesignTokens.error,
                            ),
                            const SizedBox(width: DesignTokens.spaceM),
                            Text(
                              'Sign Out',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: DesignTokens.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    final currentLocation = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.path;
    final isSelected = currentLocation.startsWith(route);

    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spaceS),
      child: GlassmorphicCard(
        onTap: () {
          context.go(route);
          Navigator.of(context).pop(); // Close drawer
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? DesignTokens.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? DesignTokens.primary
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: DesignTokens.spaceM),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isSelected
                      ? DesignTokens.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
