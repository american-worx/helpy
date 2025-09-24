import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers/sync_provider.dart';
import '../../../core/sync/sync_service.dart';

/// Widget to display sync status and progress
class SyncStatusWidget extends ConsumerWidget {
  final bool showDetails;
  final bool showProgress;
  final EdgeInsets padding;

  const SyncStatusWidget({
    super.key,
    this.showDetails = true,
    this.showProgress = true,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final theme = Theme.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _getStatusColor(syncState.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(syncState.status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Row(
            children: [
              Icon(
                _getStatusIcon(syncState.status),
                color: _getStatusColor(syncState.status),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getStatusText(syncState.status),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: _getStatusColor(syncState.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (syncState.status != SyncStatus.syncing)
                TextButton(
                  onPressed: () => _handleForceSync(ref),
                  child: const Text('Sync Now'),
                ),
            ],
          ),
          
          // Progress bar
          if (showProgress && syncState.isSyncing && syncState.progress != null) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  syncState.progress!.phase,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(syncState.status),
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: syncState.progress!.progress,
                  backgroundColor: _getStatusColor(syncState.status).withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStatusColor(syncState.status),
                  ),
                ),
                if (syncState.progress!.processedCount != null &&
                    syncState.progress!.totalCount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${syncState.progress!.processedCount}/${syncState.progress!.totalCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(syncState.status).withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ],
          
          // Error message
          if (syncState.hasError) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      syncState.error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => ref.read(syncProvider.notifier).clearError(),
                    iconSize: 16,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
          
          // Details
          if (showDetails && !syncState.isSyncing) ...[
            const SizedBox(height: 12),
            _buildSyncDetails(syncState, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncDetails(SyncState syncState, ThemeData theme) {
    final stats = syncState.statistics;
    
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Conversations',
              stats.totalConversations.toString(),
              Icons.chat_bubble_outline,
              theme,
            ),
            _buildStatItem(
              'Messages',
              stats.totalMessages.toString(),
              Icons.message,
              theme,
            ),
            _buildStatItem(
              'Lessons',
              stats.totalLessons.toString(),
              Icons.school,
              theme,
            ),
            _buildStatItem(
              'Progress',
              stats.totalSessions.toString(),
              Icons.trending_up,
              theme,
            ),
          ],
        ),
        if (syncState.lastSyncTime != null) ...[
          const SizedBox(height: 8),
          Text(
            'Last sync: ${_formatTime(syncState.lastSyncTime!)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.offline:
        return Colors.grey;
      case SyncStatus.online:
        return Colors.green;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.cancelled:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.offline:
        return Icons.cloud_off;
      case SyncStatus.online:
        return Icons.cloud_done;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.synced:
        return Icons.cloud_done;
      case SyncStatus.error:
        return Icons.error_outline;
      case SyncStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.online:
        return 'Online';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.error:
        return 'Sync Error';
      case SyncStatus.cancelled:
        return 'Sync Cancelled';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  void _handleForceSync(WidgetRef ref) {
    ref.read(syncProvider.notifier).forceSync();
  }
}

/// Compact sync status indicator
class CompactSyncStatusWidget extends ConsumerWidget {
  const CompactSyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);
    final isSyncing = ref.watch(isSyncingProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSyncing)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(status)),
              ),
            )
          else
            Icon(
              _getStatusIcon(status),
              size: 12,
              color: _getStatusColor(status),
            ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(status),
            style: TextStyle(
              fontSize: 11,
              color: _getStatusColor(status),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.offline:
        return Colors.grey;
      case SyncStatus.online:
        return Colors.green;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.cancelled:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.offline:
        return Icons.cloud_off;
      case SyncStatus.online:
        return Icons.cloud_done;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.synced:
        return Icons.cloud_done;
      case SyncStatus.error:
        return Icons.error_outline;
      case SyncStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.online:
        return 'Online';
      case SyncStatus.syncing:
        return 'Sync';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.error:
        return 'Error';
      case SyncStatus.cancelled:
        return 'Cancel';
    }
  }
}