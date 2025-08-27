import 'package:flutter/material.dart';

import '../../../../config/design_tokens.dart';
import '../../../../domain/entities/lesson.dart';
import '../../../widgets/navigation/modern_navigation.dart';

/// Custom app bar for lesson viewer with lesson information
class LessonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LessonAppBar({
    super.key,
    required this.lesson,
    required this.onBackPressed,
    required this.onMenuAction,
  });

  final Lesson lesson;
  final VoidCallback onBackPressed;
  final Function(String, Lesson) onMenuAction;

  @override
  Widget build(BuildContext context) {
    return ModernAppBar(
      title: lesson.title,
      subtitle: '${lesson.formattedDuration} • ${lesson.difficulty.name}',
      leading: IconButton(
        onPressed: onBackPressed,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      actions: [
        // Lesson type icon
        Container(
          margin: const EdgeInsets.only(right: DesignTokens.spaceS),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Color(
              int.parse(lesson.difficultyColor.substring(1), radix: 16) |
                  0xFF000000,
            ).withValues(alpha: 0.2),
            child: Text(lesson.typeIcon, style: const TextStyle(fontSize: 16)),
          ),
        ),

        // More options
        PopupMenuButton<String>(
          onSelected: (value) => onMenuAction(value, lesson),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'bookmark',
              child: Row(
                children: [
                  Icon(Icons.bookmark_add_rounded),
                  SizedBox(width: 8),
                  Text('Bookmark'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share_rounded),
                  SizedBox(width: 8),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.report_rounded),
                  SizedBox(width: 8),
                  Text('Report Issue'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
