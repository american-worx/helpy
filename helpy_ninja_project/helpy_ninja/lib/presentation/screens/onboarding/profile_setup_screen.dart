import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/design_tokens.dart';
import '../../../config/routes.dart';
import '../../../data/providers/providers.dart';
import '../../../domain/entities/user.dart';
import '../../widgets/auth/auth_form_field.dart';
import '../../widgets/auth/glassmorphic_container.dart';
import '../../widgets/common/gradient_button.dart';

/// Profile setup screen for onboarding flow
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _selectedGradeLevel = 'grade_9';
  String _selectedLearningStyle = 'mixed';
  String _selectedCurriculum = 'commonCore';
  bool _isLoading = false;

  final List<Map<String, String>> _gradeLevels = [
    {'value': 'grade_6', 'label': 'Grade 6'},
    {'value': 'grade_7', 'label': 'Grade 7'},
    {'value': 'grade_8', 'label': 'Grade 8'},
    {'value': 'grade_9', 'label': 'Grade 9'},
    {'value': 'grade_10', 'label': 'Grade 10'},
    {'value': 'grade_11', 'label': 'Grade 11'},
    {'value': 'grade_12', 'label': 'Grade 12'},
  ];

  final List<Map<String, dynamic>> _learningStyles = [
    {
      'value': 'visual',
      'label': 'Visual Learner',
      'description': 'Learn best with diagrams, charts, and images',
      'icon': Icons.visibility,
    },
    {
      'value': 'auditory',
      'label': 'Auditory Learner',
      'description': 'Learn best through listening and discussion',
      'icon': Icons.hearing,
    },
    {
      'value': 'kinesthetic',
      'label': 'Kinesthetic Learner',
      'description': 'Learn best through hands-on activities',
      'icon': Icons.touch_app,
    },
    {
      'value': 'mixed',
      'label': 'Mixed Learning',
      'description': 'Combination of all learning styles',
      'icon': Icons.psychology,
    },
  ];

  final List<Map<String, String>> _curriculums = [
    {'value': 'commonCore', 'label': 'Common Core'},
    {'value': 'cambridge', 'label': 'Cambridge IGCSE'},
    {'value': 'ib', 'label': 'International Baccalaureate'},
    {'value': 'vietnamese', 'label': 'Vietnamese National'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user preferences
      final preferences = UserPreferences(
        gradeLevel: _selectedGradeLevel,
        learningStyle: _selectedLearningStyle,
        curriculum: _selectedCurriculum,
      );

      // Store profile data in auth provider
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.updateProfileData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        preferences: preferences,
      );

      // Navigate to subject selection
      if (mounted) {
        context.go(AppRoutes.onboardingSubjects);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
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

  Widget _buildGradeLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grade Level',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: DesignTokens.spaceS),
        Wrap(
          spacing: DesignTokens.spaceS,
          runSpacing: DesignTokens.spaceS,
          children: _gradeLevels.map((grade) {
            final isSelected = _selectedGradeLevel == grade['value'];
            return GestureDetector(
              onTap: () => setState(() {
                _selectedGradeLevel = grade['value']!;
              }),
              child: AnimatedContainer(
                duration: DesignTokens.animationFast,
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceM,
                  vertical: DesignTokens.spaceS,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [DesignTokens.accent, DesignTokens.secondary],
                        )
                      : null,
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  grade['label']!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLearningStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Style',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: DesignTokens.spaceS),
        Column(
          children: _learningStyles.map((style) {
            final isSelected = _selectedLearningStyle == style['value'];
            return GestureDetector(
              onTap: () => setState(() {
                _selectedLearningStyle = style['value'];
              }),
              child: AnimatedContainer(
                duration: DesignTokens.animationFast,
                margin: const EdgeInsets.only(bottom: DesignTokens.spaceS),
                padding: const EdgeInsets.all(DesignTokens.spaceM),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            DesignTokens.accent.withValues(alpha: 0.2),
                            DesignTokens.secondary.withValues(alpha: 0.1),
                          ],
                        )
                      : null,
                  border: Border.all(
                    color: isSelected
                        ? DesignTokens.accent
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      style['icon'],
                      color: isSelected
                          ? DesignTokens.accent
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: DesignTokens.spaceM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            style['label'],
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                          ),
                          Text(
                            style['description'],
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: DesignTokens.accent,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCurriculumSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Curriculum',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: DesignTokens.spaceS),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCurriculum,
              onChanged: (value) => setState(() {
                _selectedCurriculum = value!;
              }),
              items: _curriculums.map((curriculum) {
                return DropdownMenuItem<String>(
                  value: curriculum['value'],
                  child: Text(curriculum['label']!),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
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
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spaceL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: DesignTokens.spaceS),
                          Text(
                            'Setup Your Profile',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.spaceXL),

                      // Progress indicator
                      LinearProgressIndicator(
                        value: 0.33, // Step 1 of 3
                        backgroundColor: colorScheme.outline.withValues(
                          alpha: 0.2,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          DesignTokens.accent,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceM),
                      Text(
                        'Step 1 of 3',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceXL),

                      // Form content
                      Expanded(
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: GlassmorphicContainer(
                            padding: const EdgeInsets.all(DesignTokens.spaceL),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tell us about yourself',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: DesignTokens.spaceS),
                                  Text(
                                    'This helps us personalize your learning experience with Helpy.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                  ),
                                  const SizedBox(height: DesignTokens.spaceXL),

                                  // Name field
                                  AuthFormField(
                                    controller: _nameController,
                                    label: 'Full Name',
                                    hint: 'Enter your full name',
                                    validator: _validateName,
                                    prefixIcon: Icons.person_outline,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: DesignTokens.spaceL),

                                  // Email field
                                  AuthFormField(
                                    controller: _emailController,
                                    label: 'Email Address',
                                    hint: 'Enter your email',
                                    validator: _validateEmail,
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icons.email_outlined,
                                    textInputAction: TextInputAction.done,
                                  ),
                                  const SizedBox(height: DesignTokens.spaceXL),

                                  // Grade level selector
                                  _buildGradeLevelSelector(),
                                  const SizedBox(height: DesignTokens.spaceXL),

                                  // Learning style selector
                                  _buildLearningStyleSelector(),
                                  const SizedBox(height: DesignTokens.spaceXL),

                                  // Curriculum selector
                                  _buildCurriculumSelector(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: DesignTokens.spaceL),

                      // Continue button
                      GradientButton(
                        onPressed: _isLoading ? null : _handleContinue,
                        text: 'Continue to Subjects',
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
