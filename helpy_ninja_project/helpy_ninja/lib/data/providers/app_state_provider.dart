import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

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
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 100,
      colors: false,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  AppStateNotifier() : super(const AppState()) {
    _logger.d('AppStateNotifier initialized');
    _initializeApp();
  }

  /// Initialize app state
  Future<void> _initializeApp() async {
    _logger.d('Initializing app state');
    // Initialize feature flags from constants
    final featureFlags = {
      'offline_mode': AppConstants.enableOfflineMode,
      'voice_input': AppConstants.enableVoiceInput,
      'group_chat': AppConstants.enableGroupChat,
      'local_llm': AppConstants.enableLocalLLM,
      'analytics': AppConstants.enableAnalytics,
    };

    state = state.copyWith(featureFlags: featureFlags);
    _logger.d(
      'App state initialized with feature flags: ${featureFlags.toString()}',
    );

    // Start connectivity monitoring
    _startConnectivityMonitoring();
  }

  /// Start monitoring connectivity
  void _startConnectivityMonitoring() {
    _logger.d('Starting connectivity monitoring');
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final connectivity = _mapConnectivityResults(results);
      state = state.copyWith(connectivity: connectivity);
      _logger.d('Connectivity changed to: ${connectivity.toString()}');
    });

    // Check initial connectivity
    _checkInitialConnectivity();
  }

  /// Check initial connectivity state
  Future<void> _checkInitialConnectivity() async {
    _logger.d('Checking initial connectivity');
    try {
      final results = await Connectivity().checkConnectivity();
      final connectivity = _mapConnectivityResults(results);
      state = state.copyWith(connectivity: connectivity);
      _logger.d(
        'Initial connectivity check completed: ${connectivity.toString()}',
      );
    } catch (e) {
      _logger.e('Failed to check initial connectivity: ${e.toString()}');
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
    _logger.d(
      'Setting app loading state: ${loadingState.toString()}, hasError: ${errorMessage != null}',
    );
    state = state.copyWith(
      loadingState: loadingState,
      errorMessage: loadingState == AppLoadingState.error ? errorMessage : null,
    );
  }

  /// Show global loading
  void showLoading() {
    _logger.d('Showing global loading');
    setLoadingState(AppLoadingState.loading);
  }

  /// Hide global loading
  void hideLoading() {
    _logger.d('Hiding global loading');
    setLoadingState(AppLoadingState.idle);
  }

  /// Show global error
  void showError(String errorMessage) {
    _logger.d('Showing global error: $errorMessage');
    setLoadingState(AppLoadingState.error, errorMessage: errorMessage);
  }

  /// Clear error
  void clearError() {
    _logger.d('Clearing error');
    setLoadingState(AppLoadingState.idle);
  }

  /// Toggle offline mode
  void toggleOfflineMode() {
    _logger.d('Toggling offline mode, currentValue: ${state.isOfflineMode}');
    if (state.featureFlags['offline_mode'] == true) {
      state = state.copyWith(isOfflineMode: !state.isOfflineMode);
      _logger.d('Offline mode toggled, newValue: ${state.isOfflineMode}');
    } else {
      _logger.w('Attempted to toggle offline mode but feature is disabled');
    }
  }

  /// Enable offline mode
  void enableOfflineMode() {
    _logger.d('Enabling offline mode');
    if (state.featureFlags['offline_mode'] == true) {
      state = state.copyWith(isOfflineMode: true);
      _logger.d('Offline mode enabled');
    } else {
      _logger.w('Attempted to enable offline mode but feature is disabled');
    }
  }

  /// Disable offline mode
  void disableOfflineMode() {
    _logger.d('Disabling offline mode');
    state = state.copyWith(isOfflineMode: false);
    _logger.d('Offline mode disabled');
  }

  /// Update feature flag
  void updateFeatureFlag(String feature, bool enabled) {
    _logger.d('Updating feature flag: $feature, enabled: $enabled');
    final updatedFlags = Map<String, bool>.from(state.featureFlags);
    updatedFlags[feature] = enabled;
    state = state.copyWith(featureFlags: updatedFlags);
    _logger.d('Feature flag updated: $feature, enabled: $enabled');
  }

  /// Check if feature is enabled
  bool isFeatureEnabled(String feature) {
    final isEnabled = state.featureFlags[feature] ?? false;
    _logger.d('Checking if feature is enabled: $feature, enabled: $isEnabled');
    return isEnabled;
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
