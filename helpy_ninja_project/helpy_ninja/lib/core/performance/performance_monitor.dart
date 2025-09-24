import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import 'memory_optimizer.dart';
import '../services/error_reporting_service.dart';

/// Performance monitoring service
class PerformanceMonitor {
  static final Logger _logger = Logger();
  static Timer? _monitoringTimer;
  static final List<PerformanceMetric> _metrics = [];
  static final Map<String, Stopwatch> _activeOperations = {};
  static bool _isInitialized = false;
  static late DateTime _appStartTime;
  
  /// Initialize performance monitoring
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    _appStartTime = DateTime.now();
    _isInitialized = true;
    
    // Start periodic monitoring
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _collectPerformanceMetrics(),
    );
    
    // Monitor app lifecycle
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver());
    
    _logger.i('Performance monitor initialized');
    
    // Record app start time
    recordMetric(PerformanceMetric(
      name: 'app_start',
      value: 0,
      timestamp: _appStartTime,
      type: MetricType.timing,
      tags: {'type': 'cold_start'},
    ));
  }
  
  /// Start timing an operation
  static void startTimer(String operationName) {
    _activeOperations[operationName] = Stopwatch()..start();
  }
  
  /// End timing an operation and record metric
  static void endTimer(String operationName, {Map<String, String>? tags}) {
    final stopwatch = _activeOperations.remove(operationName);
    if (stopwatch != null) {
      stopwatch.stop();
      
      recordMetric(PerformanceMetric(
        name: operationName,
        value: stopwatch.elapsedMilliseconds.toDouble(),
        timestamp: DateTime.now(),
        type: MetricType.timing,
        tags: tags ?? {},
      ));
      
      if (kDebugMode) {
        _logger.d('Operation "$operationName" took ${stopwatch.elapsedMilliseconds}ms');
      }
    }
  }
  
  /// Record a custom performance metric
  static void recordMetric(PerformanceMetric metric) {
    _metrics.add(metric);
    
    // Keep only recent metrics (last 1000)
    if (_metrics.length > 1000) {
      _metrics.removeRange(0, _metrics.length - 1000);
    }
    
    // Log performance issues
    if (metric.type == MetricType.timing && metric.value > 1000) {
      _logger.w('Slow operation detected: ${metric.name} took ${metric.value}ms');
    }
    
    // Report critical performance issues
    if (metric.value > 5000) {
      _reportPerformanceIssue(metric);
    }
  }
  
  /// Record frame rendering performance
  static void recordFrameMetric(Duration frameDuration) {
    recordMetric(PerformanceMetric(
      name: 'frame_render',
      value: frameDuration.inMicroseconds / 1000.0, // Convert to milliseconds
      timestamp: DateTime.now(),
      type: MetricType.timing,
      tags: {
        'target_fps': '60',
        'is_jank': (frameDuration.inMilliseconds > 16.67) ? 'true' : 'false',
      },
    ));
  }
  
  /// Record memory usage
  static void recordMemoryUsage() {
    try {
      // Get memory stats from optimizer
      final memoryStats = MemoryOptimizer.getMemoryStats();
      final cacheStats = ImageMemoryCache.stats;
      
      recordMetric(PerformanceMetric(
        name: 'memory_usage',
        value: cacheStats.memoryUsageMB,
        timestamp: DateTime.now(),
        type: MetricType.gauge,
        tags: {
          'type': 'image_cache',
          'items': cacheStats.itemCount.toString(),
        },
      ));
      
      recordMetric(PerformanceMetric(
        name: 'active_providers',
        value: memoryStats.activeProviders.toDouble(),
        timestamp: DateTime.now(),
        type: MetricType.gauge,
        tags: {'type': 'riverpod'},
      ));
    } catch (e) {
      _logger.w('Failed to record memory usage: $e');
    }
  }
  
  /// Record network request performance
  static void recordNetworkMetric({
    required String endpoint,
    required Duration duration,
    required int statusCode,
    int? responseSize,
  }) {
    recordMetric(PerformanceMetric(
      name: 'network_request',
      value: duration.inMilliseconds.toDouble(),
      timestamp: DateTime.now(),
      type: MetricType.timing,
      tags: {
        'endpoint': endpoint,
        'status_code': statusCode.toString(),
        'success': (statusCode >= 200 && statusCode < 300) ? 'true' : 'false',
        if (responseSize != null) 'response_size': responseSize.toString(),
      },
    ));
  }
  
  /// Record database operation performance
  static void recordDatabaseMetric({
    required String operation,
    required Duration duration,
    required String table,
    int? recordCount,
  }) {
    recordMetric(PerformanceMetric(
      name: 'database_operation',
      value: duration.inMilliseconds.toDouble(),
      timestamp: DateTime.now(),
      type: MetricType.timing,
      tags: {
        'operation': operation,
        'table': table,
        if (recordCount != null) 'record_count': recordCount.toString(),
      },
    ));
  }
  
  /// Get performance summary
  static PerformanceSummary getSummary() {
    final now = DateTime.now();
    final lastHour = now.subtract(const Duration(hours: 1));
    
    final recentMetrics = _metrics.where((m) => m.timestamp.isAfter(lastHour)).toList();
    
    // Calculate averages for different metric types
    final timingMetrics = recentMetrics.where((m) => m.type == MetricType.timing);
    final frameMetrics = timingMetrics.where((m) => m.name == 'frame_render');
    final networkMetrics = timingMetrics.where((m) => m.name == 'network_request');
    
    return PerformanceSummary(
      totalMetrics: _metrics.length,
      recentMetrics: recentMetrics.length,
      averageFrameTime: frameMetrics.isEmpty 
          ? 0.0 
          : frameMetrics.map((m) => m.value).reduce((a, b) => a + b) / frameMetrics.length,
      averageNetworkTime: networkMetrics.isEmpty
          ? 0.0
          : networkMetrics.map((m) => m.value).reduce((a, b) => a + b) / networkMetrics.length,
      jankFrames: frameMetrics.where((m) => m.tags['is_jank'] == 'true').length,
      appUptime: now.difference(_appStartTime),
      memoryStats: ImageMemoryCache.stats,
    );
  }
  
  /// Get metrics by type
  static List<PerformanceMetric> getMetricsByType(MetricType type) {
    return _metrics.where((m) => m.type == type).toList();
  }
  
  /// Get metrics by name
  static List<PerformanceMetric> getMetricsByName(String name) {
    return _metrics.where((m) => m.name == name).toList();
  }
  
  /// Clear old metrics
  static void clearOldMetrics() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    _metrics.removeWhere((m) => m.timestamp.isBefore(cutoff));
    _logger.d('Cleared old performance metrics');
  }
  
  /// Export performance data
  static Map<String, dynamic> exportData() {
    return {
      'summary': getSummary().toMap(),
      'metrics': _metrics.map((m) => m.toMap()).toList(),
      'app_start_time': _appStartTime.toIso8601String(),
      'export_time': DateTime.now().toIso8601String(),
    };
  }
  
  /// Collect system performance metrics
  static Future<void> _collectPerformanceMetrics() async {
    try {
      // Record memory usage
      recordMemoryUsage();
      
      // Record system metrics if available
      if (!kIsWeb) {
        _recordSystemMetrics();
      }
      
      // Check for performance issues
      _checkPerformanceHealth();
    } catch (e) {
      _logger.w('Failed to collect performance metrics: $e');
    }
  }
  
  /// Record system-level metrics
  static void _recordSystemMetrics() {
    try {
      // This would use platform-specific APIs in a real implementation
      recordMetric(PerformanceMetric(
        name: 'system_memory',
        value: 512.0, // Mock value
        timestamp: DateTime.now(),
        type: MetricType.gauge,
        tags: {'unit': 'mb'},
      ));
    } catch (e) {
      _logger.w('Failed to record system metrics: $e');
    }
  }
  
  /// Check overall performance health
  static void _checkPerformanceHealth() {
    final summary = getSummary();
    
    // Check for excessive jank
    if (summary.jankFrames > 10) {
      _logger.w('High jank detected: ${summary.jankFrames} frames');
    }
    
    // Check for slow network requests
    if (summary.averageNetworkTime > 3000) {
      _logger.w('Slow network detected: ${summary.averageNetworkTime.toStringAsFixed(1)}ms average');
    }
    
    // Check memory usage
    if (summary.memoryStats.usagePercentage > 80) {
      _logger.w('High memory usage: ${summary.memoryStats.usagePercentage.toStringAsFixed(1)}%');
    }
  }
  
  /// Report critical performance issues
  static void _reportPerformanceIssue(PerformanceMetric metric) {
    if (!ErrorReportingService.hasUserConsent) return;
    
    try {
      // This would send to analytics service
      _logger.w('Critical performance issue: ${metric.name} = ${metric.value}');
      
      // In a real implementation, this would use the error reporting service
      // ErrorReportingService.reportPerformanceIssue(metric.toMap());
    } catch (e) {
      _logger.e('Failed to report performance issue: $e');
    }
  }
  
  /// Dispose resources
  static void dispose() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _activeOperations.clear();
    _metrics.clear();
    _isInitialized = false;
    
    _logger.i('Performance monitor disposed');
  }
}

/// Performance metric data class
class PerformanceMetric {
  final String name;
  final double value;
  final DateTime timestamp;
  final MetricType type;
  final Map<String, String> tags;
  
  const PerformanceMetric({
    required this.name,
    required this.value,
    required this.timestamp,
    required this.type,
    this.tags = const {},
  });
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'tags': tags,
    };
  }
  
  @override
  String toString() {
    return 'PerformanceMetric(name: $name, value: $value, type: $type)';
  }
}

/// Types of performance metrics
enum MetricType {
  timing,  // Duration measurements
  gauge,   // Point-in-time values
  counter, // Cumulative counts
}

/// Performance summary
class PerformanceSummary {
  final int totalMetrics;
  final int recentMetrics;
  final double averageFrameTime;
  final double averageNetworkTime;
  final int jankFrames;
  final Duration appUptime;
  final MemoryCacheStats memoryStats;
  
  const PerformanceSummary({
    required this.totalMetrics,
    required this.recentMetrics,
    required this.averageFrameTime,
    required this.averageNetworkTime,
    required this.jankFrames,
    required this.appUptime,
    required this.memoryStats,
  });
  
  /// Get current FPS estimate
  double get currentFPS {
    if (averageFrameTime == 0) return 60.0;
    return 1000.0 / averageFrameTime;
  }
  
  /// Check if performance is healthy
  bool get isHealthy {
    return currentFPS > 55 && 
           averageNetworkTime < 2000 && 
           memoryStats.usagePercentage < 70 &&
           jankFrames < 5;
  }
  
  Map<String, dynamic> toMap() {
    return {
      'total_metrics': totalMetrics,
      'recent_metrics': recentMetrics,
      'average_frame_time': averageFrameTime,
      'current_fps': currentFPS,
      'average_network_time': averageNetworkTime,
      'jank_frames': jankFrames,
      'app_uptime_seconds': appUptime.inSeconds,
      'memory_stats': memoryStats.toString(),
      'is_healthy': isHealthy,
    };
  }
  
  @override
  String toString() {
    return 'PerformanceSummary(fps: ${currentFPS.toStringAsFixed(1)}, '
           'network: ${averageNetworkTime.toStringAsFixed(0)}ms, '
           'memory: ${memoryStats.usagePercentage.toStringAsFixed(1)}%, '
           'jank: $jankFrames, healthy: $isHealthy)';
  }
}

/// App lifecycle observer for performance monitoring
class _AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    PerformanceMonitor.recordMetric(PerformanceMetric(
      name: 'app_lifecycle',
      value: 1.0,
      timestamp: DateTime.now(),
      type: MetricType.counter,
      tags: {'state': state.name},
    ));
  }
}

/// Extension for easy performance timing
extension PerformanceTimingExtension<T> on Future<T> {
  /// Time this future and record the performance metric
  Future<T> timed(String operationName, {Map<String, String>? tags}) async {
    PerformanceMonitor.startTimer(operationName);
    try {
      final result = await this;
      PerformanceMonitor.endTimer(operationName, tags: tags);
      return result;
    } catch (e) {
      PerformanceMonitor.endTimer(operationName, tags: {
        ...?tags,
        'error': 'true',
        'error_type': e.runtimeType.toString(),
      });
      rethrow;
    }
  }
}

/// Widget for displaying performance metrics in debug mode
class PerformanceOverlay extends StatefulWidget {
  final Widget child;
  final bool showOverlay;
  
  const PerformanceOverlay({
    super.key,
    required this.child,
    this.showOverlay = kDebugMode,
  });
  
  @override
  State<PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<PerformanceOverlay> {
  Timer? _updateTimer;
  PerformanceSummary? _summary;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.showOverlay) {
      _updateTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _updateMetrics(),
      );
    }
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
  
  void _updateMetrics() {
    if (mounted) {
      setState(() {
        _summary = PerformanceMonitor.getSummary();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.showOverlay || _summary == null) {
      return widget.child;
    }
    
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FPS: ${_summary!.currentFPS.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'Memory: ${_summary!.memoryStats.memoryUsageMB.toStringAsFixed(1)}MB',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'Jank: ${_summary!.jankFrames}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}