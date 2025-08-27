import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

import '../../../config/design_tokens.dart';
import '../../../data/providers/learning_session_provider.dart';
import '../../../data/providers/providers.dart';
import '../../../domain/entities/lesson.dart';
import '../../../domain/entities/learning_session.dart';
import '../../widgets/learning/learning_components.dart';

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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.lessonStartFailed(e.toString())),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
    }
  }

  void _handleBackPress() {
    context.pop();
  }

  void _handleMenuAction(String action, Lesson lesson) {
    final l10n = AppLocalizations.of(context)!;
    switch (action) {
      case 'bookmark':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.lessonBookmarked)));
        break;
      case 'share':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.lessonSharing)));
        break;
      case 'report':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.lessonReportSubmitted)));
        break;
    }
  }

  void _updateReadingProgress() {
    setState(() {
      _readingProgress = 1.0; // Mark as read
    });
    _updateProgress();
  }

  void _updateProgress() {
    _progressAnimationController.forward();
  }

  void _goToPreviousSection() {
    if (_currentSectionIndex > 0) {
      _pageController?.animateToPage(
        _currentSectionIndex - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextSection() {
    final lesson = ref.read(lessonProvider(widget.lessonId));
    if (lesson != null && _currentSectionIndex < lesson.sections.length - 1) {
      _pageController?.animateToPage(
        _currentSectionIndex + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeLesson() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.lessonComplete),
        content: Text(l10n.lessonCompleteMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text(l10n.continueLearning),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lesson = ref.watch(lessonProvider(widget.lessonId));

    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.lessonNotFound)),
        body: const Center(child: Text('Lesson not found')),
      );
    }

    return Scaffold(
      appBar: LessonAppBar(
        lesson: lesson,
        onBackPressed: _handleBackPress,
        onMenuAction: _handleMenuAction,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Progress indicator
            LessonProgressIndicator(
              lesson: lesson,
              currentSectionIndex: _currentSectionIndex,
              readingProgress: _readingProgress,
              progressAnimation: _progressAnimation,
            ),

            // Content area
            Expanded(
              child: lesson.sections.isNotEmpty
                  ? _buildSectionBasedContent(lesson)
                  : _buildTextContent(lesson),
            ),

            // Navigation controls
            LessonNavigationControls(
              lesson: lesson,
              currentSectionIndex: _currentSectionIndex,
              canGoBack: _currentSectionIndex > 0,
              canGoNext: true, // Will be determined by progress
              onPrevious: _goToPreviousSection,
              onNext: _goToNextSection,
              onComplete: _completeLesson,
            ),
          ],
        ),
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
        return SectionContentViewer(
          section: section,
          onProgressUpdate: _updateReadingProgress,
        );
      },
    );
  }

  Widget _buildTextContent(Lesson lesson) {
    return TextSectionWidget(
      content: lesson.content,
      onProgressUpdate: _updateReadingProgress,
    );
  }
}
