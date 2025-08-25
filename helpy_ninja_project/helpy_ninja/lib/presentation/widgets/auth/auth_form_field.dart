import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/design_tokens.dart';

/// Custom form field for authentication screens with modern styling
class AuthFormField extends StatefulWidget {
  const AuthFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.autofocus = false,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enabled;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AuthFormField> createState() => _AuthFormFieldState();
}

class _AuthFormFieldState extends State<AuthFormField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  late Animation<Color?> _labelColorAnimation;

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
        ColorTween(begin: Colors.transparent, end: DesignTokens.accent).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _labelColorAnimation =
        ColorTween(begin: Colors.grey, end: DesignTokens.accent).animate(
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
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label with animation
            AnimatedContainer(
              duration: DesignTokens.animationFast,
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(bottom: DesignTokens.spaceS),
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _hasError
                      ? DesignTokens.error
                      : _isFocused
                      ? _labelColorAnimation.value
                      : colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: _isFocused ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),

            // Text field with glassmorphic styling
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
              ),
              child: TextFormField(
                controller: widget.controller,
                validator: (value) {
                  final result = widget.validator?.call(value);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _hasError = result != null;
                    });
                  });
                  return result;
                },
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                textInputAction: widget.textInputAction,
                autofocus: widget.autofocus,
                enabled: widget.enabled,
                maxLines: widget.maxLines,
                inputFormatters: widget.inputFormatters,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _isFocused
                              ? DesignTokens.accent
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                        )
                      : null,
                  suffixIcon: widget.suffixIcon,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    borderSide: BorderSide(
                      color: _borderColorAnimation.value ?? DesignTokens.accent,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    borderSide: const BorderSide(
                      color: DesignTokens.error,
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    borderSide: const BorderSide(
                      color: DesignTokens.error,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(DesignTokens.spaceM),
                  errorStyle: const TextStyle(
                    height: 0.01,
                    color: Colors.transparent,
                  ),
                ),
                onTap: () {
                  if (!_isFocused) {
                    setState(() {
                      _isFocused = true;
                    });
                    _animationController.forward();
                  }
                },
                onTapOutside: (_) {
                  if (_isFocused) {
                    setState(() {
                      _isFocused = false;
                    });
                    _animationController.reverse();
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Specialized form field for search with modern styling
class SearchFormField extends StatelessWidget {
  const SearchFormField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = 'Search...',
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final void Function(String) onChanged;
  final String hint;
  final void Function(String)? onSubmitted;
  final bool autofocus;

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
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        autofocus: autofocus,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceM,
            vertical: DesignTokens.spaceM,
          ),
        ),
      ),
    );
  }
}
