import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../config/design_tokens.dart';

/// Glassmorphic container widget that creates the modern glass effect
/// following the project specification for tech-conscious youth design
class GlassmorphicContainer extends StatelessWidget {
  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DesignTokens.spaceL),
    this.borderRadius = DesignTokens.radiusL,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.border = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final double opacity;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface.withValues(alpha: opacity + 0.05),
                colorScheme.surface.withValues(alpha: opacity),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border
                ? Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Glassmorphic card variant for smaller components
class GlassmorphicCard extends StatelessWidget {
  const GlassmorphicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DesignTokens.spaceM),
    this.onTap,
    this.elevation = 0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final container = GlassmorphicContainer(
      padding: padding,
      borderRadius: DesignTokens.radiusM,
      blur: 8.0,
      opacity: 0.08,
      child: child,
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            child: container,
          ),
        ),
      );
    }

    return container;
  }
}

/// Glassmorphic app bar for consistent styling
class GlassmorphicAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const GlassmorphicAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: AppBar(
          title: title,
          leading: leading,
          actions: actions,
          centerTitle: centerTitle,
          backgroundColor:
              backgroundColor ?? colorScheme.surface.withValues(alpha: 0.1),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          foregroundColor: colorScheme.onSurface,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
