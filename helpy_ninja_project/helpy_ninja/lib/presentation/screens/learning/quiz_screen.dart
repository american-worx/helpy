import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpy_ninja/l10n/app_localizations.dart';

import '../../../config/design_tokens.dart';
import '../../../data/providers/learning_session_provider.dart';
import '../../../data/providers/providers.dart';
import '../../../domain/entities/quiz_question.dart';
import '../../../domain/entities/learning_session.dart';
import '../../widgets/navigation/modern_navigation.dart';
import '../../widgets/layout/modern_layout.dart';
import '../../widgets/common/gradient_button.dart';

/// Quiz screen for interactive question practice
class QuizScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const QuizScreen({super.key, required this.lessonId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late AnimationController _questionController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _questionSlideAnimation;

  List<QuizQuestion> _questions = [];
  List<QuestionAnswer> _answers = [];
  int _currentQuestionIndex = 0;
  List<String> _selectedAnswers = [];
  bool _isAnswered = false;
  bool _showExplanation = false;
  int _correctAnswers = 0;
  DateTime? _questionStartTime;
  LearningSession? _currentSession;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _questionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _questionSlideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
      CurvedAnimation(parent: _questionController, curve: Curves.easeOut),
    );

    _loadQuestions();
    _startQuizSession();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _loadQuestions() {
    final allQuestions = ref.read(learningSessionProvider).quizQuestions;
    _questions =
        allQuestions.where((q) => q.lessonId == widget.lessonId).toList();

    if (_questions.isNotEmpty) {
      _questionStartTime = DateTime.now();
      _questionController.forward();
    }
  }

  void _startQuizSession() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      final session =
          await ref.read(learningSessionProvider.notifier).startLearningSession(
                userId: user.id,
                lessonId: widget.lessonId,
                type: SessionType.quiz,
              );
      setState(() {
        _currentSession = session;
      });
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.quizStartFailed(e.toString()))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: ModernAppBar(
          title: l10n.quizPractice,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: const Center(
          child: Text('No questions available for this lesson'),
        ),
      );
    }

    return Scaffold(
      appBar: ModernAppBar(
        title: l10n.quizPractice,
        subtitle: '${_currentQuestionIndex + 1} of ${_questions.length}',
        leading: IconButton(
          onPressed: () => _handleBackPress(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () => _showQuizSettings(),
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: SlideTransition(
                position: _questionSlideAnimation,
                child: _buildQuestionArea(),
              ),
            ),
            _buildActionArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    final l10n = AppLocalizations.of(context)!;
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.questionNumber(_currentQuestionIndex + 1),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                l10n.scoreLabel(_correctAnswers, _answers.length),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                value: progress * _progressAnimation.value,
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

  Widget _buildQuestionArea() {
    final question = _questions[_currentQuestionIndex];
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: ModernSection(
        showGlassmorphism: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceS,
                    vertical: DesignTokens.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(
                            question.difficultyColor.substring(1),
                            radix: 16,
                          ) |
                          0xFF000000,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                  ),
                  child: Text(
                    question.difficulty.name.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Color(
                            int.parse(
                                  question.difficultyColor.substring(1),
                                  radix: 16,
                                ) |
                                0xFF000000,
                          ),
                        ),
                  ),
                ),
                const Spacer(),
                Text(question.typeIcon, style: const TextStyle(fontSize: 24)),
              ],
            ),
            Space.l,

            // Question text
            Text(
              question.question,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            Space.l,

            // Question options
            _buildQuestionOptions(question),

            // Explanation (if answered)
            if (_isAnswered &&
                _showExplanation &&
                question.explanation != null) ...[
              Space.l,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DesignTokens.spaceM),
                decoration: BoxDecoration(
                  color: DesignTokens.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  border: Border.all(
                    color: DesignTokens.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.explanation,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: DesignTokens.primary,
                          ),
                    ),
                    Space.s,
                    Text(
                      question.explanation!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionOptions(QuizQuestion question) {
    switch (question.type) {
      case QuestionType.singleChoice:
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceOptions(question);
      case QuestionType.trueFalse:
        return _buildTrueFalseOptions(question);
      case QuestionType.text:
      case QuestionType.shortAnswer:
        return _buildTextAnswerField(question);
      default:
        return _buildMultipleChoiceOptions(question);
    }
  }

  Widget _buildMultipleChoiceOptions(QuizQuestion question) {
    return Column(
      children: question.options.map((option) {
        final isSelected = _selectedAnswers.contains(option.id);
        final isCorrect = question.correctAnswers.contains(option.id);
        final showResult = _isAnswered;

        Color? backgroundColor;
        Color? borderColor;

        if (showResult) {
          if (isCorrect) {
            backgroundColor = Colors.green.withValues(alpha: 0.1);
            borderColor = Colors.green;
          } else if (isSelected && !isCorrect) {
            backgroundColor = DesignTokens.error.withValues(alpha: 0.1);
            borderColor = DesignTokens.error;
          }
        } else if (isSelected) {
          backgroundColor = DesignTokens.primary.withValues(alpha: 0.1);
          borderColor = DesignTokens.primary;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: DesignTokens.spaceS),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isAnswered ? null : () => _selectAnswer(option.id),
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DesignTokens.spaceM),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  border: Border.all(
                    color: borderColor ??
                        Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                    width: borderColor != null ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Selection indicator
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: question.type == QuestionType.singleChoice
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                        borderRadius:
                            question.type == QuestionType.multipleChoice
                                ? BorderRadius.circular(4)
                                : null,
                        border: Border.all(
                          color: borderColor ??
                              Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        color: isSelected
                            ? (borderColor ?? DesignTokens.primary)
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              question.type == QuestionType.singleChoice
                                  ? Icons.radio_button_checked
                                  : Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Space.m,

                    // Option text
                    Expanded(
                      child: Text(
                        option.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : null,
                            ),
                      ),
                    ),

                    // Correct/Incorrect indicator
                    if (showResult && (isCorrect || (isSelected && !isCorrect)))
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : DesignTokens.error,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalseOptions(QuizQuestion question) {
    final trueOption = QuestionOption(id: 'true', text: 'True');
    final falseOption = QuestionOption(id: 'false', text: 'False');

    return Row(
      children: [
        Expanded(child: _buildTrueFalseButton(trueOption, question)),
        Space.m,
        Expanded(child: _buildTrueFalseButton(falseOption, question)),
      ],
    );
  }

  Widget _buildTrueFalseButton(QuestionOption option, QuizQuestion question) {
    final isSelected = _selectedAnswers.contains(option.id);
    final isCorrect = question.correctAnswers.contains(option.id);
    final showResult = _isAnswered;

    return GestureDetector(
      onTap: _isAnswered
          ? null
          : () {
              setState(() {
                _selectedAnswers = [option.id];
              });
            },
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spaceL),
        decoration: BoxDecoration(
          color: showResult && isCorrect
              ? Colors.green.withValues(alpha: 0.1)
              : showResult && isSelected && !isCorrect
                  ? DesignTokens.error.withValues(alpha: 0.1)
                  : isSelected
                      ? DesignTokens.primary.withValues(alpha: 0.1)
                      : null,
          borderRadius: BorderRadius.circular(DesignTokens.radiusL),
          border: Border.all(
            color: showResult && isCorrect
                ? Colors.green
                : showResult && isSelected && !isCorrect
                    ? DesignTokens.error
                    : isSelected
                        ? DesignTokens.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
            width: isSelected || (showResult && isCorrect) ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            option.text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: showResult && isCorrect
                      ? Colors.green
                      : showResult && isSelected && !isCorrect
                          ? DesignTokens.error
                          : isSelected
                              ? DesignTokens.primary
                              : null,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextAnswerField(QuizQuestion question) {
    return TextField(
      enabled: !_isAnswered,
      onChanged: (value) {
        setState(() {
          _selectedAnswers = [value];
        });
      },
      decoration: InputDecoration(
        hintText: 'Enter your answer...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        ),
      ),
      maxLines: question.type == QuestionType.text ? 3 : 1,
    );
  }

  Widget _buildActionArea() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: Row(
        children: [
          // Hint button
          if (!_isAnswered && _questions[_currentQuestionIndex].hint != null)
            Expanded(
              child: OutlineButton(
                onPressed: _showHint,
                text: 'Hint',
                icon: Icons.lightbulb_outline_rounded,
              ),
            ),

          if (!_isAnswered && _questions[_currentQuestionIndex].hint != null)
            Space.m,

          // Main action button
          Expanded(
            flex: 2,
            child: !_isAnswered
                ? GradientButton(
                    onPressed:
                        _selectedAnswers.isNotEmpty ? _submitAnswer : null,
                    text: 'Submit Answer',
                    icon: Icons.send_rounded,
                  )
                : _currentQuestionIndex < _questions.length - 1
                    ? GradientButton(
                        onPressed: _nextQuestion,
                        text: 'Next Question',
                        icon: Icons.arrow_forward_rounded,
                      )
                    : GradientButton(
                        onPressed: _finishQuiz,
                        text: 'Finish Quiz',
                        icon: Icons.flag_rounded,
                      ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(String optionId) {
    final question = _questions[_currentQuestionIndex];

    setState(() {
      if (question.type == QuestionType.singleChoice) {
        _selectedAnswers = [optionId];
      } else {
        if (_selectedAnswers.contains(optionId)) {
          _selectedAnswers.remove(optionId);
        } else {
          _selectedAnswers.add(optionId);
        }
      }
    });
  }

  void _submitAnswer() {
    final question = _questions[_currentQuestionIndex];
    final isCorrect = question.isCorrectAnswer(_selectedAnswers);
    final timeToAnswer = _questionStartTime != null
        ? DateTime.now().difference(_questionStartTime!)
        : Duration.zero;

    final answer = QuestionAnswer(
      id: 'ans_${DateTime.now().millisecondsSinceEpoch}',
      questionId: question.id,
      userId: ref.read(currentUserProvider)?.id ?? '',
      sessionId: _currentSession?.id ?? '',
      answerIds: _selectedAnswers,
      textAnswer: question.type == QuestionType.text ||
              question.type == QuestionType.shortAnswer
          ? _selectedAnswers.isNotEmpty
              ? _selectedAnswers.first
              : null
          : null,
      isCorrect: isCorrect,
      score: question.getPartialScore(_selectedAnswers) * question.points,
      timeToAnswer: timeToAnswer,
      answeredAt: DateTime.now(),
    );

    setState(() {
      _answers.add(answer);
      _isAnswered = true;
      _showExplanation = true;
      if (isCorrect) _correctAnswers++;
    });

    _progressController.forward();
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _selectedAnswers = [];
      _isAnswered = false;
      _showExplanation = false;
      _questionStartTime = DateTime.now();
    });

    _questionController.reset();
    _progressController.reset();
    _questionController.forward();
  }

  void _finishQuiz() async {
    if (_currentSession == null) return;

    final totalScore = _answers.fold(0.0, (sum, answer) => sum + answer.score);
    final maxScore = _questions.fold(
      0.0,
      (sum, question) => sum + question.points,
    );

    final sessionScore = SessionScore(
      totalScore: totalScore,
      maxScore: maxScore,
      correctAnswers: _correctAnswers,
      totalAnswers: _answers.length,
      timeToComplete: DateTime.now().difference(_currentSession!.startedAt),
    );

    try {
      await ref
          .read(learningSessionProvider.notifier)
          .completeSession(_currentSession!.id, sessionScore);

      if (mounted) {
        _showQuizResults(sessionScore);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save results: $e')));
      }
    }
  }

  void _showQuizResults(SessionScore score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Quiz Complete! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: ${score.percentage.toStringAsFixed(1)}%'),
            Text('Grade: ${score.grade}'),
            Text('Correct: ${score.correctAnswers}/${score.totalAnswers}'),
            Text(
              'Time: ${score.timeToComplete.inMinutes}m ${score.timeToComplete.inSeconds % 60}s',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showHint() {
    final hint = _questions[_currentQuestionIndex].hint;
    if (hint != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hint 💡'),
          content: Text(hint),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it!'),
            ),
          ],
        ),
      );
    }
  }

  void _showQuizSettings() {
    // Placeholder for quiz settings
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Quiz settings coming soon!')));
  }

  void _handleBackPress() {
    if (_currentSession?.status == SessionStatus.active) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Leave Quiz?'),
          content: const Text('Your progress will be lost.'),
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
}
