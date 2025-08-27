import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import 'auth_provider.dart';

/// Theme mode enum
enum AppThemeMode { light, dark, system }

/// Theme state model
class ThemeState {
  final AppThemeMode themeMode;
  final bool isSystemDarkMode;

  const ThemeState({
    this.themeMode = AppThemeMode.dark, // Default to dark for tech users
    this.isSystemDarkMode = false,
  });

  ThemeState copyWith({AppThemeMode? themeMode, bool? isSystemDarkMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isSystemDarkMode: isSystemDarkMode ?? this.isSystemDarkMode,
    );
  }

  /// Get the effective theme mode
  ThemeMode get effectiveThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Whether we should use dark theme
  bool get isDarkMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return isSystemDarkMode;
    }
  }
}

/// Theme state notifier
class ThemeNotifier extends StateNotifier<ThemeState> {
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

  ThemeNotifier() : super(const ThemeState()) {
    _logger.d('ThemeNotifier initialized');
    _initializeTheme();
  }

  late Box _themeBox;

  /// Initialize theme from storage or user preferences
  Future<void> _initializeTheme() async {
    _logger.d('Initializing theme');
    try {
      _themeBox = await Hive.openBox('theme');
      _logger.d('Theme box opened successfully');

      // Get stored theme preference
      final storedTheme = _themeBox.get(AppConstants.themeKey);
      AppThemeMode themeMode = AppThemeMode.dark; // Default
      _logger.d('Stored theme value: $storedTheme');

      if (storedTheme != null) {
        themeMode = AppThemeMode.values.firstWhere(
          (mode) => mode.name == storedTheme,
          orElse: () => AppThemeMode.dark,
        );
      }

      state = state.copyWith(themeMode: themeMode);
      _logger.d('Theme initialized: ${themeMode.toString()}');
    } catch (e) {
      _logger.e('Failed to initialize theme: ${e.toString()}');
      // If initialization fails, keep default dark theme
      debugPrint('Failed to initialize theme: $e');
    }
  }

  /// Update system brightness (called from app lifecycle)
  void updateSystemBrightness(Brightness brightness) {
    _logger.d('Updating system brightness: ${brightness.toString()}');
    final isSystemDarkMode = brightness == Brightness.dark;
    if (state.isSystemDarkMode != isSystemDarkMode) {
      state = state.copyWith(isSystemDarkMode: isSystemDarkMode);
      _logger.d('System brightness updated, isDarkMode: $isSystemDarkMode');
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    _logger.d('Setting theme mode: ${themeMode.toString()}');
    try {
      await _themeBox.put(AppConstants.themeKey, themeMode.name);
      _logger.d('Theme preference saved to storage: ${themeMode.name}');
      state = state.copyWith(themeMode: themeMode);
      _logger.d('Theme mode updated in state: ${themeMode.toString()}');
    } catch (e) {
      _logger.e('Failed to save theme preference: ${e.toString()}');
      debugPrint('Failed to save theme preference: $e');
    }
  }

  /// Toggle between light and dark (for quick toggle)
  Future<void> toggleTheme() async {
    _logger.d('Toggling theme, currentMode: ${state.themeMode.toString()}');
    final newMode = state.themeMode == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;
    _logger.d('New theme mode selected: ${newMode.toString()}');
    await setThemeMode(newMode);
  }

  /// Sync theme with user preferences
  void syncWithUserPreferences(bool isDarkMode) {
    _logger.d('Syncing theme with user preferences, isDarkMode: $isDarkMode');
    final newMode = isDarkMode ? AppThemeMode.dark : AppThemeMode.light;
    if (state.themeMode != newMode) {
      _logger.d(
        'Theme mode changed, updating - oldMode: ${state.themeMode.toString()}, newMode: ${newMode.toString()}',
      );
      setThemeMode(newMode);
    } else {
      _logger.d('Theme mode unchanged, no update needed');
    }
  }
}

/// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final notifier = ThemeNotifier();

  // Listen to auth changes to sync theme with user preferences
  ref.listen(authProvider, (previous, next) {
    if (next.user?.preferences != null) {
      notifier.syncWithUserPreferences(next.user!.preferences.isDarkMode);
    }
  });

  return notifier;
});

/// Current theme mode provider (convenience)
final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeProvider).effectiveThemeMode;
});

/// Is dark mode provider (convenience)
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider).isDarkMode;
});

/// Current theme data provider
final currentThemeProvider = Provider<ThemeData>((ref) {
  final isDarkMode = ref.watch(isDarkModeProvider);
  return isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
});

/// Current color scheme provider (convenience)
final currentColorSchemeProvider = Provider<ColorScheme>((ref) {
  final theme = ref.watch(currentThemeProvider);
  return theme.colorScheme;
});
