import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../config/design_tokens.dart';
import '../auth/glassmorphic_container.dart';

/// Modern loading indicator with various styles
class ModernLoadingIndicator extends StatefulWidget {
  const ModernLoadingIndicator({
    super.key,
    this.size = 48.0,
    this.strokeWidth = 4.0,
    this.color,
    this.type = LoadingType.circular,
  });

  final double size;
  final double strokeWidth;
  final Color? color;
  final LoadingType type;

  @override
  State<ModernLoadingIndicator> createState() => _ModernLoadingIndicatorState();
}

class _ModernLoadingIndicatorState extends State<ModernLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    if (widget.type == LoadingType.pulse) {
      _scaleController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? DesignTokens.primary;

    switch (widget.type) {
      case LoadingType.circular:
        return _buildCircularIndicator(color);
      case LoadingType.pulse:
        return _buildPulseIndicator(color);
      case LoadingType.dots:
        return _buildDotsIndicator(color);
      case LoadingType.helpy:
        return _buildHelpyIndicator(color);
    }
  }

  Widget _buildCircularIndicator(Color color) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationController.value * 2 * math.pi,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    color.withValues(alpha: 0.1),
                    color,
                    color.withValues(alpha: 0.1),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Container(
                margin: EdgeInsets.all(widget.strokeWidth),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPulseIndicator(Color color) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.6),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDotsIndicator(Color color) {
    return SizedBox(
      width: widget.size,
      height: widget.size / 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              final delay = index * 0.2;
              final animationValue = (_rotationController.value + delay) % 1.0;
              final scale =
                  0.5 + (math.sin(animationValue * 2 * math.pi) * 0.5);

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size / 6,
                  height: widget.size / 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildHelpyIndicator(Color color) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * math.pi,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.3)],
              ),
            ),
            child: const Center(
              child: Text('🥷', style: TextStyle(fontSize: 24)),
            ),
          ),
        );
      },
    );
  }
}

enum LoadingType { circular, pulse, dots, helpy }

/// Modern progress indicator with glassmorphic design
class ModernProgressIndicator extends StatelessWidget {
  const ModernProgressIndicator({
    super.key,
    required this.value,
    this.backgroundColor,
    this.valueColor,
    this.height = 8.0,
    this.borderRadius,
    this.showPercentage = false,
    this.label,
  });

  final double value; // 0.0 to 1.0
  final Color? backgroundColor;
  final Color? valueColor;
  final double height;
  final BorderRadius? borderRadius;
  final bool showPercentage;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.outline.withValues(alpha: 0.2);
    final effectiveValueColor = valueColor ?? DesignTokens.primary;
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(height / 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || showPercentage) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(
                  label!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              if (showPercentage)
                Text(
                  '${(value * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: effectiveValueColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceS),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: effectiveBorderRadius,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    effectiveValueColor,
                    effectiveValueColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: effectiveBorderRadius,
                boxShadow: [
                  BoxShadow(
                    color: effectiveValueColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Modern snackbar with glassmorphic design
class ModernSnackBar {
  static SnackBar show({
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = DesignTokens.success;
        textColor = Colors.white;
        icon = Icons.check_circle_outline;
        break;
      case SnackBarType.error:
        backgroundColor = DesignTokens.error;
        textColor = Colors.white;
        icon = Icons.error_outline;
        break;
      case SnackBarType.warning:
        backgroundColor = DesignTokens.warning;
        textColor = Colors.black;
        icon = Icons.warning_outlined;
        break;
      case SnackBarType.info:
        backgroundColor = DesignTokens.primary;
        textColor = Colors.white;
        icon = Icons.info_outline;
        break;
    }

    return SnackBar(
      content: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: DesignTokens.spaceM),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
      ),
      duration: duration,
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: textColor,
              onPressed: onActionPressed ?? () {},
            )
          : null,
    );
  }
}

enum SnackBarType { success, error, warning, info }

/// Modern dialog with glassmorphic design
class ModernDialog extends StatelessWidget {
  const ModernDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.icon,
    this.type = DialogType.info,
  });

  final String? title;
  final Widget? content;
  final List<Widget>? actions;
  final IconData? icon;
  final DialogType type;

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    switch (type) {
      case DialogType.success:
        iconColor = DesignTokens.success;
        break;
      case DialogType.error:
        iconColor = DesignTokens.error;
        break;
      case DialogType.warning:
        iconColor = DesignTokens.warning;
        break;
      case DialogType.info:
        iconColor = DesignTokens.primary;
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
      ),
      backgroundColor: Colors.transparent,
      child: GlassmorphicContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.1),
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(height: DesignTokens.spaceL),
            ],
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.spaceM),
            ],
            if (content != null) ...[
              content!,
              const SizedBox(height: DesignTokens.spaceL),
            ],
            if (actions != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!
                    .map(
                      (action) => Padding(
                        padding: const EdgeInsets.only(
                          left: DesignTokens.spaceS,
                        ),
                        child: action,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? content,
    List<Widget>? actions,
    IconData? icon,
    DialogType type = DialogType.info,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ModernDialog(
        title: title,
        content: content,
        actions: actions,
        icon: icon,
        type: type,
      ),
    );
  }
}

enum DialogType { success, error, warning, info }

/// Modern bottom sheet with glassmorphic design
class ModernBottomSheet extends StatelessWidget {
  const ModernBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.height,
    this.isScrollControlled = false,
  });

  final Widget child;
  final String? title;
  final double? height;
  final bool isScrollControlled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radiusXL),
          topRight: Radius.circular(DesignTokens.radiusXL),
        ),
      ),
      child: GlassmorphicContainer(
        borderRadius: DesignTokens.radiusXL,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: DesignTokens.spaceM),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (title != null) ...[
              const SizedBox(height: DesignTokens.spaceL),
              Text(
                title!,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: DesignTokens.spaceM),
              Divider(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ],
            Flexible(child: child),
          ],
        ),
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    double? height,
    bool isScrollControlled = false,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => ModernBottomSheet(
        title: title,
        height: height,
        isScrollControlled: isScrollControlled,
        child: child,
      ),
    );
  }
}

/// Modern tooltip with glassmorphic design
class ModernTooltip extends StatelessWidget {
  const ModernTooltip({
    super.key,
    required this.message,
    required this.child,
    this.preferBelow = true,
    this.textStyle,
  });

  final String message;
  final Widget child;
  final bool preferBelow;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.inverseSurface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      textStyle:
          textStyle ??
          TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.w500,
          ),
      child: child,
    );
  }
}
