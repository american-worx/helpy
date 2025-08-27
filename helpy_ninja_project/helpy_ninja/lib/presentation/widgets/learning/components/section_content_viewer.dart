import 'package:flutter/material.dart';

import '../../../../domain/entities/lesson.dart';
import 'text_section_widget.dart';
import 'code_section_widget.dart';
import 'image_section_widget.dart';
import 'video_section_widget.dart';

/// Widget that displays different types of lesson section content
class SectionContentViewer extends StatelessWidget {
  const SectionContentViewer({
    super.key,
    required this.section,
    required this.onProgressUpdate,
  });

  final LessonSection section;
  final VoidCallback onProgressUpdate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          if (section.title.isNotEmpty) ...[
            Text(
              section.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
          ],

          // Section content based on type
          Expanded(child: _buildContentByType()),
        ],
      ),
    );
  }

  Widget _buildContentByType() {
    switch (section.type) {
      case LessonSectionType.text:
        return TextSectionWidget(
          content: section.content,
          onProgressUpdate: onProgressUpdate,
        );
      case LessonSectionType.code:
        return CodeSectionWidget(
          content: section.content,
          language: section.metadata?['language'] ?? 'dart',
          onProgressUpdate: onProgressUpdate,
        );
      case LessonSectionType.image:
        return ImageSectionWidget(
          imagePath: section.content,
          caption: section.metadata?['caption'],
          onProgressUpdate: onProgressUpdate,
        );
      case LessonSectionType.video:
        return VideoSectionWidget(
          videoPath: section.content,
          onProgressUpdate: onProgressUpdate,
        );
      default:
        return TextSectionWidget(
          content: section.content,
          onProgressUpdate: onProgressUpdate,
        );
    }
  }
}
