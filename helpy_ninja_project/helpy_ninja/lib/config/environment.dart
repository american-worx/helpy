import 'package:flutter/foundation.dart';

/// Environment configuration for different build variants
enum Environment { development, staging, production }

class AppConfig {
  // Private constructor
  AppConfig._();

  /// Current environment based on build configuration
  static Environment get environment {
    const envName = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'development',
    );
    return Environment.values.firstWhere(
      (e) => e.name == envName,
      orElse: () => Environment.development,
    );
  }

  /// API base URL based on environment
  static String get apiBaseUrl {
    switch (environment) {
      case Environment.development:
        return 'https://dev-api.helpy.ninja';
      case Environment.staging:
        return 'https://staging-api.helpy.ninja';
      case Environment.production:
        return 'https://api.helpy.ninja';
    }
  }

  /// WebSocket URL based on environment
  static String get websocketUrl {
    switch (environment) {
      case Environment.development:
        return 'ws://dev-ws.helpy.ninja';
      case Environment.staging:
        return 'wss://staging-ws.helpy.ninja';
      case Environment.production:
        return 'wss://ws.helpy.ninja';
    }
  }

  /// Whether debug features are enabled
  static bool get isDebug {
    switch (environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }

  /// Whether analytics should be enabled
  static bool get enableAnalytics {
    switch (environment) {
      case Environment.development:
        return false;
      case Environment.staging:
        return false;
      case Environment.production:
        return true; // Only in production
    }
  }

  /// Whether to use mock data for development
  static bool get useMockData {
    switch (environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return false;
      case Environment.production:
        return false;
    }
  }

  /// Log level based on environment
  static String get logLevel {
    switch (environment) {
      case Environment.development:
        return 'debug';
      case Environment.staging:
        return 'info';
      case Environment.production:
        return 'warning';
    }
  }

  /// App name with environment suffix
  static String get appName {
    switch (environment) {
      case Environment.development:
        return 'Helpy Ninja Dev';
      case Environment.staging:
        return 'Helpy Ninja Staging';
      case Environment.production:
        return 'Helpy Ninja';
    }
  }

  /// App bundle identifier
  static String get bundleId {
    switch (environment) {
      case Environment.development:
        return 'ninja.helpy.dev';
      case Environment.staging:
        return 'ninja.helpy.staging';
      case Environment.production:
        return 'ninja.helpy';
    }
  }

  /// Feature flags based on environment
  static bool get enableLocalLLM {
    return true; // Enabled in all environments
  }

  static bool get enableOfflineMode {
    return true; // Enabled in all environments
  }

  static bool get enableGroupChat {
    switch (environment) {
      case Environment.development:
        return true;
      case Environment.staging:
        return true;
      case Environment.production:
        return true;
    }
  }

  /// API timeout configuration
  static Duration get apiTimeout {
    switch (environment) {
      case Environment.development:
        return const Duration(seconds: 60); // Longer for debugging
      case Environment.staging:
        return const Duration(seconds: 30);
      case Environment.production:
        return const Duration(seconds: 30);
    }
  }

  /// Maximum retry attempts for failed requests
  static int get maxRetryAttempts {
    switch (environment) {
      case Environment.development:
        return 5;
      case Environment.staging:
        return 3;
      case Environment.production:
        return 3;
    }
  }

  /// Cache configuration
  static Duration get cacheExpiry {
    switch (environment) {
      case Environment.development:
        return const Duration(minutes: 5); // Short for testing
      case Environment.staging:
        return const Duration(hours: 1);
      case Environment.production:
        return const Duration(hours: 24);
    }
  }

  /// Print current configuration (for debugging)
  static void printConfig() {
    if (isDebug) {
      debugPrint('=== Helpy Ninja Configuration ===');
      debugPrint('Environment: ${environment.name}');
      debugPrint('API Base URL: $apiBaseUrl');
      debugPrint('WebSocket URL: $websocketUrl');
      debugPrint('Debug Mode: $isDebug');
      debugPrint('Mock Data: $useMockData');
      debugPrint('Analytics: $enableAnalytics');
      debugPrint('Log Level: $logLevel');
      debugPrint('================================');
    }
  }
}
