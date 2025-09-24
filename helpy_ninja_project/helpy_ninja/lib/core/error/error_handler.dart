import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:hive/hive.dart';

import 'app_error.dart';

/// Global error handler for the application
class ErrorHandler {
  static final Logger _logger = Logger();
  static Box<ErrorLog>? _errorBox;
  
  /// Initialize the error handler
  static Future<void> initialize() async {
    try {
      _errorBox = await Hive.openBox<ErrorLog>('error_logs');
      
      // Set up global error handlers
      FlutterError.onError = (FlutterErrorDetails details) {
        handleFlutterError(details);
      };
      
      // Handle platform errors
      PlatformDispatcher.instance.onError = (error, stack) {
        handlePlatformError(error, stack);
        return true;
      };
      
      _logger.i('Error handler initialized');
    } catch (e) {
      _logger.e('Failed to initialize error handler: $e');
    }
  }
  
  /// Handle Flutter framework errors
  static void handleFlutterError(FlutterErrorDetails details) {
    final appError = AppError.fromFlutterError(details);
    _logError(appError);
    
    // In debug mode, also print to console
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }
  
  /// Handle platform/dart errors
  static void handlePlatformError(Object error, StackTrace stack) {
    final appError = AppError.fromException(error);
    _logError(appError);
    
    if (kDebugMode) {
      _logger.e('Platform error: $error');
    }
  }
  
  /// Handle application errors
  static Future<void> handleAppError(AppError error) async {
    _logError(error);
    
    // Store for offline reporting if needed
    if (!await _isNetworkAvailable()) {
      await _storeErrorForLaterReporting(error);
    }
  }
  
  /// Handle and recover from specific error types
  static Future<ErrorRecoveryResult> handleWithRecovery(
    Object error, 
    StackTrace stack, {
    ErrorRecoveryStrategy? strategy,
  }) async {
    final appError = AppError.fromException(error);
    await handleAppError(appError);
    
    // Attempt recovery based on error type
    final recoveryStrategy = strategy ?? _getRecoveryStrategy(appError);
    
    try {
      final result = await _attemptRecovery(appError, recoveryStrategy);
      
      if (result.success) {
        _logger.i('Successfully recovered from error: ${appError.type}');
      } else {
        _logger.w('Failed to recover from error: ${appError.type}');
      }
      
      return result;
    } catch (recoveryError) {
      _logger.e('Recovery attempt failed', error: recoveryError);
      return ErrorRecoveryResult(
        success: false,
        message: 'Recovery failed: ${recoveryError.toString()}',
      );
    }
  }
  
  /// Get user-friendly error message
  static String getUserFriendlyMessage(AppError error) {
    switch (error.type) {
      case ErrorType.network:
        return 'Connection problem. Please check your internet and try again.';
      case ErrorType.authentication:
        return 'Authentication failed. Please sign in again.';
      case ErrorType.validation:
        return 'Invalid input. Please check your data and try again.';
      case ErrorType.storage:
        return 'Storage error. Please free up space and try again.';
      case ErrorType.permission:
        return 'Permission denied. Please check app permissions.';
      case ErrorType.timeout:
        return 'Request timed out. Please try again.';
      case ErrorType.server:
        return 'Server error. Please try again later.';
      case ErrorType.parsing:
        return 'Data format error. Please try again.';
      case ErrorType.unknown:
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
  
  /// Get error logs for debugging
  static List<ErrorLog> getErrorLogs({int? limit}) {
    if (_errorBox == null) return [];
    
    final logs = _errorBox!.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    if (limit != null && logs.length > limit) {
      return logs.take(limit).toList();
    }
    
    return logs;
  }
  
  /// Clear old error logs
  static Future<void> clearOldLogs() async {
    if (_errorBox == null) return;
    
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final keysToDelete = <dynamic>[];
    
    for (final entry in _errorBox!.toMap().entries) {
      if (entry.value.timestamp.isBefore(cutoff)) {
        keysToDelete.add(entry.key);
      }
    }
    
    await _errorBox!.deleteAll(keysToDelete);
    _logger.i('Cleared ${keysToDelete.length} old error logs');
  }
  
  /// Report stored errors when network becomes available
  static Future<void> reportStoredErrors() async {
    if (_errorBox == null || !await _isNetworkAvailable()) return;
    
    final pendingErrors = _errorBox!.values
        .where((log) => !log.reported)
        .toList();
    
    for (final errorLog in pendingErrors) {
      try {
        // Mark as reported
        final index = _errorBox!.values.toList().indexOf(errorLog);
        if (index >= 0) {
          final key = _errorBox!.keyAt(index);
          await _errorBox!.put(key, errorLog.copyWith(reported: true));
        }
      } catch (e) {
        _logger.w('Failed to mark stored error as reported: $e');
      }
    }
    
    _logger.i('Marked ${pendingErrors.length} stored errors as reported');
  }
  
  // Private methods
  
  static void _logError(AppError error) {
    _logger.e(
      'App Error [${error.type.name}]: ${error.message}',
    );
  }
  
  static Future<void> _storeErrorForLaterReporting(AppError error) async {
    if (_errorBox == null) return;
    
    try {
      final errorLog = ErrorLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: error.type,
        message: error.message,
        stackTrace: error.stackTrace.toString(),
        timestamp: DateTime.now(),
        context: error.context,
        reported: false,
      );
      
      await _errorBox!.add(errorLog);
      _logger.d('Stored error for later reporting: ${error.type}');
    } catch (e) {
      _logger.e('Failed to store error log: $e');
    }
  }
  
  static ErrorRecoveryStrategy _getRecoveryStrategy(AppError error) {
    switch (error.type) {
      case ErrorType.network:
        return ErrorRecoveryStrategy.retry;
      case ErrorType.authentication:
        return ErrorRecoveryStrategy.refreshAuth;
      case ErrorType.storage:
        return ErrorRecoveryStrategy.clearCache;
      case ErrorType.timeout:
        return ErrorRecoveryStrategy.retry;
      default:
        return ErrorRecoveryStrategy.none;
    }
  }
  
  static Future<ErrorRecoveryResult> _attemptRecovery(
    AppError error,
    ErrorRecoveryStrategy strategy,
  ) async {
    switch (strategy) {
      case ErrorRecoveryStrategy.retry:
        await Future.delayed(const Duration(seconds: 1));
        return ErrorRecoveryResult(
          success: true,
          message: 'Ready to retry',
        );
      
      case ErrorRecoveryStrategy.refreshAuth:
        // Attempt to refresh authentication
        return ErrorRecoveryResult(
          success: false,
          message: 'Please sign in again',
          requiresUserAction: true,
        );
      
      case ErrorRecoveryStrategy.clearCache:
        try {
          // Clear relevant cache
          await Hive.deleteBoxFromDisk('cache');
          return ErrorRecoveryResult(
            success: true,
            message: 'Cache cleared successfully',
          );
        } catch (e) {
          return ErrorRecoveryResult(
            success: false,
            message: 'Failed to clear cache',
          );
        }
      
      case ErrorRecoveryStrategy.none:
      default:
        return ErrorRecoveryResult(
          success: false,
          message: 'No recovery available',
        );
    }
  }
  
  static Future<bool> _isNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// Error recovery strategies
enum ErrorRecoveryStrategy {
  none,
  retry,
  refreshAuth,
  clearCache,
  restart,
}

/// Result of error recovery attempt
class ErrorRecoveryResult {
  final bool success;
  final String message;
  final bool requiresUserAction;
  final Map<String, dynamic>? data;
  
  const ErrorRecoveryResult({
    required this.success,
    required this.message,
    this.requiresUserAction = false,
    this.data,
  });
}

/// Stored error log
@HiveType(typeId: 50)
class ErrorLog {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final ErrorType type;
  
  @HiveField(2)
  final String message;
  
  @HiveField(3)
  final String stackTrace;
  
  @HiveField(4)
  final DateTime timestamp;
  
  @HiveField(5)
  final Map<String, dynamic>? context;
  
  @HiveField(6)
  final bool reported;
  
  const ErrorLog({
    required this.id,
    required this.type,
    required this.message,
    required this.stackTrace,
    required this.timestamp,
    this.context,
    this.reported = false,
  });
  
  ErrorLog copyWith({
    String? id,
    ErrorType? type,
    String? message,
    String? stackTrace,
    DateTime? timestamp,
    Map<String, dynamic>? context,
    bool? reported,
  }) {
    return ErrorLog(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      context: context ?? this.context,
      reported: reported ?? this.reported,
    );
  }
}