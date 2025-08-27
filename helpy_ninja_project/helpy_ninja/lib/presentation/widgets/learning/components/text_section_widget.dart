import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../config/design_tokens.dart';
import 'markdown_renderer.dart';

/// Widget for displaying text/markdown content in lessons
class TextSectionWidget extends StatefulWidget {
  const TextSectionWidget({
    super.key,
    required this.content,
    required this.onProgressUpdate,
  });

  final String content;
  final VoidCallback onProgressUpdate;

  @override
  State<TextSectionWidget> createState() => _TextSectionWidgetState();
}

class _TextSectionWidgetState extends State<TextSectionWidget> {
  late ScrollController _scrollController;
  bool _hasNotifiedProgress = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_hasNotifiedProgress && _scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;

      // Consider section read when scrolled 80% through
      if (maxScroll > 0 && currentScroll / maxScroll > 0.8) {
        _hasNotifiedProgress = true;
        widget.onProgressUpdate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarkdownRenderer(content: widget.content),

          // Add some bottom padding for better UX
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
