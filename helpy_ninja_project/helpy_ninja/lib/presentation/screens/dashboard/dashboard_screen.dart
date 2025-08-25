import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../../config/design_tokens.dart';
import '../../../config/routes.dart';
import '../../../data/providers/dashboard_provider.dart';
import '../../../data/providers/providers.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/learning_stats.dart';
import '../../widgets/navigation/modern_navigation.dart';
import '../../widgets/auth/glassmorphic_container.dart';
import '../../widgets/layout/modern_layout.dart';

/// Main dashboard screen with learning progress and quick actions
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _streakAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _streakScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Header animations
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Streak animation
    _streakAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _streakScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _streakAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Start animations
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _streakAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _streakAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: const ModernAppBar(
        title: 'Dashboard',
        showProfile: true,
        showNotifications: true,
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: DesignTokens.error,
                  ),
                  const SizedBox(height: DesignTokens.spaceM),
                  Text(
                    'Error loading dashboard',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: DesignTokens.spaceS),
                  Text(
                    dashboardState.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DesignTokens.spaceL),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(dashboardProvider.notifier).refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _buildDashboardContent(context, dashboardState, user),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    DashboardState data,
    User? user,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(dashboardProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(DesignTokens.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header Section
            _buildWelcomeHeader(context, data, user),
            Space.l,

            // Progress Overview Cards
            _buildProgressOverview(context, data),
            Space.l,

            // Quick Actions
            _buildQuickActions(context),
            Space.l,

            // Recent Activity Feed
            _buildRecentActivity(context, data),
            Space.l,

            // Daily Tip from Helpy
            _buildDailyTip(context, data.dailyTip),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(
    BuildContext context,
    DashboardState data,
    User? user,
  ) {
    final currentHour = DateTime.now().hour;
    String greeting;

    if (currentHour < 12) {
      greeting = 'Good morning';
    } else if (currentHour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    final userName = user?.name ?? 'Student';

    return AnimatedBuilder(
      animation: _headerAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GlassmorphicContainer(
              padding: const EdgeInsets.all(DesignTokens.spaceL),
              child: Row(
                children: [
                  // Welcome text section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting,',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                        ),
                        const SizedBox(height: DesignTokens.spaceXS),
                        Text(
                          userName,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: DesignTokens.spaceS),
                        Text(
                          'Ready to continue your learning journey?',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.8),
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Streak display
                  const SizedBox(width: DesignTokens.spaceM),
                  _buildStreakDisplay(
                    context,
                    data.learningStats?.currentStreak ?? 0,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStreakDisplay(BuildContext context, int streak) {
    return AnimatedBuilder(
      animation: _streakScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _streakScaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.spaceM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DesignTokens.primary.withValues(alpha: 0.1),
                  DesignTokens.accent.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              border: Border.all(
                color: DesignTokens.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Fire icon with animation
                AnimatedBuilder(
                  animation: _streakAnimationController,
                  builder: (context, child) {
                    final flameScale =
                        1.0 +
                        (math.sin(
                              _streakAnimationController.value * math.pi * 2,
                            ) *
                            0.1);
                    return Transform.scale(
                      scale: flameScale,
                      child: Icon(
                        Icons.local_fire_department,
                        color: streak > 0
                            ? DesignTokens.accent
                            : Theme.of(context).colorScheme.outline,
                        size: 32,
                      ),
                    );
                  },
                ),
                const SizedBox(height: DesignTokens.spaceXS),
                Text(
                  '$streak',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: streak > 0
                        ? DesignTokens.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
                Text(
                  'day${streak != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                if (streak > 0) ...[
                  const SizedBox(height: DesignTokens.spaceXS),
                  Text(
                    'streak!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: DesignTokens.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressOverview(BuildContext context, DashboardState data) {
    final stats = data.learningStats;
    if (stats == null) {
      return const ModernSection(
        title: 'Your Progress',
        showGlassmorphism: true,
        child: Center(child: Text('Loading progress data...')),
      );
    }

    return ModernSection(
      title: 'Your Progress',
      subtitle: 'Track your learning journey',
      showGlassmorphism: true,
      child: Column(
        children: [
          // Main progress cards row
          Row(
            children: [
              Expanded(child: _buildLessonsCard(context, stats)),
              const SizedBox(width: DesignTokens.spaceM),
              Expanded(child: _buildAchievementsCard(context, stats)),
            ],
          ),
          Space.m,

          // Study time and weekly goal cards
          Row(
            children: [
              Expanded(child: _buildStudyTimeCard(context, stats)),
              const SizedBox(width: DesignTokens.spaceM),
              Expanded(child: _buildWeeklyGoalCard(context, stats)),
            ],
          ),
          Space.l,

          // Subject progress section
          _buildSubjectProgressSection(context, stats),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return ModernSection(
      title: 'Quick Actions',
      subtitle: 'Jump into your learning journey',
      showGlassmorphism: true,
      child: Column(
        children: [
          // Primary action - Start Chat with Helpy
          _buildPrimaryActionButton(
            context,
            title: 'Start Chat with Helpy',
            subtitle: 'Ask questions and get instant help',
            icon: Icons.smart_toy_rounded,
            gradient: const LinearGradient(
              colors: [DesignTokens.primary, DesignTokens.accent],
            ),
            onTap: () => context.go(AppRoutes.chatList),
          ),
          Space.m,

          // Secondary actions row
          Row(
            children: [
              Expanded(
                child: _buildSecondaryActionButton(
                  context,
                  title: 'Browse Subjects',
                  icon: Icons.explore_rounded,
                  color: DesignTokens.success,
                  onTap: () => context.go(AppRoutes.subjects),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceM),
              Expanded(
                child: _buildSecondaryActionButton(
                  context,
                  title: 'Continue Learning',
                  icon: Icons.play_circle_rounded,
                  color: DesignTokens.accent,
                  onTap: () => _handleContinueLearning(context),
                ),
              ),
            ],
          ),
          Space.s,

          // Additional quick actions
          Row(
            children: [
              Expanded(
                child: _buildTertiaryActionButton(
                  context,
                  title: 'Practice Quiz',
                  icon: Icons.quiz_rounded,
                  onTap: () => _handlePracticeQuiz(context),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceS),
              Expanded(
                child: _buildTertiaryActionButton(
                  context,
                  title: 'My Progress',
                  icon: Icons.analytics_rounded,
                  onTap: () => context.go(AppRoutes.progress),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceS),
              Expanded(
                child: _buildTertiaryActionButton(
                  context,
                  title: 'Study Groups',
                  icon: Icons.groups_rounded,
                  onTap: () => _handleStudyGroups(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, DashboardState data) {
    final stats = data.learningStats;
    if (stats == null || stats.recentActivities.isEmpty) {
      return ModernSection(
        title: 'Recent Activity',
        showGlassmorphism: true,
        child: Column(
          children: [
            Icon(
              Icons.history_rounded,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            Space.m,
            Text(
              'No recent activity yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            Space.s,
            Text(
              'Start learning to see your progress here!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ModernSection(
      title: 'Recent Activity',
      subtitle: 'Your learning timeline',
      headerAction: TextButton(
        onPressed: () {
          // Navigate to full activity page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Full activity history coming soon!'),
              backgroundColor: DesignTokens.primary,
            ),
          );
        },
        child: Text(
          'View All',
          style: TextStyle(
            color: DesignTokens.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      showGlassmorphism: true,
      child: Column(
        children: [
          // Take only the first 5 activities for dashboard
          ...stats.recentActivities
              .take(5)
              .map((activity) => _buildActivityItem(context, activity))
              .toList(),

          if (stats.recentActivities.length > 5) ...[
            Space.m,
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to full activity page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View all activities coming soon!'),
                      backgroundColor: DesignTokens.primary,
                    ),
                  );
                },
                child: Text(
                  'View ${stats.recentActivities.length - 5} more activities',
                  style: TextStyle(
                    color: DesignTokens.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDailyTip(BuildContext context, DailyTip? tip) {
    if (tip == null) return const SizedBox.shrink();

    return ModernSection(
      title: 'Daily Tip from Helpy',
      showGlassmorphism: true,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DesignTokens.primary, DesignTokens.accent],
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: DesignTokens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: DesignTokens.spaceXS),
                Text(
                  tip.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsCard(BuildContext context, LearningStats stats) {
    return AnimatedContainer(
      duration: DesignTokens.animationFast,
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.primary.withValues(alpha: 0.1),
            DesignTokens.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        border: Border.all(
          color: DesignTokens.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.spaceS),
                decoration: BoxDecoration(
                  color: DesignTokens.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: DesignTokens.primary,
                  size: 24,
                ),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: DesignTokens.success, size: 20),
            ],
          ),
          Space.m,
          Text(
            '${stats.totalLessonsCompleted}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignTokens.primary,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXS),
          Text(
            'Lessons Completed',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard(BuildContext context, LearningStats stats) {
    final progress = stats.achievementsUnlocked / stats.totalAchievements;

    return AnimatedContainer(
      duration: DesignTokens.animationFast,
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.accent.withValues(alpha: 0.1),
            DesignTokens.accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        border: Border.all(
          color: DesignTokens.accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.spaceS),
                decoration: BoxDecoration(
                  color: DesignTokens.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: DesignTokens.accent,
                  size: 24,
                ),
              ),
              const Spacer(),
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                backgroundColor: DesignTokens.accent.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(DesignTokens.accent),
              ),
            ],
          ),
          Space.m,
          Text(
            '${stats.achievementsUnlocked}/${stats.totalAchievements}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignTokens.accent,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXS),
          Text(
            'Achievements',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyTimeCard(BuildContext context, LearningStats stats) {
    return AnimatedContainer(
      duration: DesignTokens.animationFast,
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.success.withValues(alpha: 0.1),
            DesignTokens.success.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        border: Border.all(
          color: DesignTokens.success.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.spaceS),
                decoration: BoxDecoration(
                  color: DesignTokens.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: DesignTokens.success,
                  size: 24,
                ),
              ),
              const Spacer(),
              Icon(Icons.schedule, color: DesignTokens.success, size: 20),
            ],
          ),
          Space.m,
          Text(
            '${stats.totalStudyTimeHours.toStringAsFixed(1)}h',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignTokens.success,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXS),
          Text(
            'Study Time',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGoalCard(BuildContext context, LearningStats stats) {
    final progress = stats.weeklyProgress;
    final isOnTrack = stats.isOnTrackWeekly;

    return AnimatedContainer(
      duration: DesignTokens.animationFast,
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isOnTrack ? DesignTokens.success : DesignTokens.warning)
                .withValues(alpha: 0.1),
            (isOnTrack ? DesignTokens.success : DesignTokens.warning)
                .withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        border: Border.all(
          color: (isOnTrack ? DesignTokens.success : DesignTokens.warning)
              .withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.spaceS),
                decoration: BoxDecoration(
                  color:
                      (isOnTrack ? DesignTokens.success : DesignTokens.warning)
                          .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
                child: Icon(
                  isOnTrack ? Icons.track_changes_rounded : Icons.flag_rounded,
                  color: isOnTrack
                      ? DesignTokens.success
                      : DesignTokens.warning,
                  size: 24,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 40,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor:
                      (isOnTrack ? DesignTokens.success : DesignTokens.warning)
                          .withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(
                    isOnTrack ? DesignTokens.success : DesignTokens.warning,
                  ),
                  minHeight: 3,
                ),
              ),
            ],
          ),
          Space.m,
          Text(
            '${stats.weeklyCompletedLessons}/${stats.weeklyGoalLessons}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isOnTrack ? DesignTokens.success : DesignTokens.warning,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXS),
          Text(
            'Weekly Goal',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectProgressSection(
    BuildContext context,
    LearningStats stats,
  ) {
    if (stats.subjectProgress.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject Progress',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Space.m,
        ...stats.subjectProgress.values
            .map((subject) => _buildSubjectProgressItem(context, subject))
            .toList(),
      ],
    );
  }

  Widget _buildSubjectProgressItem(
    BuildContext context,
    SubjectProgress subject,
  ) {
    final progress = subject.completionPercentage / 100;

    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceM),
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getSubjectColor(subject.subjectId),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
                child: Icon(
                  _getSubjectIcon(subject.subjectId),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: DesignTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.subjectName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceXS),
                    Text(
                      '${subject.completedLessons}/${subject.totalLessons} lessons • Level ${subject.currentLevel}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getSubjectColor(subject.subjectId),
                ),
              ),
            ],
          ),
          Space.s,
          LinearProgressIndicator(
            value: progress,
            backgroundColor: _getSubjectColor(
              subject.subjectId,
            ).withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(
              _getSubjectColor(subject.subjectId),
            ),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subjectId) {
    switch (subjectId.toLowerCase()) {
      case 'mathematics':
        return DesignTokens.primary;
      case 'physics':
        return DesignTokens.accent;
      case 'chemistry':
        return DesignTokens.success;
      case 'biology':
        return DesignTokens.warning;
      case 'english':
        return const Color(0xFF9C27B0);
      case 'history':
        return const Color(0xFF795548);
      default:
        return DesignTokens.primary;
    }
  }

  IconData _getSubjectIcon(String subjectId) {
    switch (subjectId.toLowerCase()) {
      case 'mathematics':
        return Icons.calculate_rounded;
      case 'physics':
        return Icons.science_rounded;
      case 'chemistry':
        return Icons.biotech_rounded;
      case 'biology':
        return Icons.eco_rounded;
      case 'english':
        return Icons.menu_book_rounded;
      case 'history':
        return Icons.account_balance_rounded;
      default:
        return Icons.book_rounded;
    }
  }

  Widget _buildPrimaryActionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DesignTokens.animationFast,
        padding: const EdgeInsets.all(DesignTokens.spaceL),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(DesignTokens.radiusL),
          boxShadow: [
            BoxShadow(
              color: DesignTokens.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceM),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: DesignTokens.spaceL),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceXS),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DesignTokens.animationFast,
        padding: const EdgeInsets.all(DesignTokens.spaceL),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(DesignTokens.radiusL),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spaceM),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            Space.m,
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTertiaryActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DesignTokens.animationFast,
        padding: const EdgeInsets.all(DesignTokens.spaceM),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(height: DesignTokens.spaceXS),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinueLearning(BuildContext context) {
    // Get the most recent subject from user's progress
    final dashboardState = ref.read(dashboardProvider);
    final stats = dashboardState.learningStats;

    if (stats != null && stats.subjectProgress.isNotEmpty) {
      // Find the most recently studied subject
      var mostRecentSubject = stats.subjectProgress.values.first;
      for (final subject in stats.subjectProgress.values) {
        if (subject.lastStudied.isAfter(mostRecentSubject.lastStudied)) {
          mostRecentSubject = subject;
        }
      }

      // Navigate to the subject learning screen
      // For now, navigate to subjects page
      context.go(AppRoutes.subjects);

      // Show a snackbar with the continuation info
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Continuing ${mostRecentSubject.subjectName}...'),
          backgroundColor: DesignTokens.success,
        ),
      );
    } else {
      // No previous progress, navigate to subjects to choose
      context.go(AppRoutes.subjects);
    }
  }

  void _handlePracticeQuiz(BuildContext context) {
    // For now, show a coming soon message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Practice Quiz feature coming soon!'),
        backgroundColor: DesignTokens.accent,
      ),
    );
  }

  void _handleStudyGroups(BuildContext context) {
    // For now, show a coming soon message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Study Groups feature coming soon!'),
        backgroundColor: DesignTokens.primary,
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, RecentActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity icon with timeline line
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getActivityColor(activity.type),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                  border: Border.all(
                    color: _getActivityColor(
                      activity.type,
                    ).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getActivityIcon(activity.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              // Timeline line (except for last item)
              Container(
                width: 2,
                height: 20,
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(width: DesignTokens.spaceM),

          // Activity content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: DesignTokens.spaceXS),
                Text(
                  activity.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXS),
                Text(
                  _formatActivityTime(activity.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // Activity metadata/badge
          if (activity.type == RecentActivityType.achievementUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceS,
                vertical: DesignTokens.spaceXS,
              ),
              decoration: BoxDecoration(
                color: DesignTokens.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                border: Border.all(
                  color: DesignTokens.accent.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: DesignTokens.accent,
                    size: 12,
                  ),
                  const SizedBox(width: DesignTokens.spaceXS),
                  Text(
                    'NEW',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: DesignTokens.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getActivityColor(RecentActivityType type) {
    switch (type) {
      case RecentActivityType.lessonCompleted:
        return DesignTokens.success;
      case RecentActivityType.achievementUnlocked:
        return DesignTokens.accent;
      case RecentActivityType.streakMilestone:
        return DesignTokens.warning;
      case RecentActivityType.levelUp:
        return DesignTokens.primary;
      case RecentActivityType.quizPassed:
        return const Color(0xFF9C27B0);
      case RecentActivityType.practiceSession:
        return DesignTokens.warning;
      case RecentActivityType.helpyInteraction:
        return DesignTokens.accent;
      case RecentActivityType.goalReached:
        return DesignTokens.success;
      case RecentActivityType.other:
        return DesignTokens.primary;
    }
  }

  IconData _getActivityIcon(RecentActivityType type) {
    switch (type) {
      case RecentActivityType.lessonCompleted:
        return Icons.check_circle;
      case RecentActivityType.achievementUnlocked:
        return Icons.emoji_events;
      case RecentActivityType.streakMilestone:
        return Icons.local_fire_department;
      case RecentActivityType.levelUp:
        return Icons.trending_up;
      case RecentActivityType.quizPassed:
        return Icons.quiz;
      case RecentActivityType.practiceSession:
        return Icons.fitness_center;
      case RecentActivityType.helpyInteraction:
        return Icons.smart_toy;
      case RecentActivityType.goalReached:
        return Icons.flag;
      case RecentActivityType.other:
        return Icons.circle;
    }
  }

  String _formatActivityTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
