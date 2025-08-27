import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/design_tokens.dart';

/// Widget for displaying code content with syntax highlighting
class CodeSectionWidget extends StatelessWidget {
  const CodeSectionWidget({
    super.key,
    required this.content,
    required this.language,
    required this.onProgressUpdate,
  });

  final String content;
  final String language;
  final VoidCallback onProgressUpdate;

  @override
  Widget build(BuildContext context) {
    // Notify progress immediately for code sections
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onProgressUpdate();
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language header with copy button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceS,
                  vertical: DesignTokens.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
                child: Text(
                  language.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: DesignTokens.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _copyToClipboard(context),
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'Copy code',
                style: IconButton.styleFrom(
                  backgroundColor: DesignTokens.primary.withValues(alpha: 0.1),
                  foregroundColor: DesignTokens.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: DesignTokens.spaceS),

          // Code content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DesignTokens.spaceM),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: SelectableText(
              content,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: DesignTokens.spaceM),

          // Code explanation or notes (if any)
          Text(
            'Tap and hold to select code, or use the copy button above.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Code copied to clipboard'),
        backgroundColor: DesignTokens.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
