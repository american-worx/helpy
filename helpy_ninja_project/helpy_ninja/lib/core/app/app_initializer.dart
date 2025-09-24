import 'dart:async';
import 'package:logger/logger.dart';

import '../storage/hive_service.dart';
import '../sync/sync_service.dart';
import '../network/websocket_manager.dart';
import '../di/injection.dart';
import '../ai/enhanced_helpy_ai_service.dart';

/// Service for initializing the app with all required services
class AppInitializer {
  static final Logger _logger = Logger();
  static bool _isInitialized = false;
  
  /// Initialize all app services in the correct order
  static Future<void> initialize() async {
    if (_isInitialized) {
      _logger.w('App already initialized');
      return;
    }

    try {
      _logger.d('Starting app initialization...');

      // Phase 1: Core Infrastructure
      await _initializeCore();
      
      // Phase 2: Storage Layer
      await _initializeStorage();
      
      // Phase 3: Network Layer
      await _initializeNetwork();
      
      // Phase 4: Sync Layer
      await _initializeSync();
      
      // Phase 5: AI Services
      await _initializeAI();
      
      _isInitialized = true;
      _logger.d('App initialization completed successfully');
      
    } catch (e, stackTrace) {
      _logger.e('App initialization failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Phase 1: Initialize core infrastructure
  static Future<void> _initializeCore() async {
    _logger.d('Initializing core infrastructure...');
    
    // Configure dependency injection
    configureDependencies();
    
    // Add any other core initialization here
    _logger.d('Core infrastructure initialized');
  }

  /// Phase 2: Initialize storage layer
  static Future<void> _initializeStorage() async {
    _logger.d('Initializing storage layer...');
    
    // Initialize Hive with all adapters and boxes
    await HiveService.init();
    
    _logger.d('Storage layer initialized');
  }

  /// Phase 3: Initialize network layer
  static Future<void> _initializeNetwork() async {
    _logger.d('Initializing network layer...');
    
    try {
      // Initialize WebSocket manager
      final webSocketManager = getIt<WebSocketManager>();
      await webSocketManager.initialize();
      
      // Don't auto-connect WebSocket here - let the app decide when to connect
      _logger.d('Network layer initialized');
      
    } catch (e) {
      _logger.w('Network initialization failed (will retry when needed)', error: e);
      // Don't fail the entire initialization for network issues
    }
  }

  /// Phase 4: Initialize sync layer
  static Future<void> _initializeSync() async {
    _logger.d('Initializing sync layer...');
    
    try {
      // Initialize sync service
      final syncService = SyncService.create();
      await syncService.initialize();
      
      _logger.d('Sync layer initialized');
      
    } catch (e) {
      _logger.w('Sync initialization failed (will retry when needed)', error: e);
      // Don't fail the entire initialization for sync issues
    }
  }

  /// Phase 5: Initialize AI services
  static Future<void> _initializeAI() async {
    _logger.d('Initializing AI services...');
    
    try {
      // Initialize Enhanced AI Service with best available provider
      await EnhancedHelpyAIService.initializeWithBestProvider();
      
      _logger.d('AI services initialized successfully');
      
    } catch (e) {
      _logger.w('AI initialization failed (will use fallback)', error: e);
      // Don't fail the entire initialization for AI issues
      // The service will fall back to mock responses
    }
  }

  /// Get initialization status
  static bool get isInitialized => _isInitialized;

  /// Reset initialization state (for testing)
  static void reset() {
    _isInitialized = false;
  }

  /// Clean shutdown of all services
  static Future<void> shutdown() async {
    if (!_isInitialized) return;

    _logger.d('Shutting down app services...');

    try {
      // Shutdown in reverse order
      
      // Close WebSocket connections
      final webSocketManager = getIt<WebSocketManager>();
      webSocketManager.dispose();
      
      // Close Hive boxes
      await HiveService.close();
      
      _logger.d('App services shut down successfully');
      
    } catch (e) {
      _logger.e('Error during app shutdown', error: e);
    } finally {
      _isInitialized = false;
    }
  }
}

/// Mixin for app lifecycle management
mixin AppLifecycleManager {
  /// Initialize app services before starting the UI
  Future<void> initializeApp() async {
    await AppInitializer.initialize();
  }

  /// Clean shutdown when app is terminated
  Future<void> shutdownApp() async {
    await AppInitializer.shutdown();
  }
}

/// Status of app initialization
enum AppInitializationStatus {
  notStarted,
  initializing,
  completed,
  failed,
}

/// App initialization progress
class AppInitializationProgress {
  final AppInitializationStatus status;
  final String phase;
  final double progress; // 0.0 to 1.0
  final String? error;

  const AppInitializationProgress({
    required this.status,
    required this.phase,
    required this.progress,
    this.error,
  });

  AppInitializationProgress copyWith({
    AppInitializationStatus? status,
    String? phase,
    double? progress,
    String? error,
  }) {
    return AppInitializationProgress(
      status: status ?? this.status,
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      error: error,
    );
  }
}