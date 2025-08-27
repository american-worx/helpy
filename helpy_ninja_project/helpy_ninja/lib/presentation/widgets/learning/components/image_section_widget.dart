import 'package:flutter/material.dart';

import '../../../../config/design_tokens.dart';

/// Widget for displaying image content in lessons
class ImageSectionWidget extends StatelessWidget {
  const ImageSectionWidget({
    super.key,
    required this.imagePath,
    this.caption,
    required this.onProgressUpdate,
  });

  final String imagePath;
  final String? caption;
  final VoidCallback onProgressUpdate;

  @override
  Widget build(BuildContext context) {
    // Notify progress when image loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onProgressUpdate();
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image container
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              child: _buildImage(context),
            ),
          ),

          // Caption
          if (caption != null && caption!.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spaceM),
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceM),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: DesignTokens.primary,
                  ),
                  const SizedBox(width: DesignTokens.spaceS),
                  Expanded(
                    child: Text(
                      caption!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    // Handle different image sources
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceXL),
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder(context);
        },
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder(context);
        },
      );
    }
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      height: 200,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: DesignTokens.spaceS),
          Text(
            'Image could not be loaded',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
