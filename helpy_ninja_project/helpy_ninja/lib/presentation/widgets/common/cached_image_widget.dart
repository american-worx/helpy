import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/image_cache_service.dart';
import '../../../config/constants.dart';

/// Optimized cached image widget with progressive loading
class CachedImageWidget extends StatefulWidget {
  /// Image URL or asset path
  final String imageUrl;
  
  /// Target width for optimization
  final int? width;
  
  /// Target height for optimization  
  final int? height;
  
  /// Image quality (1-100)
  final int quality;
  
  /// Widget to show while loading
  final Widget? placeholder;
  
  /// Widget to show on error
  final Widget? errorWidget;
  
  /// How the image should be inscribed into the space
  final BoxFit fit;
  
  /// Alignment of the image
  final Alignment alignment;
  
  /// Color to blend with the image
  final Color? color;
  
  /// Blend mode for color
  final BlendMode? colorBlendMode;
  
  /// Semantic label for accessibility
  final String? semanticLabel;
  
  /// Whether to exclude from semantics
  final bool excludeFromSemantics;
  
  /// Filter quality
  final FilterQuality filterQuality;
  
  /// Enable progressive loading effect
  final bool enableProgressiveLoading;
  
  /// Duration for fade-in animation
  final Duration fadeInDuration;
  
  /// Border radius
  final BorderRadius? borderRadius;
  
  /// Custom error builder
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  
  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.quality = 85,
    this.placeholder,
    this.errorWidget,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.color,
    this.colorBlendMode,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.filterQuality = FilterQuality.low,
    this.enableProgressiveLoading = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.borderRadius,
    this.errorBuilder,
  });
  
  @override
  State<CachedImageWidget> createState() => _CachedImageWidgetState();
}

class _CachedImageWidgetState extends State<CachedImageWidget>
    with SingleTickerProviderStateMixin {
  Uint8List? _imageData;
  bool _isLoading = true;
  Object? _error;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: widget.fadeInDuration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _loadImage();
  }
  
  @override
  void didUpdateWidget(CachedImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.width != widget.width ||
        oldWidget.height != widget.height ||
        oldWidget.quality != widget.quality) {
      _loadImage();
    }
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
  
  Future<void> _loadImage() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
      _imageData = null;
    });
    
    // Check if image loading is disabled for development
    if (!AppConstants.enableImageLoading) {
      setState(() {
        _isLoading = false;
        _error = 'Image loading disabled for development';
      });
      return;
    }
    
    try {
      // Reset animation
      _fadeController.reset();
      
      // Load image from cache or network
      final imageData = await ImageCacheService.getCachedImage(
        widget.imageUrl,
        maxWidth: widget.width,
        maxHeight: widget.height,
        quality: widget.quality,
      );
      
      if (!mounted) return;
      
      if (imageData != null) {
        setState(() {
          _imageData = imageData;
          _isLoading = false;
        });
        
        // Start fade-in animation
        if (widget.enableProgressiveLoading) {
          _fadeController.forward();
        }
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load image';
        });
      }
    } catch (error) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _error = error;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    Widget child;
    
    if (_isLoading) {
      child = _buildPlaceholder(context);
    } else if (_error != null) {
      child = _buildErrorWidget(context);
    } else if (_imageData != null) {
      child = _buildImage(context);
    } else {
      child = _buildPlaceholder(context);
    }
    
    // Apply border radius if specified
    if (widget.borderRadius != null) {
      child = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: child,
      );
    }
    
    return child;
  }
  
  Widget _buildImage(BuildContext context) {
    final image = Image.memory(
      _imageData!,
      fit: widget.fit,
      alignment: widget.alignment,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
      filterQuality: widget.filterQuality,
      width: widget.width?.toDouble(),
      height: widget.height?.toDouble(),
    );
    
    if (widget.enableProgressiveLoading) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: image,
      );
    }
    
    return image;
  }
  
  Widget _buildPlaceholder(BuildContext context) {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }
    
    return Container(
      width: widget.width?.toDouble(),
      height: widget.height?.toDouble(),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  Widget _buildErrorWidget(BuildContext context) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _error!);
    }
    
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }
    
    return Container(
      width: widget.width?.toDouble(),
      height: widget.height?.toDouble(),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Theme.of(context).colorScheme.onErrorContainer,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Image failed to load',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Optimized avatar widget with caching
class CachedAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? child;
  final VoidCallback? onTap;
  
  const CachedAvatarWidget({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 20,
    this.backgroundColor,
    this.foregroundColor,
    this.child,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget avatar;
    
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Use cached image
      avatar = CachedImageWidget(
        imageUrl: imageUrl!,
        width: (radius * 2).round(),
        height: (radius * 2).round(),
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(radius),
        placeholder: _buildInitials(context, theme),
        errorWidget: _buildInitials(context, theme),
      );
    } else if (child != null) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
        child: child,
      );
    } else {
      avatar = _buildInitials(context, theme);
    }
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }
    
    return avatar;
  }
  
  Widget _buildInitials(BuildContext context, ThemeData theme) {
    String initials = '';
    if (name != null && name!.isNotEmpty) {
      final words = name!.split(' ');
      if (words.isNotEmpty) {
        initials = words[0][0].toUpperCase();
        if (words.length > 1) {
          initials += words[1][0].toUpperCase();
        }
      }
    }
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? _generateColorFromName(name ?? ''),
      foregroundColor: foregroundColor ?? Colors.white,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: radius * 0.6,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  Color _generateColorFromName(String name) {
    if (name.isEmpty) return Colors.grey;
    
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];
    
    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }
}

/// Grid of cached images with progressive loading
class CachedImageGrid extends StatelessWidget {
  final List<String> imageUrls;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final int? maxDisplayCount;
  final Widget Function(String imageUrl, int index)? itemBuilder;
  
  const CachedImageGrid({
    super.key,
    required this.imageUrls,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 4.0,
    this.mainAxisSpacing = 4.0,
    this.padding,
    this.maxDisplayCount,
    this.itemBuilder,
  });
  
  @override
  Widget build(BuildContext context) {
    final displayUrls = maxDisplayCount != null
        ? imageUrls.take(maxDisplayCount!).toList()
        : imageUrls;
    
    if (displayUrls.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: displayUrls.length,
      itemBuilder: (context, index) {
        final imageUrl = displayUrls[index];
        
        if (itemBuilder != null) {
          return itemBuilder!(imageUrl, index);
        }
        
        return CachedImageWidget(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(8),
        );
      },
    );
  }
}