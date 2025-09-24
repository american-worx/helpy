import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/message.dart';
import '../../../domain/entities/conversation.dart';
import '../../../data/providers/chat_provider.dart';

/// Widget for displaying and managing message threads (replies)
class MessageThreadWidget extends ConsumerStatefulWidget {
  final Message parentMessage;
  final Conversation conversation;
  final VoidCallback? onClose;
  
  const MessageThreadWidget({
    super.key,
    required this.parentMessage,
    required this.conversation,
    this.onClose,
  });
  
  @override
  ConsumerState<MessageThreadWidget> createState() => _MessageThreadWidgetState();
}

class _MessageThreadWidgetState extends ConsumerState<MessageThreadWidget> {
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocus = FocusNode();
  List<Message> _threadMessages = [];
  bool _isLoading = true;
  bool _isSending = false;
  
  @override
  void initState() {
    super.initState();
    _loadThreadMessages();
  }
  
  @override
  void dispose() {
    _replyController.dispose();
    _replyFocus.dispose();
    super.dispose();
  }
  
  Future<void> _loadThreadMessages() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final chatNotifier = ref.read(chatProvider.notifier);
      final allMessages = await chatNotifier.loadMessagesForConversation(widget.conversation.id);
      
      // Find all messages that reply to the parent message
      final threadMessages = allMessages
          .where((message) => message.replyToMessageId == widget.parentMessage.id)
          .toList();
      
      // Sort by timestamp
      threadMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      setState(() {
        _threadMessages = threadMessages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _sendReply() async {
    final content = _replyController.text.trim();
    if (content.isEmpty || _isSending) return;
    
    setState(() {
      _isSending = true;
    });
    
    try {
      final chatNotifier = ref.read(chatProvider.notifier);
      
      // TODO: Get current user info properly
      await chatNotifier.sendMessage(
        conversationId: widget.conversation.id,
        senderId: 'current_user', // Replace with actual user ID
        senderName: 'You', // Replace with actual user name
        content: content,
        type: MessageType.text,
        replyToMessageId: widget.parentMessage.id,
      );
      
      _replyController.clear();
      await _loadThreadMessages(); // Reload to show new reply
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reply: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thread'),
            Text(
              '${_threadMessages.length} replies',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Parent message
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: widget.parentMessage.isFromHelpy
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.secondaryContainer,
                        child: Icon(
                          widget.parentMessage.isFromHelpy ? Icons.smart_toy : Icons.person,
                          size: 20,
                          color: widget.parentMessage.isFromHelpy
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.parentMessage.senderName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatTime(widget.parentMessage.timestamp),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.parentMessage.content,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          
          // Thread messages
          Expanded(
            child: _buildThreadMessages(context),
          ),
          
          // Reply input
          _buildReplyInput(context),
        ],
      ),
    );
  }
  
  Widget _buildThreadMessages(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_threadMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No replies yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to reply to this message',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _threadMessages.length,
      itemBuilder: (context, index) {
        final message = _threadMessages[index];
        return ThreadMessageItem(
          message: message,
          isFirst: index == 0,
          isLast: index == _threadMessages.length - 1,
        );
      },
    );
  }
  
  Widget _buildReplyInput(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              focusNode: _replyFocus,
              decoration: InputDecoration(
                hintText: 'Reply to thread...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: _isSending ? null : _sendReply,
            child: _isSending
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) {
      return 'now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

/// Individual thread message item
class ThreadMessageItem extends StatelessWidget {
  final Message message;
  final bool isFirst;
  final bool isLast;
  
  const ThreadMessageItem({
    super.key,
    required this.message,
    this.isFirst = false,
    this.isLast = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : 8,
        left: 24, // Indent to show it's a reply
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: message.isFromHelpy
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.secondaryContainer,
                    child: Icon(
                      message.isFromHelpy ? Icons.smart_toy : Icons.person,
                      size: 14,
                      color: message.isFromHelpy
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.senderName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatTime(message.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildMessageStatus(context),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message.content,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMessageStatus(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (message.status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 14,
          color: theme.colorScheme.primary,
        );
      case MessageStatus.read:
        return Icon(
          Icons.done_all,
          size: 14,
          color: theme.colorScheme.primary,
        );
      case MessageStatus.failed:
        return Icon(
          Icons.error_outline,
          size: 14,
          color: theme.colorScheme.error,
        );
      default:
        return const SizedBox.shrink();
    }
  }
  
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) {
      return 'now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

/// Reply button widget for messages
class MessageReplyButton extends StatelessWidget {
  final Message message;
  final Conversation conversation;
  final VoidCallback? onReply;
  
  const MessageReplyButton({
    super.key,
    required this.message,
    required this.conversation,
    this.onReply,
  });
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (onReply != null) {
          onReply!();
        } else {
          _showThreadDialog(context);
        }
      },
      icon: const Icon(Icons.reply, size: 18),
      tooltip: 'Reply',
      iconSize: 18,
    );
  }
  
  void _showThreadDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MessageThreadWidget(
          parentMessage: message,
          conversation: conversation,
        ),
      ),
    );
  }
}

/// Reply indicator widget to show when a message is a reply
class MessageReplyIndicator extends StatelessWidget {
  final String replyToMessageId;
  final Function(String)? onTapOriginal;
  
  const MessageReplyIndicator({
    super.key,
    required this.replyToMessageId,
    this.onTapOriginal,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => onTapOriginal?.call(replyToMessageId),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: theme.colorScheme.primary,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.reply,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'Replying to message',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thread count indicator for messages that have replies
class MessageThreadCount extends StatelessWidget {
  final int replyCount;
  final VoidCallback? onTap;
  
  const MessageThreadCount({
    super.key,
    required this.replyCount,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (replyCount == 0) return const SizedBox.shrink();
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.forum,
              size: 14,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 4),
            Text(
              '$replyCount ${replyCount == 1 ? 'reply' : 'replies'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}