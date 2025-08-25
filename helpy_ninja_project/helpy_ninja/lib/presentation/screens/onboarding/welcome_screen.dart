import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/design_tokens.dart';
import '../../../config/routes.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../widgets/auth/glassmorphic_container.dart';
import '../../widgets/common/gradient_button.dart';

class WelcomeOnboardingScreen extends ConsumerStatefulWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  ConsumerState<WelcomeOnboardingScreen> createState() =>
      _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState
    extends ConsumerState<WelcomeOnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _logoController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: DesignTokens.animationSlow,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: DesignTokens.animationNormal,
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Start animations in sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DesignTokens.backgroundDark,
              Color(0xFF1A1A2E),
              DesignTokens.primary,
            ],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceL),
            child: Column(
              children: [
                // Top section with logo and title
                Expanded(
                  flex: 3,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated logo
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _logoScaleAnimation.value,
                              child: Transform.rotate(
                                angle: _logoRotationAnimation.value,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const RadialGradient(
                                      colors: [
                                        DesignTokens.accent,
                                        DesignTokens.primary,
                                        DesignTokens.primaryDark,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: DesignTokens.accent.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.psychology_rounded,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: DesignTokens.spaceXL),

                        // App title
                        Text(
                          l10n.appTitle,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1.0,
                              ),
                        ),

                        const SizedBox(height: DesignTokens.spaceM),

                        // Subtitle
                        Text(
                          l10n.personalAITutor,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                height: 1.5,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Features section
                Expanded(
                  flex: 2,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          _buildFeatureItem(
                            Icons.group_rounded,
                            'Multi-Agent Learning',
                            'Study with personalized AI tutors',
                          ),
                          const SizedBox(height: DesignTokens.spaceM),
                          _buildFeatureItem(
                            Icons.offline_bolt_rounded,
                            'Offline Capability',
                            'Learn anywhere, anytime',
                          ),
                          const SizedBox(height: DesignTokens.spaceM),
                          _buildFeatureItem(
                            Icons.psychology_alt_rounded,
                            'Personalized AI',
                            'Adapts to your learning style',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom section with buttons
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Get Started button
                        GradientButton(
                          onPressed: _handleGetStarted,
                          text: l10n.getStarted,
                          width: double.infinity,
                          icon: Icons.arrow_forward_rounded,
                        ),

                        const SizedBox(height: DesignTokens.spaceM),

                        // Login link for existing users
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.alreadyHaveAccount,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.go(AppRoutes.login);
                              },
                              child: Text(
                                l10n.login,
                                style: const TextStyle(
                                  color: DesignTokens.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(DesignTokens.spaceM),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DesignTokens.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            child: Icon(icon, color: DesignTokens.accent, size: 24),
          ),
          const SizedBox(width: DesignTokens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceXS),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleGetStarted() {
    // For development with auth bypassed, go directly to profile setup
    // In production, this would check authentication state
    context.go('/onboarding/profile');
  }
}
