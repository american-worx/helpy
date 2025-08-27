import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../../../config/design_tokens.dart';
import '../../../../config/routes.dart';

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

  Widget _buildNavItem(BuildContext context, NavItem item, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
      ),
    );
  }

  static final List<NavItem> _navItems = [
    const NavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
      route: AppRoutes.dashboard,
    ),
    const NavItem(
      icon: Icons.chat_bubble_outline,
      selectedIcon: Icons.chat_bubble_rounded,
      label: 'Chat',
      route: AppRoutes.chatList,
    ),
    const NavItem(
      icon: Icons.school_outlined,
      selectedIcon: Icons.school_rounded,
      label: 'Learn',
      route: AppRoutes.subjects,
    ),
    const NavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
      route: AppRoutes.profile,
    ),
  ];
}

/// Navigation item data class
class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}
