import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Memory optimization utilities for efficient state management
class MemoryOptimizer {
  static final Logger _logger = Logger();
  static final Map<String, Timer> _disposalTimers = {};
  static const Duration _autoDisposeDelay = Duration(minutes: 5);
  
  /// Auto-dispose providers that haven't been used for a while
  static void scheduleAutoDispose(String providerId, VoidCallback dispose) {
    // Cancel existing timer
    _disposalTimers[providerId]?.cancel();
    
    // Schedule new disposal
    _disposalTimers[providerId] = Timer(_autoDisposeDelay, () {
      try {
        dispose();
        _disposalTimers.remove(providerId);
        _logger.d('Auto-disposed provider: $providerId');
      } catch (e) {
        _logger.w('Failed to auto-dispose provider $providerId: $e');
      }
    });
  }
  
  /// Cancel scheduled auto-dispose
  static void cancelAutoDispose(String providerId) {
    _disposalTimers[providerId]?.cancel();
    _disposalTimers.remove(providerId);
  }
  
  /// Get memory usage statistics
  static MemoryStats getMemoryStats() {
    return MemoryStats(
      activeProviders: _disposalTimers.length,
      scheduledDisposals: _disposalTimers.values.where((t) => t.isActive).length,
    );
  }
  
  /// Clear all scheduled disposals
  static void clearAllScheduled() {
    for (final timer in _disposalTimers.values) {
      timer.cancel();
    }
    _disposalTimers.clear();
    _logger.i('Cleared all scheduled disposals');
  }
}

/// LRU Cache implementation for efficient caching
class LRUCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap();
  
  LRUCache(this.maxSize);
  
  V? get(K key) {
    if (_cache.containsKey(key)) {
      // Move to end (most recently used)
      final value = _cache.remove(key)!;
      _cache[key] = value;
      return value;
    }
    return null;
  }
  
  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      // Remove least recently used
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    _cache[key] = value;
  }
  
  void remove(K key) {
    _cache.remove(key);
  }
  
  void clear() {
    _cache.clear();
  }
  
  int get length => _cache.length;
  bool get isEmpty => _cache.isEmpty;
  bool get isNotEmpty => _cache.isNotEmpty;
  
  List<K> get keys => _cache.keys.toList();
  List<V> get values => _cache.values.toList();
}

/// Optimized state notifier with memory management
abstract class OptimizedStateNotifier<T> extends StateNotifier<T> {
  final String _id;
  final Logger _logger = Logger();
  Timer? _memoryCleanupTimer;
  
  OptimizedStateNotifier(super.state, {required String id}) : _id = id {
    // Schedule periodic memory cleanup
    _memoryCleanupTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _performMemoryCleanup(),
    );
  }
  
  @override
  void dispose() {
    _memoryCleanupTimer?.cancel();
    _performMemoryCleanup();
    MemoryOptimizer.cancelAutoDispose(_id);
    super.dispose();
    _logger.d('Disposed optimized state notifier: $_id');
  }
  
  /// Override to implement custom memory cleanup
  void _performMemoryCleanup() {
    // Override in subclasses for custom cleanup logic
  }
  
  /// Schedule auto-dispose when not in use
  void scheduleAutoDispose() {
    MemoryOptimizer.scheduleAutoDispose(_id, dispose);
  }
  
  /// Cancel auto-dispose (called when provider is accessed)
  void cancelAutoDispose() {
    MemoryOptimizer.cancelAutoDispose(_id);
  }
}

/// Memory-efficient collection for large lists
class MemoryEfficientList<T> {
  final List<T> _items = [];
  final int _maxSize;
  final bool _dropOldest;
  
  MemoryEfficientList({
    int maxSize = 1000,
    bool dropOldest = true,
  }) : _maxSize = maxSize, _dropOldest = dropOldest;
  
  void add(T item) {
    if (_items.length >= _maxSize) {
      if (_dropOldest) {
        _items.removeAt(0); // Remove oldest
      } else {
        return; // Don't add if at capacity
      }
    }
    _items.add(item);
  }
  
  void addAll(Iterable<T> items) {
    for (final item in items) {
      add(item);
    }
  }
  
  void clear() {
    _items.clear();
  }
  
  void removeAt(int index) {
    _items.removeAt(index);
  }
  
  bool remove(T item) {
    return _items.remove(item);
  }
  
  T operator [](int index) => _items[index];
  
  void operator []=(int index, T value) {
    _items[index] = value;
  }
  
  int get length => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  bool get isFull => _items.length >= _maxSize;
  
  List<T> toList() => List.unmodifiable(_items);
  
  Iterable<T> get reversed => _items.reversed;
  
  /// Get recent items (last N items)
  List<T> getRecent(int count) {
    final startIndex = (_items.length - count).clamp(0, _items.length);
    return _items.sublist(startIndex);
  }
  
  /// Get items in range
  List<T> getRange(int start, int end) {
    return _items.sublist(start, end);
  }
}

/// Weak reference holder for preventing memory leaks
class WeakReference<T extends Object> {
  WeakReference(T value) : _weakRef = WeakReference(value);
  
  final WeakReference<T> _weakRef;
  
  T? get target => _weakRef.target;
  
  bool get isValid => _weakRef.target != null;
}

/// Memory pool for reusing objects
class ObjectPool<T> {
  final T Function() _factory;
  final void Function(T)? _reset;
  final Queue<T> _pool = Queue();
  final int _maxSize;
  
  ObjectPool({
    required T Function() factory,
    void Function(T)? reset,
    int maxSize = 100,
  }) : _factory = factory, _reset = reset, _maxSize = maxSize;
  
  T acquire() {
    if (_pool.isNotEmpty) {
      final obj = _pool.removeFirst();
      _reset?.call(obj);
      return obj;
    }
    return _factory();
  }
  
  void release(T obj) {
    if (_pool.length < _maxSize) {
      _pool.add(obj);
    }
  }
  
  void clear() {
    _pool.clear();
  }
  
  int get poolSize => _pool.length;
  int get maxSize => _maxSize;
}

/// Lazy initialization wrapper
class Lazy<T> {
  T Function() _factory;
  T? _value;
  bool _isInitialized = false;
  
  Lazy(this._factory);
  
  T get value {
    if (!_isInitialized) {
      _value = _factory();
      _isInitialized = true;
    }
    return _value!;
  }
  
  bool get isInitialized => _isInitialized;
  
  void reset() {
    _value = null;
    _isInitialized = false;
  }
}

/// Memory statistics
class MemoryStats {
  final int activeProviders;
  final int scheduledDisposals;
  
  const MemoryStats({
    required this.activeProviders,
    required this.scheduledDisposals,
  });
  
  @override
  String toString() {
    return 'MemoryStats(providers: $activeProviders, scheduled: $scheduledDisposals)';
  }
}

/// Memory-optimized Riverpod providers
mixin AutoDisposeProviderMixin<T> on StateNotifier<T> {
  String get providerId;
  
  void onProviderAccessed() {
    MemoryOptimizer.cancelAutoDispose(providerId);
  }
  
  void onProviderUnused() {
    MemoryOptimizer.scheduleAutoDispose(providerId, dispose);
  }
}

/// Efficient image memory cache
class ImageMemoryCache {
  static final LRUCache<String, Uint8List> _cache = LRUCache(50);
  static int _maxMemoryUsage = 50 * 1024 * 1024; // 50MB
  static int _currentMemoryUsage = 0;
  
  static void put(String key, Uint8List imageData) {
    final imageSize = imageData.lengthInBytes;
    
    // Check if adding this image would exceed memory limit
    while (_currentMemoryUsage + imageSize > _maxMemoryUsage && _cache.isNotEmpty) {
      _evictOldest();
    }
    
    // Remove existing entry if it exists
    final existing = _cache.get(key);
    if (existing != null) {
      _currentMemoryUsage -= existing.lengthInBytes;
    }
    
    _cache.put(key, imageData);
    _currentMemoryUsage += imageSize;
  }
  
  static Uint8List? get(String key) {
    return _cache.get(key);
  }
  
  static void _evictOldest() {
    if (_cache.isEmpty) return;
    
    final oldestKey = _cache.keys.first;
    final imageData = _cache.get(oldestKey);
    if (imageData != null) {
      _currentMemoryUsage -= imageData.lengthInBytes;
      _cache.remove(oldestKey);
    }
  }
  
  static void clear() {
    _cache.clear();
    _currentMemoryUsage = 0;
  }
  
  static MemoryCacheStats get stats => MemoryCacheStats(
    itemCount: _cache.length,
    memoryUsageBytes: _currentMemoryUsage,
    maxMemoryBytes: _maxMemoryUsage,
  );
}

/// Memory cache statistics
class MemoryCacheStats {
  final int itemCount;
  final int memoryUsageBytes;
  final int maxMemoryBytes;
  
  const MemoryCacheStats({
    required this.itemCount,
    required this.memoryUsageBytes,
    required this.maxMemoryBytes,
  });
  
  double get memoryUsageMB => memoryUsageBytes / (1024 * 1024);
  double get maxMemoryMB => maxMemoryBytes / (1024 * 1024);
  double get usagePercentage => (memoryUsageBytes / maxMemoryBytes) * 100;
  
  @override
  String toString() {
    return 'MemoryCacheStats(items: $itemCount, usage: ${memoryUsageMB.toStringAsFixed(1)}MB/${maxMemoryMB.toStringAsFixed(1)}MB, ${usagePercentage.toStringAsFixed(1)}%)';
  }
}