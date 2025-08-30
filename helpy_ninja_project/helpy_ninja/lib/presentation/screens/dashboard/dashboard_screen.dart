import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/design_tokens.dart';
import '../../../data/providers/dashboard_provider.dart';
import '../../../data/providers/providers.dart';
import '../../../domain/entities/user.dart';
import '../../widgets/navigation/modern_navigation.dart';
import '../../widgets/layout/modern_layout.dart';
import '../../widgets/dashboard/dashboard_components.dart';

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
  late Future<void> _streakAnimationFuture;

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
    _streakAnimationFuture = Future.delayed(
      const Duration(milliseconds: 600),
      () {
        if (mounted) {
          _streakAnimationController.forward();
        }
      },
    );
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
              ? ErrorStateWidget(
                  error: dashboardState.error!,
                  onRetry: () => ref.read(dashboardProvider.notifier).refresh(),
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
            WelcomeHeader(
              user: user,
              learningStats: data.learningStats,
              fadeAnimation: _fadeAnimation,
              slideAnimation: _slideAnimation,
            ),
            Space.l,

            // Progress Overview Cards
            ProgressOverviewSection(learningStats: data.learningStats),
            Space.l,

            // Quick Actions
            const QuickActionsSection(),
            Space.l,

            // Recent Activity Feed
            if (data.learningStats?.recentActivities.isNotEmpty == true)
              RecentActivitySection(
                activities: data.learningStats!.recentActivities,
              ),
            Space.l,

            // Daily Tip from Helpy
            DailyTipCard(tip: data.dailyTip),

            // Subject Progress Section
            if (data.learningStats?.subjectProgress.isNotEmpty == true)
              SubjectProgressSection(
                subjectProgress: data.learningStats!.subjectProgress,
              ),
          ],
        ),
      ),
    );
  }
}
