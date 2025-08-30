import 'package:flutter/material.dart';
import 'package:helpy_ninja/config/design_tokens.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

/// Typing indicator widget to show when participants are typing
class TypingIndicator extends StatelessWidget {
  final String? userName;
  final bool isMultiple;
  final int typingCount;

  const TypingIndicator({
    super.key,
    this.userName,
    this.isMultiple = false,
    this.typingCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceS),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Typing dots animation
          _TypingDotsAnimation(),
          const SizedBox(width: DesignTokens.spaceS),
          // Text indicator
          Text(
            isMultiple
                ? l10n.multipleGroupTyping(typingCount)
                : (userName != null
                    ? l10n.groupTyping(userName!)
                    : l10n.typing),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

/// Animated typing dots
class _TypingDotsAnimation extends StatefulWidget {
  @override
  _TypingDotsAnimationState createState() => _TypingDotsAnimationState();
}

class _TypingDotsAnimationState extends State<_TypingDotsAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _controller3 = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Stagger the animations
    _controller1.repeat(reverse: true);
    _controller2.repeat(reverse: true);
    _controller3.repeat(reverse: true);

    // Add delays to create the typing effect
    _controller2.forward(from: 0.33);
    _controller3.forward(from: 0.66);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FadeTransition(
          opacity: _controller1,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 4),
        FadeTransition(
          opacity: _controller2,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 4),
        FadeTransition(
          opacity: _controller3,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
