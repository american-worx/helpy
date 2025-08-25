import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../../config/design_tokens.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/providers/providers.dart';
import '../../../domain/entities/conversation.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/helpy_personality.dart';
import '../../widgets/navigation/modern_navigation.dart';
import '../../widgets/layout/modern_layout.dart';

/// Chat interface screen for individual conversations
class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  late AnimationController _fadeAnimationController;
  late AnimationController _inputAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _inputScaleAnimation;

  bool _isComposing = false;

  @override
  void initState() {
    super.initState();

    _messageController = TextEditingController();
    _scrollController = ScrollController();

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _inputAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeOut),
    );

    _inputScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _inputAnimationController, curve: Curves.easeOut),
    );

    _messageController.addListener(() {
      final isComposing = _messageController.text.isNotEmpty;
      if (isComposing != _isComposing) {
        setState(() {
          _isComposing = isComposing;
        });
        if (isComposing) {
          _inputAnimationController.forward();
        } else {
          _inputAnimationController.reverse();
        }
      }
    });

    _fadeAnimationController.forward();

    // Load messages when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationMessagesProvider(widget.conversationId));
      _markMessagesAsRead();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fadeAnimationController.dispose();
    _inputAnimationController.dispose();
    super.dispose();
  }

  void _markMessagesAsRead() {
    Future.delayed(const Duration(milliseconds: 500), () {
      ref.read(chatProvider.notifier).markMessagesAsRead(widget.conversationId);
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(conversationProvider(widget.conversationId));
    final messagesAsync = ref.watch(
      conversationMessagesProvider(widget.conversationId),
    );
    final personality = conversation != null
        ? ref.watch(helpyPersonalityProvider(conversation.helpyPersonalityId))
        : null;

    if (conversation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: Text('Conversation not found')),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context, conversation, personality),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Messages area
            Expanded(
              child: messagesAsync.when(
                data: (messages) =>
                    _buildMessagesArea(context, messages, personality),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: DesignTokens.error,
                      ),
                      Space.m,
                      Text('Failed to load messages'),
                      Space.s,
                      ElevatedButton(
                        onPressed: () => ref.refresh(
                          conversationMessagesProvider(widget.conversationId),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Input area
            _buildInputArea(context, personality),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    Conversation conversation,
    HelpyPersonality? personality,
  ) {
    return ModernAppBar(
      title: conversation.displayTitle,
      subtitle: personality != null ? 'with ${personality.name}' : null,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      actions: [
        // Personality indicator
        if (personality != null)
          Container(
            margin: const EdgeInsets.only(right: DesignTokens.spaceM),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(
                int.parse(personality.colorTheme.substring(1), radix: 16) |
                    0xFF000000,
              ),
              child: Text(
                personality.icon,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

        // More actions
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, conversation),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.clear_all_rounded),
                  SizedBox(width: 8),
                  Text('Clear Chat'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_rounded),
                  SizedBox(width: 8),
                  Text('Chat Settings'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessagesArea(
    BuildContext context,
    List<Message> messages,
    HelpyPersonality? personality,
  ) {
    if (messages.isEmpty) {
      return _buildEmptyMessagesState(context, personality);
    }

    // Auto-scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (messages.isNotEmpty) {
        _scrollToBottom();
      }
    });

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final previousMessage = index > 0 ? messages[index - 1] : null;
        final showTimestamp = _shouldShowTimestamp(message, previousMessage);

        return Column(
          children: [
            if (showTimestamp) _buildTimestamp(context, message.timestamp),
            _buildMessageBubble(context, message, personality),
          ],
        );
      },
    );
  }

  Widget _buildEmptyMessagesState(
    BuildContext context,
    HelpyPersonality? personality,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (personality != null) ...[
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                              personality.colorTheme.substring(1),
                              radix: 16,
                            ) |
                            0xFF000000,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        personality.icon,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                );
              },
            ),
            Space.l,
            Text(
              'Chat with ${personality.name}',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Space.s,
            Text(
              personality.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            Space.l,
          ],
          Text(
            'Start the conversation by typing a message below!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  bool _shouldShowTimestamp(Message message, Message? previousMessage) {
    if (previousMessage == null) return true;

    final timeDiff = message.timestamp.difference(previousMessage.timestamp);
    return timeDiff.inMinutes > 5;
  }

  Widget _buildTimestamp(BuildContext context, DateTime timestamp) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: DesignTokens.spaceM),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceM,
            vertical: DesignTokens.spaceXS,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          ),
          child: Text(
            _formatTimestamp(timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays == 0) {
      // Today - show time
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      // This week - show day name
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return days[timestamp.weekday - 1];
    } else {
      // Older - show date
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Widget _buildMessageBubble(
    BuildContext context,
    Message message,
    HelpyPersonality? personality,
  ) {
    final user = ref.read(currentUserProvider);
    final isFromUser = user != null && message.isFromUser(user.id);
    final isFromHelpy = message.isFromHelpy;

    // Handle typing indicator
    if (message.type == MessageType.typing) {
      return _buildTypingIndicator(context, personality);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceS),
      child: Row(
        mainAxisAlignment: isFromUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Helpy avatar (left side)
          if (isFromHelpy) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: DesignTokens.spaceS),
              decoration: BoxDecoration(
                color: personality != null
                    ? Color(
                        int.parse(
                              personality.colorTheme.substring(1),
                              radix: 16,
                            ) |
                            0xFF000000,
                      )
                    : DesignTokens.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  personality?.icon ?? '🤖',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],

          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(DesignTokens.spaceM),
              decoration: BoxDecoration(
                gradient: isFromUser
                    ? const LinearGradient(
                        colors: [DesignTokens.primary, DesignTokens.accent],
                      )
                    : null,
                color: isFromUser
                    ? null
                    : Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(DesignTokens.radiusL),
                  topRight: const Radius.circular(DesignTokens.radiusL),
                  bottomLeft: Radius.circular(
                    isFromUser ? DesignTokens.radiusL : DesignTokens.radiusS,
                  ),
                  bottomRight: Radius.circular(
                    isFromUser ? DesignTokens.radiusS : DesignTokens.radiusL,
                  ),
                ),
                border: isFromUser
                    ? null
                    : Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isFromUser
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Space.xs,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        message.formattedTime,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isFromUser
                              ? Colors.white.withValues(alpha: 0.7)
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                      if (isFromUser) ...[
                        const SizedBox(width: DesignTokens.spaceXS),
                        _buildMessageStatusIcon(message.status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // User avatar (right side)
          if (isFromUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: DesignTokens.spaceS),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [DesignTokens.primary, DesignTokens.accent],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.name.isNotEmpty == true
                      ? user.name[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(
    BuildContext context,
    HelpyPersonality? personality,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceS),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: DesignTokens.spaceS),
            decoration: BoxDecoration(
              color: personality != null
                  ? Color(
                      int.parse(
                            personality.colorTheme.substring(1),
                            radix: 16,
                          ) |
                          0xFF000000,
                    )
                  : DesignTokens.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                personality?.icon ?? '🤖',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceM),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(DesignTokens.radiusL),
                topRight: Radius.circular(DesignTokens.radiusL),
                bottomRight: Radius.circular(DesignTokens.radiusL),
                bottomLeft: Radius.circular(DesignTokens.radiusS),
              ),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(200),
                const SizedBox(width: 4),
                _buildTypingDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 600 + delay),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: DesignTokens.primary.withValues(
              alpha: 0.3 + (0.7 * math.sin(value * math.pi * 2 + delay / 100)),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildMessageStatusIcon(MessageStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sending:
        icon = Icons.schedule_rounded;
        color = Colors.white.withValues(alpha: 0.7);
        break;
      case MessageStatus.sent:
        icon = Icons.check_rounded;
        color = Colors.white.withValues(alpha: 0.7);
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all_rounded;
        color = Colors.white.withValues(alpha: 0.7);
        break;
      case MessageStatus.read:
        icon = Icons.done_all_rounded;
        color = Colors.white;
        break;
      case MessageStatus.failed:
        icon = Icons.error_rounded;
        color = DesignTokens.error;
        break;
      case MessageStatus.encrypted:
        icon = Icons.lock_rounded;
        color = Colors.white.withValues(alpha: 0.7);
        break;
      case MessageStatus.deleted:
        icon = Icons.delete_rounded;
        color = Colors.white.withValues(alpha: 0.5);
        break;
    }

    return Icon(icon, size: 14, color: color);
  }

  Widget _buildInputArea(BuildContext context, HelpyPersonality? personality) {
    return AnimatedBuilder(
      animation: _inputScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _inputScaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.spaceM),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Message input field
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceM,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusL,
                        ),
                        border: Border.all(
                          color: _isComposing
                              ? DesignTokens.primary.withValues(alpha: 0.5)
                              : Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: personality != null
                              ? 'Ask ${personality.name} anything...'
                              : 'Type a message...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),

                  const SizedBox(width: DesignTokens.spaceS),

                  // Send button
                  AnimatedContainer(
                    duration: DesignTokens.animationFast,
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: _isComposing
                          ? const LinearGradient(
                              colors: [
                                DesignTokens.primary,
                                DesignTokens.accent,
                              ],
                            )
                          : null,
                      color: _isComposing
                          ? null
                          : Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isComposing ? _sendMessage : null,
                        borderRadius: BorderRadius.circular(24),
                        child: Icon(
                          Icons.send_rounded,
                          color: _isComposing
                              ? Colors.white
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Clear input
    _messageController.clear();
    setState(() {
      _isComposing = false;
    });
    _inputAnimationController.reverse();

    try {
      await ref
          .read(chatProvider.notifier)
          .sendMessage(
            conversationId: widget.conversationId,
            senderId: user.id,
            senderName: user.name,
            content: message,
          );

      // Refresh messages to show the new message
      ref.refresh(conversationMessagesProvider(widget.conversationId));

      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
    }
  }

  void _handleMenuAction(String action, Conversation conversation) {
    switch (action) {
      case 'clear':
        _showClearConfirmation();
        break;
      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat settings coming soon!')),
        );
        break;
    }
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text(
          'Are you sure you want to clear all messages in this chat? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear chat functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clear chat feature coming soon!'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: DesignTokens.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
