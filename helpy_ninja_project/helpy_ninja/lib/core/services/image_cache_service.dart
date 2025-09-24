import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Service for optimizing and caching images
class ImageCacheService {
  static final Logger _logger = Logger();
  static Directory? _cacheDirectory;
  static const int _maxCacheSizeMB = 100;
  static const int _maxCacheAgeDays = 30;
  
  /// Initialize image cache service
  static Future<void> initialize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      _cacheDirectory = Directory('${tempDir.path}/image_cache');
      
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }
      
      _logger.i('Image cache service initialized at: ${_cacheDirectory!.path}');
      
      // Clean up old cache files
      await _cleanupOldCache();
    } catch (e) {
      _logger.e('Failed to initialize image cache service: $e');
    }
  }
  
  /// Get cached image or download and cache it
  static Future<Uint8List?> getCachedImage(
    String url, {
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
  }) async {
    if (_cacheDirectory == null) {
      await initialize();
    }
    
    try {
      final cacheKey = _generateCacheKey(url, maxWidth, maxHeight, quality);
      final cachedFile = File('${_cacheDirectory!.path}/$cacheKey');
      
      // Return cached image if exists and not expired
      if (await cachedFile.exists()) {
        final stat = await cachedFile.stat();
        final age = DateTime.now().difference(stat.modified).inDays;
        
        if (age < _maxCacheAgeDays) {
          _logger.d('Returning cached image: $cacheKey');
          return await cachedFile.readAsBytes();
        } else {
          // Delete expired cache
          await cachedFile.delete();
        }
      }
      
      // Download and cache new image
      return await _downloadAndCacheImage(url, cacheKey, maxWidth, maxHeight, quality);
    } catch (e) {
      _logger.e('Failed to get cached image: $e');
      return null;
    }
  }
  
  /// Optimize image data
  static Future<Uint8List?> optimizeImage(
    Uint8List imageData, {
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
  }) async {
    try {
      final codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: maxWidth,
        targetHeight: maxHeight,
      );
      
      final frame = await codec.getNextFrame();
      final resizedImage = frame.image;
      
      // Convert to bytes with specified quality
      final byteData = await resizedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
    } catch (e) {
      _logger.e('Failed to optimize image: $e');
    }
    
    return null;
  }
  
  /// Clear all cached images
  static Future<void> clearCache() async {
    if (_cacheDirectory == null) return;
    
    try {
      if (await _cacheDirectory!.exists()) {
        await _cacheDirectory!.delete(recursive: true);
        await _cacheDirectory!.create(recursive: true);
        _logger.i('Image cache cleared');
      }
    } catch (e) {
      _logger.e('Failed to clear image cache: $e');
    }
  }
  
  /// Get cache size in MB
  static Future<double> getCacheSizeMB() async {
    if (_cacheDirectory == null) return 0.0;
    
    try {
      if (!await _cacheDirectory!.exists()) return 0.0;
      
      int totalSize = 0;
      await for (final entity in _cacheDirectory!.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize / (1024 * 1024);
    } catch (e) {
      _logger.e('Failed to calculate cache size: $e');
      return 0.0;
    }
  }
  
  /// Get cache statistics
  static Future<CacheStatistics> getCacheStatistics() async {
    if (_cacheDirectory == null) {
      return const CacheStatistics();
    }
    
    try {
      if (!await _cacheDirectory!.exists()) {
        return const CacheStatistics();
      }
      
      int totalFiles = 0;
      int totalSize = 0;
      DateTime? oldestFile;
      DateTime? newestFile;
      
      await for (final entity in _cacheDirectory!.list()) {
        if (entity is File) {
          totalFiles++;
          final stat = await entity.stat();
          totalSize += stat.size;
          
          if (oldestFile == null || stat.modified.isBefore(oldestFile)) {
            oldestFile = stat.modified;
          }
          if (newestFile == null || stat.modified.isAfter(newestFile)) {
            newestFile = stat.modified;
          }
        }
      }
      
      return CacheStatistics(
        totalFiles: totalFiles,
        totalSizeMB: totalSize / (1024 * 1024),
        oldestFile: oldestFile,
        newestFile: newestFile,
      );
    } catch (e) {
      _logger.e('Failed to get cache statistics: $e');
      return const CacheStatistics();
    }
  }
  
  /// Download and cache image
  static Future<Uint8List?> _downloadAndCacheImage(
    String url,
    String cacheKey,
    int? maxWidth,
    int? maxHeight,
    int quality,
  ) async {
    try {
      _logger.d('Downloading image: $url');
      
      // Simulate image download (in real implementation, use http client)
      // For now, return a placeholder
      final placeholderData = await _generatePlaceholderImage(200, 200);
      
      if (placeholderData != null) {
        // Optimize image if dimensions specified
        Uint8List? optimizedData;
        if (maxWidth != null || maxHeight != null) {
          optimizedData = await optimizeImage(
            placeholderData,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            quality: quality,
          );
        }
        
        final finalData = optimizedData ?? placeholderData;
        
        // Cache the image
        final cachedFile = File('${_cacheDirectory!.path}/$cacheKey');
        await cachedFile.writeAsBytes(finalData);
        
        _logger.d('Image cached: $cacheKey');
        return finalData;
      }
    } catch (e) {
      _logger.e('Failed to download and cache image: $e');
    }
    
    return null;
  }
  
  /// Generate cache key for image
  static String _generateCacheKey(
    String url,
    int? maxWidth,
    int? maxHeight,
    int quality,
  ) {
    final keyData = '$url-$maxWidth-$maxHeight-$quality';
    final bytes = utf8.encode(keyData);
    final digest = md5.convert(bytes);
    return digest.toString();
  }
  
  /// Generate placeholder image
  static Future<Uint8List?> _generatePlaceholderImage(int width, int height) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final paint = ui.Paint()
        ..color = const ui.Color(0xFFE0E0E0)
        ..style = ui.PaintingStyle.fill;
      
      // Draw background
      canvas.drawRect(
        ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        paint,
      );
      
      // Draw icon
      paint.color = const ui.Color(0xFF9E9E9E);
      final centerX = width / 2;
      final centerY = height / 2;
      final iconSize = (width < height ? width : height) * 0.3;
      
      canvas.drawCircle(
        ui.Offset(centerX, centerY - iconSize * 0.2),
        iconSize * 0.3,
        paint,
      );
      
      canvas.drawRect(
        ui.Rect.fromLTWH(
          centerX - iconSize * 0.4,
          centerY + iconSize * 0.1,
          iconSize * 0.8,
          iconSize * 0.5,
        ),
        paint,
      );
      
      final picture = recorder.endRecording();
      final image = await picture.toImage(width, height);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      _logger.e('Failed to generate placeholder image: $e');
      return null;
    }
  }
  
  /// Clean up old cache files
  static Future<void> _cleanupOldCache() async {
    if (_cacheDirectory == null) return;
    
    try {
      // Check cache size
      final cacheSizeMB = await getCacheSizeMB();
      
      if (cacheSizeMB > _maxCacheSizeMB) {
        _logger.i('Cache size (${cacheSizeMB.toStringAsFixed(1)}MB) exceeds limit, cleaning up...');
        await _cleanupBySize();
      }
      
      // Clean up by age
      await _cleanupByAge();
    } catch (e) {
      _logger.e('Failed to cleanup cache: $e');
    }
  }
  
  /// Clean up cache by size (remove oldest files)
  static Future<void> _cleanupBySize() async {
    if (_cacheDirectory == null) return;
    
    try {
      final files = <File>[];
      await for (final entity in _cacheDirectory!.list()) {
        if (entity is File) {
          files.add(entity);
        }
      }
      
      // Sort by modification time (oldest first)
      files.sort((a, b) {
        return a.statSync().modified.compareTo(b.statSync().modified);
      });
      
      // Remove oldest files until cache size is under limit
      double currentSize = await getCacheSizeMB();
      int removedFiles = 0;
      
      for (final file in files) {
        if (currentSize <= _maxCacheSizeMB * 0.8) break; // Leave 20% buffer
        
        final stat = await file.stat();
        await file.delete();
        currentSize -= stat.size / (1024 * 1024);
        removedFiles++;
      }
      
      if (removedFiles > 0) {
        _logger.i('Removed $removedFiles old cache files');
      }
    } catch (e) {
      _logger.e('Failed to cleanup cache by size: $e');
    }
  }
  
  /// Clean up cache by age
  static Future<void> _cleanupByAge() async {
    if (_cacheDirectory == null) return;
    
    try {
      final cutoff = DateTime.now().subtract(const Duration(days: _maxCacheAgeDays));
      int removedFiles = 0;
      
      await for (final entity in _cacheDirectory!.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoff)) {
            await entity.delete();
            removedFiles++;
          }
        }
      }
      
      if (removedFiles > 0) {
        _logger.i('Removed $removedFiles expired cache files');
      }
    } catch (e) {
      _logger.e('Failed to cleanup cache by age: $e');
    }
  }
}

/// Cache statistics
class CacheStatistics {
  final int totalFiles;
  final double totalSizeMB;
  final DateTime? oldestFile;
  final DateTime? newestFile;
  
  const CacheStatistics({
    this.totalFiles = 0,
    this.totalSizeMB = 0.0,
    this.oldestFile,
    this.newestFile,
  });
  
  /// Get cache age in days
  int get cacheAgeDays {
    if (oldestFile == null) return 0;
    return DateTime.now().difference(oldestFile!).inDays;
  }
  
  /// Check if cache needs cleanup
  bool get needsCleanup {
    return totalSizeMB > 80 || cacheAgeDays > 25;
  }
  
  @override
  String toString() {
    return 'CacheStats(files: $totalFiles, size: ${totalSizeMB.toStringAsFixed(1)}MB, age: ${cacheAgeDays}d)';
  }
}