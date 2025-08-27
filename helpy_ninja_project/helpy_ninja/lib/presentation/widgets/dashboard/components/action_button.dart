import 'package:flutter/material.dart';

import '../../../../config/design_tokens.dart';

/// Reusable action button component for quick actions
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.color = DesignTokens.primary,
    this.variant = ActionButtonVariant.primary,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final ActionButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: DesignTokens.animationFast,
          padding: EdgeInsets.all(
            variant == ActionButtonVariant.tertiary 
                ? DesignTokens.spaceM 
                : DesignTokens.spaceL,
          ),
          decoration: BoxDecoration(
            gradient: _getGradient(),
            borderRadius: BorderRadius.circular(DesignTokens.radiusL),
            border: variant == ActionButtonVariant.tertiary 
                ? Border.all(
                    color: color.withValues(alpha: 0.3), 
                    width: 1,
                  )
                : null,
            boxShadow: variant == ActionButtonVariant.primary
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(
                  variant == ActionButtonVariant.tertiary 
                      ? DesignTokens.spaceS 
                      : DesignTokens.spaceM,
                ),
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
                child: Icon(
                  icon,
                  color: _getIconColor(),
                  size: variant == ActionButtonVariant.tertiary ? 20 : 28,
                ),
              ),
              SizedBox(height: variant == ActionButtonVariant.tertiary 
                  ? DesignTokens.spaceXS 
                  : DesignTokens.spaceS,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Gradient? _getGradient() {
    switch (variant) {
      case ActionButtonVariant.primary:
        return LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
        );
      case ActionButtonVariant.secondary:
        return LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        );
      case ActionButtonVariant.tertiary:
        return null;
    }
  }

  Color _getIconBackgroundColor() {
    switch (variant) {
      case ActionButtonVariant.primary:
        return Colors.white.withValues(alpha: 0.2);
      case ActionButtonVariant.secondary:
        return color.withValues(alpha: 0.2);
      case ActionButtonVariant.tertiary:
        return color.withValues(alpha: 0.1);
    }
  }

  Color _getIconColor() {
    switch (variant) {
      case ActionButtonVariant.primary:
        return Colors.white;
      case ActionButtonVariant.secondary:
      case ActionButtonVariant.tertiary:
        return color;
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case ActionButtonVariant.primary:
        return Colors.white;
      case ActionButtonVariant.secondary:
      case ActionButtonVariant.tertiary:
        return color;
    }
  }
}

/// Action button variants
enum ActionButtonVariant {
  primary,   // Filled with gradient and shadow
  secondary, // Light background with colored text
  tertiary,  // Border only with minimal styling
}