import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../../domain/entities/message.dart';
import '../../../domain/entities/conversation.dart';
import '../../../data/providers/chat_provider.dart';

/// Search widget for finding messages in conversations
class MessageSearchWidget extends ConsumerStatefulWidget {
  final Function(Message, Conversation)? onMessageTap;
  final VoidCallback? onClose;
  
  const MessageSearchWidget({
    super.key,
    this.onMessageTap,
    this.onClose,
  });
  
  @override
  ConsumerState<MessageSearchWidget> createState() => _MessageSearchWidgetState();
}

class _MessageSearchWidgetState extends ConsumerState<MessageSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _searchTimer;
  String _searchQuery = '';
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  
  late ChatNotifier _chatNotifier;
  
  @override
  void initState() {
    super.initState();
    _chatNotifier = ref.read(chatProvider.notifier);
    _searchFocus.requestFocus();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }
  
  void _onSearchChanged() {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.trim();
      if (query != _searchQuery) {
        setState(() {
          _searchQuery = query;
          _isSearching = query.isNotEmpty;
        });
        if (query.isNotEmpty) {
          _performSearch(query);
        } else {
          setState(() {
            _searchResults.clear();
          });
        }
      }
    });
  }
  
  void _performSearch(String query) async {
    final results = <SearchResult>[];
    final lowercaseQuery = query.toLowerCase();
    
    // Get conversations from the chat provider
    final conversations = ref.read(chatProvider).conversations;
    
    for (final conversation in conversations) {
      try {
        // Load messages for this conversation
        final messages = await _chatNotifier.loadMessagesForConversation(conversation.id);
        
        for (final message in messages) {
          if (message.content.toLowerCase().contains(lowercaseQuery)) {
            // Find the position of the match for highlighting
            final contentLower = message.content.toLowerCase();
            final matchIndex = contentLower.indexOf(lowercaseQuery);
            
            results.add(SearchResult(
              message: message,
              conversation: conversation,
              matchIndex: matchIndex,
              matchLength: query.length,
            ));
          }
          
          // Also search in sender name (which includes AI personalities)
          if (message.senderName.toLowerCase().contains(lowercaseQuery)) {
            results.add(SearchResult(
              message: message,
              conversation: conversation,
              matchIndex: -1, // Special case for sender name match
              matchLength: query.length,
            ));
          }
        }
      } catch (e) {
        // Skip conversations that fail to load
        continue;
      }
    }
    
    // Sort results by most recent first
    results.sort((a, b) => b.message.timestamp.compareTo(a.message.timestamp));
    
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          decoration: InputDecoration(
            hintText: 'Search messages...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          style: theme.textTheme.titleMedium,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _searchResults.clear();
                  _isSearching = false;
                });
              },
            ),
        ],
      ),
      body: _buildSearchBody(context),
    );
  }
  
  Widget _buildSearchBody(BuildContext context) {
    if (_searchQuery.isEmpty) {
      return _buildEmptyState(context);
    }
    
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_searchResults.isEmpty) {
      return _buildNoResultsState(context);
    }
    
    return _buildSearchResults(context);
  }
  
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Search Messages',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Type to search through your conversations',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoResultsState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Results Found',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or check your spelling',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return SearchResultItem(
          result: result,
          searchQuery: _searchQuery,
          onTap: () {
            widget.onMessageTap?.call(result.message, result.conversation);
            widget.onClose?.call();
          },
        );
      },
    );
  }
}

/// Individual search result item
class SearchResultItem extends StatelessWidget {
  final SearchResult result;
  final String searchQuery;
  final VoidCallback? onTap;
  
  const SearchResultItem({
    super.key,
    required this.result,
    required this.searchQuery,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = result.message;
    final conversation = result.conversation;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Conversation info
              Row(
                children: [
                  Icon(
                    conversation.type == ConversationType.group ? Icons.group : Icons.chat,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      conversation.title.isNotEmpty ? conversation.title : 'Conversation',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDate(message.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Sender info
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: message.isFromHelpy 
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.secondaryContainer,
                    child: Icon(
                      message.isFromHelpy ? Icons.smart_toy : Icons.person,
                      size: 16,
                      color: message.isFromHelpy
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    message.senderName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Message content with highlighting
              _buildHighlightedContent(context),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHighlightedContent(BuildContext context) {
    final theme = Theme.of(context);
    final message = result.message;
    final content = message.content;
    
    // Handle AI personality name match
    if (result.matchIndex == -1) {
      return Text(
        content.length > 150 ? '${content.substring(0, 150)}...' : content,
        style: theme.textTheme.bodyMedium,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      );
    }
    
    // Extract snippet around the match
    final matchStart = result.matchIndex;
    final matchEnd = matchStart + result.matchLength;
    
    // Calculate snippet bounds
    final snippetStart = (matchStart - 50).clamp(0, content.length);
    final snippetEnd = (matchEnd + 50).clamp(0, content.length);
    
    final beforeMatch = content.substring(snippetStart, matchStart);
    final match = content.substring(matchStart, matchEnd);
    final afterMatch = content.substring(matchEnd, snippetEnd);
    
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium,
        children: [
          if (snippetStart > 0) const TextSpan(text: '...'),
          TextSpan(text: beforeMatch),
          TextSpan(
            text: match,
            style: TextStyle(
              backgroundColor: theme.colorScheme.primaryContainer,
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: afterMatch),
          if (snippetEnd < content.length) const TextSpan(text: '...'),
        ],
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Search result data model
class SearchResult {
  final Message message;
  final Conversation conversation;
  final int matchIndex;
  final int matchLength;
  
  const SearchResult({
    required this.message,
    required this.conversation,
    required this.matchIndex,
    required this.matchLength,
  });
}

/// Search bar widget for embedding in other screens
class MessageSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final String? hintText;
  
  const MessageSearchBar({
    super.key,
    this.onTap,
    this.hintText,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hintText ?? 'Search messages...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}