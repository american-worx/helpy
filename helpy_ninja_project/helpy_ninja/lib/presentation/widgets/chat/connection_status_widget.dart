import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/realtime_chat_provider.dart';

/// Widget to display real-time connection status
class ConnectionStatusWidget extends ConsumerWidget {
  final bool showLabel;
  final bool showIcon;
  final EdgeInsets padding;

  const ConnectionStatusWidget({
    super.key,
    this.showLabel = true,
    this.showIcon = true,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectionStatusProvider);
    final theme = Theme.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _getStatusColor(isConnected).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(isConnected).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _getStatusIcon(isConnected),
              color: _getStatusColor(isConnected),
              size: 16,
            ),
            if (showLabel) const SizedBox(width: 6),
          ],
          if (showLabel)
            Text(
              _getStatusText(isConnected),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getStatusColor(isConnected),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(bool isConnected) {
    return isConnected ? Colors.green : Colors.orange;
  }

  IconData _getStatusIcon(bool isConnected) {
    return isConnected ? Icons.wifi : Icons.wifi_off;
  }

  String _getStatusText(bool isConnected) {
    return isConnected ? 'Connected' : 'Offline';
  }
}

/// Compact version for app bars
class CompactConnectionStatusWidget extends ConsumerWidget {
  const CompactConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectionStatusProvider);
    
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isConnected ? Colors.green : Colors.orange,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Connection status banner for important notifications
class ConnectionStatusBanner extends ConsumerWidget {
  final VoidCallback? onRetry;

  const ConnectionStatusBanner({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(connectionStatusProvider);
    final theme = Theme.of(context);

    if (isConnected) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.orange.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Offline Mode',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Messages will be sent when you reconnect',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}