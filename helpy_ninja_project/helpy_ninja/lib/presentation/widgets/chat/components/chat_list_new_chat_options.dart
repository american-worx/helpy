import 'package:flutter/material.dart';

import '../../../../config/design_tokens.dart';
import '../../../../domain/entities/helpy_personality.dart';
import 'chat_list_personality_selection_card.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

/// New chat options modal bottom sheet
class ChatListNewChatOptions extends StatelessWidget {
  final List<HelpyPersonality> personalities;
  final Function(HelpyPersonality) onPersonalitySelected;

  const ChatListNewChatOptions({
    super.key,
    required this.personalities,
    required this.onPersonalitySelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
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
              l10n.chooseYourHelpyPersonality,
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
                return ChatListPersonalitySelectionCard(
                  personality: personality,
                  onTap: () {
                    Navigator.pop(context);
                    onPersonalitySelected(personality);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
