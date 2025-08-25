import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../config/design_tokens.dart';
import '../auth/glassmorphic_container.dart';

/// Modern subject card component with glassmorphic design
class SubjectCard extends StatefulWidget {
  const SubjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.progress = 0.0,
    this.lessonCount = 0,
    this.completedLessons = 0,
    this.onTap,
    this.isSelected = false,
    this.showProgress = true,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final double progress;
  final int lessonCount;
  final int completedLessons;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showProgress;

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.animationFast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _elevationAnimation = Tween<double>(begin: 4.0, end: 8.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.2),
                  blurRadius: _elevationAnimation.value,
                  offset: Offset(0, _elevationAnimation.value / 2),
                ),
              ],
            ),
            child: GlassmorphicCard(
              onTap: widget.onTap != null ? _handleTap : null,
              padding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isSelected
                        ? [
                            widget.color.withValues(alpha: 0.3),
                            widget.color.withValues(alpha: 0.1),
                          ]
                        : [
                            colorScheme.surface.withValues(alpha: 0.1),
                            colorScheme.surface.withValues(alpha: 0.05),
                          ],
                  ),
                  border: Border.all(
                    color: widget.isSelected
                        ? widget.color
                        : colorScheme.outline.withValues(alpha: 0.2),
                    width: widget.isSelected ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spaceL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with icon and title
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: widget.color.withValues(
                                alpha: widget.isSelected ? 1.0 : 0.1,
                              ),
                              borderRadius: BorderRadius.circular(
                                DesignTokens.radiusM,
                              ),
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.isSelected
                                  ? Colors.white
                                  : widget.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spaceM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: widget.isSelected
                                            ? widget.color
                                            : colorScheme.onSurface,
                                      ),
                                ),
                                if (widget.showProgress &&
                                    widget.lessonCount > 0)
                                  Text(
                                    '${widget.completedLessons}/${widget.lessonCount} lessons',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.spaceM),

                      // Description
                      Text(
                        widget.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (widget.showProgress) ...[
                        const SizedBox(height: DesignTokens.spaceM),
                        // Progress indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusXS,
                          ),
                          child: LinearProgressIndicator(
                            value: widget.progress,
                            backgroundColor: colorScheme.outline.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.color,
                            ),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spaceS),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(widget.progress * 100).round()}% Complete',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: widget.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            if (widget.progress > 0)
                              Icon(
                                Icons.trending_up,
                                color: widget.color,
                                size: 16,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTap() {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
      setState(() {
        _isPressed = false;
      });
    });
    widget.onTap?.call();
  }
}

/// Lesson card component for displaying individual lessons
class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.title,
    required this.description,
    required this.duration,
    required this.difficulty,
    this.isCompleted = false,
    this.isLocked = false,
    this.completionPercentage = 0.0,
    this.onTap,
    this.thumbnailUrl,
  });

  final String title;
  final String description;
  final String duration;
  final String difficulty;
  final bool isCompleted;
  final bool isLocked;
  final double completionPercentage;
  final VoidCallback? onTap;
  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassmorphicCard(
      onTap: isLocked ? null : onTap,
      child: Row(
        children: [
          // Thumbnail or icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isLocked
                    ? [
                        colorScheme.outline.withValues(alpha: 0.3),
                        colorScheme.outline.withValues(alpha: 0.1),
                      ]
                    : [
                        DesignTokens.primary.withValues(alpha: 0.3),
                        DesignTokens.accent.withValues(alpha: 0.1),
                      ],
              ),
            ),
            child: Icon(
              isLocked
                  ? Icons.lock_outline
                  : isCompleted
                  ? Icons.check_circle_outline
                  : Icons.play_circle_outline,
              color: isLocked
                  ? colorScheme.outline
                  : isCompleted
                  ? DesignTokens.success
                  : DesignTokens.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: DesignTokens.spaceM),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isLocked
                              ? colorScheme.onSurface.withValues(alpha: 0.5)
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                    _buildDifficultyChip(context),
                  ],
                ),
                const SizedBox(height: DesignTokens.spaceXS),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(
                      alpha: isLocked ? 0.4 : 0.7,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: DesignTokens.spaceS),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: DesignTokens.spaceXS),
                    Text(
                      duration,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (completionPercentage > 0 && !isCompleted) ...[
                      const Spacer(),
                      Text(
                        '${(completionPercentage * 100).round()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: DesignTokens.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                if (completionPercentage > 0 && !isCompleted) ...[
                  const SizedBox(height: DesignTokens.spaceXS),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                    child: LinearProgressIndicator(
                      value: completionPercentage,
                      backgroundColor: colorScheme.outline.withValues(
                        alpha: 0.2,
                      ),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        DesignTokens.primary,
                      ),
                      minHeight: 3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(BuildContext context) {
    Color chipColor;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        chipColor = DesignTokens.success;
        break;
      case 'medium':
        chipColor = DesignTokens.warning;
        break;
      case 'hard':
        chipColor = DesignTokens.error;
        break;
      default:
        chipColor = DesignTokens.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceS,
        vertical: DesignTokens.spaceXS,
      ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
      ),
      child: Text(
        difficulty,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: chipColor,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }
}

/// Progress card component for displaying learning statistics
class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.trend,
    this.trendValue,
    this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? trend; // 'up', 'down', 'neutral'
  final String? trendValue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassmorphicCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (trend != null && trendValue != null)
                _buildTrendIndicator(context),
            ],
          ),
          const SizedBox(height: DesignTokens.spaceM),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXS),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator(BuildContext context) {
    Color trendColor;
    IconData trendIcon;

    switch (trend) {
      case 'up':
        trendColor = DesignTokens.success;
        trendIcon = Icons.trending_up;
        break;
      case 'down':
        trendColor = DesignTokens.error;
        trendIcon = Icons.trending_down;
        break;
      default:
        trendColor = Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.6);
        trendIcon = Icons.trending_flat;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceS,
        vertical: DesignTokens.spaceXS,
      ),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trendIcon, color: trendColor, size: 12),
          const SizedBox(width: DesignTokens.spaceXS),
          Text(
            trendValue!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: trendColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Achievement card component for displaying badges and milestones
class AchievementCard extends StatefulWidget {
  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.progress = 0.0,
    this.maxProgress = 100,
    this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final double progress;
  final int maxProgress;
  final VoidCallback? onTap;

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _shineAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    if (widget.isUnlocked) {
      _shineController.repeat(period: const Duration(seconds: 3));
    }
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassmorphicCard(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Column(
            children: [
              // Badge icon with shine effect for unlocked achievements
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.isUnlocked
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.color,
                            widget.color.withValues(alpha: 0.6),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            colorScheme.outline.withValues(alpha: 0.3),
                            colorScheme.outline.withValues(alpha: 0.1),
                          ],
                        ),
                  boxShadow: widget.isUnlocked
                      ? [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isUnlocked ? Colors.white : colorScheme.outline,
                  size: 28,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceM),

              // Title and description
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.isUnlocked
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DesignTokens.spaceXS),
              Text(
                widget.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Progress for locked achievements
              if (!widget.isUnlocked && widget.progress > 0) ...[
                const SizedBox(height: DesignTokens.spaceM),
                ClipRRect(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                  child: LinearProgressIndicator(
                    value: widget.progress / widget.maxProgress,
                    backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXS),
                Text(
                  '${widget.progress.toInt()}/${widget.maxProgress}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),

          // Shine effect for unlocked achievements
          if (widget.isUnlocked)
            AnimatedBuilder(
              animation: _shineAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    child: Transform.translate(
                      offset: Offset(_shineAnimation.value * 200, 0),
                      child: Transform.rotate(
                        angle: math.pi / 6,
                        child: Container(
                          width: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
