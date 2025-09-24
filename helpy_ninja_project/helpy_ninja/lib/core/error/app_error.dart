import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'error_handler.dart';

/// Application error types
@HiveType(typeId: 51)
enum ErrorType {
  @HiveField(0)
  unknown,
  @HiveField(1)
  network,
  @HiveField(2)
  authentication,
  @HiveField(3)
  validation,
  @HiveField(4)
  storage,
  @HiveField(5)
  permission,
  @HiveField(6)
  timeout,
  @HiveField(7)
  server,
  @HiveField(8)
  parsing,
  @HiveField(9)
  ui,
  @HiveField(10)
  business,
}

/// Severity levels for errors
@HiveType(typeId: 52)
enum ErrorSeverity {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
  @HiveField(3)
  critical,
}

/// Comprehensive application error class
class AppError implements Exception {
  final String message;
  final ErrorType type;
  final ErrorSeverity severity;
  final Object? originalError;
  final StackTrace stackTrace;
  final Map<String, dynamic>? context;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;
  final bool isRecoverable;
  
  AppError({
    required this.message,
    required this.type,
    this.severity = ErrorSeverity.medium,
    this.originalError,
    required this.stackTrace,
    this.context,
    DateTime? timestamp,
    this.userId,
    this.sessionId,
    this.isRecoverable = true,
  }) : timestamp = timestamp ?? DateTime.now();
  
  /// Create error from Flutter framework error
  factory AppError.fromFlutterError(FlutterErrorDetails details) {
    return AppError(
      message: details.exception.toString(),
      type: _determineErrorType(details.exception),
      severity: details.silent ? ErrorSeverity.low : ErrorSeverity.high,
      originalError: details.exception,
      stackTrace: details.stack ?? StackTrace.current,
      context: {
        'library': details.library,
        'context': details.context?.toString(),
        'informationCollector': details.informationCollector?.toString(),
      },
      isRecoverable: !details.silent,
    );
  }
  
  /// Create error from generic exception
  factory AppError.fromException(
    Object exception, [
    StackTrace? stack,
    Map<String, dynamic>? context,
  ]) {
    return AppError(
      message: exception.toString(),
      type: _determineErrorType(exception),
      severity: _determineSeverity(exception),
      originalError: exception,
      stackTrace: stack ?? StackTrace.current,
      context: context,
    );
  }
  
  /// Create error from stored error log
  factory AppError.fromErrorLog(ErrorLog errorLog) {
    return AppError(
      message: errorLog.message,
      type: errorLog.type,
      severity: ErrorSeverity.medium,
      originalError: null,
      stackTrace: StackTrace.fromString(errorLog.stackTrace),
      context: errorLog.context,
      timestamp: errorLog.timestamp,
    );
  }
  
  /// Create network error
  factory AppError.network(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      message: message,
      type: ErrorType.network,
      severity: ErrorSeverity.medium,
      originalError: originalError,
      stackTrace: stackTrace ?? StackTrace.current,
      context: context,
      isRecoverable: true,
    );
  }
  
  /// Create authentication error
  factory AppError.authentication(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      message: message,
      type: ErrorType.authentication,
      severity: ErrorSeverity.high,
      originalError: originalError,
      stackTrace: stackTrace ?? StackTrace.current,
      context: context,
      isRecoverable: true,
    );
  }
  
  /// Create validation error
  factory AppError.validation(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      message: message,
      type: ErrorType.validation,
      severity: ErrorSeverity.low,
      originalError: originalError,
      stackTrace: stackTrace ?? StackTrace.current,
      context: context,
      isRecoverable: true,
    );
  }
  
  /// Create storage error
  factory AppError.storage(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      message: message,
      type: ErrorType.storage,
      severity: ErrorSeverity.high,
      originalError: originalError,
      stackTrace: stackTrace ?? StackTrace.current,
      context: context,
      isRecoverable: true,
    );
  }
  
  /// Create business logic error
  factory AppError.business(
    String message, {
    ErrorSeverity severity = ErrorSeverity.medium,
    Object? originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      message: message,
      type: ErrorType.business,
      severity: severity,
      originalError: originalError,
      stackTrace: stackTrace ?? StackTrace.current,
      context: context,
      isRecoverable: true,
    );
  }
  
  /// Create unknown error
  factory AppError.unknown(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      message: message,
      type: ErrorType.unknown,
      severity: ErrorSeverity.medium,
      originalError: originalError,
      stackTrace: stackTrace ?? StackTrace.current,
      context: context,
      isRecoverable: false,
    );
  }
  
  /// Create copy with additional context
  AppError copyWith({
    String? message,
    ErrorType? type,
    ErrorSeverity? severity,
    Object? originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    DateTime? timestamp,
    String? userId,
    String? sessionId,
    bool? isRecoverable,
  }) {
    return AppError(
      message: message ?? this.message,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      originalError: originalError ?? this.originalError,
      stackTrace: stackTrace ?? this.stackTrace,
      context: context ?? this.context,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      isRecoverable: isRecoverable ?? this.isRecoverable,
    );
  }
  
  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'type': type.name,
      'severity': severity.name,
      'originalError': originalError?.toString(),
      'stackTrace': stackTrace.toString(),
      'context': context,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'sessionId': sessionId,
      'isRecoverable': isRecoverable,
    };
  }
  
  /// Create from map
  factory AppError.fromMap(Map<String, dynamic> map) {
    return AppError(
      message: map['message'] ?? '',
      type: ErrorType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ErrorType.unknown,
      ),
      severity: ErrorSeverity.values.firstWhere(
        (e) => e.name == map['severity'],
        orElse: () => ErrorSeverity.medium,
      ),
      originalError: map['originalError'],
      stackTrace: map['stackTrace'] != null
          ? StackTrace.fromString(map['stackTrace'])
          : StackTrace.current,
      context: map['context']?.cast<String, dynamic>(),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      userId: map['userId'],
      sessionId: map['sessionId'],
      isRecoverable: map['isRecoverable'] ?? true,
    );
  }
  
  @override
  String toString() {
    return 'AppError{type: $type, severity: $severity, message: $message}';
  }
  
  // Private helper methods
  
  static ErrorType _determineErrorType(Object exception) {
    final exceptionString = exception.toString().toLowerCase();
    
    if (exceptionString.contains('socket') ||
        exceptionString.contains('network') ||
        exceptionString.contains('connection') ||
        exceptionString.contains('timeout')) {
      return ErrorType.network;
    }
    
    if (exceptionString.contains('auth') ||
        exceptionString.contains('token') ||
        exceptionString.contains('unauthorized') ||
        exceptionString.contains('forbidden')) {
      return ErrorType.authentication;
    }
    
    if (exceptionString.contains('storage') ||
        exceptionString.contains('hive') ||
        exceptionString.contains('database') ||
        exceptionString.contains('file')) {
      return ErrorType.storage;
    }
    
    if (exceptionString.contains('permission') ||
        exceptionString.contains('denied')) {
      return ErrorType.permission;
    }
    
    if (exceptionString.contains('format') ||
        exceptionString.contains('parse') ||
        exceptionString.contains('json') ||
        exceptionString.contains('decode')) {
      return ErrorType.parsing;
    }
    
    if (exceptionString.contains('server') ||
        exceptionString.contains('http') ||
        exceptionString.contains('response')) {
      return ErrorType.server;
    }
    
    if (exceptionString.contains('validation') ||
        exceptionString.contains('invalid') ||
        exceptionString.contains('required')) {
      return ErrorType.validation;
    }
    
    return ErrorType.unknown;
  }
  
  static ErrorSeverity _determineSeverity(Object exception) {
    final exceptionString = exception.toString().toLowerCase();
    
    if (exceptionString.contains('critical') ||
        exceptionString.contains('fatal') ||
        exceptionString.contains('crash')) {
      return ErrorSeverity.critical;
    }
    
    if (exceptionString.contains('error') ||
        exceptionString.contains('failed') ||
        exceptionString.contains('exception')) {
      return ErrorSeverity.high;
    }
    
    if (exceptionString.contains('warning') ||
        exceptionString.contains('deprecated')) {
      return ErrorSeverity.medium;
    }
    
    return ErrorSeverity.low;
  }
}