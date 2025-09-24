import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:hive/hive.dart';

import '../error/app_error.dart';
import '../error/error_handler.dart';
import 'error_reporting_service.dart';
import 'image_cache_service.dart';

/// Background processing service for handling tasks without blocking UI
class BackgroundProcessor {
  static final Logger _logger = Logger();
  static final Map<String, BackgroundTask> _activeTasks = {};
  static final Map<String, Timer> _scheduledTasks = {};
  static Box<BackgroundTaskData>? _taskBox;
  static bool _isInitialized = false;
  
  /// Initialize background processor
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _taskBox = await Hive.openBox<BackgroundTaskData>('background_tasks');
      _isInitialized = true;
      
      // Resume any pending tasks
      await _resumePendingTasks();
      
      // Schedule periodic maintenance
      _schedulePeriodicMaintenance();
      
      _logger.i('Background processor initialized');
    } catch (e) {
      _logger.e('Failed to initialize background processor: $e');
    }
  }
  
  /// Schedule a background task
  static String scheduleTask({
    required String name,
    required BackgroundTaskFunction function,
    Map<String, dynamic>? data,
    Duration delay = Duration.zero,
    TaskPriority priority = TaskPriority.normal,
    bool persistent = false,
  }) {
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final task = BackgroundTask(
      id: taskId,
      name: name,
      function: function,
      data: data ?? {},
      priority: priority,
      persistent: persistent,
      createdAt: DateTime.now(),
      status: TaskStatus.scheduled,
    );
    
    _activeTasks[taskId] = task;
    
    // Store persistent tasks
    if (persistent) {
      _storeTask(task);
    }
    
    // Schedule execution
    if (delay == Duration.zero) {
      _executeTask(task);
    } else {
      _scheduledTasks[taskId] = Timer(delay, () {
        _scheduledTasks.remove(taskId);
        _executeTask(task);
      });
    }
    
    _logger.d('Scheduled background task: $name (ID: $taskId)');
    return taskId;
  }
  
  /// Schedule a recurring task
  static String scheduleRecurringTask({
    required String name,
    required BackgroundTaskFunction function,
    required Duration interval,
    Map<String, dynamic>? data,
    TaskPriority priority = TaskPriority.normal,
    int? maxExecutions,
  }) {
    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    int executionCount = 0;
    
    void scheduleNext() {
      if (maxExecutions != null && executionCount >= maxExecutions) {
        _logger.d('Recurring task completed max executions: $name');
        return;
      }
      
      _scheduledTasks[taskId] = Timer(interval, () {
        executionCount++;
        
        final task = BackgroundTask(
          id: '${taskId}_$executionCount',
          name: '$name (execution $executionCount)',
          function: function,
          data: data ?? {},
          priority: priority,
          persistent: false,
          createdAt: DateTime.now(),
          status: TaskStatus.scheduled,
        );
        
        _executeTask(task).then((_) => scheduleNext());
      });
    }
    
    scheduleNext();
    
    _logger.d('Scheduled recurring task: $name (interval: ${interval.inMinutes}min)');
    return taskId;
  }
  
  /// Cancel a scheduled task
  static bool cancelTask(String taskId) {
    // Cancel timer if exists
    final timer = _scheduledTasks.remove(taskId);
    timer?.cancel();
    
    // Remove from active tasks
    final task = _activeTasks.remove(taskId);
    if (task != null) {
      task.status = TaskStatus.cancelled;
      
      // Remove from persistent storage
      if (task.persistent) {
        _removeStoredTask(taskId);
      }
      
      _logger.d('Cancelled background task: ${task.name}');
      return true;
    }
    
    return false;
  }
  
  /// Get task status
  static TaskStatus? getTaskStatus(String taskId) {
    return _activeTasks[taskId]?.status;
  }
  
  /// Get all active tasks
  static List<BackgroundTask> getActiveTasks() {
    return _activeTasks.values.toList();
  }
  
  /// Get task statistics
  static BackgroundProcessorStats getStats() {
    final tasks = _activeTasks.values.toList();
    
    return BackgroundProcessorStats(
      totalTasks: tasks.length,
      runningTasks: tasks.where((t) => t.status == TaskStatus.running).length,
      scheduledTasks: tasks.where((t) => t.status == TaskStatus.scheduled).length,
      completedTasks: tasks.where((t) => t.status == TaskStatus.completed).length,
      failedTasks: tasks.where((t) => t.status == TaskStatus.failed).length,
      cancelledTasks: tasks.where((t) => t.status == TaskStatus.cancelled).length,
    );
  }
  
  /// Execute a background task
  static Future<void> _executeTask(BackgroundTask task) async {
    if (!_activeTasks.containsKey(task.id)) return;
    
    task.status = TaskStatus.running;
    task.startedAt = DateTime.now();
    
    try {
      _logger.d('Executing background task: ${task.name}');
      
      // Execute in isolate for compute-heavy tasks
      if (task.priority == TaskPriority.high) {
        await _executeInIsolate(task);
      } else {
        await task.function(task.data);
      }
      
      task.status = TaskStatus.completed;
      task.completedAt = DateTime.now();
      
      _logger.d('Completed background task: ${task.name} in ${task.completedAt!.difference(task.startedAt!).inMilliseconds}ms');
    } catch (e, stackTrace) {
      task.status = TaskStatus.failed;
      task.error = e.toString();
      task.completedAt = DateTime.now();
      
      _logger.e('Background task failed: ${task.name} - $e');
      
      // Report error
      await ErrorHandler.handleAppError(
        AppError.fromException(e, stackTrace, {
          'task_id': task.id,
          'task_name': task.name,
          'task_data': task.data.toString(),
        }),
      );
    } finally {
      // Clean up completed/failed tasks after delay
      Timer(const Duration(minutes: 5), () {
        if (task.status == TaskStatus.completed || task.status == TaskStatus.failed) {
          _activeTasks.remove(task.id);
          if (task.persistent) {
            _removeStoredTask(task.id);
          }
        }
      });
    }
  }
  
  /// Execute task in isolate for heavy computation
  static Future<void> _executeInIsolate(BackgroundTask task) async {
    if (kIsWeb) {
      // Web doesn't support isolates, run normally
      await task.function(task.data);
      return;
    }
    
    try {
      final receivePort = ReceivePort();
      
      await Isolate.spawn(
        _isolateEntryPoint,
        [receivePort.sendPort, task.function, task.data],
      );
      
      final result = await receivePort.first;
      
      if (result is Exception) {
        throw result;
      }
    } catch (e) {
      _logger.w('Isolate execution failed, running in main isolate: $e');
      await task.function(task.data);
    }
  }
  
  /// Isolate entry point
  static void _isolateEntryPoint(List<dynamic> args) async {
    final SendPort sendPort = args[0];
    final BackgroundTaskFunction function = args[1];
    final Map<String, dynamic> data = args[2];
    
    try {
      await function(data);
      sendPort.send('completed');
    } catch (e) {
      sendPort.send(e);
    }
  }
  
  /// Store persistent task
  static void _storeTask(BackgroundTask task) {
    try {
      final taskData = BackgroundTaskData(
        id: task.id,
        name: task.name,
        data: task.data,
        priority: task.priority,
        createdAt: task.createdAt,
        status: task.status,
      );
      
      _taskBox?.put(task.id, taskData);
    } catch (e) {
      _logger.w('Failed to store persistent task: $e');
    }
  }
  
  /// Remove stored task
  static void _removeStoredTask(String taskId) {
    try {
      _taskBox?.delete(taskId);
    } catch (e) {
      _logger.w('Failed to remove stored task: $e');
    }
  }
  
  /// Resume pending tasks from storage
  static Future<void> _resumePendingTasks() async {
    if (_taskBox == null) return;
    
    try {
      final storedTasks = _taskBox!.values.toList();
      
      for (final taskData in storedTasks) {
        // Only resume tasks that were running or scheduled
        if (taskData.status == TaskStatus.running || taskData.status == TaskStatus.scheduled) {
          // Note: We can't restore the function reference, so we skip these
          // In a real implementation, you'd register function factories
          _logger.d('Skipping resume of task: ${taskData.name} (function not restorable)');
          await _taskBox!.delete(taskData.id);
        }
      }
    } catch (e) {
      _logger.w('Failed to resume pending tasks: $e');
    }
  }
  
  /// Schedule periodic maintenance tasks
  static void _schedulePeriodicMaintenance() {
    // Clean up old image cache
    scheduleRecurringTask(
      name: 'image_cache_cleanup',
      function: (_) async {
        await ImageCacheService.clearCache();
      },
      interval: const Duration(hours: 6),
    );
    
    // Report pending errors
    scheduleRecurringTask(
      name: 'error_reporting',
      function: (_) async {
        await ErrorHandler.reportStoredErrors();
      },
      interval: const Duration(minutes: 30),
    );
    
    // Clean up old performance metrics
    scheduleRecurringTask(
      name: 'metrics_cleanup',
      function: (_) async {
        // This would clean up old metrics
        _logger.d('Cleaning up old metrics');
      },
      interval: const Duration(hours: 12),
    );
    
    _logger.d('Scheduled periodic maintenance tasks');
  }
  
  /// Dispose resources
  static void dispose() {
    // Cancel all scheduled tasks
    for (final timer in _scheduledTasks.values) {
      timer.cancel();
    }
    _scheduledTasks.clear();
    
    // Update active tasks status
    for (final task in _activeTasks.values) {
      if (task.status == TaskStatus.running || task.status == TaskStatus.scheduled) {
        task.status = TaskStatus.cancelled;
      }
    }
    
    _activeTasks.clear();
    _isInitialized = false;
    
    _logger.i('Background processor disposed');
  }
}

/// Background task function signature
typedef BackgroundTaskFunction = Future<void> Function(Map<String, dynamic> data);

/// Background task class
class BackgroundTask {
  final String id;
  final String name;
  final BackgroundTaskFunction function;
  final Map<String, dynamic> data;
  final TaskPriority priority;
  final bool persistent;
  final DateTime createdAt;
  
  TaskStatus status;
  DateTime? startedAt;
  DateTime? completedAt;
  String? error;
  
  BackgroundTask({
    required this.id,
    required this.name,
    required this.function,
    required this.data,
    required this.priority,
    required this.persistent,
    required this.createdAt,
    required this.status,
  });
  
  Duration? get duration {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!);
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'data': data,
      'priority': priority.name,
      'persistent': persistent,
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'duration_ms': duration?.inMilliseconds,
      'error': error,
    };
  }
}

/// Task priority levels
enum TaskPriority {
  low,
  normal,
  high,
  critical,
}

/// Task execution status
enum TaskStatus {
  scheduled,
  running,
  completed,
  failed,
  cancelled,
}

/// Persistent task data for Hive storage
@HiveType(typeId: 54)
class BackgroundTaskData {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final Map<String, dynamic> data;
  
  @HiveField(3)
  final TaskPriority priority;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final TaskStatus status;
  
  const BackgroundTaskData({
    required this.id,
    required this.name,
    required this.data,
    required this.priority,
    required this.createdAt,
    required this.status,
  });
}

/// Background processor statistics
class BackgroundProcessorStats {
  final int totalTasks;
  final int runningTasks;
  final int scheduledTasks;
  final int completedTasks;
  final int failedTasks;
  final int cancelledTasks;
  
  const BackgroundProcessorStats({
    required this.totalTasks,
    required this.runningTasks,
    required this.scheduledTasks,
    required this.completedTasks,
    required this.failedTasks,
    required this.cancelledTasks,
  });
  
  double get successRate {
    final processed = completedTasks + failedTasks;
    if (processed == 0) return 0.0;
    return (completedTasks / processed) * 100;
  }
  
  @override
  String toString() {
    return 'BackgroundProcessorStats(total: $totalTasks, running: $runningTasks, '
           'completed: $completedTasks, failed: $failedTasks, success: ${successRate.toStringAsFixed(1)}%)';
  }
}

/// Predefined background tasks
class BackgroundTasks {
  /// Clean up old cached data
  static String cleanupCache() {
    return BackgroundProcessor.scheduleTask(
      name: 'cleanup_cache',
      function: (data) async {
        await ImageCacheService.clearCache();
        await ErrorHandler.clearOldLogs();
      },
      priority: TaskPriority.low,
    );
  }
  
  /// Sync data with server
  static String syncData(Map<String, dynamic> syncData) {
    return BackgroundProcessor.scheduleTask(
      name: 'sync_data',
      function: (data) async {
        // Simulate data sync
        await Future.delayed(const Duration(seconds: 2));
        // In real implementation, this would sync with server
      },
      data: syncData,
      priority: TaskPriority.normal,
      persistent: true,
    );
  }
  
  /// Process analytics data
  static String processAnalytics(Map<String, dynamic> analyticsData) {
    return BackgroundProcessor.scheduleTask(
      name: 'process_analytics',
      function: (data) async {
        // Process analytics in background
        await Future.delayed(const Duration(seconds: 1));
        // In real implementation, this would process and aggregate data
      },
      data: analyticsData,
      priority: TaskPriority.high,
    );
  }
  
  /// Generate reports
  static String generateReport({
    required String reportType,
    required Map<String, dynamic> parameters,
  }) {
    return BackgroundProcessor.scheduleTask(
      name: 'generate_report',
      function: (data) async {
        final type = data['reportType'] as String;
        final params = data['parameters'] as Map<String, dynamic>;
        
        // Simulate report generation
        await Future.delayed(const Duration(seconds: 5));
        
        // In real implementation, this would generate the actual report
        Logger().d('Generated $type report with parameters: $params');
      },
      data: {
        'reportType': reportType,
        'parameters': parameters,
      },
      priority: TaskPriority.normal,
      persistent: true,
    );
  }
}