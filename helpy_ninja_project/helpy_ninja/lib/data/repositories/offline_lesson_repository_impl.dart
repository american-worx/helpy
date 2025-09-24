import '../../core/storage/hive_repository_base.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/learning_session.dart';

/// Offline-first lesson repository implementation using Hive
class OfflineLessonRepositoryImpl {
  final HiveLessonRepository _lessonRepository;
  final HiveLearningSessionRepository _sessionRepository;

  OfflineLessonRepositoryImpl()
      : _lessonRepository = getIt<HiveLessonRepository>(),
        _sessionRepository = getIt<HiveLearningSessionRepository>();

  /// Save lesson locally
  Future<void> saveLesson(Lesson lesson) async {
    await _lessonRepository.save(lesson.id, lesson);
  }

  /// Get lesson by ID
  Lesson? getLesson(String lessonId) {
    return _lessonRepository.get(lessonId) as Lesson?;
  }

  /// Get all lessons
  List<Lesson> getAllLessons() {
    return _lessonRepository.getAll().cast<Lesson>().toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  /// Get lessons by subject
  List<Lesson> getLessonsBySubject(String subjectId) {
    return _lessonRepository.getBySubjectId(subjectId).cast<Lesson>().toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  /// Get published lessons only
  List<Lesson> getPublishedLessons() {
    return _lessonRepository.getPublished().cast<Lesson>().toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  /// Save learning session
  Future<void> saveLearningSession(LearningSession session) async {
    await _sessionRepository.save(session.id, session);
  }

  /// Get learning session by ID
  LearningSession? getLearningSession(String sessionId) {
    return _sessionRepository.get(sessionId) as LearningSession?;
  }

  /// Get sessions for a user
  List<LearningSession> getSessionsForUser(String userId) {
    return _sessionRepository.getByUserId(userId).cast<LearningSession>().toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  /// Get sessions for a lesson
  List<LearningSession> getSessionsForLesson(String lessonId) {
    return _sessionRepository.getByLessonId(lessonId).cast<LearningSession>().toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  /// Get active sessions
  List<LearningSession> getActiveSessions() {
    return _sessionRepository.getActive().cast<LearningSession>().toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  /// Get user's progress for a specific lesson
  LearningSession? getUserProgressForLesson(String userId, String lessonId) {
    final sessions = getSessionsForLesson(lessonId)
        .where((s) => s.userId == userId)
        .toList();
    
    if (sessions.isEmpty) return null;
    
    // Return the most recent session
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions.first;
  }

  /// Check if lesson is available for user (prerequisites met)
  bool isLessonAvailable(String lessonId, String userId) {
    final lesson = getLesson(lessonId);
    if (lesson == null) return false;
    
    if (lesson.prerequisites.isEmpty) return true;
    
    // Check if all prerequisites are completed
    for (final prereqId in lesson.prerequisites) {
      final progress = getUserProgressForLesson(userId, prereqId);
      if (progress == null || !progress.isCompleted) {
        return false;
      }
    }
    
    return true;
  }

  /// Get completion rate for a user across all lessons
  double getUserCompletionRate(String userId) {
    final allLessons = getPublishedLessons();
    if (allLessons.isEmpty) return 0.0;
    
    int completedCount = 0;
    for (final lesson in allLessons) {
      final progress = getUserProgressForLesson(userId, lesson.id);
      if (progress != null && progress.isCompleted) {
        completedCount++;
      }
    }
    
    return completedCount / allLessons.length;
  }

  /// Delete lesson and all associated sessions
  Future<void> deleteLesson(String lessonId) async {
    // Delete all sessions for this lesson
    final sessions = getSessionsForLesson(lessonId);
    for (final session in sessions) {
      await _sessionRepository.delete(session.id);
    }
    
    // Delete the lesson
    await _lessonRepository.delete(lessonId);
  }

  /// Delete learning session
  Future<void> deleteLearningSession(String sessionId) async {
    await _sessionRepository.delete(sessionId);
  }

  /// Clear all lesson data
  Future<void> clearAllData() async {
    await _lessonRepository.clear();
    await _sessionRepository.clear();
  }

  /// Get lessons count
  int get lessonsCount => _lessonRepository.length;

  /// Get sessions count
  int get sessionsCount => _sessionRepository.length;

  /// Listen to lesson changes
  Stream<dynamic> watchLessons() {
    return _lessonRepository.watch();
  }

  /// Listen to session changes
  Stream<dynamic> watchSessions() {
    return _sessionRepository.watch();
  }
}