import 'dart:async';
import 'package:logger/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/group_session_enhanced.dart';

/// Enhanced group session service with advanced features
class EnhancedGroupSessionService {
  final Logger _logger = Logger();
  
  static const String _invitationsBoxName = 'group_invitations';
  static const String _progressBoxName = 'group_progress';
  static const String _moderationBoxName = 'group_moderation';
  static const String _analyticsBoxName = 'group_analytics';

  late Box<Map> _invitationsBox;
  late Box<Map> _progressBox;
  late Box<Map> _moderationBox;
  late Box<Map> _analyticsBox;

  /// Initialize the enhanced group session service
  Future<void> initialize() async {
    try {
      _invitationsBox = await Hive.openBox<Map>(_invitationsBoxName);
      _progressBox = await Hive.openBox<Map>(_progressBoxName);
      _moderationBox = await Hive.openBox<Map>(_moderationBoxName);
      _analyticsBox = await Hive.openBox<Map>(_analyticsBoxName);
      
      _logger.d('Enhanced group session service initialized');
    } catch (e) {
      _logger.e('Failed to initialize enhanced group session service: $e');
      rethrow;
    }
  }

  /// Create an invitation for a group session
  Future<GroupInvitation> createInvitation({
    required String sessionId,
    required String invitedBy,
    required String inviteeId,
    String? inviteeEmail,
    String? message,
    InvitationType type = InvitationType.direct,
  }) async {
    try {
      final invitation = GroupInvitation(
        id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        invitedBy: invitedBy,
        inviteeId: inviteeId,
        inviteeEmail: inviteeEmail,
        status: InvitationStatus.pending,
        createdAt: DateTime.now(),
        message: message,
        type: type,
      );

      await _invitationsBox.put(invitation.id, invitation.toJson());
      _logger.d('Created invitation: ${invitation.id}');
      
      return invitation;
    } catch (e) {
      _logger.e('Failed to create invitation: $e');
      rethrow;
    }
  }

  /// Respond to an invitation
  Future<void> respondToInvitation({
    required String invitationId,
    required InvitationStatus response,
  }) async {
    try {
      final invitationData = _invitationsBox.get(invitationId);
      if (invitationData == null) {
        throw Exception('Invitation not found: $invitationId');
      }

      final invitation = GroupInvitation.fromJson(
        Map<String, dynamic>.from(invitationData),
      );

      if (invitation.status != InvitationStatus.pending) {
        throw Exception('Invitation already responded to');
      }

      if (invitation.isExpired) {
        throw Exception('Invitation has expired');
      }

      final updatedInvitation = GroupInvitation(
        id: invitation.id,
        sessionId: invitation.sessionId,
        invitedBy: invitation.invitedBy,
        inviteeId: invitation.inviteeId,
        inviteeEmail: invitation.inviteeEmail,
        status: response,
        createdAt: invitation.createdAt,
        respondedAt: DateTime.now(),
        message: invitation.message,
        type: invitation.type,
      );

      await _invitationsBox.put(invitationId, updatedInvitation.toJson());
      _logger.d('Responded to invitation: $invitationId with $response');

      // If accepted, trigger session join logic here
      if (response == InvitationStatus.accepted) {
        await _handleInvitationAccepted(updatedInvitation);
      }
    } catch (e) {
      _logger.e('Failed to respond to invitation: $e');
      rethrow;
    }
  }

  /// Get pending invitations for a user
  Future<List<GroupInvitation>> getPendingInvitationsForUser(String userId) async {
    try {
      final allInvitations = _invitationsBox.values
          .map((data) => GroupInvitation.fromJson(Map<String, dynamic>.from(data)))
          .where((inv) => inv.inviteeId == userId && inv.status == InvitationStatus.pending)
          .where((inv) => !inv.isExpired)
          .toList();

      return allInvitations;
    } catch (e) {
      _logger.e('Failed to get pending invitations: $e');
      return [];
    }
  }

  /// Apply moderation action to a participant
  Future<void> applyModerationAction({
    required String sessionId,
    required String participantId,
    required ModerationType action,
    required String reason,
    required String moderatorId,
    Duration? duration,
  }) async {
    try {
      final moderationAction = ModerationAction(
        participantId: participantId,
        type: action,
        reason: reason,
        timestamp: DateTime.now(),
        moderatorId: moderatorId,
        duration: duration,
      );

      final key = '${sessionId}_${participantId}_${DateTime.now().millisecondsSinceEpoch}';
      await _moderationBox.put(key, moderationAction.toJson());

      // Log the action
      await _logModerationAction(sessionId, moderationAction);

      _logger.d('Applied moderation action: $action to $participantId');
    } catch (e) {
      _logger.e('Failed to apply moderation action: $e');
      rethrow;
    }
  }

  /// Track participant progress
  Future<void> updateParticipantProgress({
    required String sessionId,
    required String participantId,
    required ParticipantProgress progress,
  }) async {
    try {
      final key = '${sessionId}_$participantId';
      await _progressBox.put(key, progress.toJson());

      // Update analytics
      await _updateAnalytics(sessionId, participantId, progress);

      _logger.d('Updated participant progress: $participantId');
    } catch (e) {
      _logger.e('Failed to update participant progress: $e');
      rethrow;
    }
  }

  /// Get participant progress
  Future<ParticipantProgress?> getParticipantProgress({
    required String sessionId,
    required String participantId,
  }) async {
    try {
      final key = '${sessionId}_$participantId';
      final progressData = _progressBox.get(key);
      
      if (progressData == null) return null;

      return ParticipantProgress.fromJson(
        Map<String, dynamic>.from(progressData),
      );
    } catch (e) {
      _logger.e('Failed to get participant progress: $e');
      return null;
    }
  }

  /// Calculate group learning analytics
  Future<GroupLearningAnalytics> calculateGroupAnalytics(String sessionId) async {
    try {
      final participantProgresses = await _getSessionParticipantProgresses(sessionId);
      
      // Calculate overall metrics
      final totalMessages = participantProgresses
          .fold<int>(0, (sum, p) => sum + p.messagesContributed);
      
      final totalQuestions = participantProgresses
          .fold<int>(0, (sum, p) => sum + p.questionsAsked);
      
      final totalAnswers = participantProgresses
          .fold<int>(0, (sum, p) => sum + p.questionsAnswered);
      
      final avgEngagement = participantProgresses.isEmpty ? 0.0 : 
          participantProgresses.fold<double>(0.0, (sum, p) => sum + p.engagementScore) /
          participantProgresses.length;

      // Calculate topic coverage
      final allTopics = <String>{};
      for (final progress in participantProgresses) {
        allTopics.addAll(progress.topicsEngaged);
      }

      return GroupLearningAnalytics(
        sessionId: sessionId,
        totalParticipants: participantProgresses.length,
        totalMessages: totalMessages,
        totalQuestionsAsked: totalQuestions,
        totalQuestionsAnswered: totalAnswers,
        averageEngagementScore: avgEngagement,
        topicsCovered: allTopics.toList(),
        calculatedAt: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Failed to calculate group analytics: $e');
      rethrow;
    }
  }

  /// Generate learning recommendations for a participant
  Future<List<LearningRecommendation>> generatePersonalizedRecommendations({
    required String sessionId,
    required String participantId,
  }) async {
    try {
      final progress = await getParticipantProgress(
        sessionId: sessionId,
        participantId: participantId,
      );

      if (progress == null) {
        return [];
      }

      final recommendations = <LearningRecommendation>[];

      // Recommend based on low engagement
      if (progress.engagementScore < 0.5) {
        recommendations.add(
          const LearningRecommendation(
            id: 'engage_more',
            title: 'Increase Participation',
            description: 'Try asking questions or contributing more to discussions',
            type: RecommendationType.engagement,
            priority: RecommendationPriority.high,
          ),
        );
      }

      // Recommend based on topics engaged
      if (progress.topicsEngaged.length < 3) {
        recommendations.add(
          const LearningRecommendation(
            id: 'explore_topics',
            title: 'Explore More Topics',
            description: 'Try engaging with different subjects to broaden your knowledge',
            type: RecommendationType.content,
            priority: RecommendationPriority.medium,
          ),
        );
      }

      // Recommend based on question/answer ratio
      if (progress.questionsAsked > 0 && progress.questionsAnswered == 0) {
        recommendations.add(
          const LearningRecommendation(
            id: 'help_others',
            title: 'Help Your Peers',
            description: 'Try answering questions from other participants',
            type: RecommendationType.collaboration,
            priority: RecommendationPriority.medium,
          ),
        );
      }

      await _storeRecommendations(sessionId, participantId, recommendations);
      
      return recommendations;
    } catch (e) {
      _logger.e('Failed to generate recommendations: $e');
      return [];
    }
  }

  /// Create collaborative learning tools
  Future<CollaborativeTool> createCollaborativeTool({
    required String sessionId,
    required ToolType type,
    required String createdBy,
    required Map<String, dynamic> configuration,
  }) async {
    try {
      final tool = CollaborativeTool(
        id: 'tool_${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        type: type,
        name: _getToolName(type),
        description: _getToolDescription(type),
        createdBy: createdBy,
        createdAt: DateTime.now(),
        configuration: configuration,
        isActive: true,
        participants: [],
      );

      final key = 'collab_${tool.id}';
      await _analyticsBox.put(key, tool.toJson());

      _logger.d('Created collaborative tool: ${tool.name}');
      return tool;
    } catch (e) {
      _logger.e('Failed to create collaborative tool: $e');
      rethrow;
    }
  }

  /// Handle invitation acceptance
  Future<void> _handleInvitationAccepted(GroupInvitation invitation) async {
    // This would typically trigger the group session join logic
    // For now, just log it
    _logger.d('Invitation accepted, user ${invitation.inviteeId} should join session ${invitation.sessionId}');
  }

  /// Log moderation action
  Future<void> _logModerationAction(String sessionId, ModerationAction action) async {
    final log = ModerationLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      action: action.type.name,
      details: 'Action: ${action.type.name}, Participant: ${action.participantId}, Reason: ${action.reason}',
      timestamp: action.timestamp,
      performedBy: action.moderatorId,
    );

    await _moderationBox.put('${sessionId}_log_${log.id}', log.toJson());
  }

  /// Update analytics for participant activity
  Future<void> _updateAnalytics(String sessionId, String participantId, ParticipantProgress progress) async {
    // Store analytics data for trend analysis
    final analyticsEntry = {
      'sessionId': sessionId,
      'participantId': participantId,
      'timestamp': DateTime.now().toIso8601String(),
      'engagementScore': progress.engagementScore,
      'messagesCount': progress.messagesContributed,
      'questionsAsked': progress.questionsAsked,
      'questionsAnswered': progress.questionsAnswered,
    };

    final key = '${sessionId}_${participantId}_${DateTime.now().millisecondsSinceEpoch}';
    await _analyticsBox.put(key, analyticsEntry);
  }

  /// Get all participant progresses for a session
  Future<List<ParticipantProgress>> _getSessionParticipantProgresses(String sessionId) async {
    final progresses = <ParticipantProgress>[];
    
    for (final entry in _progressBox.toMap().entries) {
      if (entry.key.toString().startsWith(sessionId)) {
        try {
          final progress = ParticipantProgress.fromJson(
            Map<String, dynamic>.from(entry.value),
          );
          progresses.add(progress);
        } catch (e) {
          _logger.w('Failed to parse progress for key ${entry.key}: $e');
        }
      }
    }
    
    return progresses;
  }

  /// Store personalized recommendations
  Future<void> _storeRecommendations(String sessionId, String participantId, List<LearningRecommendation> recommendations) async {
    final key = 'rec_${sessionId}_$participantId';
    final data = {
      'sessionId': sessionId,
      'participantId': participantId,
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'generatedAt': DateTime.now().toIso8601String(),
    };
    
    await _analyticsBox.put(key, data);
  }

  /// Get tool name based on type
  String _getToolName(ToolType type) {
    switch (type) {
      case ToolType.whiteboard:
        return 'Collaborative Whiteboard';
      case ToolType.quiz:
        return 'Interactive Quiz';
      case ToolType.poll:
        return 'Live Poll';
      case ToolType.brainstorm:
        return 'Brainstorming Session';
      case ToolType.fileSharing:
        return 'File Sharing';
      case ToolType.codeEditor:
        return 'Collaborative Code Editor';
    }
  }

  /// Get tool description based on type
  String _getToolDescription(ToolType type) {
    switch (type) {
      case ToolType.whiteboard:
        return 'Draw, sketch, and collaborate on a shared digital whiteboard';
      case ToolType.quiz:
        return 'Create and take interactive quizzes together';
      case ToolType.poll:
        return 'Conduct live polls and see real-time results';
      case ToolType.brainstorm:
        return 'Collaborate on ideas and brainstorming sessions';
      case ToolType.fileSharing:
        return 'Share and collaborate on files and documents';
      case ToolType.codeEditor:
        return 'Write and edit code together in real-time';
    }
  }
}

/// Group learning analytics
class GroupLearningAnalytics {
  final String sessionId;
  final int totalParticipants;
  final int totalMessages;
  final int totalQuestionsAsked;
  final int totalQuestionsAnswered;
  final double averageEngagementScore;
  final List<String> topicsCovered;
  final DateTime calculatedAt;

  const GroupLearningAnalytics({
    required this.sessionId,
    required this.totalParticipants,
    required this.totalMessages,
    required this.totalQuestionsAsked,
    required this.totalQuestionsAnswered,
    required this.averageEngagementScore,
    required this.topicsCovered,
    required this.calculatedAt,
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'totalParticipants': totalParticipants,
        'totalMessages': totalMessages,
        'totalQuestionsAsked': totalQuestionsAsked,
        'totalQuestionsAnswered': totalQuestionsAnswered,
        'averageEngagementScore': averageEngagementScore,
        'topicsCovered': topicsCovered,
        'calculatedAt': calculatedAt.toIso8601String(),
      };

  factory GroupLearningAnalytics.fromJson(Map<String, dynamic> json) =>
      GroupLearningAnalytics(
        sessionId: json['sessionId'],
        totalParticipants: json['totalParticipants'],
        totalMessages: json['totalMessages'],
        totalQuestionsAsked: json['totalQuestionsAsked'],
        totalQuestionsAnswered: json['totalQuestionsAnswered'],
        averageEngagementScore: json['averageEngagementScore'],
        topicsCovered: List<String>.from(json['topicsCovered']),
        calculatedAt: DateTime.parse(json['calculatedAt']),
      );
}

/// Learning recommendation
class LearningRecommendation {
  final String id;
  final String title;
  final String description;
  final RecommendationType type;
  final RecommendationPriority priority;

  const LearningRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'priority': priority.name,
      };

  factory LearningRecommendation.fromJson(Map<String, dynamic> json) =>
      LearningRecommendation(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        type: RecommendationType.values.byName(json['type']),
        priority: RecommendationPriority.values.byName(json['priority']),
      );
}

/// Recommendation types
enum RecommendationType {
  engagement,
  content,
  collaboration,
  skill,
  practice,
}

/// Recommendation priority
enum RecommendationPriority {
  low,
  medium,
  high,
  critical,
}

/// Collaborative tool
class CollaborativeTool {
  final String id;
  final String sessionId;
  final ToolType type;
  final String name;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final Map<String, dynamic> configuration;
  final bool isActive;
  final List<String> participants;

  const CollaborativeTool({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.configuration,
    required this.isActive,
    required this.participants,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'type': type.name,
        'name': name,
        'description': description,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'configuration': configuration,
        'isActive': isActive,
        'participants': participants,
      };

  factory CollaborativeTool.fromJson(Map<String, dynamic> json) =>
      CollaborativeTool(
        id: json['id'],
        sessionId: json['sessionId'],
        type: ToolType.values.byName(json['type']),
        name: json['name'],
        description: json['description'],
        createdBy: json['createdBy'],
        createdAt: DateTime.parse(json['createdAt']),
        configuration: Map<String, dynamic>.from(json['configuration']),
        isActive: json['isActive'],
        participants: List<String>.from(json['participants']),
      );
}

/// Types of collaborative tools
enum ToolType {
  whiteboard,
  quiz,
  poll,
  brainstorm,
  fileSharing,
  codeEditor,
}