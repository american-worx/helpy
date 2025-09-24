import 'dart:async';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../network/api_client.dart';
import '../storage/hive_service.dart';
import '../di/injection.dart';
import '../../data/repositories/offline_chat_repository_impl.dart';
import '../../data/repositories/offline_lesson_repository_impl.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/learning_session.dart';
import '../../domain/entities/shared_enums.dart';

/// Service for managing data synchronization between local and remote storage
class SyncService {
  final ApiClient _apiClient;
  final OfflineChatRepositoryImpl _chatRepository;
  final OfflineLessonRepositoryImpl _lessonRepository;
  final Logger _logger = Logger();
  
  bool _isOnline = false;
  bool _isSyncing = false;
  Timer? _syncTimer;
  StreamSubscription? _connectivitySubscription;
  
  // Sync status streams
  final StreamController<SyncStatus> _syncStatusController = 
      StreamController<SyncStatus>.broadcast();
  final StreamController<SyncProgress> _syncProgressController = 
      StreamController<SyncProgress>.broadcast();
  
  // Sync configuration
  static const Duration _syncInterval = Duration(minutes: 5);

  SyncService(this._apiClient, this._chatRepository, this._lessonRepository);

  /// Factory constructor with dependency injection
  factory SyncService.create() {
    return SyncService(
      getIt<ApiClient>(),
      OfflineChatRepositoryImpl(),
      OfflineLessonRepositoryImpl(),
    );
  }

  /// Initialize sync service
  Future<void> initialize() async {
    await _setupConnectivityListener();
    _setupPeriodicSync();
    _logger.d('Sync service initialized');
  }

  /// Stream of sync status changes
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  /// Stream of sync progress updates
  Stream<SyncProgress> get syncProgress => _syncProgressController.stream;

  /// Check if currently online
  bool get isOnline => _isOnline;

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  /// Force a manual sync
  Future<void> forceSync() async {
    if (!_isOnline) {
      _logger.w('Cannot sync: device is offline');
      return;
    }

    if (_isSyncing) {
      _logger.w('Sync already in progress');
      return;
    }

    await _performSync();
  }

  /// Sync specific conversation
  Future<void> syncConversation(String conversationId) async {
    if (!_isOnline) return;

    try {
      _logger.d('Syncing conversation: $conversationId');
      
      // Download latest messages from server
      final response = await _apiClient.get('/conversations/$conversationId/messages');
      if (response.statusCode == 200) {
        final messagesData = response.data['messages'] as List;
        
        for (final messageData in messagesData) {
          final message = Message.fromJson(messageData);
          await _chatRepository.saveMessage(message);
        }
        
        _logger.d('Synced ${messagesData.length} messages for conversation $conversationId');
      }
    } catch (e) {
      _logger.e('Failed to sync conversation $conversationId', error: e);
    }
  }

  /// Sync specific lesson progress
  Future<void> syncLessonProgress(String lessonId, String userId) async {
    if (!_isOnline) return;

    try {
      _logger.d('Syncing lesson progress: $lessonId for user $userId');
      
      // Upload local progress to server
      final localSession = _lessonRepository.getUserProgressForLesson(userId, lessonId);
      if (localSession != null) {
        await _apiClient.put(
          '/users/$userId/lessons/$lessonId/progress',
          data: localSession.toJson(),
        );
      }
      
      // Download latest progress from server
      final response = await _apiClient.get('/users/$userId/lessons/$lessonId/progress');
      if (response.statusCode == 200) {
        final sessionData = response.data;
        final session = LearningSession.fromJson(sessionData);
        await _lessonRepository.saveLearningSession(session);
      }
    } catch (e) {
      _logger.e('Failed to sync lesson progress', error: e);
    }
  }

  /// Setup connectivity listener
  Future<void> _setupConnectivityListener() async {
    // Check initial connectivity
    final connectivity = Connectivity();
    final connectivityResult = await connectivity.checkConnectivity();
    _updateOnlineStatus(connectivityResult);

    // Listen to connectivity changes
    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      _updateOnlineStatus,
    );
  }

  /// Update online status based on connectivity
  void _updateOnlineStatus(List<ConnectivityResult> results) {
    final isOnline = results.any((result) => 
        result == ConnectivityResult.mobile || 
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
    
    if (isOnline != _isOnline) {
      _isOnline = isOnline;
      _logger.d('Connectivity changed: ${isOnline ? 'online' : 'offline'}');
      
      if (isOnline) {
        _onConnectionRestored();
      } else {
        _onConnectionLost();
      }
    }
  }

  /// Handle connection restored
  void _onConnectionRestored() {
    _syncStatusController.add(SyncStatus.online);
    
    // Start quick sync to catch up on missed data
    Timer(const Duration(seconds: 2), () {
      forceSync();
    });
  }

  /// Handle connection lost
  void _onConnectionLost() {
    _syncStatusController.add(SyncStatus.offline);
    _cancelSync();
  }

  /// Setup periodic sync
  void _setupPeriodicSync() {
    _syncTimer = Timer.periodic(_syncInterval, (timer) {
      if (_isOnline && !_isSyncing) {
        _performSync();
      }
    });
  }

  /// Perform complete data sync
  Future<void> _performSync() async {
    if (_isSyncing || !_isOnline) return;

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);
    
    try {
      _logger.d('Starting data sync');
      final progress = SyncProgress(phase: 'Starting sync...', progress: 0.0);
      _syncProgressController.add(progress);

      // 1. Sync conversations
      await _syncConversations();
      _syncProgressController.add(progress.copyWith(
        phase: 'Syncing conversations...',
        progress: 0.2,
      ));

      // 2. Sync messages
      await _syncMessages();
      _syncProgressController.add(progress.copyWith(
        phase: 'Syncing messages...',
        progress: 0.4,
      ));

      // 3. Sync lessons
      await _syncLessons();
      _syncProgressController.add(progress.copyWith(
        phase: 'Syncing lessons...',
        progress: 0.6,
      ));

      // 4. Sync learning sessions
      await _syncLearningSessions();
      _syncProgressController.add(progress.copyWith(
        phase: 'Syncing progress...',
        progress: 0.8,
      ));

      // 5. Upload pending data
      await _uploadPendingData();
      _syncProgressController.add(progress.copyWith(
        phase: 'Uploading changes...',
        progress: 1.0,
      ));

      _logger.d('Data sync completed successfully');
      _syncStatusController.add(SyncStatus.synced);

    } catch (e) {
      _logger.e('Sync failed', error: e);
      _syncStatusController.add(SyncStatus.error);
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync conversations from server
  Future<void> _syncConversations() async {
    try {
      final response = await _apiClient.get('/conversations');
      if (response.statusCode == 200) {
        final conversationsData = response.data['conversations'] as List;
        
        for (final conversationData in conversationsData) {
          final conversation = Conversation.fromJson(conversationData);
          await _chatRepository.saveConversation(conversation);
        }
        
        _logger.d('Synced ${conversationsData.length} conversations');
      }
    } catch (e) {
      _logger.e('Failed to sync conversations', error: e);
    }
  }

  /// Sync messages from server
  Future<void> _syncMessages() async {
    try {
      // Get all conversations and sync their messages
      final conversations = _chatRepository.getAllConversations();
      
      for (final conversation in conversations) {
        await syncConversation(conversation.id);
        
        // Add small delay to avoid overwhelming the server
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      _logger.e('Failed to sync messages', error: e);
    }
  }

  /// Sync lessons from server
  Future<void> _syncLessons() async {
    try {
      final response = await _apiClient.get('/lessons');
      if (response.statusCode == 200) {
        final lessonsData = response.data['lessons'] as List;
        
        for (final lessonData in lessonsData) {
          final lesson = Lesson.fromJson(lessonData);
          await _lessonRepository.saveLesson(lesson);
        }
        
        _logger.d('Synced ${lessonsData.length} lessons');
      }
    } catch (e) {
      _logger.e('Failed to sync lessons', error: e);
    }
  }

  /// Sync learning sessions from server
  Future<void> _syncLearningSessions() async {
    try {
      // This would typically be user-specific
      final response = await _apiClient.get('/learning-sessions');
      if (response.statusCode == 200) {
        final sessionsData = response.data['sessions'] as List;
        
        for (final sessionData in sessionsData) {
          final session = LearningSession.fromJson(sessionData);
          await _lessonRepository.saveLearningSession(session);
        }
        
        _logger.d('Synced ${sessionsData.length} learning sessions');
      }
    } catch (e) {
      _logger.e('Failed to sync learning sessions', error: e);
    }
  }

  /// Upload pending data to server
  Future<void> _uploadPendingData() async {
    await _uploadPendingMessages();
    await _uploadPendingProgress();
  }

  /// Upload messages that failed to send
  Future<void> _uploadPendingMessages() async {
    try {
      // Find messages with failed or sending status
      final allMessages = _chatRepository.getAllConversations()
          .expand((conv) => _chatRepository.getMessagesForConversation(conv.id))
          .where((msg) => 
              msg.status == MessageStatus.failed || 
              msg.status == MessageStatus.sending)
          .toList();

      for (final message in allMessages) {
        try {
          await _apiClient.post('/conversations/${message.conversationId}/messages', 
              data: message.toJson());
          
          // Update message status to sent
          final updatedMessage = message.copyWith(
            status: MessageStatus.sent,
            deliveryStatus: MessageDeliveryStatus.sent,
          );
          await _chatRepository.saveMessage(updatedMessage);
          
        } catch (e) {
          _logger.e('Failed to upload message ${message.id}', error: e);
        }
      }
    } catch (e) {
      _logger.e('Failed to upload pending messages', error: e);
    }
  }

  /// Upload learning progress that hasn't been synced
  Future<void> _uploadPendingProgress() async {
    try {
      final allSessions = _lessonRepository.getActiveSessions();
      
      for (final session in allSessions) {
        try {
          await _apiClient.put(
            '/users/${session.userId}/lessons/${session.lessonId}/progress',
            data: session.toJson(),
          );
        } catch (e) {
          _logger.e('Failed to upload session progress ${session.id}', error: e);
        }
      }
    } catch (e) {
      _logger.e('Failed to upload pending progress', error: e);
    }
  }

  /// Cancel ongoing sync
  void _cancelSync() {
    if (_isSyncing) {
      _isSyncing = false;
      _syncStatusController.add(SyncStatus.cancelled);
    }
  }

  /// Get sync statistics
  SyncStatistics getSyncStatistics() {
    final boxStats = HiveService.getBoxStats();
    
    return SyncStatistics(
      totalConversations: boxStats['conversations'] ?? 0,
      totalMessages: boxStats['messages'] ?? 0,
      totalLessons: boxStats['lessons'] ?? 0,
      totalSessions: boxStats['learning_sessions'] ?? 0,
      lastSyncTime: DateTime.now(), // This should be stored persistently
      isOnline: _isOnline,
      isSyncing: _isSyncing,
    );
  }

  /// Dispose of resources
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
    _syncProgressController.close();
  }
}

/// Sync status enumeration
enum SyncStatus {
  offline,
  online,
  syncing,
  synced,
  error,
  cancelled,
}

/// Sync progress data
class SyncProgress {
  final String phase;
  final double progress; // 0.0 to 1.0
  final String? currentItem;
  final int? processedCount;
  final int? totalCount;

  const SyncProgress({
    required this.phase,
    required this.progress,
    this.currentItem,
    this.processedCount,
    this.totalCount,
  });

  SyncProgress copyWith({
    String? phase,
    double? progress,
    String? currentItem,
    int? processedCount,
    int? totalCount,
  }) {
    return SyncProgress(
      phase: phase ?? this.phase,
      progress: progress ?? this.progress,
      currentItem: currentItem ?? this.currentItem,
      processedCount: processedCount ?? this.processedCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// Sync statistics
class SyncStatistics {
  final int totalConversations;
  final int totalMessages;
  final int totalLessons;
  final int totalSessions;
  final DateTime lastSyncTime;
  final bool isOnline;
  final bool isSyncing;

  const SyncStatistics({
    required this.totalConversations,
    required this.totalMessages,
    required this.totalLessons,
    required this.totalSessions,
    required this.lastSyncTime,
    required this.isOnline,
    required this.isSyncing,
  });
}