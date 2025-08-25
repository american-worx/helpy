import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../config/constants.dart';

/// App connectivity state
enum ConnectivityState { online, offline, unknown }

/// App loading state for global operations
enum AppLoadingState { idle, loading, error }

/// Global app state
class AppState {
  final ConnectivityState connectivity;
  final AppLoadingState loadingState;
  final String? errorMessage;
  final bool isOfflineMode;
  final Map<String, bool> featureFlags;

  const AppState({
    this.connectivity = ConnectivityState.unknown,
    this.loadingState = AppLoadingState.idle,
    this.errorMessage,
    this.isOfflineMode = false,
    this.featureFlags = const {},
  });

  AppState copyWith({
    ConnectivityState? connectivity,
    AppLoadingState? loadingState,
    String? errorMessage,
    bool? isOfflineMode,
    Map<String, bool>? featureFlags,
  }) {
    return AppState(
      connectivity: connectivity ?? this.connectivity,
      loadingState: loadingState ?? this.loadingState,
      errorMessage: errorMessage ?? this.errorMessage,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      featureFlags: featureFlags ?? this.featureFlags,
    );
  }

  bool get isOnline => connectivity == ConnectivityState.online;
  bool get isOffline => connectivity == ConnectivityState.offline;
  bool get isLoading => loadingState == AppLoadingState.loading;
  bool get hasError =>
      loadingState == AppLoadingState.error && errorMessage != null;
}

/// App state notifier
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState()) {
    _initializeApp();
  }

  /// Initialize app state
  Future<void> _initializeApp() async {
    // Initialize feature flags from constants
    final featureFlags = {
      'offline_mode': AppConstants.enableOfflineMode,
      'voice_input': AppConstants.enableVoiceInput,
      'group_chat': AppConstants.enableGroupChat,
      'local_llm': AppConstants.enableLocalLLM,
      'analytics': AppConstants.enableAnalytics,
    };

    state = state.copyWith(featureFlags: featureFlags);

    // Start connectivity monitoring
    _startConnectivityMonitoring();
  }

  /// Start monitoring connectivity
  void _startConnectivityMonitoring() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final connectivity = _mapConnectivityResults(results);
      state = state.copyWith(connectivity: connectivity);
    });

    // Check initial connectivity
    _checkInitialConnectivity();
  }

  /// Check initial connectivity state
  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final connectivity = _mapConnectivityResults(results);
      state = state.copyWith(connectivity: connectivity);
    } catch (e) {
      state = state.copyWith(connectivity: ConnectivityState.unknown);
    }
  }

  /// Map connectivity results to our state
  ConnectivityState _mapConnectivityResults(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return ConnectivityState.offline;
    }

    // Check if any connection is available
    for (final result in results) {
      switch (result) {
        case ConnectivityResult.wifi:
        case ConnectivityResult.mobile:
        case ConnectivityResult.ethernet:
          return ConnectivityState.online;
        case ConnectivityResult.none:
          continue;
        default:
          continue;
      }
    }

    return ConnectivityState.offline;
  }

  /// Set app loading state
  void setLoadingState(AppLoadingState loadingState, {String? errorMessage}) {
    state = state.copyWith(
      loadingState: loadingState,
      errorMessage: loadingState == AppLoadingState.error ? errorMessage : null,
    );
  }

  /// Show global loading
  void showLoading() {
    setLoadingState(AppLoadingState.loading);
  }

  /// Hide global loading
  void hideLoading() {
    setLoadingState(AppLoadingState.idle);
  }

  /// Show global error
  void showError(String errorMessage) {
    setLoadingState(AppLoadingState.error, errorMessage: errorMessage);
  }

  /// Clear error
  void clearError() {
    setLoadingState(AppLoadingState.idle);
  }

  /// Toggle offline mode
  void toggleOfflineMode() {
    if (state.featureFlags['offline_mode'] == true) {
      state = state.copyWith(isOfflineMode: !state.isOfflineMode);
    }
  }

  /// Enable offline mode
  void enableOfflineMode() {
    if (state.featureFlags['offline_mode'] == true) {
      state = state.copyWith(isOfflineMode: true);
    }
  }

  /// Disable offline mode
  void disableOfflineMode() {
    state = state.copyWith(isOfflineMode: false);
  }

  /// Update feature flag
  void updateFeatureFlag(String feature, bool enabled) {
    final updatedFlags = Map<String, bool>.from(state.featureFlags);
    updatedFlags[feature] = enabled;
    state = state.copyWith(featureFlags: updatedFlags);
  }

  /// Check if feature is enabled
  bool isFeatureEnabled(String feature) {
    return state.featureFlags[feature] ?? false;
  }
}

/// App state provider
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  return AppStateNotifier();
});

/// Connectivity provider (convenience)
final connectivityProvider = Provider<ConnectivityState>((ref) {
  return ref.watch(appStateProvider).connectivity;
});

/// Is online provider (convenience)
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isOnline;
});

/// Is offline provider (convenience)
final isOfflineProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isOffline;
});

/// Is offline mode enabled provider (convenience)
final isOfflineModeProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isOfflineMode;
});

/// App loading state provider (convenience)
final appLoadingStateProvider = Provider<AppLoadingState>((ref) {
  return ref.watch(appStateProvider).loadingState;
});

/// Is app loading provider (convenience)
final isAppLoadingProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isLoading;
});

/// App error provider (convenience)
final appErrorProvider = Provider<String?>((ref) {
  return ref.watch(appStateProvider).errorMessage;
});

/// Feature flag provider (convenience)
final featureFlagProvider = Provider.family<bool, String>((ref, feature) {
  return ref.watch(appStateProvider).featureFlags[feature] ?? false;
});
