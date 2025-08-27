import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/design_tokens.dart';
import '../../../../domain/entities/conversation.dart';
import '../../../../data/providers/chat_provider.dart';
import 'chat_list_conversation_card.dart';

/// Conversations list with refresh functionality
class ChatListConversationsList extends ConsumerWidget {
  final List<Conversation> conversations;
  final Function(Conversation, String) onConversationAction;

  const ChatListConversationsList({
    super.key,
    required this.conversations,
    required this.onConversationAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(chatProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(DesignTokens.spaceM),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ChatListConversationCard(
            conversation: conversation,
            onTap: () => _openConversation(context, conversation),
            onActionSelected: (value) =>
                onConversationAction(conversation, value),
          );
        },
      ),
    );
  }

  void _openConversation(BuildContext context, Conversation conversation) {
    final routePath = '/chat/${conversation.id}';
    debugPrint('Opening conversation: ${conversation.id}');
    debugPrint('Conversation title: ${conversation.displayTitle}');
    debugPrint('Navigation path: $routePath');

    try {
      context.go(routePath);
    } catch (e) {
      debugPrint('Error during navigation: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation error: ${e.toString()}'),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
    }
  }
}
