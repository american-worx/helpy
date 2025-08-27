import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/design_tokens.dart';
import '../../../config/routes.dart';
import '../../../data/providers/providers.dart';
import '../../widgets/auth/glassmorphic_container.dart';
import '../../widgets/common/gradient_button.dart';

/// Subject selection screen for onboarding flow
class SubjectSelectionScreen extends ConsumerStatefulWidget {
  const SubjectSelectionScreen({super.key});

  @override
  ConsumerState<SubjectSelectionScreen> createState() =>
      _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends ConsumerState<SubjectSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  final List<String> _selectedSubjects = [];
  bool _isLoading = false;

  // Sample subjects data - in a real app this would come from an API
  final List<Map<String, dynamic>> _subjects = [
    {
      'id': 'math',
      'name': 'Mathematics',
      'icon': Icons.calculate_rounded,
      'color': const Color(0xFF3B82F6),
      'description': 'Algebra, Geometry, Calculus and more',
    },
    {
      'id': 'science',
      'name': 'Science',
      'icon': Icons.science_rounded,
      'color': const Color(0xFF10B981),
      'description': 'Physics, Chemistry, Biology',
    },
    {
      'id': 'english',
      'name': 'English',
      'icon': Icons.book_rounded,
      'color': const Color(0xFFEC4899),
      'description': 'Literature, Grammar, Writing',
    },
    {
      'id': 'history',
      'name': 'History',
      'icon': Icons.history_edu_rounded,
      'color': const Color(0xFFF59E0B),
      'description': 'World History, Geography, Politics',
    },
    {
      'id': 'art',
      'name': 'Art & Music',
      'icon': Icons.palette_rounded,
      'color': const Color(0xFF8B5CF6),
      'description': 'Visual Arts, Music Theory, Design',
    },
    {
      'id': 'language',
      'name': 'Languages',
      'icon': Icons.language_rounded,
      'color': const Color(0xFF06B6D4),
      'description': 'Spanish, French, Vietnamese',
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
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
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

    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
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
    if (user != null) {
      setState(() {
        _selectedSubjects.addAll(user.preferences.subjects);
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _toggleSubject(String subjectId) {
    setState(() {
      if (_selectedSubjects.contains(subjectId)) {
        _selectedSubjects.remove(subjectId);
      } else {
        _selectedSubjects.add(subjectId);
      }
    });

    // Add bounce animation when selecting
    if (_selectedSubjects.contains(subjectId)) {
      _bounceController.forward().then((_) {
        _bounceController.reset();
      });
    }
  }

  Future<void> _handleContinue() async {
    if (_selectedSubjects.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one subject'),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update user preferences with selected subjects
      final authNotifier = ref.read(authProvider.notifier);
      final currentUser = ref.read(currentUserProvider);

      if (currentUser != null) {
        final updatedPreferences = currentUser.preferences.copyWith(
          subjects: _selectedSubjects,
        );

        final updatedUser = currentUser.copyWith(
          preferences: updatedPreferences,
        );

        await authNotifier.updateUserProfile(updatedUser);
      }

      // Navigate to Helpy customization
      if (context.mounted) {
        context.go(AppRoutes.helpyCustomization);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving subjects: $e'),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                // Header section
                Expanded(
                  flex: 2,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: DesignTokens.spaceL),
                        Text(
                          'Select Your Subjects',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: DesignTokens.spaceM),
                        Text(
                          'Choose the subjects you want to learn. You can always add more later.',
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

                // Subjects grid
                Expanded(
                  flex: 4,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: DesignTokens.spaceM,
                              mainAxisSpacing: DesignTokens.spaceM,
                              childAspectRatio: 0.9,
                            ),
                        itemCount: _subjects.length,
                        itemBuilder: (context, index) {
                          final subject = _subjects[index];
                          final isSelected = _selectedSubjects.contains(
                            subject['id'],
                          );

                          return AnimatedBuilder(
                            animation: _bounceAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: isSelected
                                    ? _bounceAnimation.value
                                    : 1.0,
                                child: child,
                              );
                            },
                            child: GestureDetector(
                              onTap: () => _toggleSubject(subject['id']),
                              child: GlassmorphicContainer(
                                borderRadius: DesignTokens.radiusL,
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    DesignTokens.spaceM,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      DesignTokens.radiusL,
                                    ),
                                    color: isSelected
                                        ? subject['color'].withValues(
                                            alpha: 0.15,
                                          )
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? subject['color']
                                          : Colors.white.withValues(alpha: 0.2),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        subject['icon'],
                                        size: 40,
                                        color: isSelected
                                            ? subject['color']
                                            : Colors.white.withValues(
                                                alpha: 0.7,
                                              ),
                                      ),
                                      const SizedBox(
                                        height: DesignTokens.spaceS,
                                      ),
                                      Text(
                                        subject['name'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: isSelected
                                                  ? subject['color']
                                                  : Colors.white,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(
                                        height: DesignTokens.spaceXS,
                                      ),
                                      Text(
                                        subject['description'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: isSelected
                                                  ? subject['color'].withValues(
                                                      alpha: 0.9,
                                                    )
                                                  : Colors.white.withValues(
                                                      alpha: 0.6,
                                                    ),
                                              height: 1.3,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(
                                        height: DesignTokens.spaceXS,
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: subject['color'],
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Continue button
                Expanded(
                  flex: 1,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GradientButton(
                          onPressed: _handleContinue,
                          text: 'Continue',
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: DesignTokens.spaceM),
                        TextButton(
                          onPressed: () {
                            context.go(AppRoutes.profileSetup);
                          },
                          child: Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
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
}
