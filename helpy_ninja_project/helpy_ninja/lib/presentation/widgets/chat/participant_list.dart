import 'package:flutter/material.dart';
import 'package:helpy_ninja/domain/entities/group_session.dart';
import 'package:helpy_ninja/domain/entities/helpy_personality.dart';
import 'package:helpy_ninja/config/design_tokens.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';
import 'package:helpy_ninja/domain/entities/shared_enums.dart';
import 'helpy_indicator.dart';

/// Participant list widget for group sessions
class ParticipantList extends StatelessWidget {
  final GroupSession session;
  final VoidCallback? onParticipantTap;

  const ParticipantList({
    super.key,
    required this.session,
    this.onParticipantTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.participantListTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${session.participantCount} ${l10n.participants.toLowerCase()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceM),
          // Participant list
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Human participants
                ...session.participantIds.map((participantId) {
                  final status = session.participantStatuses[participantId] ??
                      ParticipantStatus.inactive;
                  return _buildParticipantItem(
                    context,
                    participantId,
                    _getParticipantName(participantId),
                    _getParticipantColor(context),
                    status,
                    l10n,
                  );
                }).toList(),
                // Helpy participants
                ...session.helpyParticipants.map((helpy) {
                  return _buildHelpyParticipantItem(context, helpy, l10n);
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build participant item for human participants
  Widget _buildParticipantItem(
    BuildContext context,
    String id,
    String name,
    Color color,
    ParticipantStatus status,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: DesignTokens.spaceS),
      child: Column(
        children: [
          Stack(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getInitials(name),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              // Status indicator
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getParticipantStatusColor(context, status),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceXS),
          // Name
          SizedBox(
            width: 60,
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXS / 2),
          // Status text
          Text(
            _getParticipantStatusText(status, l10n),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 10,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build participant item for Helpy participants
  Widget _buildHelpyParticipantItem(
    BuildContext context,
    HelpyPersonality helpy,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: DesignTokens.spaceS),
      child: HelpyIndicator(
        helpy: helpy,
        size: 48.0,
        showName: true,
        showStatus: true,
        status: HelpyStatus
            .online, // In a real implementation, this would be dynamic
      ),
    );
  }

  /// Get participant name (in a real app, this would come from user data)
  String _getParticipantName(String id) {
    // This is a placeholder implementation
    switch (id) {
      case 'user_001':
        return 'You';
      case 'user_002':
        return 'Alex';
      case 'user_003':
        return 'Taylor';
      default:
        return 'User';
    }
  }

  /// Get participant color
  Color _getParticipantColor(BuildContext context) {
    return Theme.of(context).colorScheme.primaryContainer;
  }

  /// Get participant status color
  Color _getParticipantStatusColor(
      BuildContext context, ParticipantStatus status) {
    switch (status) {
      case ParticipantStatus.active:
        return DesignTokens.success;
      case ParticipantStatus.inactive:
        return Theme.of(context).colorScheme.outline;
      case ParticipantStatus.left:
        return DesignTokens.error;
      case ParticipantStatus.disconnected:
        return DesignTokens.warning;
    }
  }

  /// Get participant status text
  String _getParticipantStatusText(
      ParticipantStatus status, AppLocalizations l10n) {
    switch (status) {
      case ParticipantStatus.active:
        return l10n.participantStatusActive;
      case ParticipantStatus.inactive:
        return l10n.participantStatusInactive;
      case ParticipantStatus.left:
        return l10n.participantStatusLeft;
      case ParticipantStatus.disconnected:
        return l10n.participantStatusDisconnected;
    }
  }

  /// Get initials from name
  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }
}
