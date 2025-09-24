import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/file_attachment_service.dart';
import '../common/cached_image_widget.dart';

/// Widget for displaying file attachments in messages
class FileAttachmentWidget extends StatelessWidget {
  final FileAttachment attachment;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool compact;
  
  const FileAttachmentWidget({
    super.key,
    required this.attachment,
    this.onTap,
    this.onDownload,
    this.onDelete,
    this.showActions = true,
    this.compact = false,
  });
  
  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactView(context);
    }
    return _buildFullView(context);
  }
  
  Widget _buildCompactView(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFileIcon(context),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    attachment.originalName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    attachment.formattedSize,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFullView(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildFileIcon(context),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.originalName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            attachment.formattedSize,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(' • ', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                          Text(
                            attachment.fileType.name.toUpperCase(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (showActions) ...[
                  const SizedBox(width: 8),
                  _buildActionButtons(context),
                ],
              ],
            ),
            if (attachment.isImage && attachment.thumbnailPath != null) ...[
              const SizedBox(height: 12),
              _buildImagePreview(context),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildFileIcon(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;
    
    switch (attachment.fileType) {
      case FileType.image:
        icon = Icons.image;
        color = Colors.green;
        break;
      case FileType.document:
        icon = Icons.description;
        color = Colors.blue;
        break;
      case FileType.audio:
        icon = Icons.audiotrack;
        color = Colors.orange;
        break;
      case FileType.unknown:
      default:
        icon = Icons.attach_file;
        color = theme.colorScheme.onSurfaceVariant;
        break;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onDownload,
          icon: const Icon(Icons.download),
          tooltip: 'Download',
          iconSize: 20,
        ),
        if (onDelete != null)
          IconButton(
            onPressed: _confirmDelete(context),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            iconSize: 20,
          ),
      ],
    );
  }
  
  Widget _buildImagePreview(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedImageWidget(
            imageUrl: attachment.filePath,
            fit: BoxFit.cover,
            placeholder: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(
                child: Icon(Icons.broken_image),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  VoidCallback? _confirmDelete(BuildContext context) {
    if (onDelete == null) return null;
    
    return () async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Attachment'),
          content: Text('Are you sure you want to delete "${attachment.originalName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        onDelete!();
      }
    };
  }
}

/// File picker widget for selecting attachments
class FilePickerWidget extends StatelessWidget {
  final VoidCallback? onImagePick;
  final VoidCallback? onDocumentPick;
  final VoidCallback? onAudioPick;
  final bool enabled;
  
  const FilePickerWidget({
    super.key,
    this.onImagePick,
    this.onDocumentPick,
    this.onAudioPick,
    this.enabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<FileType>(
      enabled: enabled,
      icon: const Icon(Icons.attach_file),
      tooltip: 'Attach file',
      onSelected: (type) {
        switch (type) {
          case FileType.image:
            onImagePick?.call();
            break;
          case FileType.document:
            onDocumentPick?.call();
            break;
          case FileType.audio:
            onAudioPick?.call();
            break;
          case FileType.unknown:
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: FileType.image,
          child: const Row(
            children: [
              Icon(Icons.image, color: Colors.green),
              SizedBox(width: 12),
              Text('Photo'),
            ],
          ),
        ),
        PopupMenuItem(
          value: FileType.document,
          child: const Row(
            children: [
              Icon(Icons.description, color: Colors.blue),
              SizedBox(width: 12),
              Text('Document'),
            ],
          ),
        ),
        PopupMenuItem(
          value: FileType.audio,
          child: const Row(
            children: [
              Icon(Icons.audiotrack, color: Colors.orange),
              SizedBox(width: 12),
              Text('Audio'),
            ],
          ),
        ),
      ],
    );
  }
}

/// Attachment list widget
class AttachmentListWidget extends StatelessWidget {
  final List<FileAttachment> attachments;
  final Function(FileAttachment)? onAttachmentTap;
  final Function(FileAttachment)? onDownload;
  final Function(FileAttachment)? onDelete;
  final bool showActions;
  final bool compact;
  
  const AttachmentListWidget({
    super.key,
    required this.attachments,
    this.onAttachmentTap,
    this.onDownload,
    this.onDelete,
    this.showActions = true,
    this.compact = false,
  });
  
  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }
    
    if (compact) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: attachments.map((attachment) => FileAttachmentWidget(
          attachment: attachment,
          onTap: () => onAttachmentTap?.call(attachment),
          onDownload: () => onDownload?.call(attachment),
          onDelete: onDelete != null ? () => onDelete!(attachment) : null,
          showActions: showActions,
          compact: true,
        )).toList(),
      );
    }
    
    return Column(
      children: attachments.map((attachment) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FileAttachmentWidget(
          attachment: attachment,
          onTap: () => onAttachmentTap?.call(attachment),
          onDownload: () => onDownload?.call(attachment),
          onDelete: onDelete != null ? () => onDelete!(attachment) : null,
          showActions: showActions,
        ),
      )).toList(),
    );
  }
}

/// File upload progress widget
class FileUploadProgressWidget extends StatelessWidget {
  final String fileName;
  final double progress;
  final VoidCallback? onCancel;
  
  const FileUploadProgressWidget({
    super.key,
    required this.fileName,
    required this.progress,
    this.onCancel,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.upload_file, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Uploading: $fileName',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onCancel != null)
                  IconButton(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 4),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}