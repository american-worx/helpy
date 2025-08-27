import 'package:flutter/material.dart';

import '../../../../config/design_tokens.dart';

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
