import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../error/app_error.dart';
import '../network/api_client.dart';

/// Service for reporting errors to remote analytics/monitoring services
class ErrorReportingService {
  static final Logger _logger = Logger();
  static SharedPreferences? _prefs;
  static ApiClient? _apiClient;
  
  /// Initialize error reporting service
  static Future<void> initialize([ApiClient? apiClient]) async {
    _prefs = await SharedPreferences.getInstance();
    _apiClient = apiClient;
    
    _logger.i('Error reporting service initialized');
  }
  
  /// Check if user has consented to error reporting
  static bool get hasUserConsent {
    return _prefs?.getBool('error_reporting_consent') ?? false;
  }
  
  /// Request user consent for error reporting
  static Future<void> requestUserConsent(bool consent) async {
    await _prefs?.setBool('error_reporting_consent', consent);
    await _prefs?.setBool('crash_reporting_consent', consent);
    _logger.i('Error reporting consent: $consent');
  }
  
  /// Report error to remote service
  Future<bool> reportError(AppError error) async {
    if (!hasUserConsent) {
      _logger.d('Error reporting disabled by user consent');
      return false;
    }
    
    try {
      final errorReport = await _buildErrorReport(error);
      
      // Send to multiple endpoints if needed
      final results = await Future.wait([
        _sendToAnalytics(errorReport),
        _sendToLoggingService(errorReport),
        if (error.severity == ErrorSeverity.critical) _sendToCrashReporting(errorReport),
      ]);
      
      final success = results.every((result) => result);
      
      if (success) {
        _logger.d('Error report sent successfully: ${error.type}');
      } else {
        _logger.w('Some error reporting endpoints failed');
      }
      
      return success;
    } catch (e) {
      _logger.e('Failed to report error: $e');
      return false;
    }
  }
  
  /// Report performance metrics
  Future<bool> reportPerformanceMetrics(Map<String, dynamic> metrics) async {
    if (!hasUserConsent) return false;
    
    try {
      final report = await _buildPerformanceReport(metrics);
      return await _sendToAnalytics(report);
    } catch (e) {
      _logger.e('Failed to report performance metrics: $e');
      return false;
    }
  }
  
  /// Report app crash
  Future<bool> reportCrash(AppError error, Map<String, dynamic>? additionalContext) async {
    if (!hasUserConsent) return false;
    
    try {
      final crashReport = await _buildCrashReport(error, additionalContext);
      
      // High priority reporting for crashes
      final results = await Future.wait([
        _sendToCrashReporting(crashReport),
        _sendToAnalytics(crashReport),
      ]);
      
      return results.every((result) => result);
    } catch (e) {
      _logger.e('Failed to report crash: $e');
      return false;
    }
  }
  
  /// Build comprehensive error report
  Future<Map<String, dynamic>> _buildErrorReport(AppError error) async {
    final deviceInfo = await _getDeviceInfo();
    final appInfo = await _getAppInfo();
    
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'error': error.toMap(),
      'device': deviceInfo,
      'app': appInfo,
      'build_info': _getBuildInfo(),
      'user_context': {
        'user_id': error.userId,
        'session_id': error.sessionId,
      },
      'technical_context': {
        'dart_version': Platform.version,
        'platform': Platform.operatingSystem,
        'platform_version': Platform.operatingSystemVersion,
      },
    };
  }
  
  /// Build performance report
  Future<Map<String, dynamic>> _buildPerformanceReport(Map<String, dynamic> metrics) async {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'performance',
      'metrics': metrics,
      'device': await _getDeviceInfo(),
      'app': await _getAppInfo(),
    };
  }
  
  /// Build crash report
  Future<Map<String, dynamic>> _buildCrashReport(AppError error, Map<String, dynamic>? additionalContext) async {
    final baseReport = await _buildErrorReport(error);
    
    return {
      ...baseReport,
      'type': 'crash',
      'severity': 'critical',
      'additional_context': additionalContext,
      'memory_info': _getMemoryInfo(),
    };
  }
  
  /// Send report to analytics service
  Future<bool> _sendToAnalytics(Map<String, dynamic> report) async {
    try {
      if (_apiClient == null) return false;
      
      final response = await _apiClient!.post(
        '/analytics/error-report',
        data: report,
        options: Options(
          sendTimeout: const Duration(milliseconds: 10000),
          receiveTimeout: const Duration(milliseconds: 10000),
        ),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      _logger.w('Failed to send to analytics service: $e');
      return false;
    }
  }
  
  /// Send report to logging service
  Future<bool> _sendToLoggingService(Map<String, dynamic> report) async {
    try {
      // This would integrate with services like Sentry, Rollbar, etc.
      // For now, we'll simulate the API call
      
      final jsonReport = jsonEncode(report);
      _logger.d('Would send to logging service: ${jsonReport.length} bytes');
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 100));
      
      return true;
    } catch (e) {
      _logger.w('Failed to send to logging service: $e');
      return false;
    }
  }
  
  /// Send report to crash reporting service
  Future<bool> _sendToCrashReporting(Map<String, dynamic> report) async {
    try {
      // This would integrate with services like Crashlytics, Bugsnag, etc.
      // For now, we'll simulate the API call
      
      if (report['error']['severity'] == 'critical') {
        _logger.w('Critical error reported to crash service: ${report['error']['message']}');
      }
      
      return true;
    } catch (e) {
      _logger.w('Failed to send to crash reporting service: $e');
      return false;
    }
  }
  
  /// Get device information
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final Map<String, dynamic> deviceData = {};
    
    try {
      deviceData.addAll({
        'platform': Platform.operatingSystem,
        'platform_version': Platform.operatingSystemVersion,
        'locale': Platform.localeName,
        'number_of_processors': Platform.numberOfProcessors,
        'path_separator': Platform.pathSeparator,
        'is_android': Platform.isAndroid,
        'is_ios': Platform.isIOS,
        'is_web': kIsWeb,
      });
    } catch (e) {
      _logger.w('Failed to get device info: $e');
    }
    
    return deviceData;
  }
  
  /// Get app information
  Future<Map<String, dynamic>> _getAppInfo() async {
    return {
      'app_name': 'Helpy Ninja',
      'package_name': 'com.example.helpy_ninja',
      'version': '1.0.0',
      'build_number': '1',
      'flutter_version': kIsWeb ? 'web' : Platform.version,
    };
  }
  
  /// Get build information
  Map<String, dynamic> _getBuildInfo() {
    return {
      'mode': kDebugMode ? 'debug' : kProfileMode ? 'profile' : 'release',
      'is_web': kIsWeb,
      'dart_version': Platform.version,
    };
  }
  
  /// Get memory information
  Map<String, dynamic> _getMemoryInfo() {
    try {
      // This would be more sophisticated in a real implementation
      return {
        'process_memory': ProcessInfo.currentRss,
        'max_rss': ProcessInfo.maxRss,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    } catch (e) {
      return {
        'error': 'Failed to get memory info: $e',
      };
    }
  }
}

