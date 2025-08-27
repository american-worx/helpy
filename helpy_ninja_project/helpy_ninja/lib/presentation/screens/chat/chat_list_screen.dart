import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/design_tokens.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/providers/providers.dart';
import '../../../domain/entities/conversation.dart';
import '../../../domain/entities/helpy_personality.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';
import '../../widgets/chat/chat_list_components.dart';

/// Chat list screen showing conversation history and new chat options
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start animations
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: ChatListAppBar(
        totalUnreadCount: chatState.totalUnreadCount,
        onNewChatPressed: () => _showNewChatOptions(context),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: chatState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : chatState.error != null
              ? ChatListErrorState(
                  error: chatState.error!,
                  onRetry: () => ref.read(chatProvider.notifier).refresh(),
                )
              : chatState.conversations.isEmpty
              ? ChatListEmptyState(
                  personalities: ref.watch(availablePersonalitiesProvider),
                  onStartFirstChat: () => _showNewChatOptions(context),
                  onSeeAllPersonalities: () => _showNewChatOptions(context),
                )
              : ChatListConversationsList(
                  conversations: chatState.conversations,
                  onConversationAction: _handleConversationAction,
                ),
        ),
      ),
      floatingActionButton: chatState.conversations.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showNewChatOptions(context),
              backgroundColor: DesignTokens.primary,
              icon: const Icon(Icons.smart_toy_rounded, color: Colors.white),
              label: Text(
                l10n.newChat,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  void _showNewChatOptions(BuildContext context) {
    final personalities = ref.read(availablePersonalitiesProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatListNewChatOptions(
        personalities: personalities,
        onPersonalitySelected: _startNewChat,
      ),
    );
  }

  void _startNewChat(HelpyPersonality personality) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      debugPrint('Cannot start chat: No current user');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please sign in to start a chat'),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
      return;
    }

    try {
      debugPrint(
        'Creating conversation for user ${user.id} with personality ${personality.id}',
      );

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Creating chat...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final conversation = await ref
          .read(chatProvider.notifier)
          .createConversation(
            title: '',
            userId: user.id,
            helpyPersonalityId: personality.id,
            type: ConversationType.general,
          );

      debugPrint('Conversation created with ID: ${conversation.id}');
      debugPrint('Conversation title: ${conversation.displayTitle}');
      debugPrint('Conversation type: ${conversation.type}');

      if (mounted) {
        final routePath = '/chat/${conversation.id}';
        debugPrint('Navigating to: $routePath');
        debugPrint(
          'Current location: ${GoRouter.of(context).routerDelegate.currentConfiguration.uri.path}',
        );

        // Clear any existing snackbars
        ScaffoldMessenger.of(context).clearSnackBars();

        // Navigate to chat
        context.go(routePath);

        // Add a small delay and check if navigation succeeded
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            final currentPath = GoRouter.of(
              context,
            ).routerDelegate.currentConfiguration.uri.path;
            debugPrint('Navigation result - Current path: $currentPath');
            if (currentPath != routePath) {
              debugPrint(
                'WARNING: Navigation may have failed. Expected: $routePath, Actual: $currentPath',
              );
            }
          }
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to start chat: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start chat: ${e.toString()}'),
            backgroundColor: DesignTokens.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _startNewChat(personality),
            ),
          ),
        );
      }
    }
  }

  void _openConversation(Conversation conversation) {
    final routePath = '/chat/${conversation.id}';
    debugPrint('Opening conversation: ${conversation.id}');
    debugPrint('Conversation title: ${conversation.displayTitle}');
    debugPrint('Navigation path: $routePath');
    debugPrint(
      'Current location: ${GoRouter.of(context).routerDelegate.currentConfiguration.uri.path}',
    );

    try {
      context.go(routePath);

      // Add a small delay and check if navigation succeeded
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          final currentPath = GoRouter.of(
            context,
          ).routerDelegate.currentConfiguration.uri.path;
          debugPrint('Navigation result - Current path: $currentPath');
          if (currentPath != routePath) {
            debugPrint(
              'WARNING: Navigation may have failed. Expected: $routePath, Actual: $currentPath',
            );
            // Show error to user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to open chat. Please try again.'),
                backgroundColor: DesignTokens.error,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () => _openConversation(conversation),
                ),
              ),
            );
          }
        }
      });
    } catch (e) {
      debugPrint('Error during navigation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation error: ${e.toString()}'),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
    }
  }

  void _handleConversationAction(
    Conversation conversation,
    String action,
  ) async {
    switch (action) {
      case 'mark_read':
        await ref
            .read(chatProvider.notifier)
            .markMessagesAsRead(conversation.id);
        break;
      case 'archive':
        // TODO: Implement archive functionality
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.archiveFeatureComingSoon,
            ),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(conversation);
        break;
    }
  }

  void _showDeleteConfirmation(Conversation conversation) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConversation),
        content: Text(
          l10n.deleteConversationConfirm(conversation.displayTitle),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(chatProvider.notifier)
                    .deleteConversation(conversation.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.conversationDeleted)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.failedToDeleteConversation(e.toString()),
                      ),
                      backgroundColor: DesignTokens.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: DesignTokens.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
