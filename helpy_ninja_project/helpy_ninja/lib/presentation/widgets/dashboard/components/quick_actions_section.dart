import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/design_tokens.dart';
import '../../../../config/routes.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';
import '../../../widgets/layout/modern_layout.dart';
import 'action_button.dart';

/// Quick actions section with various learning actions
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ModernSection(
      title: l10n.quickActions,
      subtitle: l10n.getStartedWithTheseActions,
      showGlassmorphism: true,
      child: Column(
        children: [
          // Primary actions row
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  title: l10n.startNewChat,
                  icon: Icons.smart_toy_rounded,
                  color: DesignTokens.primary,
                  variant: ActionButtonVariant.primary,
                  onTap: () => context.go(AppRoutes.chatList),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceM),
              Expanded(
                child: ActionButton(
                  title: l10n.browseSubjects,
                  icon: Icons.explore_rounded,
                  color: DesignTokens.success,
                  variant: ActionButtonVariant.secondary,
                  onTap: () => context.go(AppRoutes.subjects),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceM),

          // Secondary actions row
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  title: l10n.continueLearning,
                  icon: Icons.play_circle_rounded,
                  color: DesignTokens.accent,
                  variant: ActionButtonVariant.secondary,
                  onTap: () => _handleContinueLearning(context),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceS),
              Expanded(
                child: ActionButton(
                  title: l10n.practiceQuiz,
                  icon: Icons.quiz_rounded,
                  color: DesignTokens.primary,
                  variant: ActionButtonVariant.tertiary,
                  onTap: () => _handlePracticeQuiz(context),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceS),
              Expanded(
                child: ActionButton(
                  title: l10n.myProgress,
                  icon: Icons.analytics_rounded,
                  color: DesignTokens.accent,
                  variant: ActionButtonVariant.tertiary,
                  onTap: () => context.go(AppRoutes.progress),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceS),
              Expanded(
                child: ActionButton(
                  title: l10n.studyGroups,
                  icon: Icons.groups_rounded,
                  color: DesignTokens.success,
                  variant: ActionButtonVariant.tertiary,
                  onTap: () => _handleStudyGroups(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleContinueLearning(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.continueLearningComingSoon),
        backgroundColor: DesignTokens.primary,
      ),
    );
  }

  void _handlePracticeQuiz(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.practiceQuizComingSoon),
        backgroundColor: DesignTokens.primary,
      ),
    );
  }

  void _handleStudyGroups(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.studyGroupsComingSoon),
        backgroundColor: DesignTokens.primary,
      ),
    );
  }
}
