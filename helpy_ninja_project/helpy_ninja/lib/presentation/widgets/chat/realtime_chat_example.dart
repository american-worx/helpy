import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/realtime_chat_provider.dart';
import 'connection_status_widget.dart';
import 'typing_indicator_widget.dart';

/// Example implementation of a real-time chat interface
/// This shows how to use the WebSocket integration with Riverpod providers
class RealtimeChatExample extends ConsumerStatefulWidget {
  final String conversationId;
  final String conversationTitle;

  const RealtimeChatExample({
    super.key,
    required this.conversationId,
    required this.conversationTitle,
  });

  @override
  ConsumerState<RealtimeChatExample> createState() => _RealtimeChatExampleState();
}

class _RealtimeChatExampleState extends ConsumerState<RealtimeChatExample> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    
    // Connect to WebSocket and join conversation when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  @override
  void dispose() {
    // Leave conversation when screen is disposed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(realtimeChatProvider.notifier).leaveConversation(widget.conversationId);
    });
    
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    final notifier = ref.read(realtimeChatProvider.notifier);
    
    // Connect to WebSocket if not already connected
    if (!ref.read(connectionStatusProvider)) {
      await notifier.connect();
    }
    
    // Join this conversation
    await notifier.joinConversation(widget.conversationId);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(realtimeChatProvider);
    final messages = ref.watch(conversationMessagesProvider(widget.conversationId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversationTitle),
        actions: [
          const ConnectionStatusWidget(
            showLabel: false,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRetryConnection,
            tooltip: 'Retry Connection',
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status banner
          ConnectionStatusBanner(
            onRetry: _handleRetryConnection,
          ),
          
          // Error message display
          if (chatState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatState.error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => ref.read(realtimeChatProvider.notifier).clearError(),
                    iconSize: 20,
                    color: Colors.red[700],
                  ),
                ],
              ),
            ),
          
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildMessageBubble(message, theme);
                    },
                  ),
          ),
          
          // Typing indicators
          TypingIndicatorWidget(
            conversationId: widget.conversationId,
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: _buildMessageInput(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with Helpy!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message, ThemeData theme) {
    final isFromUser = message.senderId != 'helpy';
    final isFailedMessage = message.status.toString().contains('failed');
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isFromUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.smart_toy, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isFromUser 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(18),
                border: isFailedMessage 
                    ? Border.all(color: Colors.red[300]!, width: 1)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isFromUser 
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isFromUser 
                              ? theme.colorScheme.onPrimary.withOpacity(0.7)
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      if (isFromUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          _getMessageStatusIcon(message.status.toString()),
                          size: 12,
                          color: theme.colorScheme.onPrimary.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isFromUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.secondary,
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: 'Type a message...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            maxLines: null,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _sendMessage(),
            onChanged: _handleTextChanged,
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton(
          onPressed: _sendMessage,
          mini: true,
          child: const Icon(Icons.send),
        ),
      ],
    );
  }

  void _handleTextChanged(String text) {
    final isCurrentlyTyping = text.isNotEmpty;
    
    if (isCurrentlyTyping != _isTyping) {
      _isTyping = isCurrentlyTyping;
      ref.read(realtimeChatProvider.notifier).sendTypingIndicator(
        conversationId: widget.conversationId,
        isTyping: _isTyping,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    
    // Stop typing indicator
    if (_isTyping) {
      _isTyping = false;
      ref.read(realtimeChatProvider.notifier).sendTypingIndicator(
        conversationId: widget.conversationId,
        isTyping: false,
      );
    }

    // Send message
    await ref.read(realtimeChatProvider.notifier).sendMessage(
      conversationId: widget.conversationId,
      content: message,
    );

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleRetryConnection() async {
    final notifier = ref.read(realtimeChatProvider.notifier);
    await notifier.connect();
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  IconData _getMessageStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'sending':
        return Icons.schedule;
      case 'sent':
        return Icons.done;
      case 'delivered':
        return Icons.done_all;
      case 'read':
        return Icons.done_all;
      case 'failed':
        return Icons.error_outline;
      default:
        return Icons.schedule;
    }
  }
}