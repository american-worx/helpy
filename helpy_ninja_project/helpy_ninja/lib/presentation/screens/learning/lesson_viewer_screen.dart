import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../config/design_tokens.dart';
import '../../../data/providers/learning_session_provider.dart';
import '../../../data/providers/providers.dart';
import '../../../domain/entities/lesson.dart';
import '../../../domain/entities/learning_session.dart';
import '../../widgets/navigation/modern_navigation.dart';
import '../../widgets/layout/modern_layout.dart';
import '../../widgets/common/gradient_button.dart';

/// Lesson viewer screen with content display and navigation
class LessonViewerScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonViewerScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonViewerScreen> createState() => _LessonViewerScreenState();
}

class _LessonViewerScreenState extends ConsumerState<LessonViewerScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  PageController? _pageController;
  LearningSession? _currentSession;
  int _currentSectionIndex = 0;
  double _readingProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pageController = PageController();
    _fadeAnimationController.forward();

    // Start learning session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLearningSession();
    });
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _progressAnimationController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  void _startLearningSession() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      final session = await ref
          .read(learningSessionProvider.notifier)
          .startLearningSession(
            userId: user.id,
            lessonId: widget.lessonId,
            type: SessionType.lesson,
          );

      setState(() {
        _currentSession = session;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start lesson: $e'),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = ref.watch(lessonProvider(widget.lessonId));
    // final progress = ref.watch(userProgressProvider(widget.lessonId));

    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson')),
        body: const Center(child: Text('Lesson not found')),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context, lesson),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(lesson),

            // Content area
            Expanded(
              child: lesson.sections.isNotEmpty
                  ? _buildSectionBasedContent(lesson)
                  : _buildTextContent(lesson),
            ),

            // Navigation controls
            _buildNavigationControls(lesson),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Lesson lesson) {
    return ModernAppBar(
      title: lesson.title,
      subtitle: '${lesson.formattedDuration} • ${lesson.difficulty.name}',
      leading: IconButton(
        onPressed: () => _handleBackPress(),
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
          onSelected: (value) => _handleMenuAction(value, lesson),
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

  Widget _buildProgressIndicator(Lesson lesson) {
    final totalSections = lesson.sections.isNotEmpty
        ? lesson.sections.length
        : 1;
    final progressValue =
        ((_currentSectionIndex + _readingProgress) / totalSections).clamp(
          0.0,
          1.0,
        );

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '${(progressValue * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: DesignTokens.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Space.s,
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: progressValue * _progressAnimation.value,
                backgroundColor: DesignTokens.primary.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(DesignTokens.primary),
                minHeight: 6,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionBasedContent(Lesson lesson) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentSectionIndex = index;
          _readingProgress = 0.0;
        });
        _updateProgress();
      },
      itemCount: lesson.sections.length,
      itemBuilder: (context, index) {
        final section = lesson.sections[index];
        return _buildSectionContent(section);
      },
    );
  }

  Widget _buildSectionContent(LessonSection section) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: ModernSection(
        showGlassmorphism: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Text(
              section.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: DesignTokens.primary,
              ),
            ),
            Space.l,

            // Section content based on type
            _buildSectionContentByType(section),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContentByType(LessonSection section) {
    switch (section.type) {
      case LessonSectionType.text:
        return _buildTextSection(section.content);
      case LessonSectionType.code:
        return _buildCodeSection(section.content);
      case LessonSectionType.image:
        return _buildImageSection(section.content);
      case LessonSectionType.video:
        return _buildVideoSection(section.content);
      default:
        return _buildTextSection(section.content);
    }
  }

  Widget _buildTextSection(String content) {
    return MarkdownBody(
      data: content,
      styleSheet: MarkdownStyleSheet(
        p: Theme.of(context).textTheme.bodyLarge,
        h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: DesignTokens.primary,
        ),
        h2: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: DesignTokens.primary,
        ),
        h3: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        listBullet: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: DesignTokens.accent),
      ),
      onTapLink: (text, href, title) {
        // Handle link taps
        if (href != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Would open: $href')));
        }
      },
    );
  }

  Widget _buildCodeSection(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        content,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
      ),
    );
  }

  Widget _buildImageSection(String imagePath) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_rounded, size: 48),
            SizedBox(height: 8),
            Text('Image placeholder'),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSection(String videoPath) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline_rounded, size: 64),
            SizedBox(height: 8),
            Text('Video player placeholder'),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContent(Lesson lesson) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: ModernSection(
        showGlassmorphism: true,
        child: _buildTextSection(lesson.content),
      ),
    );
  }

  Widget _buildNavigationControls(Lesson lesson) {
    final hasSection = lesson.sections.isNotEmpty;
    final isFirstSection = _currentSectionIndex == 0;
    final isLastSection = hasSection
        ? _currentSectionIndex == lesson.sections.length - 1
        : true;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: Row(
        children: [
          // Previous button
          if (hasSection && !isFirstSection)
            Expanded(
              child: OutlineButton(
                onPressed: _goToPreviousSection,
                text: 'Previous',
                icon: Icons.arrow_back_rounded,
              ),
            ),

          if (hasSection && !isFirstSection && !isLastSection)
            const SizedBox(width: DesignTokens.spaceM),

          // Next/Complete button
          Expanded(
            child: isLastSection
                ? GradientButton(
                    onPressed: _completeLesson,
                    text: 'Complete Lesson',
                    icon: Icons.check_rounded,
                  )
                : GradientButton(
                    onPressed: _goToNextSection,
                    text: 'Next',
                    icon: Icons.arrow_forward_rounded,
                  ),
          ),
        ],
      ),
    );
  }

  void _goToPreviousSection() {
    if (_currentSectionIndex > 0) {
      _pageController?.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextSection() {
    final lesson = ref.read(lessonProvider(widget.lessonId));
    if (lesson != null && _currentSectionIndex < lesson.sections.length - 1) {
      _pageController?.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    _updateProgress();
  }

  void _updateProgress() {
    final lesson = ref.read(lessonProvider(widget.lessonId));
    if (lesson == null) return;

    final totalSections = lesson.sections.isNotEmpty
        ? lesson.sections.length
        : 1;
    final progress = ((_currentSectionIndex + 1) / totalSections * 100).clamp(
      0.0,
      100.0,
    );

    _progressAnimationController.forward();

    // Update session progress if exists
    if (_currentSession != null) {
      // In a real app, you would call the provider to update session progress
    }
  }

  void _completeLesson() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _currentSession == null) return;

    try {
      final score = SessionScore(
        totalScore: 100.0,
        maxScore: 100.0,
        timeToComplete: DateTime.now().difference(_currentSession!.startedAt),
      );

      await ref
          .read(learningSessionProvider.notifier)
          .completeSession(_currentSession!.id, score);

      if (mounted) {
        _showCompletionDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete lesson: $e'),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration_rounded, color: DesignTokens.accent),
            SizedBox(width: 8),
            Text('Lesson Complete!'),
          ],
        ),
        content: const Text(
          'Congratulations! You have successfully completed this lesson. Keep up the great work!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Continue Learning'),
          ),
        ],
      ),
    );
  }

  void _handleBackPress() {
    // Show confirmation if lesson is in progress
    if (_currentSession?.status == SessionStatus.active) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Leave Lesson?'),
          content: const Text(
            'Your progress will be saved, but you will need to restart the lesson next time.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              child: const Text('Leave'),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }

  void _handleMenuAction(String action, Lesson lesson) {
    switch (action) {
      case 'bookmark':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lesson bookmarked!')));
        break;
      case 'share':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sharing "${lesson.title}"')));
        break;
      case 'report':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Report submitted')));
        break;
    }
  }
}
