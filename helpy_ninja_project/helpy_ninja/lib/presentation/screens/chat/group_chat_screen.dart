import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/design_tokens.dart';
import '../../../data/providers/group_session_provider.dart';
import '../../../domain/entities/group_session.dart';
import '../../../domain/entities/helpy_personality.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/shared_enums.dart';
import '../../widgets/navigation/modern_navigation.dart';
import '../../widgets/chat/helpy_indicator.dart';
import '../../widgets/chat/participant_list.dart';
import '../../widgets/chat/session_status_indicator.dart';
import '../../widgets/chat/typing_indicator.dart';
import '../../widgets/chat/ai_coordination_cue.dart';
import '../../widgets/chat/add_participants_dialog.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

/// Group chat interface screen for multi-agent conversations
class GroupChatScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const GroupChatScreen({super.key, required this.sessionId});

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen>
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

    // Load session when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // No need to explicitly read the provider, it will be watched in build
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(specificGroupSessionProvider(widget.sessionId));

    return Scaffold(
      appBar: _buildAppBar(context, l10n),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Session info area
            _buildSessionInfoArea(context, session, l10n),

            // Participant list
            if (session != null) ...[
              ParticipantList(session: session),
              const SizedBox(height: DesignTokens.spaceS),
            ],

            // Messages area
            Expanded(
              child: _buildMessagesArea(context, session, l10n),
            ),

            // AI coordination cue
            AICoordinationCue(
              message:
                  "Helpys are coordinating to provide the best response...",
            ),

            // Input area
            _buildInputArea(context, l10n),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppLocalizations l10n) {
    return ModernAppBar(
      title: l10n.groupChatTitle,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Implement session settings
          },
          icon: const Icon(Icons.settings_rounded),
        ),
        IconButton(
          onPressed: () => _showAddParticipantsDialog(context, l10n),
          icon: const Icon(Icons.person_add_rounded),
        ),
      ],
    );
  }

  void _showAddParticipantsDialog(
      BuildContext context, AppLocalizations l10n) async {
    // In a real implementation, we would fetch available Helpys that are not already in the session
    // For now, we'll use a placeholder list with explicit type
    final availableHelpys = <HelpyPersonality>[];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddParticipantsDialog(
        session: ref.read(specificGroupSessionProvider(widget.sessionId))!,
        availableHelpys: availableHelpys,
      ),
    );

    // Use the result to avoid unused result warning
    if (result == true && mounted) {
      // Refresh the session data to show the new participants
      // Use the result of refresh to avoid unused result warning
      final _ = ref.refresh(specificGroupSessionProvider(widget.sessionId));
    }
  }

  Widget _buildSessionInfoArea(
    BuildContext context,
    GroupSession? session,
    AppLocalizations l10n,
  ) {
    if (session == null) {
      return Container(
        padding: const EdgeInsets.all(DesignTokens.spaceM),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceS),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Enhanced session status indicator
          SessionStatusIndicator(
            status: session.status,
            size: 12.0,
            showText: true,
          ),
          const SizedBox(width: DesignTokens.spaceS),
          // Participant count
          Text(
            '${session.participantCount} ${l10n.participantListTitle.toLowerCase()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          // Helpy indicators with enhanced visualization
          ...session.helpyParticipants.take(3).map((helpy) {
            return Container(
              margin: const EdgeInsets.only(left: DesignTokens.spaceXS),
              child: HelpyIndicator(
                helpy: helpy,
                size: 24.0,
                showStatus: true,
                status: HelpyStatus
                    .online, // In a real implementation, this would be dynamic
              ),
            );
          }).toList(),
          if (session.helpyParticipants.length > 3) ...[
            const SizedBox(width: DesignTokens.spaceXS),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                '+${session.helpyParticipants.length - 3}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getSessionStatusColor(GroupSessionStatus status) {
    switch (status) {
      case GroupSessionStatus.active:
        return DesignTokens.success;
      case GroupSessionStatus.paused:
        return DesignTokens.warning;
      case GroupSessionStatus.completed:
        return DesignTokens.primary;
      case GroupSessionStatus.cancelled:
        return DesignTokens.error;
    }
  }

  String _getSessionStatusText(
      GroupSessionStatus status, AppLocalizations l10n) {
    switch (status) {
      case GroupSessionStatus.active:
        return l10n.sessionStatusActive;
      case GroupSessionStatus.paused:
        return l10n.sessionStatusPaused;
      case GroupSessionStatus.completed:
        return l10n.sessionStatusCompleted;
      case GroupSessionStatus.cancelled:
        return l10n.sessionStatusCancelled;
    }
  }

  Color _getHelpyColor(HelpyPersonality helpy) {
    try {
      return Color(
          int.parse(helpy.colorTheme.substring(1), radix: 16) | 0xFF000000);
    } catch (e) {
      return DesignTokens.primary;
    }
  }

  Widget _buildMessagesArea(
    BuildContext context,
    GroupSession? session,
    AppLocalizations l10n,
  ) {
    if (session == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (session.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: DesignTokens.spaceM),
            Text(
              l10n.startYourLearningJourney,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: DesignTokens.spaceS),
            Text(
              l10n.chooseHelpyPersonality,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(DesignTokens.spaceM),
          itemCount: session.messages.length,
          itemBuilder: (context, index) {
            final message = session.messages[index];
            return _buildMessageBubble(context, message, session, l10n);
          },
        ),
        // Typing indicator (positioned at the bottom of the messages area)
        Positioned(
          bottom: DesignTokens.spaceM,
          left: DesignTokens.spaceM,
          child: TypingIndicator(
            userName:
                "Helpy", // In a real implementation, this would be dynamic
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    Message message,
    GroupSession session,
    AppLocalizations l10n,
  ) {
    final isOwnMessage = message.senderId == 'user'; // TODO: Get actual user ID
    final sender = _getMessageSender(message, session);

    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceS),
      child: Column(
        crossAxisAlignment:
            isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender info with enhanced Helpy indicator
          if (!isOwnMessage) ...[
            Row(
              children: [
                // Enhanced sender avatar with status
                HelpyIndicator(
                  helpy: sender,
                  size: 24.0,
                  showStatus: true,
                  status: HelpyStatus
                      .online, // In a real implementation, this would be dynamic
                ),
                const SizedBox(width: DesignTokens.spaceXS),
                // Sender name
                Text(
                  sender.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: DesignTokens.spaceXS),
                // Timestamp
                Text(
                  _formatTimestamp(message.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spaceXS),
          ],

          // Message content
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceM),
            decoration: BoxDecoration(
              color: isOwnMessage
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.1),
              ),
            ),
            child: Text(message.content),
          ),
        ],
      ),
    );
  }

  HelpyPersonality _getMessageSender(Message message, GroupSession session) {
    // Check if sender is a Helpy
    for (final helpy in session.helpyParticipants) {
      if (helpy.id == message.senderId) {
        return helpy;
      }
    }

    // Default to first Helpy if not found
    return session.helpyParticipants.first;
  }

  Color _getSenderColor(Message message, GroupSession session) {
    final sender = _getMessageSender(message, session);
    return _getHelpyColor(sender);
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }

  Widget _buildInputArea(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Attachment button
          IconButton(
            onPressed: () {
              // TODO: Implement attachment functionality
            },
            icon: const Icon(Icons.attach_file_rounded),
          ),
          const SizedBox(width: DesignTokens.spaceS),

          // Message input
          Expanded(
            child: ScaleTransition(
              scale: _inputScaleAnimation,
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: l10n.typeYourMessage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceM,
                    vertical: DesignTokens.spaceS,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceS),

          // Send button
          IconButton(
            onPressed: _isComposing ? _sendMessage : null,
            icon: Icon(
              Icons.send_rounded,
              color: _isComposing
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    // TODO: Implement actual message sending
    _messageController.clear();
    setState(() {
      _isComposing = false;
    });
    _inputAnimationController.reverse();
  }
}
