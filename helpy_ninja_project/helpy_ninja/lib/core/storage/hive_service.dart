import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/learning_session.dart';
import '../../domain/entities/shared_enums.dart';

/// Hive service for managing local storage
class HiveService {
  static const String _userBoxName = 'users';
  static const String _conversationBoxName = 'conversations';
  static const String _messageBoxName = 'messages';
  static const String _lessonBoxName = 'lessons';
  static const String _learningSessionBoxName = 'learning_sessions';
  static const String _settingsBoxName = 'settings';

  static late Box _userBox;
  static late Box _conversationBox;
  static late Box _messageBox;
  static late Box _lessonBox;
  static late Box _learningSessionBox;
  static late Box _settingsBox;

  /// Initialize Hive and register all adapters
  static Future<void> init() async {
    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Register type adapters
    await _registerAdapters();

    // Open boxes
    await _openBoxes();
  }

  /// Register all Hive type adapters
  static Future<void> _registerAdapters() async {
    // Core entities
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserPreferencesAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MessageAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(MessageTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(MessageStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(MessageAttachmentAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(ConversationAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(ConversationTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(ConversationStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(ConversationSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(LessonAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(LessonTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(LessonStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(LessonSectionAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(LessonSectionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(LearningSessionAdapter());
    }
    if (!Hive.isAdapterRegistered(16)) {
      Hive.registerAdapter(SessionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(17)) {
      Hive.registerAdapter(SessionStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(18)) {
      Hive.registerAdapter(SessionEventAdapter());
    }
    if (!Hive.isAdapterRegistered(19)) {
      Hive.registerAdapter(SessionEventTypeAdapter());
    }
    
    // Shared enums and classes
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(DifficultyLevelAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(ThemeModeAdapter());
    }
    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(AttachmentTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(23)) {
      Hive.registerAdapter(AttachmentStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(24)) {
      Hive.registerAdapter(MessagePriorityAdapter());
    }
    if (!Hive.isAdapterRegistered(25)) {
      Hive.registerAdapter(MessageDeliveryStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(26)) {
      Hive.registerAdapter(MessageReactionAdapter());
    }
    if (!Hive.isAdapterRegistered(27)) {
      Hive.registerAdapter(CompressionInfoAdapter());
    }
    if (!Hive.isAdapterRegistered(28)) {
      Hive.registerAdapter(SessionScoreAdapter());
    }
  }

  /// Open all Hive boxes
  static Future<void> _openBoxes() async {
    _userBox = await Hive.openBox(_userBoxName);
    _conversationBox = await Hive.openBox(_conversationBoxName);
    _messageBox = await Hive.openBox(_messageBoxName);
    _lessonBox = await Hive.openBox(_lessonBoxName);
    _learningSessionBox = await Hive.openBox(_learningSessionBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  /// Get user box
  static Box get userBox => _userBox;

  /// Get conversation box
  static Box get conversationBox => _conversationBox;

  /// Get message box
  static Box get messageBox => _messageBox;

  /// Get lesson box
  static Box get lessonBox => _lessonBox;

  /// Get learning session box
  static Box get learningSessionBox => _learningSessionBox;

  /// Get settings box
  static Box get settingsBox => _settingsBox;

  /// Clear all data (for testing or logout)
  static Future<void> clearAll() async {
    await _userBox.clear();
    await _conversationBox.clear();
    await _messageBox.clear();
    await _lessonBox.clear();
    await _learningSessionBox.clear();
    await _settingsBox.clear();
  }

  /// Close all boxes
  static Future<void> close() async {
    await _userBox.close();
    await _conversationBox.close();
    await _messageBox.close();
    await _lessonBox.close();
    await _learningSessionBox.close();
    await _settingsBox.close();
  }

  /// Get box statistics
  static Map<String, int> getBoxStats() {
    return {
      'users': _userBox.length,
      'conversations': _conversationBox.length,
      'messages': _messageBox.length,
      'lessons': _lessonBox.length,
      'learning_sessions': _learningSessionBox.length,
      'settings': _settingsBox.length,
    };
  }
}