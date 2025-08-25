import 'package:flutter/material.dart';
import 'dart:ui';

import '../../../config/design_tokens.dart';
import '../auth/glassmorphic_container.dart';

/// Modern section container with optional header and footer
class ModernSection extends StatelessWidget {
  const ModernSection({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.headerAction,
    this.footer,
    this.padding = const EdgeInsets.all(DesignTokens.spaceL),
    this.margin = EdgeInsets.zero,
    this.showGlassmorphism = false,
    this.backgroundColor,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? headerAction;
  final Widget? footer;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool showGlassmorphism;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null || headerAction != null) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: DesignTokens.spaceXS),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (headerAction != null) headerAction!,
            ],
          ),
          const SizedBox(height: DesignTokens.spaceL),
        ],
        child,
        if (footer != null) ...[
          const SizedBox(height: DesignTokens.spaceL),
          footer!,
        ],
      ],
    );

    if (showGlassmorphism) {
      return Container(
        margin: margin,
        child: GlassmorphicContainer(padding: padding, child: content),
      );
    }

    return Container(
      margin: margin,
      padding: padding,
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
            )
          : null,
      child: content,
    );
  }
}

/// Modern grid layout with responsive columns
class ModernGrid extends StatelessWidget {
  const ModernGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = DesignTokens.spaceM,
    this.crossAxisSpacing = DesignTokens.spaceM,
    this.childAspectRatio = 1.0,
    this.physics,
    this.shrinkWrap = false,
    this.padding = EdgeInsets.zero,
  });

  final List<Widget> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Modern list layout with built-in spacing
class ModernList extends StatelessWidget {
  const ModernList({
    super.key,
    required this.children,
    this.spacing = DesignTokens.spaceM,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.shrinkWrap = false,
    this.direction = Axis.vertical,
  });

  final List<Widget> children;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(
          direction == Axis.vertical
              ? SizedBox(height: spacing)
              : SizedBox(width: spacing),
        );
      }
    }

    if (direction == Axis.vertical) {
      return ListView(
        padding: padding,
        physics: physics,
        shrinkWrap: shrinkWrap,
        children: spacedChildren,
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: physics,
        padding: padding,
        child: Row(children: spacedChildren),
      );
    }
  }
}

/// Modern stack container with positioned children
class ModernStack extends StatelessWidget {
  const ModernStack({
    super.key,
    required this.children,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
  });

  final List<Widget> children;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit fit;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: alignment,
      textDirection: textDirection,
      fit: fit,
      clipBehavior: clipBehavior,
      children: children,
    );
  }
}

/// Modern responsive layout that adapts to screen size
class ModernResponsiveLayout extends StatelessWidget {
  const ModernResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 1024,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double mobileBreakpoint;
  final double tabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletBreakpoint && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= mobileBreakpoint && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Modern spacing utility widgets
class Space {
  // Vertical spacing
  static const Widget xs = SizedBox(height: DesignTokens.spaceXS);
  static const Widget s = SizedBox(height: DesignTokens.spaceS);
  static const Widget m = SizedBox(height: DesignTokens.spaceM);
  static const Widget l = SizedBox(height: DesignTokens.spaceL);
  static const Widget xl = SizedBox(height: DesignTokens.spaceXL);
  static const Widget xxl = SizedBox(height: DesignTokens.spaceXXL);

  // Horizontal spacing
  static const Widget hXS = SizedBox(width: DesignTokens.spaceXS);
  static const Widget hS = SizedBox(width: DesignTokens.spaceS);
  static const Widget hM = SizedBox(width: DesignTokens.spaceM);
  static const Widget hL = SizedBox(width: DesignTokens.spaceL);
  static const Widget hXL = SizedBox(width: DesignTokens.spaceXL);
  static const Widget hXXL = SizedBox(width: DesignTokens.spaceXXL);

  // Custom spacing
  static Widget custom(double size) => SizedBox(height: size);
  static Widget customH(double size) => SizedBox(width: size);
}

/// Modern divider with customizable styling
class ModernDivider extends StatelessWidget {
  const ModernDivider({
    super.key,
    this.height = 1.0,
    this.thickness = 1.0,
    this.indent = 0.0,
    this.endIndent = 0.0,
    this.color,
    this.type = DividerType.line,
  });

  final double height;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color? color;
  final DividerType type;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? Theme.of(context).colorScheme.outline.withValues(alpha: 0.2);

    switch (type) {
      case DividerType.line:
        return Divider(
          height: height,
          thickness: thickness,
          indent: indent,
          endIndent: endIndent,
          color: effectiveColor,
        );
      case DividerType.dashed:
        return _buildDashedDivider(effectiveColor);
      case DividerType.dotted:
        return _buildDottedDivider(effectiveColor);
      case DividerType.gradient:
        return _buildGradientDivider();
    }
  }

  Widget _buildDashedDivider(Color color) {
    return Container(
      height: height,
      margin: EdgeInsets.only(left: indent, right: endIndent),
      child: CustomPaint(
        painter: _DashedLinePainter(color: color, thickness: thickness),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildDottedDivider(Color color) {
    return Container(
      height: height,
      margin: EdgeInsets.only(left: indent, right: endIndent),
      child: CustomPaint(
        painter: _DottedLinePainter(color: color, thickness: thickness),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildGradientDivider() {
    return Container(
      height: height,
      margin: EdgeInsets.only(left: indent, right: endIndent),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            DesignTokens.primary.withValues(alpha: 0.5),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

enum DividerType { line, dashed, dotted, gradient }

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double thickness;

  _DashedLinePainter({required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0.0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  final double thickness;

  _DottedLinePainter({required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const dotSpace = 6.0;
    double startX = 0.0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawPoints(PointMode.points, [Offset(startX, y)], paint);
      startX += dotSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Modern container with elevation and glassmorphic effects
class ModernContainer extends StatelessWidget {
  const ModernContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DesignTokens.spaceM),
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.borderRadius = DesignTokens.radiusM,
    this.elevation = 0.0,
    this.glassmorphic = false,
    this.border,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final double borderRadius;
  final double elevation;
  final bool glassmorphic;
  final Border? border;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (glassmorphic) {
      return Container(
        margin: margin,
        child: GlassmorphicContainer(
          padding: padding,
          borderRadius: borderRadius,
          child: child,
        ),
      );
    }

    final container = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        gradient: gradient,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: container,
        ),
      );
    }

    return container;
  }
}

/// Modern wrap layout with automatic spacing
class ModernWrap extends StatelessWidget {
  const ModernWrap({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.spacing = DesignTokens.spaceS,
    this.runAlignment = WrapAlignment.start,
    this.runSpacing = DesignTokens.spaceS,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.clipBehavior = Clip.none,
  });

  final List<Widget> children;
  final Axis direction;
  final WrapAlignment alignment;
  final double spacing;
  final WrapAlignment runAlignment;
  final double runSpacing;
  final WrapCrossAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: direction,
      alignment: alignment,
      spacing: spacing,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      clipBehavior: clipBehavior,
      children: children,
    );
  }
}
