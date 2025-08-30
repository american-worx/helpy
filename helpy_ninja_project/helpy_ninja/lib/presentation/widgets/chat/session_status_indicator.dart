import 'package:flutter/material.dart';
import 'package:helpy_ninja/domain/entities/shared_enums.dart';
import 'package:helpy_ninja/config/design_tokens.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

/// Session status indicator widget
class SessionStatusIndicator extends StatelessWidget {
  final GroupSessionStatus status;
  final double size;
  final bool showText;

  const SessionStatusIndicator({
    super.key,
    required this.status,
    this.size = 12.0,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            shape: BoxShape.circle,
          ),
        ),
        if (showText) ...[
          const SizedBox(width: DesignTokens.spaceXS),
          Text(
            _getStatusText(status, l10n),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }

  /// Get color based on session status
  Color _getStatusColor(GroupSessionStatus status) {
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

  /// Get localized status text
  String _getStatusText(GroupSessionStatus status, AppLocalizations l10n) {
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
}
