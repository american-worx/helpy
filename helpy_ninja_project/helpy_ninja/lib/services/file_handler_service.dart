import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../domain/entities/message.dart';
import '../domain/entities/chat_settings.dart';
import '../domain/entities/shared_enums.dart';

/// File handler service for processing attachments
class FileHandlerService {
  static const int _maxFileSize = 100 * 1024 * 1024; // 100MB
  static const int _maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int _maxVideoSize = 50 * 1024 * 1024; // 50MB
  static const int _maxDocumentSize = 25 * 1024 * 1024; // 25MB

  static const Map<String, List<String>> _supportedTypes = {
    'image': ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'tiff'],
    'video': ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv'],
    'audio': ['mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a', 'wma'],
    'document': [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
      'rtf',
    ],
  };

  /// Process file for attachment
  static Future<FileProcessResult> processFile({
    required String filePath,
    required ChatPreferences preferences,
    String? customFileName,
    bool? forceCompress,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return FileProcessResult.error('File does not exist');
      }

      final fileInfo = await _analyzeFile(file);

      // Check file size limits
      final sizeCheckResult = _checkFileSizeLimit(fileInfo);
      if (!sizeCheckResult.isValid) {
        return FileProcessResult.error(sizeCheckResult.errorMessage!);
      }

      // Determine if compression is needed
      final shouldCompress =
          forceCompress ?? _shouldCompressFile(fileInfo, preferences);

      MessageAttachment attachment;

      if (shouldCompress) {
        final compressionResult = await _compressFile(
          file,
          fileInfo,
          preferences,
        );
        if (compressionResult.success) {
          attachment = await _createAttachment(
            file: compressionResult.file!,
            originalFile: file,
            fileInfo: fileInfo,
            compressionInfo: compressionResult.compressionInfo,
            customFileName: customFileName,
          );
        } else {
          return FileProcessResult.error(compressionResult.errorMessage);
        }
      } else {
        attachment = await _createAttachment(
          file: file,
          originalFile: null,
          fileInfo: fileInfo,
          compressionInfo: null,
          customFileName: customFileName,
        );
      }

      return FileProcessResult.success(attachment);
    } catch (e) {
      debugPrint('Error processing file: $e');
      return FileProcessResult.error('Failed to process file: $e');
    }
  }

  /// Analyze file to determine type and properties
  static Future<FileInfo> _analyzeFile(File file) async {
    final fileName = path.basename(file.path);
    final extension = path
        .extension(fileName)
        .toLowerCase()
        .replaceFirst('.', '');
    final fileSize = await file.length();
    final lastModified = await file.lastModified();

    AttachmentType type = AttachmentType.file;
    String mimeType = 'application/octet-stream';

    // Determine file type based on extension
    for (final category in _supportedTypes.keys) {
      if (_supportedTypes[category]!.contains(extension)) {
        switch (category) {
          case 'image':
            type = AttachmentType.image;
            mimeType = 'image/$extension';
            break;
          case 'video':
            type = AttachmentType.video;
            mimeType = 'video/$extension';
            break;
          case 'audio':
            type = AttachmentType.audio;
            mimeType = 'audio/$extension';
            break;
          case 'document':
            type = AttachmentType.document;
            mimeType = _getDocumentMimeType(extension);
            break;
        }
        break;
      }
    }

    return FileInfo(
      fileName: fileName,
      extension: extension,
      size: fileSize,
      type: type,
      mimeType: mimeType,
      lastModified: lastModified,
      path: file.path,
    );
  }

  /// Check if file size is within limits
  static SizeCheckResult _checkFileSizeLimit(FileInfo fileInfo) {
    int limit;
    String typeName;

    switch (fileInfo.type) {
      case AttachmentType.image:
        limit = _maxImageSize;
        typeName = 'image';
        break;
      case AttachmentType.video:
        limit = _maxVideoSize;
        typeName = 'video';
        break;
      case AttachmentType.document:
        limit = _maxDocumentSize;
        typeName = 'document';
        break;
      default:
        limit = _maxFileSize;
        typeName = 'file';
    }

    if (fileInfo.size > limit) {
      final limitMB = (limit / (1024 * 1024)).toStringAsFixed(1);
      final actualMB = (fileInfo.size / (1024 * 1024)).toStringAsFixed(1);
      return SizeCheckResult(
        isValid: false,
        errorMessage:
            '$typeName file size (${actualMB}MB) exceeds limit of ${limitMB}MB',
      );
    }

    return SizeCheckResult(isValid: true);
  }

  /// Determine if file should be compressed
  static bool _shouldCompressFile(
    FileInfo fileInfo,
    ChatPreferences preferences,
  ) {
    switch (fileInfo.type) {
      case AttachmentType.image:
        return preferences.compressImages && fileInfo.size > 1024 * 1024; // 1MB
      case AttachmentType.video:
        return preferences.compressVideos &&
            fileInfo.size > 5 * 1024 * 1024; // 5MB
      default:
        return false; // Don't compress other file types by default
    }
  }

  /// Compress file based on type
  static Future<CompressionResult> _compressFile(
    File file,
    FileInfo fileInfo,
    ChatPreferences preferences,
  ) async {
    try {
      switch (fileInfo.type) {
        case AttachmentType.image:
          return await _compressImage(file, fileInfo);
        case AttachmentType.video:
          return await _compressVideo(file, fileInfo);
        default:
          return CompressionResult.error(
            'Compression not supported for this file type',
          );
      }
    } catch (e) {
      debugPrint('Error compressing file: $e');
      return CompressionResult.error('Failed to compress file: $e');
    }
  }

  /// Compress image file
  static Future<CompressionResult> _compressImage(
    File file,
    FileInfo fileInfo,
  ) async {
    // This is a simplified implementation
    // In a real app, you would use image compression libraries like flutter_image_compress

    try {
      final bytes = await file.readAsBytes();

      // Simulate compression by reducing quality (this is just for demo)
      // In reality, you'd use proper image compression algorithms
      final compressionRatio = 0.3; // 30% reduction
      final compressedSize = (bytes.length * (1 - compressionRatio)).round();

      // Create a temporary compressed file
      final tempDir = Directory.systemTemp;
      final compressedFileName = 'compressed_${fileInfo.fileName}';
      final compressedFile = File('${tempDir.path}/$compressedFileName');

      // In a real implementation, write compressed bytes
      await compressedFile.writeAsBytes(bytes.take(compressedSize).toList());

      final compressionInfo = CompressionInfo(
        originalSize: fileInfo.size,
        compressedSize: compressedSize,
        compressionRatio: compressionRatio,
        algorithm: 'jpeg_optimization',
        processingTime: Duration(milliseconds: 500),
        metadata: {'quality': 0.8, 'format': 'jpeg'},
      );

      return CompressionResult.success(compressedFile, compressionInfo);
    } catch (e) {
      return CompressionResult.error('Failed to compress image: $e');
    }
  }

  /// Compress video file
  static Future<CompressionResult> _compressVideo(
    File file,
    FileInfo fileInfo,
  ) async {
    // This is a simplified implementation
    // In a real app, you would use video compression libraries like ffmpeg

    try {
      // Simulate video compression
      final compressionRatio = 0.5; // 50% reduction
      final compressedSize = (fileInfo.size * (1 - compressionRatio)).round();

      final tempDir = Directory.systemTemp;
      final compressedFileName = 'compressed_${fileInfo.fileName}';
      final compressedFile = File('${tempDir.path}/$compressedFileName');

      // In a real implementation, use ffmpeg to compress video
      final originalBytes = await file.readAsBytes();
      await compressedFile.writeAsBytes(
        originalBytes.take(compressedSize).toList(),
      );

      final compressionInfo = CompressionInfo(
        originalSize: fileInfo.size,
        compressedSize: compressedSize,
        compressionRatio: compressionRatio,
        algorithm: 'h264_compression',
        processingTime: Duration(milliseconds: 2000),
        metadata: {'codec': 'h264', 'bitrate': '1000k', 'resolution': '720p'},
      );

      return CompressionResult.success(compressedFile, compressionInfo);
    } catch (e) {
      return CompressionResult.error('Failed to compress video: $e');
    }
  }

  /// Create message attachment from processed file
  static Future<MessageAttachment> _createAttachment({
    required File file,
    File? originalFile,
    required FileInfo fileInfo,
    CompressionInfo? compressionInfo,
    String? customFileName,
  }) async {
    final fileName = customFileName ?? fileInfo.fileName;
    final fileSize = await file.length();

    // Generate unique ID for attachment
    final attachmentId = 'att_${DateTime.now().millisecondsSinceEpoch}';

    // In a real app, you would upload the file to cloud storage and get a URL
    final fileUrl = 'file://${file.path}'; // Local path for demo

    String? thumbnailUrl;
    if (fileInfo.type == AttachmentType.image ||
        fileInfo.type == AttachmentType.video) {
      thumbnailUrl = await _generateThumbnail(file, fileInfo.type);
    }

    return MessageAttachment(
      id: attachmentId,
      fileName: fileName,
      originalFileName: originalFile != null ? fileInfo.fileName : null,
      fileType: fileInfo.mimeType,
      fileSize: fileSize,
      originalFileSize: originalFile != null ? fileInfo.size : null,
      url: fileUrl,
      localPath: file.path,
      thumbnail: thumbnailUrl,
      type: fileInfo.type,
      status: AttachmentStatus.uploaded,
      compressionInfo: compressionInfo,
      uploadedAt: DateTime.now(),
      metadata: {
        'extension': fileInfo.extension,
        'lastModified': fileInfo.lastModified.toIso8601String(),
      },
    );
  }

  /// Generate thumbnail for media files
  static Future<String?> _generateThumbnail(
    File file,
    AttachmentType type,
  ) async {
    try {
      // This is a simplified implementation
      // In a real app, you would use thumbnail generation libraries

      if (type == AttachmentType.image) {
        // For images, you could generate a smaller version
        return 'thumbnail_${path.basename(file.path)}';
      } else if (type == AttachmentType.video) {
        // For videos, you could extract a frame as thumbnail
        return 'video_thumbnail_${path.basename(file.path)}.jpg';
      }

      return null;
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return null;
    }
  }

  /// Get MIME type for document files
  static String _getDocumentMimeType(String extension) {
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'rtf':
        return 'application/rtf';
      default:
        return 'application/octet-stream';
    }
  }

  /// Check if file type is supported
  static bool isFileTypeSupported(String fileName) {
    final extension = path
        .extension(fileName)
        .toLowerCase()
        .replaceFirst('.', '');
    return _supportedTypes.values.any((types) => types.contains(extension));
  }

  /// Get maximum file size for type
  static int getMaxFileSizeForType(AttachmentType type) {
    switch (type) {
      case AttachmentType.image:
        return _maxImageSize;
      case AttachmentType.video:
        return _maxVideoSize;
      case AttachmentType.document:
        return _maxDocumentSize;
      default:
        return _maxFileSize;
    }
  }

  /// Delete temporary files
  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = Directory.systemTemp;
      final tempFiles = await tempDir.list().toList();

      for (final entity in tempFiles) {
        if (entity is File &&
            (entity.path.contains('compressed_') ||
                entity.path.contains('thumbnail_'))) {
          try {
            await entity.delete();
          } catch (e) {
            debugPrint('Error deleting temp file ${entity.path}: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up temp files: $e');
    }
  }
}

/// File information model
class FileInfo {
  final String fileName;
  final String extension;
  final int size;
  final AttachmentType type;
  final String mimeType;
  final DateTime lastModified;
  final String path;

  const FileInfo({
    required this.fileName,
    required this.extension,
    required this.size,
    required this.type,
    required this.mimeType,
    required this.lastModified,
    required this.path,
  });
}

/// File processing result
class FileProcessResult {
  final bool success;
  final MessageAttachment? attachment;
  final String? errorMessage;

  const FileProcessResult._({
    required this.success,
    this.attachment,
    this.errorMessage,
  });

  factory FileProcessResult.success(MessageAttachment attachment) {
    return FileProcessResult._(success: true, attachment: attachment);
  }

  factory FileProcessResult.error(String message) {
    return FileProcessResult._(success: false, errorMessage: message);
  }
}

/// Compression result
class CompressionResult {
  final bool success;
  final File? file;
  final CompressionInfo? compressionInfo;
  final String errorMessage;

  const CompressionResult._({
    required this.success,
    this.file,
    this.compressionInfo,
    this.errorMessage = '',
  });

  factory CompressionResult.success(File file, CompressionInfo info) {
    return CompressionResult._(
      success: true,
      file: file,
      compressionInfo: info,
    );
  }

  factory CompressionResult.error(String message) {
    return CompressionResult._(success: false, errorMessage: message);
  }
}

/// Size check result
class SizeCheckResult {
  final bool isValid;
  final String? errorMessage;

  const SizeCheckResult({required this.isValid, this.errorMessage});
}
