import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/design_tokens.dart';
import '../../../config/routes.dart';
import '../../../data/providers/providers.dart';
import '../../widgets/auth/glassmorphic_container.dart';
import '../../widgets/common/gradient_button.dart';

/// Helpy customization screen for onboarding flow
class HelpyCustomizationScreen extends ConsumerStatefulWidget {
  const HelpyCustomizationScreen({super.key});

  @override
  ConsumerState<HelpyCustomizationScreen> createState() =>
      _HelpyCustomizationScreenState();
}

class _HelpyCustomizationScreenState
    extends ConsumerState<HelpyCustomizationScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatAnimation;

  String _selectedPersonality = 'friendly';
  bool _isLoading = false;

  // Helpy personality options
  final List<Map<String, dynamic>> _personalities = [
    {
      'id': 'friendly',
      'name': 'Friendly & Encouraging',
      'description': 'Patient, supportive, and always positive',
      'icon': Icons.sentiment_very_satisfied,
      'color': const Color(0xFF10B981),
      'traits': ['Patient', 'Supportive', 'Positive'],
    },
    {
      'id': 'professional',
      'name': 'Professional & Focused',
      'description': 'Direct, efficient, and goal-oriented',
      'icon': Icons.work_outline,
      'color': const Color(0xFF3B82F6),
      'traits': ['Direct', 'Efficient', 'Goal-oriented'],
    },
    {
      'id': 'playful',
      'name': 'Playful & Creative',
      'description': 'Fun, energetic, and uses humor in learning',
      'icon': Icons.celebration,
      'color': const Color(0xFFEC4899),
      'traits': ['Fun', 'Creative', 'Humorous'],
    },
    {
      'id': 'wise',
      'name': 'Wise & Thoughtful',
      'description': 'Deep thinker, philosophical, and reflective',
      'icon': Icons.psychology,
      'color': const Color(0xFF8B5CF6),
      'traits': ['Thoughtful', 'Philosophical', 'Reflective'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserPreferences();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _floatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _floatController.repeat(reverse: true);
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  void _loadUserPreferences() {
    final user = ref.read(currentUserProvider);
    if (user?.preferences != null) {
      setState(() {
        _selectedPersonality = user!.preferences.preferredHelpyPersonality;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Update user preferences with Helpy customization
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final updatedPreferences = user.preferences.copyWith(
          preferredHelpyPersonality: _selectedPersonality,
        );

        await ref
            .read(authProvider.notifier)
            .updateProfileData(preferences: updatedPreferences);
      }

      // Complete onboarding
      await ref.read(authProvider.notifier).completeOnboarding();

      // Navigate to dashboard
      if (mounted) {
        context.go(AppRoutes.dashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing setup: $e'),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildPersonalityCard(Map<String, dynamic> personality) {
    final isSelected = _selectedPersonality == personality['id'];

    return GestureDetector(
      onTap: () => setState(() {
        _selectedPersonality = personality['id'];
      }),
      child: AnimatedContainer(
        duration: DesignTokens.animationFast,
        margin: const EdgeInsets.only(bottom: DesignTokens.spaceM),
        padding: const EdgeInsets.all(DesignTokens.spaceM),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (personality['color'] as Color).withValues(alpha: 0.2),
                    (personality['color'] as Color).withValues(alpha: 0.1),
                  ],
                )
              : null,
          border: Border.all(
            color: isSelected
                ? personality['color'] as Color
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? personality['color'] as Color
                        : (personality['color'] as Color).withValues(
                            alpha: 0.1,
                          ),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                  ),
                  child: Icon(
                    personality['icon'] as IconData,
                    color: isSelected
                        ? Colors.white
                        : personality['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        personality['name'],
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? personality['color'] as Color
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                      ),
                      Text(
                        personality['description'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: personality['color'] as Color,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: DesignTokens.spaceM),
            Wrap(
              spacing: DesignTokens.spaceS,
              children: (personality['traits'] as List<String>).map((trait) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spaceS,
                    vertical: DesignTokens.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (personality['color'] as Color).withValues(alpha: 0.2)
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                  ),
                  child: Text(
                    trait,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? personality['color'] as Color
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpyPreview() {
    final selectedPersonality = _personalities.firstWhere(
      (p) => p['id'] == _selectedPersonality,
    );

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 10 * _floatAnimation.value),
          child: GlassmorphicContainer(
            padding: const EdgeInsets.all(DesignTokens.spaceL),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        selectedPersonality['color'] as Color,
                        (selectedPersonality['color'] as Color).withValues(
                          alpha: 0.6,
                        ),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (selectedPersonality['color'] as Color)
                            .withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🥷', style: TextStyle(fontSize: 64)),
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceM),

                // Greeting bubble
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceM),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    border: Border.all(
                      color: selectedPersonality['color'] as Color,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Hi! I\'m Helpy 👋',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: selectedPersonality['color'] as Color,
                                ),
                      ),
                      const SizedBox(height: DesignTokens.spaceXS),
                      Text(
                        _getPersonalityGreeting(_selectedPersonality),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getPersonalityGreeting(String personality) {
    switch (personality) {
      case 'friendly':
        return 'I\'m so excited to learn together! We\'ll make this journey fun and rewarding. 😊';
      case 'professional':
        return 'I\'m here to help you achieve your academic goals efficiently and effectively.';
      case 'playful':
        return 'Ready for some fun learning adventures? Let\'s make studying awesome! 🎉';
      case 'wise':
        return 'Learning is a journey of discovery. I\'m here to guide you thoughtfully through each step.';
      default:
        return 'Welcome! I\'m here to support your learning journey.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(DesignTokens.spaceL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            const SizedBox(width: DesignTokens.spaceS),
                            Text(
                              'Meet Your Helpy',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignTokens.spaceM),

                        // Progress indicator
                        LinearProgressIndicator(
                          value: 1.0, // Step 3 of 3
                          backgroundColor: colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            DesignTokens.accent,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spaceS),
                        Text(
                          'Step 3 of 3 - Almost done!',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceL,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Helpy preview
                          _buildHelpyPreview(),
                          const SizedBox(height: DesignTokens.spaceXL),

                          // Personality selection
                          Text(
                            'Choose Helpy\'s Personality',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: DesignTokens.accent,
                                ),
                          ),
                          const SizedBox(height: DesignTokens.spaceS),
                          Text(
                            'Select the personality that matches your learning style best.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                          ),
                          const SizedBox(height: DesignTokens.spaceL),

                          // Personality options
                          ..._personalities.map((personality) {
                            return _buildPersonalityCard(personality);
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Complete button
                  Padding(
                    padding: const EdgeInsets.all(DesignTokens.spaceL),
                    child: GradientButton(
                      onPressed: _isLoading ? null : _handleComplete,
                      text: 'Start Learning with Helpy!',
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
