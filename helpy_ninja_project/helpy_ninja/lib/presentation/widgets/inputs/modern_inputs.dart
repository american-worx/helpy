import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/design_tokens.dart';

/// Modern text field with glassmorphic design and animations
class ModernTextField extends StatefulWidget {
  const ModernTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.inputFormatters,
    this.focusNode,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _labelScaleAnimation;

  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: DesignTokens.animationFast,
      vsync: this,
    );

    _borderColorAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: DesignTokens.primary,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _labelScaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              AnimatedScale(
                duration: DesignTokens.animationFast,
                scale: _labelScaleAnimation.value,
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.label!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _hasError
                        ? DesignTokens.error
                        : _isFocused
                        ? DesignTokens.primary
                        : colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: _isFocused
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.spaceS),
            ],
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surface.withValues(alpha: 0.1),
                    colorScheme.surface.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: _hasError
                      ? DesignTokens.error
                      : _borderColorAnimation.value ??
                            colorScheme.outline.withValues(alpha: 0.3),
                  width: _isFocused || _hasError ? 2 : 1,
                ),
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                validator: (value) {
                  final result = widget.validator?.call(value);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _hasError = result != null;
                    });
                  });
                  return result;
                },
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                obscureText: widget.obscureText,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                maxLines: widget.maxLines,
                inputFormatters: widget.inputFormatters,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(DesignTokens.spaceM),
                  errorStyle: const TextStyle(
                    height: 0.01,
                    color: Colors.transparent,
                  ),
                ),
                onTap: () => _onFocusChange(),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Modern slider with glassmorphic track design
class ModernSlider extends StatefulWidget {
  const ModernSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
  });

  final double value;
  final void Function(double) onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;

  @override
  State<ModernSlider> createState() => _ModernSliderState();
}

class _ModernSliderState extends State<ModernSlider> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface.withValues(alpha: 0.1),
            colorScheme.surface.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceM),
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: widget.activeColor ?? DesignTokens.primary,
            inactiveTrackColor:
                widget.inactiveColor ??
                colorScheme.outline.withValues(alpha: 0.3),
            thumbColor: widget.thumbColor ?? DesignTokens.primary,
            overlayColor: (widget.thumbColor ?? DesignTokens.primary)
                .withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            trackHeight: 6,
            valueIndicatorColor: widget.activeColor ?? DesignTokens.primary,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Slider(
            value: widget.value,
            onChanged: widget.onChanged,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            label: widget.label,
          ),
        ),
      ),
    );
  }
}

/// Modern toggle switch with glassmorphic design
class ModernToggle extends StatefulWidget {
  const ModernToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.size = ModernToggleSize.medium,
  });

  final bool value;
  final void Function(bool) onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final ModernToggleSize size;

  @override
  State<ModernToggle> createState() => _ModernToggleState();
}

class _ModernToggleState extends State<ModernToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _thumbAnimation;
  late Animation<Color?> _trackColorAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: DesignTokens.animationFast,
      vsync: this,
    );

    _thumbAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _trackColorAnimation =
        ColorTween(
          begin: widget.inactiveColor ?? Colors.grey.withValues(alpha: 0.3),
          end: widget.activeColor ?? DesignTokens.primary,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ModernToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = _getToggleDimensions();

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: dimensions.width,
            height: dimensions.height,
            decoration: BoxDecoration(
              color: _trackColorAnimation.value,
              borderRadius: BorderRadius.circular(dimensions.height / 2),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: DesignTokens.animationFast,
                  left:
                      _thumbAnimation.value *
                          (dimensions.width - dimensions.thumbSize - 4) +
                      2,
                  top: 2,
                  child: Container(
                    width: dimensions.thumbSize,
                    height: dimensions.thumbSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _ToggleDimensions _getToggleDimensions() {
    switch (widget.size) {
      case ModernToggleSize.small:
        return const _ToggleDimensions(width: 36, height: 20, thumbSize: 16);
      case ModernToggleSize.medium:
        return const _ToggleDimensions(width: 48, height: 26, thumbSize: 22);
      case ModernToggleSize.large:
        return const _ToggleDimensions(width: 60, height: 32, thumbSize: 28);
    }
  }
}

enum ModernToggleSize { small, medium, large }

class _ToggleDimensions {
  final double width;
  final double height;
  final double thumbSize;

  const _ToggleDimensions({
    required this.width,
    required this.height,
    required this.thumbSize,
  });
}

/// Modern checkbox with glassmorphic design
class ModernCheckbox extends StatefulWidget {
  const ModernCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.size = 24.0,
  });

  final bool value;
  final void Function(bool) onChanged;
  final Color? activeColor;
  final double size;

  @override
  State<ModernCheckbox> createState() => _ModernCheckboxState();
}

class _ModernCheckboxState extends State<ModernCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _checkAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: DesignTokens.animationFast,
      vsync: this,
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _colorAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: widget.activeColor ?? DesignTokens.primary,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ModernCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
              border: Border.all(
                color: widget.value
                    ? (widget.activeColor ?? DesignTokens.primary)
                    : colorScheme.outline.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: widget.value
                ? Transform.scale(
                    scale: _checkAnimation.value,
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}

/// Modern radio button with glassmorphic design
class ModernRadio<T> extends StatefulWidget {
  const ModernRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.activeColor,
    this.size = 24.0,
  });

  final T value;
  final T groupValue;
  final void Function(T) onChanged;
  final Color? activeColor;
  final double size;

  @override
  State<ModernRadio<T>> createState() => _ModernRadioState<T>();
}

class _ModernRadioState<T> extends State<ModernRadio<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _dotAnimation;
  late Animation<Color?> _colorAnimation;

  bool get isSelected => widget.value == widget.groupValue;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: DesignTokens.animationFast,
      vsync: this,
    );

    _dotAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _colorAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: widget.activeColor ?? DesignTokens.primary,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    if (isSelected) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ModernRadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (isSelected != (oldWidget.value == oldWidget.groupValue)) {
      if (isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => widget.onChanged(widget.value),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? (widget.activeColor ?? DesignTokens.primary)
                    : colorScheme.outline.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Transform.scale(
                scale: _dotAnimation.value,
                child: Container(
                  width: widget.size * 0.5,
                  height: widget.size * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.activeColor ?? DesignTokens.primary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
