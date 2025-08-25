import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/design_tokens.dart';

/// Gradient button with modern styling and micro-interactions
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.width,
    this.height = 56.0,
    this.gradient,
    this.textStyle,
    this.icon,
    this.borderRadius,
    this.elevation = 2.0,
    this.hapticFeedback = true,
  });

  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final double? width;
  final double height;
  final Gradient? gradient;
  final TextStyle? textStyle;
  final IconData? icon;
  final BorderRadius? borderRadius;
  final double elevation;
  final bool hapticFeedback;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isPressed = false;

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

    _elevationAnimation =
        Tween<double>(
          begin: widget.elevation,
          end: widget.elevation * 0.3,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final colorScheme = Theme.of(context).colorScheme;

    final gradient =
        widget.gradient ??
        const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DesignTokens.primary, DesignTokens.accent],
        );

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            elevation: _elevationAnimation.value,
            borderRadius:
                widget.borderRadius ??
                BorderRadius.circular(DesignTokens.radiusM),
            color: Colors.transparent,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: isEnabled
                    ? gradient
                    : LinearGradient(
                        colors: [
                          colorScheme.outline.withValues(alpha: 0.3),
                          colorScheme.outline.withValues(alpha: 0.2),
                        ],
                      ),
                borderRadius:
                    widget.borderRadius ??
                    BorderRadius.circular(DesignTokens.radiusM),
                boxShadow: isEnabled && !_isPressed
                    ? [
                        BoxShadow(
                          color: DesignTokens.primary.withValues(alpha: 0.3),
                          blurRadius: widget.elevation * 4,
                          offset: Offset(0, widget.elevation),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isEnabled ? _handleTap : null,
                  onTapDown: isEnabled ? _handleTapDown : null,
                  onTapUp: isEnabled ? _handleTapUp : null,
                  onTapCancel: isEnabled ? _handleTapCancel : null,
                  borderRadius:
                      widget.borderRadius ??
                      BorderRadius.circular(DesignTokens.radiusM),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceM,
                    ),
                    child: _buildContent(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceS),
          Text('Loading...', style: _getTextStyle()),
        ],
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, color: Colors.white, size: 20),
          const SizedBox(width: DesignTokens.spaceS),
          Text(widget.text, style: _getTextStyle()),
        ],
      );
    }

    return Text(widget.text, style: _getTextStyle());
  }

  TextStyle _getTextStyle() {
    return widget.textStyle ??
        Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ) ??
        const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        );
  }

  void _handleTap() {
    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onPressed?.call();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }
}

/// Secondary button variant with outline style
class OutlineButton extends StatelessWidget {
  const OutlineButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height = 56.0,
    this.borderColor,
    this.textColor,
    this.icon,
    this.borderRadius,
  });

  final VoidCallback? onPressed;
  final String text;
  final double? width;
  final double height;
  final Color? borderColor;
  final Color? textColor;
  final IconData? icon;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBorderColor = borderColor ?? DesignTokens.accent;
    final effectiveTextColor = textColor ?? DesignTokens.accent;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: onPressed != null
              ? effectiveBorderColor
              : colorScheme.outline.withValues(alpha: 0.3),
          width: 2,
        ),
        borderRadius:
            borderRadius ?? BorderRadius.circular(DesignTokens.radiusM),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius:
              borderRadius ?? BorderRadius.circular(DesignTokens.radiusM),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceM,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: onPressed != null
                        ? effectiveTextColor
                        : colorScheme.outline.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  const SizedBox(width: DesignTokens.spaceS),
                ],
                Text(
                  text,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: onPressed != null
                        ? effectiveTextColor
                        : colorScheme.outline.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
