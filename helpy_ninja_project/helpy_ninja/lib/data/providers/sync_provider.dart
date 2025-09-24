import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/sync/sync_service.dart';

/// Provider for sync service
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService.create();
});

/// State for sync management
class SyncState {
  final SyncStatus status;
  final SyncProgress? progress;
  final SyncStatistics statistics;
  final String? error;
  final DateTime? lastSyncTime;

  const SyncState({
    this.status = SyncStatus.offline,
    this.progress,
    required this.statistics,
    this.error,
    this.lastSyncTime,
  });

  SyncState copyWith({
    SyncStatus? status,
    SyncProgress? progress,
    SyncStatistics? statistics,
    String? error,
    DateTime? lastSyncTime,
  }) {
    return SyncState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      statistics: statistics ?? this.statistics,
      error: error,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  bool get isOnline => status != SyncStatus.offline;
  bool get isSyncing => status == SyncStatus.syncing;
  bool get hasError => error != null;
}

/// Notifier for sync management
class SyncNotifier extends StateNotifier<SyncState> {
  final SyncService _syncService;
  
  StreamSubscription? _statusSubscription;
  StreamSubscription? _progressSubscription;

  SyncNotifier(this._syncService) : super(SyncState(
    statistics: _syncService.getSyncStatistics(),
  )) {
    _initialize();
  }

  /// Initialize sync service and listeners
  void _initialize() async {
    await _syncService.initialize();
    _setupListeners();
    _updateStatistics();
  }

  /// Force a manual sync
  Future<void> forceSync() async {
    try {
      state = state.copyWith(error: null);
      await _syncService.forceSync();
      _updateStatistics();
    } catch (e) {
      state = state.copyWith(error: 'Sync failed: ${e.toString()}');
    }
  }

  /// Sync specific conversation
  Future<void> syncConversation(String conversationId) async {
    try {
      await _syncService.syncConversation(conversationId);
      _updateStatistics();
    } catch (e) {
      state = state.copyWith(error: 'Failed to sync conversation: ${e.toString()}');
    }
  }

  /// Sync lesson progress
  Future<void> syncLessonProgress(String lessonId, String userId) async {
    try {
      await _syncService.syncLessonProgress(lessonId, userId);
      _updateStatistics();
    } catch (e) {
      state = state.copyWith(error: 'Failed to sync progress: ${e.toString()}');
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get current sync statistics
  SyncStatistics getStatistics() {
    return _syncService.getSyncStatistics();
  }

  /// Setup sync service listeners
  void _setupListeners() {
    // Listen to sync status changes
    _statusSubscription = _syncService.syncStatus.listen(
      (status) {
        state = state.copyWith(
          status: status,
          lastSyncTime: status == SyncStatus.synced ? DateTime.now() : null,
        );
        
        if (status == SyncStatus.error) {
          state = state.copyWith(error: 'Sync operation failed');
        } else if (status == SyncStatus.synced) {
          state = state.copyWith(error: null);
          _updateStatistics();
        }
      },
    );

    // Listen to sync progress updates
    _progressSubscription = _syncService.syncProgress.listen(
      (progress) {
        state = state.copyWith(progress: progress);
      },
    );
  }

  /// Update sync statistics
  void _updateStatistics() {
    final statistics = _syncService.getSyncStatistics();
    state = state.copyWith(statistics: statistics);
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _progressSubscription?.cancel();
    _syncService.dispose();
    super.dispose();
  }
}

/// Provider for sync state management
final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final syncService = ref.read(syncServiceProvider);
  return SyncNotifier(syncService);
});

/// Provider for sync status only
final syncStatusProvider = Provider<SyncStatus>((ref) {
  return ref.watch(syncProvider).status;
});

/// Provider for online status
final onlineStatusProvider = Provider<bool>((ref) {
  return ref.watch(syncProvider).isOnline;
});

/// Provider for sync progress
final syncProgressProvider = Provider<SyncProgress?>((ref) {
  return ref.watch(syncProvider).progress;
});

/// Provider for sync statistics
final syncStatisticsProvider = Provider<SyncStatistics>((ref) {
  return ref.watch(syncProvider).statistics;
});

/// Provider for checking if sync is in progress
final isSyncingProvider = Provider<bool>((ref) {
  return ref.watch(syncProvider).isSyncing;
});

/// Provider for last sync time
final lastSyncTimeProvider = Provider<DateTime?>((ref) {
  return ref.watch(syncProvider).lastSyncTime;
});

/// Provider for sync error
final syncErrorProvider = Provider<String?>((ref) {
  return ref.watch(syncProvider).error;
});