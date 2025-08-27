import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../config/design_tokens.dart';

/// Markdown renderer for lesson content
class MarkdownRenderer extends StatelessWidget {
  const MarkdownRenderer({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _parseMarkdown(context, content),
    );
  }

  List<Widget> _parseMarkdown(BuildContext context, String content) {
    final document = md.Document(extensionSet: md.ExtensionSet.gitHubFlavored);
    final nodes = document.parseLines(content.split('\n'));

    return nodes.map((node) => _buildNode(context, node)).toList();
  }

  Widget _buildNode(BuildContext context, md.Node node) {
    if (node is md.Element) {
      switch (node.tag) {
        case 'h1':
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceM),
            child: Text(
              node.textContent,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: DesignTokens.primary,
              ),
            ),
          );
        case 'h2':
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceM),
            child: Text(
              node.textContent,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: DesignTokens.primary,
              ),
            ),
          );
        case 'h3':
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceS),
            child: Text(
              node.textContent,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: DesignTokens.primary,
              ),
            ),
          );
        case 'p':
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceS),
            child: Text(
              node.textContent,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        case 'ul':
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  node.children?.map((child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8, right: 8),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: DesignTokens.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              child.textContent,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList() ??
                  [],
            ),
          );
        case 'blockquote':
          return Container(
            margin: const EdgeInsets.symmetric(vertical: DesignTokens.spaceM),
            padding: const EdgeInsets.all(DesignTokens.spaceM),
            decoration: BoxDecoration(
              color: DesignTokens.primary.withValues(alpha: 0.05),
              border: Border(
                left: BorderSide(color: DesignTokens.primary, width: 4),
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(DesignTokens.radiusM),
                bottomRight: Radius.circular(DesignTokens.radiusM),
              ),
            ),
            child: Text(
              node.textContent,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: DesignTokens.primary,
                height: 1.5,
              ),
            ),
          );
        case 'code':
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              node.textContent,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                color: DesignTokens.primary,
              ),
            ),
          );
        default:
          return Text(
            node.textContent,
            style: Theme.of(context).textTheme.bodyMedium,
          );
      }
    }

    return Text(
      node.textContent,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
