import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/design_tokens.dart';
import '../../../data/providers/chat_provider.dart';
import '../../../data/providers/providers.dart';
import '../../../domain/entities/conversation.dart';
import '../../../domain/entities/helpy_personality.dart';
import '../../widgets/navigation/modern_navigation.dart';
import '../../widgets/auth/glassmorphic_container.dart';
import '../../widgets/layout/modern_layout.dart';
import '../../widgets/common/gradient_button.dart';

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
    // final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: ModernAppBar(
        title: 'Chat with Helpy',
        subtitle: chatState.totalUnreadCount > 0
            ? '${chatState.totalUnreadCount} unread messages'
            : null,
        showProfile: true,
        showNotifications: false,
        actions: [
          IconButton(
            onPressed: () => _showNewChatOptions(context),
            icon: const Icon(Icons.add_rounded),
            style: IconButton.styleFrom(
              backgroundColor: DesignTokens.primary.withValues(alpha: 0.1),
              foregroundColor: DesignTokens.primary,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: chatState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : chatState.error != null
              ? _buildErrorState(context, chatState.error!)
              : chatState.conversations.isEmpty
              ? _buildEmptyState(context)
              : _buildConversationsList(context, chatState.conversations),
        ),
      ),
      floatingActionButton: chatState.conversations.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showNewChatOptions(context),
              backgroundColor: DesignTokens.primary,
              icon: const Icon(Icons.smart_toy_rounded, color: Colors.white),
              label: const Text(
                'New Chat',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: ModernSection(
        showGlassmorphism: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: DesignTokens.error,
            ),
            Space.m,
            Text(
              'Oops! Something went wrong',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Space.s,
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            Space.l,
            GradientButton(
              onPressed: () => ref.read(chatProvider.notifier).refresh(),
              text: 'Try Again',
              icon: Icons.refresh_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final personalities = ref.watch(availablePersonalitiesProvider);

    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Helpy illustration
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 2),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              DesignTokens.primary.withValues(alpha: 0.2),
                              DesignTokens.accent.withValues(alpha: 0.2),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          size: 60,
                          color: DesignTokens.primary,
                        ),
                      ),
                    );
                  },
                ),
                Space.xl,
                Text(
                  'Start Your Learning Journey!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Space.m,
                Text(
                  'Choose a Helpy personality to begin chatting and get personalized help with your studies.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                Space.xl,
              ],
            ),
          ),

          // Quick personality selection
          if (personalities.isNotEmpty) ...[
            ModernSection(
              title: 'Choose Your Helpy',
              showGlassmorphism: true,
              child: Column(
                children: [
                  // Show first 3 personalities as quick options
                  ...personalities
                      .take(3)
                      .map(
                        (personality) =>
                            _buildPersonalityQuickCard(context, personality),
                      )
                      .toList(),
                  Space.m,
                  OutlineButton(
                    onPressed: () => _showNewChatOptions(context),
                    text: 'See All Personalities',
                    icon: Icons.explore_rounded,
                  ),
                ],
              ),
            ),
          ] else ...[
            GradientButton(
              onPressed: () => _showNewChatOptions(context),
              text: 'Start First Chat',
              icon: Icons.smart_toy_rounded,
              width: double.infinity,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalityQuickCard(
    BuildContext context,
    HelpyPersonality personality,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceM),
      child: GestureDetector(
        onTap: () => _startNewChat(personality),
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.spaceM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(
                  int.parse(personality.colorTheme.substring(1), radix: 16) |
                      0xFF000000,
                ).withValues(alpha: 0.1),
                Color(
                  int.parse(personality.colorTheme.substring(1), radix: 16) |
                      0xFF000000,
                ).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            border: Border.all(
              color: Color(
                int.parse(personality.colorTheme.substring(1), radix: 16) |
                    0xFF000000,
              ).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(personality.colorTheme.substring(1), radix: 16) |
                        0xFF000000,
                  ),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
                child: Center(
                  child: Text(
                    personality.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personality.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceXS),
                    Text(
                      personality.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(
                  int.parse(personality.colorTheme.substring(1), radix: 16) |
                      0xFF000000,
                ),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationsList(
    BuildContext context,
    List<Conversation> conversations,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(chatProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(DesignTokens.spaceM),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return _buildConversationCard(context, conversation);
        },
      ),
    );
  }

  Widget _buildConversationCard(
    BuildContext context,
    Conversation conversation,
  ) {
    final personality = ref.watch(
      helpyPersonalityProvider(conversation.helpyPersonalityId),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceM),
      child: GlassmorphicCard(
        onTap: () => _openConversation(conversation),
        child: Row(
          children: [
            // Personality avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: personality != null
                      ? [
                          Color(
                            int.parse(
                                  personality.colorTheme.substring(1),
                                  radix: 16,
                                ) |
                                0xFF000000,
                          ),
                          Color(
                            int.parse(
                                  personality.colorTheme.substring(1),
                                  radix: 16,
                                ) |
                                0xFF000000,
                          ).withValues(alpha: 0.8),
                        ]
                      : [DesignTokens.primary, DesignTokens.accent],
                ),
                borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              ),
              child: Center(
                child: Text(
                  personality?.icon ?? '🤖',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.spaceM),

            // Conversation info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.displayTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessageTime != null)
                        Text(
                          conversation.formattedLastMessageTime,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spaceXS),
                  if (conversation.lastMessagePreview != null)
                    Text(
                      conversation.lastMessagePreview!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Unread badge and actions
            Column(
              children: [
                if (conversation.hasUnreadMessages)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceS,
                      vertical: DesignTokens.spaceXS,
                    ),
                    decoration: BoxDecoration(
                      color: DesignTokens.accent,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                    ),
                    child: Text(
                      '${conversation.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: DesignTokens.spaceS),
                PopupMenuButton<String>(
                  onSelected: (value) =>
                      _handleConversationAction(conversation, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(Icons.mark_email_read_rounded),
                          SizedBox(width: 8),
                          Text('Mark as Read'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'archive',
                      child: Row(
                        children: [
                          Icon(Icons.archive_rounded),
                          SizedBox(width: 8),
                          Text('Archive'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded, color: DesignTokens.error),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: DesignTokens.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNewChatOptions(BuildContext context) {
    final personalities = ref.read(availablePersonalitiesProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(DesignTokens.radiusXL),
            topRight: Radius.circular(DesignTokens.radiusXL),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: DesignTokens.spaceM),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceL),
              child: Text(
                'Choose Your Helpy Personality',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            // Personalities list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceL,
                ),
                itemCount: personalities.length,
                itemBuilder: (context, index) {
                  final personality = personalities[index];
                  return _buildPersonalitySelectionCard(context, personality);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalitySelectionCard(
    BuildContext context,
    HelpyPersonality personality,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceM),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          _startNewChat(personality);
        },
        child: GlassmorphicCard(
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(personality.colorTheme.substring(1), radix: 16) |
                        0xFF000000,
                  ),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                ),
                child: Center(
                  child: Text(
                    personality.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personality.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceXS),
                    Text(
                      personality.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    if (personality.specializations.isNotEmpty) ...[
                      const SizedBox(height: DesignTokens.spaceS),
                      Wrap(
                        spacing: DesignTokens.spaceXS,
                        children: personality.specializations
                            .take(3)
                            .map(
                              (spec) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DesignTokens.spaceS,
                                  vertical: DesignTokens.spaceXS,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(
                                    int.parse(
                                          personality.colorTheme.substring(1),
                                          radix: 16,
                                        ) |
                                        0xFF000000,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusS,
                                  ),
                                ),
                                child: Text(
                                  spec,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Color(
                                          int.parse(
                                                personality.colorTheme
                                                    .substring(1),
                                                radix: 16,
                                              ) |
                                              0xFF000000,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(
                  int.parse(personality.colorTheme.substring(1), radix: 16) |
                      0xFF000000,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startNewChat(HelpyPersonality personality) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      final conversation = await ref
          .read(chatProvider.notifier)
          .createConversation(
            title: '',
            userId: user.id,
            helpyPersonalityId: personality.id,
            type: ConversationType.general,
          );

      if (mounted) {
        context.go('/chat/${conversation.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start chat: $e'),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
    }
  }

  void _openConversation(Conversation conversation) {
    context.go('/chat/${conversation.id}');
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
          const SnackBar(content: Text('Archive feature coming soon!')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(conversation);
        break;
    }
  }

  void _showDeleteConfirmation(Conversation conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: Text(
          'Are you sure you want to delete "${conversation.displayTitle}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
                    const SnackBar(content: Text('Conversation deleted')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete conversation: $e'),
                      backgroundColor: DesignTokens.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: DesignTokens.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
