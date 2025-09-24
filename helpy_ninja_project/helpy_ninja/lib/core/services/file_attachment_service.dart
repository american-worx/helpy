import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../error/app_error.dart';
import '../error/error_handler.dart';

/// Service for handling file attachments in messages
class FileAttachmentService {
  static final Logger _logger = Logger();
  static Directory? _attachmentDirectory;
  static const int _maxFileSizeMB = 10;
  static const List<String> _allowedImageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
  static const List<String> _allowedDocumentExtensions = ['.pdf', '.doc', '.docx', '.txt', '.md'];
  static const List<String> _allowedAudioExtensions = ['.mp3', '.wav', '.m4a', '.aac'];
  
  /// Initialize file attachment service
  static Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _attachmentDirectory = Directory('${appDir.path}/attachments');
      
      if (!await _attachmentDirectory!.exists()) {
        await _attachmentDirectory!.create(recursive: true);
      }
      
      _logger.i('File attachment service initialized at: ${_attachmentDirectory!.path}');
    } catch (e) {
      _logger.e('Failed to initialize file attachment service: $e');
      throw AppError.storage('Failed to initialize attachment storage');
    }
  }
  
  /// Upload file and get attachment info
  static Future<FileAttachment> uploadFile(String filePath) async {
    if (_attachmentDirectory == null) {
      await initialize();
    }
    
    try {
      final file = File(filePath);
      
      // Check if file exists
      if (!await file.exists()) {
        throw AppError.validation('File does not exist: $filePath');
      }
      
      // Get file info
      final stat = await file.stat();
      final fileName = file.uri.pathSegments.last;
      final fileExtension = fileName.toLowerCase().substring(fileName.lastIndexOf('.'));
      
      // Validate file size
      if (stat.size > _maxFileSizeMB * 1024 * 1024) {
        throw AppError.validation('File size exceeds ${_maxFileSizeMB}MB limit');
      }
      
      // Validate file type
      final fileType = _getFileType(fileExtension);
      if (fileType == FileType.unknown) {
        throw AppError.validation('File type not supported: $fileExtension');
      }
      
      // Generate unique filename
      final fileId = _generateFileId(fileName);
      final storedFileName = '$fileId$fileExtension';
      final storedFile = File('${_attachmentDirectory!.path}/$storedFileName');
      
      // Copy file to attachments directory
      await file.copy(storedFile.path);
      
      // Generate thumbnail if it's an image
      String? thumbnailPath;
      if (fileType == FileType.image) {
        thumbnailPath = await _generateThumbnail(storedFile.path, fileId);
      }
      
      final attachment = FileAttachment(
        id: fileId,
        originalName: fileName,
        storedName: storedFileName,
        filePath: storedFile.path,
        thumbnailPath: thumbnailPath,
        fileType: fileType,
        fileSize: stat.size,
        mimeType: _getMimeType(fileExtension),
        uploadedAt: DateTime.now(),
      );
      
      _logger.d('File uploaded: $fileName (${_formatFileSize(stat.size)})');
      return attachment;
    } catch (e) {
      _logger.e('Failed to upload file: $e');
      if (e is AppError) {
        rethrow;
      }
      throw AppError.storage('Failed to upload file: $e');
    }
  }
  
  /// Download file to downloads directory
  static Future<String> downloadFile(FileAttachment attachment) async {
    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        throw AppError.storage('Downloads directory not available');
      }
      
      final sourceFile = File(attachment.filePath);
      if (!await sourceFile.exists()) {
        throw AppError.storage('Attachment file not found');
      }
      
      // Generate unique filename in downloads
      String downloadFileName = attachment.originalName;
      String downloadPath = '${downloadsDir.path}/$downloadFileName';
      int counter = 1;
      
      // Handle duplicate filenames
      while (await File(downloadPath).exists()) {
        final extension = attachment.originalName.substring(attachment.originalName.lastIndexOf('.'));
        final nameWithoutExt = attachment.originalName.substring(0, attachment.originalName.lastIndexOf('.'));
        downloadFileName = '${nameWithoutExt}_$counter$extension';
        downloadPath = '${downloadsDir.path}/$downloadFileName';
        counter++;
      }
      
      // Copy file to downloads
      await sourceFile.copy(downloadPath);
      
      _logger.d('File downloaded: $downloadFileName');
      return downloadPath;
    } catch (e) {
      _logger.e('Failed to download file: $e');
      if (e is AppError) {
        rethrow;
      }
      throw AppError.storage('Failed to download file: $e');
    }
  }
  
  /// Get file data as bytes
  static Future<Uint8List> getFileData(FileAttachment attachment) async {
    try {
      final file = File(attachment.filePath);
      if (!await file.exists()) {
        throw AppError.storage('Attachment file not found');
      }
      
      return await file.readAsBytes();
    } catch (e) {
      _logger.e('Failed to get file data: $e');
      if (e is AppError) {
        rethrow;
      }
      throw AppError.storage('Failed to read file data: $e');
    }
  }
  
  /// Delete attachment file
  static Future<void> deleteFile(FileAttachment attachment) async {
    try {
      final file = File(attachment.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Delete thumbnail if exists
      if (attachment.thumbnailPath != null) {
        final thumbnail = File(attachment.thumbnailPath!);
        if (await thumbnail.exists()) {
          await thumbnail.delete();
        }
      }
      
      _logger.d('File deleted: ${attachment.originalName}');
    } catch (e) {
      _logger.w('Failed to delete file: $e');
    }
  }
  
  /// Get attachment statistics
  static Future<AttachmentStatistics> getStatistics() async {
    if (_attachmentDirectory == null) return const AttachmentStatistics();
    
    try {
      if (!await _attachmentDirectory!.exists()) {
        return const AttachmentStatistics();
      }
      
      int totalFiles = 0;
      int totalSize = 0;
      final typeStats = <FileType, int>{};
      
      await for (final entity in _attachmentDirectory!.list()) {
        if (entity is File) {
          totalFiles++;
          final stat = await entity.stat();
          totalSize += stat.size;
          
          final extension = entity.path.toLowerCase().substring(entity.path.lastIndexOf('.'));
          final fileType = _getFileType(extension);
          typeStats[fileType] = (typeStats[fileType] ?? 0) + 1;
        }
      }
      
      return AttachmentStatistics(
        totalFiles: totalFiles,
        totalSizeMB: totalSize / (1024 * 1024),
        filesByType: typeStats,
      );
    } catch (e) {
      _logger.w('Failed to get attachment statistics: $e');
      return const AttachmentStatistics();
    }
  }
  
  /// Clean up old attachments
  static Future<void> cleanupOldAttachments() async {
    if (_attachmentDirectory == null) return;
    
    try {
      final cutoff = DateTime.now().subtract(const Duration(days: 30));
      int deletedFiles = 0;
      
      await for (final entity in _attachmentDirectory!.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoff)) {
            await entity.delete();
            deletedFiles++;
          }
        }
      }
      
      _logger.i('Cleaned up $deletedFiles old attachment files');
    } catch (e) {
      _logger.w('Failed to cleanup old attachments: $e');
    }
  }
  
  /// Generate thumbnail for image files
  static Future<String?> _generateThumbnail(String imagePath, String fileId) async {
    try {
      // In a real implementation, this would generate actual thumbnails
      // For now, we'll just return the original path as a placeholder
      return imagePath;
    } catch (e) {
      _logger.w('Failed to generate thumbnail: $e');
      return null;
    }
  }
  
  /// Generate unique file ID
  static String _generateFileId(String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = '$fileName$timestamp';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }
  
  /// Get file type from extension
  static FileType _getFileType(String extension) {
    if (_allowedImageExtensions.contains(extension)) {
      return FileType.image;
    } else if (_allowedDocumentExtensions.contains(extension)) {
      return FileType.document;
    } else if (_allowedAudioExtensions.contains(extension)) {
      return FileType.audio;
    }
    return FileType.unknown;
  }
  
  /// Get MIME type from extension
  static String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.txt':
        return 'text/plain';
      case '.md':
        return 'text/markdown';
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.m4a':
        return 'audio/mp4';
      case '.aac':
        return 'audio/aac';
      default:
        return 'application/octet-stream';
    }
  }
  
  /// Format file size for display
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// File attachment data model
class FileAttachment {
  final String id;
  final String originalName;
  final String storedName;
  final String filePath;
  final String? thumbnailPath;
  final FileType fileType;
  final int fileSize;
  final String mimeType;
  final DateTime uploadedAt;
  
  const FileAttachment({
    required this.id,
    required this.originalName,
    required this.storedName,
    required this.filePath,
    this.thumbnailPath,
    required this.fileType,
    required this.fileSize,
    required this.mimeType,
    required this.uploadedAt,
  });
  
  /// Get formatted file size
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Get file extension
  String get extension {
    return originalName.substring(originalName.lastIndexOf('.'));
  }
  
  /// Check if file is an image
  bool get isImage => fileType == FileType.image;
  
  /// Check if file is a document
  bool get isDocument => fileType == FileType.document;
  
  /// Check if file is audio
  bool get isAudio => fileType == FileType.audio;
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'original_name': originalName,
      'stored_name': storedName,
      'file_path': filePath,
      'thumbnail_path': thumbnailPath,
      'file_type': fileType.name,
      'file_size': fileSize,
      'mime_type': mimeType,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
  
  factory FileAttachment.fromMap(Map<String, dynamic> map) {
    return FileAttachment(
      id: map['id'],
      originalName: map['original_name'],
      storedName: map['stored_name'],
      filePath: map['file_path'],
      thumbnailPath: map['thumbnail_path'],
      fileType: FileType.values.firstWhere(
        (e) => e.name == map['file_type'],
        orElse: () => FileType.unknown,
      ),
      fileSize: map['file_size'],
      mimeType: map['mime_type'],
      uploadedAt: DateTime.parse(map['uploaded_at']),
    );
  }
}

/// File types supported for attachments
enum FileType {
  image,
  document,
  audio,
  unknown,
}

/// Attachment statistics
class AttachmentStatistics {
  final int totalFiles;
  final double totalSizeMB;
  final Map<FileType, int> filesByType;
  
  const AttachmentStatistics({
    this.totalFiles = 0,
    this.totalSizeMB = 0.0,
    this.filesByType = const {},
  });
  
  @override
  String toString() {
    return 'AttachmentStats(files: $totalFiles, size: ${totalSizeMB.toStringAsFixed(1)}MB)';
  }
}