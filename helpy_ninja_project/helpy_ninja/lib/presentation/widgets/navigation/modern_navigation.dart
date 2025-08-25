import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../../config/design_tokens.dart';
import '../../../config/routes.dart';
import '../../../data/providers/providers.dart';
import '../auth/glassmorphic_container.dart';

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
    return GestureDetector(
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
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}

/// Modern bottom navigation bar with glassmorphic design
class ModernBottomNavBar extends ConsumerWidget {
  const ModernBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentLocation = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.path;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(DesignTokens.radiusL),
        topRight: Radius.circular(DesignTokens.radiusL),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceM,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _navItems.map((item) {
                  final isSelected = currentLocation.startsWith(item.route);
                  return _buildNavItem(context, item, isSelected);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, _NavItem item, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => context.go(item.route),
      child: AnimatedContainer(
        duration: DesignTokens.animationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceM,
          vertical: DesignTokens.spaceS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignTokens.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: DesignTokens.animationFast,
              scale: isSelected ? 1.1 : 1.0,
              child: Icon(
                isSelected ? item.selectedIcon : item.icon,
                color: isSelected
                    ? DesignTokens.primary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: DesignTokens.animationFast,
              style: TextStyle(
                color: isSelected
                    ? DesignTokens.primary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }

  static final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
      route: AppRoutes.dashboard,
    ),
    _NavItem(
      icon: Icons.chat_bubble_outline,
      selectedIcon: Icons.chat_bubble_rounded,
      label: 'Chat',
      route: AppRoutes.chatList,
    ),
    _NavItem(
      icon: Icons.school_outlined,
      selectedIcon: Icons.school_rounded,
      label: 'Learn',
      route: AppRoutes.subjects,
    ),
    _NavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
      route: AppRoutes.profile,
    ),
  ];
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}

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

/// Floating action button with modern design
class ModernFAB extends StatefulWidget {
  const ModernFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.heroTag,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Object? heroTag;

  @override
  State<ModernFAB> createState() => _ModernFABState();
}

class _ModernFABState extends State<ModernFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.animationFast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.backgroundColor ?? DesignTokens.primary,
                  (widget.backgroundColor ?? DesignTokens.primary).withValues(
                    alpha: 0.8,
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(
                widget.label != null ? DesignTokens.radiusL : 28,
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.backgroundColor ?? DesignTokens.primary)
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleTap,
                borderRadius: BorderRadius.circular(
                  widget.label != null ? DesignTokens.radiusL : 28,
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    widget.label != null ? DesignTokens.spaceM : 16,
                  ),
                  child: widget.label != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.icon,
                              color: widget.foregroundColor ?? Colors.white,
                            ),
                            const SizedBox(width: DesignTokens.spaceS),
                            Text(
                              widget.label!,
                              style: TextStyle(
                                color: widget.foregroundColor ?? Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Icon(
                          widget.icon,
                          color: widget.foregroundColor ?? Colors.white,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onPressed();
  }
}
