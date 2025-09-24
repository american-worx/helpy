import 'dart:async';
import 'dart:math' as math;
import 'package:logger/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Comprehensive learning analytics service for tracking progress and performance
class LearningAnalyticsService {
  final Logger _logger = Logger();
  
  static const String _analyticsBoxName = 'learning_analytics';
  static const String _trendsBoxName = 'performance_trends';
  static const String _insightsBoxName = 'learning_insights';

  late Box<Map> _analyticsBox;
  late Box<Map> _trendsBox;
  late Box<Map> _insightsBox;

  /// Initialize the learning analytics service
  Future<void> initialize() async {
    try {
      _analyticsBox = await Hive.openBox<Map>(_analyticsBoxName);
      _trendsBox = await Hive.openBox<Map>(_trendsBoxName);
      _insightsBox = await Hive.openBox<Map>(_insightsBoxName);
      
      _logger.d('Learning analytics service initialized');
    } catch (e) {
      _logger.e('Failed to initialize learning analytics service: $e');
      rethrow;
    }
  }

  /// Track learning session activity
  Future<void> trackLearningActivity({
    required String userId,
    required String sessionId,
    required LearningActivity activity,
  }) async {
    try {
      final activityRecord = LearningActivityRecord(
        id: 'act_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        sessionId: sessionId,
        activity: activity,
        timestamp: DateTime.now(),
        metadata: {},
      );

      await _analyticsBox.put(activityRecord.id, activityRecord.toJson());
      await _updateUserTrends(userId, activity);
      
      _logger.d('Tracked learning activity: ${activity.type} for user $userId');
    } catch (e) {
      _logger.e('Failed to track learning activity: $e');
      rethrow;
    }
  }

  /// Generate comprehensive learning report for a user
  Future<LearningReport> generateUserReport(String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      startDate ??= DateTime.now().subtract(const Duration(days: 30));
      endDate ??= DateTime.now();

      final activities = await _getUserActivitiesInRange(userId, startDate, endDate);
      final trends = await _getUserTrends(userId);
      
      // Calculate metrics
      final totalSessions = _countUniqueSessions(activities);
      final totalTime = _calculateTotalTime(activities);
      final averageSessionDuration = totalSessions > 0 
          ? Duration(milliseconds: totalTime.inMilliseconds ~/ totalSessions)
          : Duration.zero;

      final subjectBreakdown = _analyzeSubjectBreakdown(activities);
      final skillProgression = _analyzeSkillProgression(activities);
      final engagementMetrics = _calculateEngagementMetrics(activities);
      final learningVelocity = _calculateLearningVelocity(activities, trends);

      final report = LearningReport(
        userId: userId,
        reportPeriod: ReportPeriod(start: startDate, end: endDate),
        totalSessions: totalSessions,
        totalLearningTime: totalTime,
        averageSessionDuration: averageSessionDuration,
        subjectBreakdown: subjectBreakdown,
        skillProgression: skillProgression,
        engagementMetrics: engagementMetrics,
        learningVelocity: learningVelocity,
        achievements: await _getUserAchievements(userId, startDate, endDate),
        recommendations: await _generatePersonalizedInsights(userId, activities),
        generatedAt: DateTime.now(),
      );

      // Store the report for future reference
      await _storeReport(userId, report);
      
      return report;
    } catch (e) {
      _logger.e('Failed to generate user report: $e');
      rethrow;
    }
  }

  /// Analyze performance trends over time
  Future<PerformanceTrends> analyzePerformanceTrends(String userId, {
    Duration period = const Duration(days: 90),
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(period);
      
      final activities = await _getUserActivitiesInRange(userId, startDate, endDate);
      
      // Group activities by week
      final weeklyData = _groupActivitiesByWeek(activities);
      final monthlyData = _groupActivitiesByMonth(activities);
      
      // Calculate trend metrics
      final engagementTrend = _calculateEngagementTrend(weeklyData);
      final performanceTrend = _calculatePerformanceTrend(weeklyData);
      final consistencyScore = _calculateConsistencyScore(weeklyData);
      final improvementRate = _calculateImprovementRate(monthlyData);

      final trends = PerformanceTrends(
        userId: userId,
        period: ReportPeriod(start: startDate, end: endDate),
        weeklyEngagement: engagementTrend,
        monthlyPerformance: performanceTrend,
        consistencyScore: consistencyScore,
        improvementRate: improvementRate,
        strongestSubjects: _identifyStrongestSubjects(activities),
        areasForImprovement: _identifyAreasForImprovement(activities),
        predictedPerformance: _predictFuturePerformance(trends: performanceTrend),
        calculatedAt: DateTime.now(),
      );

      await _storeTrends(userId, trends);
      
      return trends;
    } catch (e) {
      _logger.e('Failed to analyze performance trends: $e');
      rethrow;
    }
  }

  /// Generate personalized learning recommendations
  Future<List<PersonalizedRecommendation>> generatePersonalizedRecommendations(String userId) async {
    try {
      final report = await generateUserReport(userId);
      final trends = await analyzePerformanceTrends(userId);
      
      final recommendations = <PersonalizedRecommendation>[];

      // Recommendation based on engagement
      if (report.engagementMetrics.averageEngagement < 0.6) {
        recommendations.add(PersonalizedRecommendation(
          id: 'improve_engagement',
          type: RecommendationType.engagement,
          priority: RecommendationPriority.high,
          title: 'Boost Your Learning Engagement',
          description: 'Your engagement score is below average. Try interactive learning methods.',
          actionItems: [
            'Join group study sessions',
            'Ask more questions during lessons',
            'Take regular breaks to maintain focus',
          ],
          expectedImpact: ImpactLevel.high,
        ));
      }

      // Recommendation based on consistency
      if (trends.consistencyScore < 0.5) {
        recommendations.add(PersonalizedRecommendation(
          id: 'improve_consistency',
          type: RecommendationType.habit,
          priority: RecommendationPriority.high,
          title: 'Build a Consistent Learning Routine',
          description: 'Regular study sessions will improve your learning outcomes.',
          actionItems: [
            'Set daily study reminders',
            'Create a dedicated study schedule',
            'Track your daily progress',
          ],
          expectedImpact: ImpactLevel.high,
        ));
      }

      // Subject-specific recommendations
      for (final weakSubject in trends.areasForImprovement.take(2)) {
        recommendations.add(PersonalizedRecommendation(
          id: 'improve_${weakSubject.toLowerCase()}',
          type: RecommendationType.content,
          priority: RecommendationPriority.medium,
          title: 'Strengthen Your ${weakSubject} Skills',
          description: 'Focus on improving your performance in ${weakSubject}.',
          actionItems: [
            'Practice ${weakSubject.toLowerCase()} exercises daily',
            'Find study partners for ${weakSubject.toLowerCase()}',
            'Use visual aids and interactive content',
          ],
          expectedImpact: ImpactLevel.medium,
        ));
      }

      // Time management recommendation
      if (report.averageSessionDuration < const Duration(minutes: 15)) {
        recommendations.add(PersonalizedRecommendation(
          id: 'extend_sessions',
          type: RecommendationType.strategy,
          priority: RecommendationPriority.medium,
          title: 'Extend Your Study Sessions',
          description: 'Longer focused sessions can improve retention and understanding.',
          actionItems: [
            'Gradually increase session length',
            'Use the Pomodoro Technique',
            'Eliminate distractions during study time',
          ],
          expectedImpact: ImpactLevel.medium,
        ));
      }

      await _storeRecommendations(userId, recommendations);
      
      return recommendations;
    } catch (e) {
      _logger.e('Failed to generate personalized recommendations: $e');
      return [];
    }
  }

  /// Update user learning trends
  Future<void> _updateUserTrends(String userId, LearningActivity activity) async {
    final today = DateTime.now();
    final trendsKey = '${userId}_${today.year}_${today.month}_${today.day}';
    
    final existingTrends = _trendsBox.get(trendsKey);
    final dailyTrends = existingTrends != null 
        ? DailyLearningTrends.fromJson(Map<String, dynamic>.from(existingTrends))
        : DailyLearningTrends(
            userId: userId,
            date: today,
            activities: [],
            totalTime: Duration.zero,
            subjectsStudied: [],
            engagementScore: 0.0,
          );

    // Update trends with new activity
    final updatedTrends = dailyTrends.addActivity(activity);
    await _trendsBox.put(trendsKey, updatedTrends.toJson());
  }

  /// Get user activities in a date range
  Future<List<LearningActivityRecord>> _getUserActivitiesInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final activities = <LearningActivityRecord>[];
    
    for (final entry in _analyticsBox.toMap().entries) {
      try {
        final record = LearningActivityRecord.fromJson(
          Map<String, dynamic>.from(entry.value),
        );
        
        if (record.userId == userId && 
            record.timestamp.isAfter(startDate) &&
            record.timestamp.isBefore(endDate)) {
          activities.add(record);
        }
      } catch (e) {
        _logger.w('Failed to parse activity record: $e');
      }
    }
    
    activities.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return activities;
  }

  /// Get user trends data
  Future<List<DailyLearningTrends>> _getUserTrends(String userId) async {
    final trends = <DailyLearningTrends>[];
    
    for (final entry in _trendsBox.toMap().entries) {
      if (entry.key.toString().startsWith(userId)) {
        try {
          final dailyTrend = DailyLearningTrends.fromJson(
            Map<String, dynamic>.from(entry.value),
          );
          trends.add(dailyTrend);
        } catch (e) {
          _logger.w('Failed to parse trends data: $e');
        }
      }
    }
    
    trends.sort((a, b) => a.date.compareTo(b.date));
    return trends;
  }

  /// Calculate various analytics metrics
  int _countUniqueSessions(List<LearningActivityRecord> activities) {
    return activities.map((a) => a.sessionId).toSet().length;
  }

  Duration _calculateTotalTime(List<LearningActivityRecord> activities) {
    return activities.fold(Duration.zero, (total, activity) => total + activity.activity.duration);
  }

  Map<String, SubjectAnalytics> _analyzeSubjectBreakdown(List<LearningActivityRecord> activities) {
    final subjects = <String, List<LearningActivity>>{};
    
    for (final record in activities) {
      final subject = record.activity.subject ?? 'General';
      subjects.putIfAbsent(subject, () => []).add(record.activity);
    }

    return subjects.map((subject, activities) {
      final totalTime = activities.fold(Duration.zero, (sum, a) => sum + a.duration);
      final avgScore = activities.where((a) => a.score != null)
          .fold(0.0, (sum, a) => sum + a.score!) / 
          math.max(1, activities.where((a) => a.score != null).length);

      return MapEntry(subject, SubjectAnalytics(
        subject: subject,
        totalTime: totalTime,
        sessionCount: activities.length,
        averageScore: avgScore,
        completionRate: activities.where((a) => a.completed).length / activities.length,
        improvementTrend: 0.0, // Would be calculated from historical data
      ));
    });
  }

  Map<String, double> _analyzeSkillProgression(List<LearningActivityRecord> activities) {
    final skills = <String, List<double>>{};
    
    for (final record in activities) {
      if (record.activity.skillsAssessed != null) {
        for (final skill in record.activity.skillsAssessed!) {
          final score = record.activity.score ?? 0.0;
          skills.putIfAbsent(skill, () => []).add(score);
        }
      }
    }

    return skills.map((skill, scores) {
      // Calculate progression as trend over time
      if (scores.length < 2) return MapEntry(skill, 0.0);
      
      final firstHalf = scores.take(scores.length ~/ 2).toList();
      final secondHalf = scores.skip(scores.length ~/ 2).toList();
      
      final firstAvg = firstHalf.fold(0.0, (sum, s) => sum + s) / firstHalf.length;
      final secondAvg = secondHalf.fold(0.0, (sum, s) => sum + s) / secondHalf.length;
      
      return MapEntry(skill, secondAvg - firstAvg);
    });
  }

  EngagementMetrics _calculateEngagementMetrics(List<LearningActivityRecord> activities) {
    if (activities.isEmpty) {
      return const EngagementMetrics(
        averageEngagement: 0.0,
        peakEngagementTime: 0,
        engagementTrend: 0.0,
        interactionRate: 0.0,
      );
    }

    final avgEngagement = activities
        .where((a) => a.activity.engagementScore != null)
        .fold(0.0, (sum, a) => sum + a.activity.engagementScore!) /
        activities.where((a) => a.activity.engagementScore != null).length;

    // Find peak engagement time (hour of day)
    final hourCounts = <int, int>{};
    for (final activity in activities) {
      final hour = activity.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    final peakHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b).key;

    return EngagementMetrics(
      averageEngagement: avgEngagement,
      peakEngagementTime: peakHour,
      engagementTrend: 0.0, // Would calculate from historical data
      interactionRate: activities.where((a) => a.activity.interactive).length / activities.length,
    );
  }

  double _calculateLearningVelocity(
    List<LearningActivityRecord> activities,
    List<DailyLearningTrends> trends,
  ) {
    if (trends.length < 2) return 0.0;
    
    // Calculate improvement rate over time
    final recentTrends = trends.length > 7 ? trends.sublist(trends.length - 7) : trends;
    final olderTrends = trends.take(7).toList();
    
    final recentAvgScore = recentTrends.fold(0.0, (sum, t) => sum + t.engagementScore) / recentTrends.length;
    final olderAvgScore = olderTrends.fold(0.0, (sum, t) => sum + t.engagementScore) / olderTrends.length;
    
    return recentAvgScore - olderAvgScore;
  }

  // Additional helper methods for trend analysis
  Map<int, List<LearningActivityRecord>> _groupActivitiesByWeek(List<LearningActivityRecord> activities) {
    final grouped = <int, List<LearningActivityRecord>>{};
    for (final activity in activities) {
      final weekOfYear = _getWeekOfYear(activity.timestamp);
      grouped.putIfAbsent(weekOfYear, () => []).add(activity);
    }
    return grouped;
  }

  Map<int, List<LearningActivityRecord>> _groupActivitiesByMonth(List<LearningActivityRecord> activities) {
    final grouped = <int, List<LearningActivityRecord>>{};
    for (final activity in activities) {
      final monthKey = activity.timestamp.year * 100 + activity.timestamp.month;
      grouped.putIfAbsent(monthKey, () => []).add(activity);
    }
    return grouped;
  }

  List<double> _calculateEngagementTrend(Map<int, List<LearningActivityRecord>> weeklyData) {
    return weeklyData.entries.map((entry) {
      final activities = entry.value;
      return activities
          .where((a) => a.activity.engagementScore != null)
          .fold(0.0, (sum, a) => sum + a.activity.engagementScore!) /
          math.max(1, activities.where((a) => a.activity.engagementScore != null).length);
    }).toList();
  }

  List<double> _calculatePerformanceTrend(Map<int, List<LearningActivityRecord>> weeklyData) {
    return weeklyData.entries.map((entry) {
      final activities = entry.value;
      return activities
          .where((a) => a.activity.score != null)
          .fold(0.0, (sum, a) => sum + a.activity.score!) /
          math.max(1, activities.where((a) => a.activity.score != null).length);
    }).toList();
  }

  double _calculateConsistencyScore(Map<int, List<LearningActivityRecord>> weeklyData) {
    if (weeklyData.isEmpty) return 0.0;
    
    final weeklySessions = weeklyData.values.map((activities) => activities.length).toList();
    final avgSessions = weeklySessions.fold(0, (sum, count) => sum + count) / weeklySessions.length;
    final variance = weeklySessions.fold(0.0, (sum, count) => sum + math.pow(count - avgSessions, 2)) / weeklySessions.length;
    final stdDev = math.sqrt(variance);
    
    // Consistency score is higher when standard deviation is lower
    return math.max(0.0, 1.0 - (stdDev / avgSessions));
  }

  double _calculateImprovementRate(Map<int, List<LearningActivityRecord>> monthlyData) {
    if (monthlyData.length < 2) return 0.0;
    
    final months = monthlyData.keys.toList()..sort();
    final firstMonth = monthlyData[months.first]!;
    final lastMonth = monthlyData[months.last]!;
    
    final firstScore = firstMonth
        .where((a) => a.activity.score != null)
        .fold(0.0, (sum, a) => sum + a.activity.score!) /
        math.max(1, firstMonth.where((a) => a.activity.score != null).length);
    
    final lastScore = lastMonth
        .where((a) => a.activity.score != null)
        .fold(0.0, (sum, a) => sum + a.activity.score!) /
        math.max(1, lastMonth.where((a) => a.activity.score != null).length);
    
    return lastScore - firstScore;
  }

  List<String> _identifyStrongestSubjects(List<LearningActivityRecord> activities) {
    final subjectScores = <String, List<double>>{};
    
    for (final record in activities) {
      final subject = record.activity.subject ?? 'General';
      if (record.activity.score != null) {
        subjectScores.putIfAbsent(subject, () => []).add(record.activity.score!);
      }
    }
    
    final sortedEntries = subjectScores.entries
        .map((e) => MapEntry(e.key, e.value.fold(0.0, (sum, s) => sum + s) / e.value.length))
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
        
    return sortedEntries
        .take(3)
        .map((e) => e.key)
        .toList();
  }

  List<String> _identifyAreasForImprovement(List<LearningActivityRecord> activities) {
    final subjectScores = <String, List<double>>{};
    
    for (final record in activities) {
      final subject = record.activity.subject ?? 'General';
      if (record.activity.score != null) {
        subjectScores.putIfAbsent(subject, () => []).add(record.activity.score!);
      }
    }
    
    final sortedEntries = subjectScores.entries
        .map((e) => MapEntry(e.key, e.value.fold(0.0, (sum, s) => sum + s) / e.value.length))
        .toList()
        ..sort((a, b) => a.value.compareTo(b.value));
        
    return sortedEntries
        .take(3)
        .map((e) => e.key)
        .toList();
  }

  List<double> _predictFuturePerformance({required List<double> trends}) {
    if (trends.length < 3) return [];
    
    // Simple linear regression for prediction
    final n = trends.length;
    final x = List.generate(n, (i) => i.toDouble());
    final y = trends;
    
    final sumX = x.fold(0.0, (sum, val) => sum + val);
    final sumY = y.fold(0.0, (sum, val) => sum + val);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).fold(0.0, (sum, val) => sum + val);
    final sumXX = x.fold(0.0, (sum, val) => sum + val * val);
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;
    
    // Predict next 4 weeks
    return List.generate(4, (i) => slope * (n + i) + intercept);
  }

  int _getWeekOfYear(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return (dayOfYear / 7).ceil();
  }

  Future<List<Achievement>> _getUserAchievements(String userId, DateTime startDate, DateTime endDate) async {
    // This would be implemented based on actual achievement system
    return [];
  }

  Future<List<PersonalizedInsight>> _generatePersonalizedInsights(String userId, List<LearningActivityRecord> activities) async {
    // Generate insights based on activity patterns
    return [];
  }

  Future<void> _storeReport(String userId, LearningReport report) async {
    final key = 'report_${userId}_${report.generatedAt.millisecondsSinceEpoch}';
    await _insightsBox.put(key, report.toJson());
  }

  Future<void> _storeTrends(String userId, PerformanceTrends trends) async {
    final key = 'trends_${userId}_${trends.calculatedAt.millisecondsSinceEpoch}';
    await _trendsBox.put(key, trends.toJson());
  }

  Future<void> _storeRecommendations(String userId, List<PersonalizedRecommendation> recommendations) async {
    final key = 'rec_${userId}_${DateTime.now().millisecondsSinceEpoch}';
    final data = {
      'userId': userId,
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'generatedAt': DateTime.now().toIso8601String(),
    };
    await _insightsBox.put(key, data);
  }
}

// Data classes for learning analytics
class LearningActivity {
  final ActivityType type;
  final String? subject;
  final Duration duration;
  final double? score;
  final double? engagementScore;
  final bool completed;
  final bool interactive;
  final List<String>? skillsAssessed;
  final Map<String, dynamic> metadata;

  const LearningActivity({
    required this.type,
    this.subject,
    required this.duration,
    this.score,
    this.engagementScore,
    required this.completed,
    this.interactive = false,
    this.skillsAssessed,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'subject': subject,
        'duration': duration.inMilliseconds,
        'score': score,
        'engagementScore': engagementScore,
        'completed': completed,
        'interactive': interactive,
        'skillsAssessed': skillsAssessed,
        'metadata': metadata,
      };

  factory LearningActivity.fromJson(Map<String, dynamic> json) => LearningActivity(
        type: ActivityType.values.byName(json['type']),
        subject: json['subject'],
        duration: Duration(milliseconds: json['duration']),
        score: json['score'],
        engagementScore: json['engagementScore'],
        completed: json['completed'],
        interactive: json['interactive'] ?? false,
        skillsAssessed: json['skillsAssessed']?.cast<String>(),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );
}

class LearningActivityRecord {
  final String id;
  final String userId;
  final String sessionId;
  final LearningActivity activity;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const LearningActivityRecord({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.activity,
    required this.timestamp,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'sessionId': sessionId,
        'activity': activity.toJson(),
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };

  factory LearningActivityRecord.fromJson(Map<String, dynamic> json) =>
      LearningActivityRecord(
        id: json['id'],
        userId: json['userId'],
        sessionId: json['sessionId'],
        activity: LearningActivity.fromJson(json['activity']),
        timestamp: DateTime.parse(json['timestamp']),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );
}

class DailyLearningTrends {
  final String userId;
  final DateTime date;
  final List<LearningActivity> activities;
  final Duration totalTime;
  final List<String> subjectsStudied;
  final double engagementScore;

  const DailyLearningTrends({
    required this.userId,
    required this.date,
    required this.activities,
    required this.totalTime,
    required this.subjectsStudied,
    required this.engagementScore,
  });

  DailyLearningTrends addActivity(LearningActivity activity) {
    final updatedActivities = [...activities, activity];
    final updatedTime = totalTime + activity.duration;
    final updatedSubjects = {...subjectsStudied};
    if (activity.subject != null) {
      updatedSubjects.add(activity.subject!);
    }

    final avgEngagement = updatedActivities
        .where((a) => a.engagementScore != null)
        .fold(0.0, (sum, a) => sum + a.engagementScore!) /
        math.max(1, updatedActivities.where((a) => a.engagementScore != null).length);

    return DailyLearningTrends(
      userId: userId,
      date: date,
      activities: updatedActivities,
      totalTime: updatedTime,
      subjectsStudied: updatedSubjects.toList(),
      engagementScore: avgEngagement,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'date': date.toIso8601String(),
        'activities': activities.map((a) => a.toJson()).toList(),
        'totalTime': totalTime.inMilliseconds,
        'subjectsStudied': subjectsStudied,
        'engagementScore': engagementScore,
      };

  factory DailyLearningTrends.fromJson(Map<String, dynamic> json) =>
      DailyLearningTrends(
        userId: json['userId'],
        date: DateTime.parse(json['date']),
        activities: (json['activities'] as List)
            .map((a) => LearningActivity.fromJson(a))
            .toList(),
        totalTime: Duration(milliseconds: json['totalTime']),
        subjectsStudied: List<String>.from(json['subjectsStudied']),
        engagementScore: json['engagementScore'],
      );
}

// Additional data classes (LearningReport, PerformanceTrends, etc.)
class LearningReport {
  final String userId;
  final ReportPeriod reportPeriod;
  final int totalSessions;
  final Duration totalLearningTime;
  final Duration averageSessionDuration;
  final Map<String, SubjectAnalytics> subjectBreakdown;
  final Map<String, double> skillProgression;
  final EngagementMetrics engagementMetrics;
  final double learningVelocity;
  final List<Achievement> achievements;
  final List<PersonalizedInsight> recommendations;
  final DateTime generatedAt;

  const LearningReport({
    required this.userId,
    required this.reportPeriod,
    required this.totalSessions,
    required this.totalLearningTime,
    required this.averageSessionDuration,
    required this.subjectBreakdown,
    required this.skillProgression,
    required this.engagementMetrics,
    required this.learningVelocity,
    required this.achievements,
    required this.recommendations,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'reportPeriod': reportPeriod.toJson(),
        'totalSessions': totalSessions,
        'totalLearningTime': totalLearningTime.inMilliseconds,
        'averageSessionDuration': averageSessionDuration.inMilliseconds,
        'subjectBreakdown': subjectBreakdown.map((k, v) => MapEntry(k, v.toJson())),
        'skillProgression': skillProgression,
        'engagementMetrics': engagementMetrics.toJson(),
        'learningVelocity': learningVelocity,
        'achievements': achievements.map((a) => a.toJson()).toList(),
        'recommendations': recommendations.map((r) => r.toJson()).toList(),
        'generatedAt': generatedAt.toIso8601String(),
      };
}

enum ActivityType {
  lesson,
  quiz,
  discussion,
  practice,
  review,
  project,
  assessment,
}

class ReportPeriod {
  final DateTime start;
  final DateTime end;

  const ReportPeriod({required this.start, required this.end});

  Map<String, dynamic> toJson() => {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };

  factory ReportPeriod.fromJson(Map<String, dynamic> json) => ReportPeriod(
        start: DateTime.parse(json['start']),
        end: DateTime.parse(json['end']),
      );
}

class SubjectAnalytics {
  final String subject;
  final Duration totalTime;
  final int sessionCount;
  final double averageScore;
  final double completionRate;
  final double improvementTrend;

  const SubjectAnalytics({
    required this.subject,
    required this.totalTime,
    required this.sessionCount,
    required this.averageScore,
    required this.completionRate,
    required this.improvementTrend,
  });

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'totalTime': totalTime.inMilliseconds,
        'sessionCount': sessionCount,
        'averageScore': averageScore,
        'completionRate': completionRate,
        'improvementTrend': improvementTrend,
      };

  factory SubjectAnalytics.fromJson(Map<String, dynamic> json) => SubjectAnalytics(
        subject: json['subject'],
        totalTime: Duration(milliseconds: json['totalTime']),
        sessionCount: json['sessionCount'],
        averageScore: json['averageScore'],
        completionRate: json['completionRate'],
        improvementTrend: json['improvementTrend'],
      );
}

class EngagementMetrics {
  final double averageEngagement;
  final int peakEngagementTime;
  final double engagementTrend;
  final double interactionRate;

  const EngagementMetrics({
    required this.averageEngagement,
    required this.peakEngagementTime,
    required this.engagementTrend,
    required this.interactionRate,
  });

  Map<String, dynamic> toJson() => {
        'averageEngagement': averageEngagement,
        'peakEngagementTime': peakEngagementTime,
        'engagementTrend': engagementTrend,
        'interactionRate': interactionRate,
      };

  factory EngagementMetrics.fromJson(Map<String, dynamic> json) => EngagementMetrics(
        averageEngagement: json['averageEngagement'],
        peakEngagementTime: json['peakEngagementTime'],
        engagementTrend: json['engagementTrend'],
        interactionRate: json['interactionRate'],
      );
}

class PerformanceTrends {
  final String userId;
  final ReportPeriod period;
  final List<double> weeklyEngagement;
  final List<double> monthlyPerformance;
  final double consistencyScore;
  final double improvementRate;
  final List<String> strongestSubjects;
  final List<String> areasForImprovement;
  final List<double> predictedPerformance;
  final DateTime calculatedAt;

  const PerformanceTrends({
    required this.userId,
    required this.period,
    required this.weeklyEngagement,
    required this.monthlyPerformance,
    required this.consistencyScore,
    required this.improvementRate,
    required this.strongestSubjects,
    required this.areasForImprovement,
    required this.predictedPerformance,
    required this.calculatedAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'period': period.toJson(),
        'weeklyEngagement': weeklyEngagement,
        'monthlyPerformance': monthlyPerformance,
        'consistencyScore': consistencyScore,
        'improvementRate': improvementRate,
        'strongestSubjects': strongestSubjects,
        'areasForImprovement': areasForImprovement,
        'predictedPerformance': predictedPerformance,
        'calculatedAt': calculatedAt.toIso8601String(),
      };
}

class PersonalizedRecommendation {
  final String id;
  final RecommendationType type;
  final RecommendationPriority priority;
  final String title;
  final String description;
  final List<String> actionItems;
  final ImpactLevel expectedImpact;

  const PersonalizedRecommendation({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.actionItems,
    required this.expectedImpact,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'priority': priority.name,
        'title': title,
        'description': description,
        'actionItems': actionItems,
        'expectedImpact': expectedImpact.name,
      };
}

enum RecommendationType {
  engagement,
  content,
  collaboration,
  skill,
  practice,
  habit,
  strategy,
}

enum RecommendationPriority {
  low,
  medium,
  high,
  critical,
}

enum ImpactLevel {
  low,
  medium,
  high,
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final DateTime earnedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.earnedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'earnedAt': earnedAt.toIso8601String(),
      };
}

class PersonalizedInsight {
  final String id;
  final String title;
  final String description;

  const PersonalizedInsight({
    required this.id,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
      };
}