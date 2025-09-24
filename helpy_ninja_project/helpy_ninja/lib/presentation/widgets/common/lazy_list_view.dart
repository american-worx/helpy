import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Generic lazy loading list view for large data sets
class LazyListView<T> extends ConsumerStatefulWidget {
  /// Function to load data items
  final Future<List<T>> Function(int page, int pageSize) loadItems;
  
  /// Builder for individual list items
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  
  /// Builder for loading indicator
  final Widget Function(BuildContext context)? loadingBuilder;
  
  /// Builder for error state
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  
  /// Builder for empty state
  final Widget Function(BuildContext context)? emptyBuilder;
  
  /// Page size for lazy loading
  final int pageSize;
  
  /// Threshold for triggering load (items from bottom)
  final int loadThreshold;
  
  /// Whether to show loading indicator at bottom
  final bool showBottomLoader;
  
  /// List separator builder
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  
  /// Scroll controller (optional)
  final ScrollController? controller;
  
  /// List padding
  final EdgeInsetsGeometry? padding;
  
  /// Physics for scroll view
  final ScrollPhysics? physics;
  
  /// Initial items (optional)
  final List<T>? initialItems;
  
  /// Refresh callback for pull-to-refresh
  final Future<void> Function()? onRefresh;
  
  const LazyListView({
    super.key,
    required this.loadItems,
    required this.itemBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.pageSize = 20,
    this.loadThreshold = 5,
    this.showBottomLoader = true,
    this.separatorBuilder,
    this.controller,
    this.padding,
    this.physics,
    this.initialItems,
    this.onRefresh,
  });
  
  @override
  ConsumerState<LazyListView<T>> createState() => _LazyListViewState<T>();
}

class _LazyListViewState<T> extends ConsumerState<LazyListView<T>> {
  final List<T> _items = [];
  late ScrollController _scrollController;
  
  bool _isLoading = false;
  bool _hasError = false;
  bool _hasMore = true;
  Object? _error;
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Add initial items if provided
    if (widget.initialItems != null) {
      _items.addAll(widget.initialItems!);
    } else {
      _loadInitialData();
    }
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }
  
  Future<void> _loadInitialData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _error = null;
    });
    
    try {
      final newItems = await widget.loadItems(0, widget.pageSize);
      
      setState(() {
        _items.clear();
        _items.addAll(newItems);
        _currentPage = 1;
        _hasMore = newItems.length >= widget.pageSize;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _hasError = true;
        _error = error;
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final newItems = await widget.loadItems(_currentPage, widget.pageSize);
      
      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _hasMore = newItems.length >= widget.pageSize;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        // Don't show error for load more, just stop loading
      });
      
      // Show snackbar for load more errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more items: ${error.toString()}'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadMoreData,
            ),
          ),
        );
      }
    }
  }
  
  Future<void> _refresh() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    } else {
      await _loadInitialData();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Error state
    if (_hasError && _items.isEmpty) {
      return _buildErrorState();
    }
    
    // Loading state (initial)
    if (_isLoading && _items.isEmpty) {
      return _buildLoadingState();
    }
    
    // Empty state
    if (_items.isEmpty && !_isLoading) {
      return _buildEmptyState();
    }
    
    // List view
    return _buildListView();
  }
  
  Widget _buildLoadingState() {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context);
    }
    
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  Widget _buildErrorState() {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _error!);
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _error.toString(),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    if (widget.emptyBuilder != null) {
      return widget.emptyBuilder!(context);
    }
    
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildListView() {
    final itemCount = _items.length + (_hasMore && widget.showBottomLoader ? 1 : 0);
    
    Widget listView;
    
    if (widget.separatorBuilder != null) {
      listView = ListView.separated(
        controller: _scrollController,
        padding: widget.padding,
        physics: widget.physics,
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return widget.itemBuilder(context, _items[index], index);
        },
        separatorBuilder: widget.separatorBuilder!,
      );
    } else {
      listView = ListView.builder(
        controller: _scrollController,
        padding: widget.padding,
        physics: widget.physics,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Bottom loader
          if (index >= _items.length) {
            return _buildBottomLoader();
          }
          
          // Regular item
          return widget.itemBuilder(context, _items[index], index);
        },
      );
    }
    
    // Add pull to refresh if callback is provided
    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: listView,
      );
    }
    
    return listView;
  }
  
  Widget _buildBottomLoader() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: _isLoading
          ? const CircularProgressIndicator()
          : const SizedBox.shrink(),
    );
  }
}

/// Lazy loading grid view for large data sets
class LazyGridView<T> extends ConsumerStatefulWidget {
  /// Function to load data items
  final Future<List<T>> Function(int page, int pageSize) loadItems;
  
  /// Builder for individual grid items
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  
  /// Grid delegate for layout
  final SliverGridDelegate gridDelegate;
  
  /// Builder for loading indicator
  final Widget Function(BuildContext context)? loadingBuilder;
  
  /// Builder for error state
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  
  /// Builder for empty state
  final Widget Function(BuildContext context)? emptyBuilder;
  
  /// Page size for lazy loading
  final int pageSize;
  
  /// Scroll controller (optional)
  final ScrollController? controller;
  
  /// Grid padding
  final EdgeInsetsGeometry? padding;
  
  /// Physics for scroll view
  final ScrollPhysics? physics;
  
  /// Initial items (optional)
  final List<T>? initialItems;
  
  /// Refresh callback for pull-to-refresh
  final Future<void> Function()? onRefresh;
  
  const LazyGridView({
    super.key,
    required this.loadItems,
    required this.itemBuilder,
    required this.gridDelegate,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.pageSize = 20,
    this.controller,
    this.padding,
    this.physics,
    this.initialItems,
    this.onRefresh,
  });
  
  @override
  ConsumerState<LazyGridView<T>> createState() => _LazyGridViewState<T>();
}

class _LazyGridViewState<T> extends ConsumerState<LazyGridView<T>> {
  final List<T> _items = [];
  late ScrollController _scrollController;
  
  bool _isLoading = false;
  bool _hasError = false;
  bool _hasMore = true;
  Object? _error;
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Add initial items if provided
    if (widget.initialItems != null) {
      _items.addAll(widget.initialItems!);
    } else {
      _loadInitialData();
    }
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }
  
  Future<void> _loadInitialData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _error = null;
    });
    
    try {
      final newItems = await widget.loadItems(0, widget.pageSize);
      
      setState(() {
        _items.clear();
        _items.addAll(newItems);
        _currentPage = 1;
        _hasMore = newItems.length >= widget.pageSize;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _hasError = true;
        _error = error;
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final newItems = await widget.loadItems(_currentPage, widget.pageSize);
      
      setState(() {
        _items.addAll(newItems);
        _currentPage++;
        _hasMore = newItems.length >= widget.pageSize;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      
      // Show snackbar for load more errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load more items: ${error.toString()}'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadMoreData,
            ),
          ),
        );
      }
    }
  }
  
  Future<void> _refresh() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    } else {
      await _loadInitialData();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Error state
    if (_hasError && _items.isEmpty) {
      return _buildErrorState();
    }
    
    // Loading state (initial)
    if (_isLoading && _items.isEmpty) {
      return _buildLoadingState();
    }
    
    // Empty state
    if (_items.isEmpty && !_isLoading) {
      return _buildEmptyState();
    }
    
    // Grid view
    return _buildGridView();
  }
  
  Widget _buildLoadingState() {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context);
    }
    
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  
  Widget _buildErrorState() {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _error!);
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load data',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _error.toString(),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    if (widget.emptyBuilder != null) {
      return widget.emptyBuilder!(context);
    }
    
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grid_view,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGridView() {
    Widget gridView = CustomScrollView(
      controller: _scrollController,
      physics: widget.physics,
      slivers: [
        SliverPadding(
          padding: widget.padding ?? EdgeInsets.zero,
          sliver: SliverGrid(
            gridDelegate: widget.gridDelegate,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return widget.itemBuilder(context, _items[index], index);
              },
              childCount: _items.length,
            ),
          ),
        ),
        if (_hasMore && _isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
    
    // Add pull to refresh if callback is provided
    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: gridView,
      );
    }
    
    return gridView;
  }
}