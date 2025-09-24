import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/realtime_chat_provider.dart';

/// Widget to display typing indicators for a conversation
class TypingIndicatorWidget extends ConsumerStatefulWidget {
  final String conversationId;
  final EdgeInsets padding;

  const TypingIndicatorWidget({
    super.key,
    required this.conversationId,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  ConsumerState<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends ConsumerState<TypingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typingUsers = ref.watch(typingUsersProvider(widget.conversationId));
    final theme = Theme.of(context);

    if (typingUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: widget.padding,
      child: Row(
        children: [
          _buildTypingDots(),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _buildTypingText(typingUsers),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDots() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final opacity = (_animation.value + delay) % 1.0;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }

  String _buildTypingText(Set<String> typingUsers) {
    if (typingUsers.length == 1) {
      return '${typingUsers.first} is typing...';
    } else if (typingUsers.length == 2) {
      return '${typingUsers.first} and ${typingUsers.last} are typing...';
    } else {
      return '${typingUsers.length} people are typing...';
    }
  }
}

/// Compact typing indicator for message lists
class CompactTypingIndicator extends ConsumerWidget {
  final String conversationId;

  const CompactTypingIndicator({
    super.key,
    required this.conversationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typingUsers = ref.watch(typingUsersProvider(conversationId));
    
    if (typingUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnimatedDots(context),
          const SizedBox(width: 8),
          Text(
            _buildCompactText(typingUsers),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 100)),
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(value),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }

  String _buildCompactText(Set<String> typingUsers) {
    if (typingUsers.length == 1) {
      return 'typing...';
    } else {
      return '${typingUsers.length} typing...';
    }
  }
}