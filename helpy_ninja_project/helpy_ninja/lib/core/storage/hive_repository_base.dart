import 'package:hive/hive.dart';
import 'hive_service.dart';

/// Base class for Hive repositories with common operations
abstract class HiveRepositoryBase<T> {
  final Box _box;

  HiveRepositoryBase(this._box);

  /// Save an entity
  Future<void> save(String key, T entity) async {
    await _box.put(key, entity);
  }

  /// Get an entity by key
  T? get(String key) {
    return _box.get(key) as T?;
  }

  /// Get all entities
  List<T> getAll() {
    return _box.values.cast<T>().toList();
  }

  /// Delete an entity by key
  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  /// Check if an entity exists
  bool exists(String key) {
    return _box.containsKey(key);
  }

  /// Get all keys
  Iterable<dynamic> get keys => _box.keys;

  /// Get count of entities
  int get length => _box.length;

  /// Clear all entities
  Future<void> clear() async {
    await _box.clear();
  }

  /// Save multiple entities
  Future<void> saveAll(Map<String, T> entities) async {
    await _box.putAll(entities);
  }

  /// Delete multiple entities
  Future<void> deleteAll(List<String> keys) async {
    await _box.deleteAll(keys);
  }

  /// Get entities by a filter function
  List<T> where(bool Function(T) test) {
    return getAll().where(test).toList();
  }

  /// Find first entity matching condition
  T? firstWhere(bool Function(T) test, {T? Function()? orElse}) {
    try {
      return getAll().firstWhere(test);
    } catch (e) {
      return orElse?.call();
    }
  }

  /// Listen to box changes
  Stream<BoxEvent> watch({dynamic key}) {
    return _box.watch(key: key);
  }
}

/// User repository using Hive
class HiveUserRepository extends HiveRepositoryBase {
  HiveUserRepository() : super(HiveService.userBox);
}

/// Conversation repository using Hive
class HiveConversationRepository extends HiveRepositoryBase {
  HiveConversationRepository() : super(HiveService.conversationBox);
}

/// Message repository using Hive
class HiveMessageRepository extends HiveRepositoryBase {
  HiveMessageRepository() : super(HiveService.messageBox);
  
  /// Get messages for a specific conversation
  List<dynamic> getByConversationId(String conversationId) {
    return where((message) => (message as dynamic).conversationId == conversationId);
  }

  /// Get recent messages (last N messages)
  List<dynamic> getRecent(int count) {
    final allMessages = getAll();
    allMessages.sort((a, b) => (b as dynamic).timestamp.compareTo((a as dynamic).timestamp));
    return allMessages.take(count).toList();
  }
}

/// Lesson repository using Hive
class HiveLessonRepository extends HiveRepositoryBase {
  HiveLessonRepository() : super(HiveService.lessonBox);

  /// Get lessons by subject ID
  List<dynamic> getBySubjectId(String subjectId) {
    return where((lesson) => (lesson as dynamic).subjectId == subjectId);
  }

  /// Get published lessons only
  List<dynamic> getPublished() {
    return where((lesson) => (lesson as dynamic).isPublished == true);
  }
}

/// Learning session repository using Hive
class HiveLearningSessionRepository extends HiveRepositoryBase {
  HiveLearningSessionRepository() : super(HiveService.learningSessionBox);

  /// Get sessions for a specific user
  List<dynamic> getByUserId(String userId) {
    return where((session) => (session as dynamic).userId == userId);
  }

  /// Get sessions for a specific lesson
  List<dynamic> getByLessonId(String lessonId) {
    return where((session) => (session as dynamic).lessonId == lessonId);
  }

  /// Get active sessions
  List<dynamic> getActive() {
    return where((session) => (session as dynamic).status.toString().contains('active'));
  }
}