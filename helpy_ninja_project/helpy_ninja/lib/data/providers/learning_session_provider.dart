import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpy_ninja/domain/entities/shared_enums.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/lesson.dart';
import '../../domain/entities/learning_session.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/entities/progress.dart';

/// Learning session state notifier
class LearningSessionNotifier extends StateNotifier<LearningSessionState> {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 100,
      colors: false,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  LearningSessionNotifier() : super(const LearningSessionState()) {
    _logger.d('LearningSessionNotifier initialized');
    _initializeLearningSession();
  }

  late Box _lessonsBox;
  late Box _sessionsBox;
  late Box _questionsBox;
  late Box _progressBox;

  /// Initialize learning session system
  Future<void> _initializeLearningSession() async {
    _logger.d('Initializing learning session system');
    state = state.copyWith(isLoading: true);
    try {
      _lessonsBox = await Hive.openBox('lessons');
      _sessionsBox = await Hive.openBox('learning_sessions');
      _questionsBox = await Hive.openBox('quiz_questions');
      _progressBox = await Hive.openBox('user_progress');
      _logger.d('All Hive boxes opened successfully');

      await _loadLessons();
      await _loadQuestions();
      await _loadUserProgress();

      state = state.copyWith(isLoading: false, isInitialized: true);
      _logger.d('Learning session system initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize learning session system: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize: $e',
      );
    }
  }

  /// Load lessons from storage
  Future<void> _loadLessons() async {
    _logger.d('Loading lessons from storage');
    try {
      final lessonMaps = _lessonsBox.values.toList();
      _logger.d('Found ${lessonMaps.length} lesson maps in storage');

      if (lessonMaps.isEmpty) {
        _logger.d('No lessons found, creating sample lessons');
        await _createSampleLessons();
        return;
      }

      final lessons = lessonMaps
          .map((map) => Lesson.fromJson(Map<String, dynamic>.from(map)))
          .where((lesson) => lesson.isPublished)
          .toList();

      state = state.copyWith(lessons: lessons);
      _logger.d('Loaded ${lessons.length} published lessons');
    } catch (e) {
      _logger.e('Failed to load lessons: $e');
      debugPrint('Failed to load lessons: $e');
    }
  }

  /// Load quiz questions
  Future<void> _loadQuestions() async {
    _logger.d('Loading quiz questions from storage');
    try {
      final questionMaps = _questionsBox.values.toList();
      _logger.d('Found ${questionMaps.length} question maps in storage');

      final questions = questionMaps
          .map((map) => QuizQuestion.fromJson(Map<String, dynamic>.from(map)))
          .where((q) => q.isActive)
          .toList();

      state = state.copyWith(quizQuestions: questions);
      _logger.d('Loaded ${questions.length} active questions');
    } catch (e) {
      _logger.e('Failed to load questions: $e');
      debugPrint('Failed to load questions: $e');
    }
  }

  /// Load user progress
  Future<void> _loadUserProgress() async {
    _logger.d('Loading user progress from storage');
    try {
      final progressMaps = _progressBox.values.toList();
      _logger.d('Found ${progressMaps.length} progress maps in storage');

      final progressList = progressMaps
          .map((map) => UserProgress.fromJson(Map<String, dynamic>.from(map)))
          .toList();

      final progressMap = <String, UserProgress>{};
      for (final progress in progressList) {
        progressMap[progress.lessonId ?? progress.subjectId] = progress;
      }

      state = state.copyWith(userProgress: progressMap);
      _logger.d('Loaded progress for ${progressMap.length} items');
    } catch (e) {
      _logger.e('Failed to load progress: $e');
      debugPrint('Failed to load progress: $e');
    }
  }

  /// Create sample lessons
  Future<void> _createSampleLessons() async {
    _logger.d('Creating sample lessons');
    final sampleLessons = [
      Lesson(
        id: 'lesson_math_1',
        title: 'Introduction to Algebra',
        description: 'Learn the basics of algebraic expressions.',
        subjectId: 'mathematics',
        content: 'Basic algebra concepts and examples.',
        type: LessonType.reading,
        difficulty: DifficultyLevel.beginner,
        estimatedDuration: 20,
        createdAt: DateTime.now(),
        isPublished: true,
        orderIndex: 1,
      ),
    ];

    for (final lesson in sampleLessons) {
      await _lessonsBox.put(lesson.id, lesson.toJson());
      _logger.d('Saved sample lesson: ${lesson.id}');
    }
    state = state.copyWith(lessons: sampleLessons);
    _logger.d('Sample lessons created successfully');
  }

  /// Start learning session
  Future<LearningSession> startLearningSession({
    required String userId,
    required String lessonId,
    SessionType type = SessionType.lesson,
  }) async {
    _logger.d(
      'Starting learning session - userId: $userId, lessonId: $lessonId, type: ${type.toString()}',
    );

    try {
      final session = LearningSession(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        lessonId: lessonId,
        type: type,
        status: SessionStatus.active,
        startedAt: DateTime.now(),
      );

      await _sessionsBox.put(session.id, session.toJson());
      _logger.d('Session saved to storage: ${session.id}');

      final updatedSessions = Map<String, LearningSession>.from(
        state.activeSessions,
      );
      updatedSessions[session.id] = session;

      state = state.copyWith(activeSessions: updatedSessions);
      _logger.d('Learning session started successfully: ${session.id}');
      return session;
    } catch (e) {
      _logger.e('Failed to start session: $e');
      throw Exception('Failed to start session: $e');
    }
  }

  /// Complete learning session
  Future<void> completeSession(String sessionId, SessionScore? score) async {
    _logger.d(
      'Completing learning session - sessionId: $sessionId, hasScore: ${score != null}',
    );

    try {
      final session = state.activeSessions[sessionId];
      if (session == null) {
        _logger.w('Session not found: $sessionId');
        return;
      }

      final completedSession = session.complete(score);
      await _sessionsBox.put(sessionId, completedSession.toJson());
      _logger.d('Session completed and saved to storage');

      final updatedSessions = Map<String, LearningSession>.from(
        state.activeSessions,
      );
      updatedSessions[sessionId] = completedSession;

      state = state.copyWith(activeSessions: updatedSessions);

      // Update user progress
      await _updateUserProgress(
        session.userId,
        session.lessonId,
        score?.totalScore ?? 0.0,
      );
      _logger.d('Learning session completed successfully: $sessionId');
    } catch (e) {
      _logger.e('Failed to complete session: $e');
      debugPrint('Failed to complete session: $e');
    }
  }

  /// Update user progress
  Future<void> _updateUserProgress(
    String userId,
    String lessonId,
    double score,
  ) async {
    _logger.d(
      'Updating user progress - userId: $userId, lessonId: $lessonId, score: $score',
    );

    try {
      final existingProgress = state.userProgress[lessonId];
      UserProgress progress;

      if (existingProgress != null) {
        progress = existingProgress.completeLesson(lessonId, score, 30);
        _logger.d('Updated existing progress for lesson: $lessonId');
      } else {
        progress = UserProgress(
          id: 'progress_${userId}_$lessonId',
          userId: userId,
          subjectId: 'general',
          lessonId: lessonId,
          type: ProgressType.lesson,
          averageScore: score,
          sessionsCompleted: 1,
          completedLessons: [lessonId],
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );
        _logger.d('Created new progress for lesson: $lessonId');
      }

      await _progressBox.put(progress.id, progress.toJson());
      _logger.d('Progress saved to storage: ${progress.id}');

      final updatedProgress = Map<String, UserProgress>.from(
        state.userProgress,
      );
      updatedProgress[lessonId] = progress;

      state = state.copyWith(userProgress: updatedProgress);
      _logger.d('User progress updated successfully');
    } catch (e) {
      _logger.e('Failed to update progress: $e');
      debugPrint('Failed to update progress: $e');
    }
  }
}

/// Learning session state
class LearningSessionState {
  final List<Lesson> lessons;
  final List<QuizQuestion> quizQuestions;
  final Map<String, LearningSession> activeSessions;
  final Map<String, UserProgress> userProgress;
  final bool isLoading;
  final bool isInitialized;
  final String? error;

  const LearningSessionState({
    this.lessons = const [],
    this.quizQuestions = const [],
    this.activeSessions = const {},
    this.userProgress = const {},
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
  });

  LearningSessionState copyWith({
    List<Lesson>? lessons,
    List<QuizQuestion>? quizQuestions,
    Map<String, LearningSession>? activeSessions,
    Map<String, UserProgress>? userProgress,
    bool? isLoading,
    bool? isInitialized,
    String? error,
  }) {
    return LearningSessionState(
      lessons: lessons ?? this.lessons,
      quizQuestions: quizQuestions ?? this.quizQuestions,
      activeSessions: activeSessions ?? this.activeSessions,
      userProgress: userProgress ?? this.userProgress,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error ?? this.error,
    );
  }
}

/// Learning session provider
final learningSessionProvider =
    StateNotifierProvider<LearningSessionNotifier, LearningSessionState>((ref) {
      return LearningSessionNotifier();
    });

/// Convenience providers
final lessonsProvider = Provider<List<Lesson>>((ref) {
  return ref.watch(learningSessionProvider).lessons;
});

final lessonProvider = Provider.family<Lesson?, String>((ref, lessonId) {
  final lessons = ref.watch(lessonsProvider);
  try {
    return lessons.firstWhere((lesson) => lesson.id == lessonId);
  } catch (e) {
    return null;
  }
});

final userProgressProvider = Provider.family<UserProgress?, String>((
  ref,
  lessonId,
) {
  return ref.watch(learningSessionProvider).userProgress[lessonId];
});

final activeSessionProvider = Provider.family<LearningSession?, String>((
  ref,
  sessionId,
) {
  return ref.watch(learningSessionProvider).activeSessions[sessionId];
});
