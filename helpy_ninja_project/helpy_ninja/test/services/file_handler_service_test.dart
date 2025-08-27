import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:helpy_ninja/services/file_handler_service.dart';
import 'package:helpy_ninja/domain/entities/chat_settings.dart';
import 'package:helpy_ninja/domain/entities/shared_enums.dart';
import 'package:helpy_ninja/domain/entities/message.dart';

void main() {
  group('FileHandlerService Tests', () {
    test('should identify supported file types correctly', () {
      expect(FileHandlerService.isFileTypeSupported('image.jpg'), true);
      expect(FileHandlerService.isFileTypeSupported('video.mp4'), true);
      expect(FileHandlerService.isFileTypeSupported('document.pdf'), true);
      expect(FileHandlerService.isFileTypeSupported('audio.mp3'), true);
      expect(FileHandlerService.isFileTypeSupported('unknown.xyz'), false);
    });

    test('should return correct max file sizes for different types', () {
      expect(
        FileHandlerService.getMaxFileSizeForType(AttachmentType.image),
        10 * 1024 * 1024, // 10MB
      );
      expect(
        FileHandlerService.getMaxFileSizeForType(AttachmentType.video),
        50 * 1024 * 1024, // 50MB
      );
      expect(
        FileHandlerService.getMaxFileSizeForType(AttachmentType.document),
        25 * 1024 * 1024, // 25MB
      );
      expect(
        FileHandlerService.getMaxFileSizeForType(AttachmentType.file),
        100 * 1024 * 1024, // 100MB
      );
    });

    group('FileInfo Tests', () {
      test('should create FileInfo with correct properties', () {
        final fileInfo = FileInfo(
          fileName: 'test.jpg',
          extension: 'jpg',
          size: 1024000,
          type: AttachmentType.image,
          mimeType: 'image/jpeg',
          lastModified: DateTime.now(),
          path: '/path/to/test.jpg',
        );

        expect(fileInfo.fileName, 'test.jpg');
        expect(fileInfo.extension, 'jpg');
        expect(fileInfo.size, 1024000);
        expect(fileInfo.type, AttachmentType.image);
        expect(fileInfo.mimeType, 'image/jpeg');
      });
    });

    group('FileProcessResult Tests', () {
      test('should create success result', () {
        final attachment = MessageAttachment(
          id: 'test_id',
          fileName: 'test.jpg',
          fileType: 'image/jpeg',
          fileSize: 1024,
          url: 'file://test.jpg',
          type: AttachmentType.image,
        );

        final result = FileProcessResult.success(attachment);

        expect(result.success, true);
        expect(result.attachment, attachment);
        expect(result.errorMessage, null);
      });

      test('should create error result', () {
        const errorMessage = 'File too large';
        final result = FileProcessResult.error(errorMessage);

        expect(result.success, false);
        expect(result.attachment, null);
        expect(result.errorMessage, errorMessage);
      });
    });

    group('CompressionResult Tests', () {
      test('should create success compression result', () {
        final file = File('test.jpg');
        final compressionInfo = CompressionInfo(
          originalSize: 2000000,
          compressedSize: 1000000,
          compressionRatio: 0.5,
          algorithm: 'jpeg',
          processingTime: const Duration(milliseconds: 500),
        );

        final result = CompressionResult.success(file, compressionInfo);

        expect(result.success, true);
        expect(result.file, file);
        expect(result.compressionInfo, compressionInfo);
        expect(result.errorMessage, '');
      });

      test('should create error compression result', () {
        const errorMessage = 'Compression failed';
        final result = CompressionResult.error(errorMessage);

        expect(result.success, false);
        expect(result.file, null);
        expect(result.compressionInfo, null);
        expect(result.errorMessage, errorMessage);
      });
    });

    group('SizeCheckResult Tests', () {
      test('should create valid size check result', () {
        final result = SizeCheckResult(isValid: true);

        expect(result.isValid, true);
        expect(result.errorMessage, null);
      });

      test('should create invalid size check result with error message', () {
        const errorMessage = 'File size exceeds limit';
        final result = SizeCheckResult(
          isValid: false,
          errorMessage: errorMessage,
        );

        expect(result.isValid, false);
        expect(result.errorMessage, errorMessage);
      });
    });
  });

  group('MessageAttachment Tests', () {
    test('should create MessageAttachment with required fields', () {
      final attachment = MessageAttachment(
        id: 'att_001',
        fileName: 'test.jpg',
        fileType: 'image/jpeg',
        fileSize: 1024000,
        url: 'https://example.com/test.jpg',
        type: AttachmentType.image,
      );

      expect(attachment.id, 'att_001');
      expect(attachment.fileName, 'test.jpg');
      expect(attachment.fileType, 'image/jpeg');
      expect(attachment.fileSize, 1024000);
      expect(attachment.type, AttachmentType.image);
      expect(attachment.status, AttachmentStatus.uploaded); // default value
      expect(attachment.isEncrypted, false); // default value
    });

    test('should format file size correctly', () {
      final smallFile = MessageAttachment(
        id: 'small',
        fileName: 'small.txt',
        fileType: 'text/plain',
        fileSize: 512,
        url: 'file://small.txt',
        type: AttachmentType.file,
      );

      final mediumFile = MessageAttachment(
        id: 'medium',
        fileName: 'medium.jpg',
        fileType: 'image/jpeg',
        fileSize: 1024 * 500, // 500KB
        url: 'file://medium.jpg',
        type: AttachmentType.image,
      );

      final largeFile = MessageAttachment(
        id: 'large',
        fileName: 'large.mp4',
        fileType: 'video/mp4',
        fileSize: 1024 * 1024 * 5, // 5MB
        url: 'file://large.mp4',
        type: AttachmentType.video,
      );

      expect(smallFile.formattedFileSize, '512B');
      expect(mediumFile.formattedFileSize, '500.0KB');
      expect(largeFile.formattedFileSize, '5.0MB');
    });

    test('should calculate compression ratio correctly', () {
      final compressedAttachment = MessageAttachment(
        id: 'compressed',
        fileName: 'compressed.jpg',
        fileType: 'image/jpeg',
        fileSize: 500000,
        originalFileSize: 1000000,
        url: 'file://compressed.jpg',
        type: AttachmentType.image,
      );

      final uncompressedAttachment = MessageAttachment(
        id: 'uncompressed',
        fileName: 'uncompressed.jpg',
        fileType: 'image/jpeg',
        fileSize: 1000000,
        url: 'file://uncompressed.jpg',
        type: AttachmentType.image,
      );

      expect(compressedAttachment.compressionRatio, 0.5);
      expect(compressedAttachment.compressionPercentage, '50.0%');
      expect(uncompressedAttachment.compressionRatio, null);
      expect(uncompressedAttachment.compressionPercentage, 'No compression');
    });

    test('should identify file types correctly', () {
      final imageAttachment = MessageAttachment(
        id: 'image',
        fileName: 'test.jpg',
        fileType: 'image/jpeg',
        fileSize: 1024,
        url: 'file://test.jpg',
        type: AttachmentType.image,
      );

      final videoAttachment = MessageAttachment(
        id: 'video',
        fileName: 'test.mp4',
        fileType: 'video/mp4',
        fileSize: 1024,
        url: 'file://test.mp4',
        type: AttachmentType.video,
      );

      final audioAttachment = MessageAttachment(
        id: 'audio',
        fileName: 'test.mp3',
        fileType: 'audio/mpeg',
        fileSize: 1024,
        url: 'file://test.mp3',
        type: AttachmentType.audio,
      );

      final documentAttachment = MessageAttachment(
        id: 'document',
        fileName: 'test.pdf',
        fileType: 'application/pdf',
        fileSize: 1024,
        url: 'file://test.pdf',
        type: AttachmentType.document,
      );

      expect(imageAttachment.isImage, true);
      expect(imageAttachment.isVideo, false);
      expect(videoAttachment.isVideo, true);
      expect(videoAttachment.isAudio, false);
      expect(audioAttachment.isAudio, true);
      expect(audioAttachment.isDocument, false);
      expect(documentAttachment.isDocument, true);
      expect(documentAttachment.isImage, false);
    });

    test('should get correct file extension', () {
      final attachment = MessageAttachment(
        id: 'test',
        fileName: 'document.PDF',
        fileType: 'application/pdf',
        fileSize: 1024,
        url: 'file://document.PDF',
        type: AttachmentType.document,
      );

      expect(attachment.fileExtension, 'pdf'); // Should be lowercase
    });

    test('should get correct type icons', () {
      final imageAttachment = MessageAttachment(
        id: 'image',
        fileName: 'test.jpg',
        fileType: 'image/jpeg',
        fileSize: 1024,
        url: 'file://test.jpg',
        type: AttachmentType.image,
      );

      final videoAttachment = MessageAttachment(
        id: 'video',
        fileName: 'test.mp4',
        fileType: 'video/mp4',
        fileSize: 1024,
        url: 'file://test.mp4',
        type: AttachmentType.video,
      );

      expect(imageAttachment.typeIcon, '🖼️');
      expect(videoAttachment.typeIcon, '🎥');
    });

    test('should convert MessageAttachment to and from JSON', () {
      final originalAttachment = MessageAttachment(
        id: 'att_001',
        fileName: 'test.jpg',
        originalFileName: 'original_test.jpg',
        fileType: 'image/jpeg',
        fileSize: 1024000,
        originalFileSize: 2048000,
        url: 'https://example.com/test.jpg',
        localPath: '/local/test.jpg',
        thumbnail: 'https://example.com/thumb.jpg',
        type: AttachmentType.image,
        status: AttachmentStatus.compressed,
        uploadedAt: DateTime.parse('2024-01-01T12:00:00Z'),
        uploadedBy: 'user_001',
        isEncrypted: true,
        encryptionKey: 'secret_key',
      );

      final json = originalAttachment.toJson();
      final reconstructedAttachment = MessageAttachment.fromJson(json);

      expect(reconstructedAttachment.id, originalAttachment.id);
      expect(reconstructedAttachment.fileName, originalAttachment.fileName);
      expect(
        reconstructedAttachment.originalFileName,
        originalAttachment.originalFileName,
      );
      expect(reconstructedAttachment.fileType, originalAttachment.fileType);
      expect(reconstructedAttachment.fileSize, originalAttachment.fileSize);
      expect(
        reconstructedAttachment.originalFileSize,
        originalAttachment.originalFileSize,
      );
      expect(reconstructedAttachment.url, originalAttachment.url);
      expect(reconstructedAttachment.localPath, originalAttachment.localPath);
      expect(reconstructedAttachment.thumbnail, originalAttachment.thumbnail);
      expect(reconstructedAttachment.type, originalAttachment.type);
      expect(reconstructedAttachment.status, originalAttachment.status);
      expect(reconstructedAttachment.uploadedAt, originalAttachment.uploadedAt);
      expect(reconstructedAttachment.uploadedBy, originalAttachment.uploadedBy);
      expect(
        reconstructedAttachment.isEncrypted,
        originalAttachment.isEncrypted,
      );
      expect(
        reconstructedAttachment.encryptionKey,
        originalAttachment.encryptionKey,
      );
    });
  });
}
