import '../entities/learning_session.dart';
import '../entities/lesson.dart';
import '../entities/quiz_question.dart';
import '../entities/progress.dart';

/// Repository interface for learning operations
abstract class ILearningRepository {
  /// Get available subjects
  Future<List<String>> getSubjects();

  /// Get lessons for a subject
  Future<List<Lesson>> getLessons(String subject);

  /// Get a specific lesson
  Future<Lesson?> getLesson(String lessonId);

  /// Start a learning session
  Future<LearningSession> startSession({
    required String userId,
    required String lessonId,
    required String sessionType,
  });

  /// Update session progress
  Future<LearningSession> updateSessionProgress(
    String sessionId,
    Map<String, dynamic> progress,
  );

  /// Complete a learning session
  Future<LearningSession> completeSession(
    String sessionId,
    Map<String, dynamic> results,
  );

  /// Get quiz questions for a lesson
  Future<List<QuizQuestion>> getQuizQuestions(String lessonId);

  /// Submit quiz answer
  Future<bool> submitQuizAnswer(
    String sessionId,
    String questionId,
    dynamic answer,
  );

  /// Get learning progress for user
  Future<UserProgress> getProgress(String userId, String subject);

  /// Update learning progress
  Future<UserProgress> updateProgress(UserProgress progress);

  /// Get learning analytics
  Future<Map<String, dynamic>> getAnalytics(String userId);

  /// Get learning recommendations
  Future<List<String>> getRecommendations(String userId);

  /// Get user achievements
  Future<List<Map<String, dynamic>>> getAchievements(String userId);

  /// Award achievement
  Future<void> awardAchievement(String userId, String achievementId);
}