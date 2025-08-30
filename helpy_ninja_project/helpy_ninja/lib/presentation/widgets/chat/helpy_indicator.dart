import 'package:flutter/material.dart';
import 'package:helpy_ninja/domain/entities/helpy_personality.dart';
import 'package:helpy_ninja/config/design_tokens.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

/// Helpy indicator widget that visualizes Helpy personalities with enhanced styling
class HelpyIndicator extends StatelessWidget {
  final HelpyPersonality helpy;
  final double size;
  final bool showName;
  final bool showStatus;
  final HelpyStatus? status;

  const HelpyIndicator({
    super.key,
    required this.helpy,
    this.size = 24.0,
    this.showName = false,
    this.showStatus = false,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations? l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            // Main avatar circle
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: _getHelpyColor(context, helpy),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        _getHelpyColor(context, helpy).withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  helpy.icon,
                  style: TextStyle(
                    fontSize: size * 0.6,
                  ),
                ),
              ),
            ),
            // Status indicator
            if (showStatus && status != null) ...[
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: size * 0.4,
                  height: size * 0.4,
                  decoration: BoxDecoration(
                    color: _getStatusColor(context, status!),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: status == HelpyStatus.thinking
                      ? SizedBox(
                          width: size * 0.25,
                          height: size * 0.25,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ],
        ),
        // Helpy name
        if (showName) ...[
          const SizedBox(height: DesignTokens.spaceXS),
          Text(
            helpy.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        // Status text
        if (showStatus && status != null && l10n != null) ...[
          const SizedBox(height: DesignTokens.spaceXS / 2),
          Text(
            _getStatusText(status!, l10n),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 10,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  /// Get color based on Helpy personality type
  Color _getHelpyColor(BuildContext context, HelpyPersonality helpy) {
    try {
      return Color(
          int.parse(helpy.colorTheme.substring(1), radix: 16) | 0xFF000000);
    } catch (e) {
      return Theme.of(context).colorScheme.primary;
    }
  }

  /// Get color based on Helpy status
  Color _getStatusColor(BuildContext context, HelpyStatus status) {
    switch (status) {
      case HelpyStatus.online:
        return DesignTokens.success;
      case HelpyStatus.thinking:
        return DesignTokens.warning;
      case HelpyStatus.responding:
        return Theme.of(context).colorScheme.primary;
      case HelpyStatus.offline:
        return Theme.of(context).colorScheme.outline;
    }
  }

  /// Get localized status text
  String _getStatusText(HelpyStatus status, AppLocalizations l10n) {
    switch (status) {
      case HelpyStatus.online:
        return l10n.helpyStatusOnline;
      case HelpyStatus.thinking:
        return l10n.helpyStatusThinking;
      case HelpyStatus.responding:
        return l10n.helpyStatusResponding;
      case HelpyStatus.offline:
        return l10n.helpyStatusOffline;
    }
  }
}

/// Helpy status enumeration
enum HelpyStatus {
  online,
  thinking,
  responding,
  offline,
}
