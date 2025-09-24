import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

import '../error/app_error.dart';
import '../error/error_handler.dart';
import 'error_reporting_service.dart';

/// Service for handling app crashes with user consent
class CrashReportingService {
  static final Logger _logger = Logger();
  static SharedPreferences? _prefs;
  static Box<CrashReport>? _crashBox;
  static bool _isInitialized = false;
  
  /// Initialize crash reporting service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _crashBox = await Hive.openBox<CrashReport>('crash_reports');
      
      // Set up crash handlers
      _setupCrashHandlers();
      
      _isInitialized = true;
      _logger.i('Crash reporting service initialized');
      
      // Check for previous crashes
      await _processPendingCrashes();
    } catch (e) {
      _logger.e('Failed to initialize crash reporting service: $e');
    }
  }
  
  /// Check if user has consented to crash reporting
  static bool get hasUserConsent {
    return _prefs?.getBool('crash_reporting_consent') ?? false;
  }
  
  /// Request user consent for crash reporting
  static Future<void> requestUserConsent(bool consent) async {
    await _prefs?.setBool('crash_reporting_consent', consent);
    
    if (consent) {
      _logger.i('Crash reporting enabled by user');
      await _processPendingCrashes();
    } else {
      _logger.i('Crash reporting disabled by user');
      await _clearPendingCrashes();
    }
  }
  
  /// Report a critical error/crash
  static Future<void> reportCrash({
    required Object error,
    required StackTrace stackTrace,
    Map<String, dynamic>? context,
    String? userId,
    String? sessionId,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      final crashReport = CrashReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        error: error.toString(),
        stackTrace: stackTrace.toString(),
        timestamp: DateTime.now(),
        context: context ?? {},
        userId: userId,
        sessionId: sessionId,
        reported: false,
        appVersion: '1.0.0', // Would get from package info
        osVersion: defaultTargetPlatform.name,
        deviceModel: 'unknown', // Would get from device info
      );
      
      // Store crash report
      await _crashBox?.add(crashReport);
      _logger.w('Crash report stored: ${crashReport.id}');
      
      // If user has consented, report immediately
      if (hasUserConsent) {
        await _reportCrashImmediately(crashReport);
      }
    } catch (e) {
      _logger.e('Failed to report crash: $e');
    }
  }
  
  /// Get crash statistics
  static CrashStatistics getCrashStatistics() {
    if (_crashBox == null) return const CrashStatistics();
    
    final crashes = _crashBox!.values.toList();
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final lastWeek = now.subtract(const Duration(days: 7));
    final lastMonth = now.subtract(const Duration(days: 30));
    
    return CrashStatistics(
      totalCrashes: crashes.length,
      crashesLast24Hours: crashes.where((c) => c.timestamp.isAfter(last24Hours)).length,
      crashesLastWeek: crashes.where((c) => c.timestamp.isAfter(lastWeek)).length,
      crashesLastMonth: crashes.where((c) => c.timestamp.isAfter(lastMonth)).length,
      lastCrashTime: crashes.isNotEmpty 
          ? crashes.map((c) => c.timestamp).reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
    );
  }
  
  /// Clear old crash reports
  static Future<void> clearOldCrashes() async {
    if (_crashBox == null) return;
    
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    final keysToDelete = <dynamic>[];
    
    for (final entry in _crashBox!.toMap().entries) {
      if (entry.value.timestamp.isBefore(cutoff)) {
        keysToDelete.add(entry.key);
      }
    }
    
    await _crashBox!.deleteAll(keysToDelete);
    _logger.i('Cleared ${keysToDelete.length} old crash reports');
  }
  
  /// Setup crash handlers
  static void _setupCrashHandlers() {
    // Handle Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('RenderFlex overflowed') ||
          details.silent) {
        // Skip UI overflow errors and silent errors
        return;
      }
      
      reportCrash(
        error: details.exception,
        stackTrace: details.stack ?? StackTrace.current,
        context: {
          'library': details.library,
          'context': details.context?.toString(),
          'silent': details.silent,
        },
      );
      
      // Also handle through error handler
      ErrorHandler.handleFlutterError(details);
    };
    
    // Handle isolate errors
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await reportCrash(
        error: errorAndStacktrace.first,
        stackTrace: StackTrace.fromString(errorAndStacktrace.last.toString()),
        context: {'source': 'isolate'},
      );
    }).sendPort);
    
    // Handle platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      reportCrash(
        error: error,
        stackTrace: stack,
        context: {'source': 'platform'},
      );
      return true;
    };
  }
  
  /// Process pending crash reports
  static Future<void> _processPendingCrashes() async {
    if (_crashBox == null || !hasUserConsent) return;
    
    final pendingCrashes = _crashBox!.values
        .where((crash) => !crash.reported)
        .toList();
    
    for (final crash in pendingCrashes) {
      await _reportCrashImmediately(crash);
    }
  }
  
  /// Report crash immediately
  static Future<void> _reportCrashImmediately(CrashReport crash) async {
    try {
      // Create app error for reporting
      final appError = AppError(
        message: crash.error,
        type: ErrorType.unknown,
        severity: ErrorSeverity.critical,
        originalError: crash.error,
        stackTrace: StackTrace.fromString(crash.stackTrace),
        context: crash.context,
        timestamp: crash.timestamp,
        userId: crash.userId,
        sessionId: crash.sessionId,
        isRecoverable: false,
      );
      
      // Report through error reporting service
      final reportingService = ErrorReportingService();
      final success = await reportingService.reportCrash(appError, crash.context);
      
      if (success) {
        // Mark as reported
        final index = _crashBox!.values.toList().indexOf(crash);
        if (index >= 0) {
          final key = _crashBox!.keyAt(index);
          await _crashBox!.put(key, crash.copyWith(reported: true));
        }
        
        _logger.d('Crash report sent successfully: ${crash.id}');
      } else {
        _logger.w('Failed to send crash report: ${crash.id}');
      }
    } catch (e) {
      _logger.e('Error reporting crash: $e');
    }
  }
  
  /// Clear pending crashes when consent is revoked
  static Future<void> _clearPendingCrashes() async {
    if (_crashBox == null) return;
    
    final pendingCrashes = _crashBox!.values
        .where((crash) => !crash.reported)
        .toList();
    
    for (final crash in pendingCrashes) {
      final index = _crashBox!.values.toList().indexOf(crash);
      if (index >= 0) {
        final key = _crashBox!.keyAt(index);
        await _crashBox!.delete(key);
      }
    }
    
    _logger.i('Cleared ${pendingCrashes.length} pending crash reports');
  }
}

/// Crash report model
@HiveType(typeId: 53)
class CrashReport {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String error;
  
  @HiveField(2)
  final String stackTrace;
  
  @HiveField(3)
  final DateTime timestamp;
  
  @HiveField(4)
  final Map<String, dynamic> context;
  
  @HiveField(5)
  final String? userId;
  
  @HiveField(6)
  final String? sessionId;
  
  @HiveField(7)
  final bool reported;
  
  @HiveField(8)
  final String appVersion;
  
  @HiveField(9)
  final String osVersion;
  
  @HiveField(10)
  final String deviceModel;
  
  const CrashReport({
    required this.id,
    required this.error,
    required this.stackTrace,
    required this.timestamp,
    required this.context,
    this.userId,
    this.sessionId,
    required this.reported,
    required this.appVersion,
    required this.osVersion,
    required this.deviceModel,
  });
  
  CrashReport copyWith({
    String? id,
    String? error,
    String? stackTrace,
    DateTime? timestamp,
    Map<String, dynamic>? context,
    String? userId,
    String? sessionId,
    bool? reported,
    String? appVersion,
    String? osVersion,
    String? deviceModel,
  }) {
    return CrashReport(
      id: id ?? this.id,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      context: context ?? this.context,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      reported: reported ?? this.reported,
      appVersion: appVersion ?? this.appVersion,
      osVersion: osVersion ?? this.osVersion,
      deviceModel: deviceModel ?? this.deviceModel,
    );
  }
}

/// Crash statistics
class CrashStatistics {
  final int totalCrashes;
  final int crashesLast24Hours;
  final int crashesLastWeek;
  final int crashesLastMonth;
  final DateTime? lastCrashTime;
  
  const CrashStatistics({
    this.totalCrashes = 0,
    this.crashesLast24Hours = 0,
    this.crashesLastWeek = 0,
    this.crashesLastMonth = 0,
    this.lastCrashTime,
  });
  
  /// Check if app has frequent crashes (more than 5 in last 24 hours)
  bool get hasFrequentCrashes => crashesLast24Hours > 5;
  
  /// Check if app crashed recently (within last hour)
  bool get crashedRecently {
    if (lastCrashTime == null) return false;
    return DateTime.now().difference(lastCrashTime!).inHours < 1;
  }
  
  @override
  String toString() {
    return 'CrashStatistics(total: $totalCrashes, last24h: $crashesLast24Hours, '
           'lastWeek: $crashesLastWeek, lastMonth: $crashesLastMonth)';
  }
}