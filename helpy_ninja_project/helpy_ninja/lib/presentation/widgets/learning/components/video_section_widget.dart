import 'package:flutter/material.dart';

import '../../../../config/design_tokens.dart';

/// Widget for displaying video content in lessons
/// Note: This is a placeholder implementation. A full implementation would
/// require video_player package and proper video controls.
class VideoSectionWidget extends StatelessWidget {
  const VideoSectionWidget({
    super.key,
    required this.videoPath,
    required this.onProgressUpdate,
  });

  final String videoPath;
  final VoidCallback onProgressUpdate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Video placeholder container
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceL),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [DesignTokens.primary, DesignTokens.accent],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: GestureDetector(
                    onTap: () => _playVideo(context),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceM),
                Text(
                  'Tap to play video',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceS),
                Text(
                  videoPath,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: DesignTokens.spaceM),

          // Video info
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceM),
            decoration: BoxDecoration(
              color: DesignTokens.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: DesignTokens.primary,
                  size: 20,
                ),
                const SizedBox(width: DesignTokens.spaceS),
                Expanded(
                  child: Text(
                    'Video player integration requires additional setup. This is a placeholder implementation.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: DesignTokens.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _playVideo(BuildContext context) {
    // Notify progress when video is "played"
    onProgressUpdate();

    // Show placeholder dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Player'),
        content: Text(
          'Video: $videoPath\n\nVideo player integration coming soon!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
