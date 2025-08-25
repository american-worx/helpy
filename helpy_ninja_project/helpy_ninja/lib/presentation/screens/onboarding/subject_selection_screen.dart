import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/design_tokens.dart';
import '../../../config/routes.dart';
import '../../../data/providers/providers.dart';

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
  late AnimationController _staggerController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _selectedSubjects = [];
  bool _isLoading = false;

  // Subject categories with icons and descriptions
  final Map<String, List<Map<String, dynamic>>> _subjectCategories = {
    'STEM': [
      {
        'id': 'mathematics',
        'name': 'Mathematics',
        'description': 'Algebra, Geometry, Calculus, Statistics',
        'icon': Icons.calculate_outlined,
        'color': const Color(0xFF6366F1),
        'selected': false,
      },
      {
        'id': 'physics',
        'name': 'Physics',
        'description': 'Mechanics, Thermodynamics, Electromagnetism',
        'icon': Icons.science_outlined,
        'color': const Color(0xFF8B5CF6),
        'selected': false,
      },
      {
        'id': 'chemistry',
        'name': 'Chemistry',
        'description': 'Organic, Inorganic, Physical Chemistry',
        'icon': Icons.biotech_outlined,
        'color': const Color(0xFF06B6D4),
        'selected': false,
      },
      {
        'id': 'biology',
        'name': 'Biology',
        'description': 'Cell Biology, Genetics, Ecology',
        'icon': Icons.local_florist_outlined,
        'color': const Color(0xFF10B981),
        'selected': false,
      },
      {
        'id': 'computer_science',
        'name': 'Computer Science',
        'description': 'Programming, Algorithms, Data Structures',
        'icon': Icons.computer_outlined,
        'color': const Color(0xFF3B82F6),
        'selected': false,
      },
    ],
    'Languages': [
      {
        'id': 'english',
        'name': 'English',
        'description': 'Literature, Grammar, Writing, Reading',
        'icon': Icons.book_outlined,
        'color': const Color(0xFFEF4444),
        'selected': false,
      },
      {
        'id': 'vietnamese',
        'name': 'Vietnamese',
        'description': 'Literature, Grammar, Composition',
        'icon': Icons.translate_outlined,
        'color': const Color(0xFFF59E0B),
        'selected': false,
      },
      {
        'id': 'french',
        'name': 'French',
        'description': 'Conversation, Grammar, Culture',
        'icon': Icons.language_outlined,
        'color': const Color(0xFF8B5CF6),
        'selected': false,
      },
      {
        'id': 'spanish',
        'name': 'Spanish',
        'description': 'Conversation, Grammar, Culture',
        'icon': Icons.language_outlined,
        'color': const Color(0xFFEC4899),
        'selected': false,
      },
    ],
    'Social Studies': [
      {
        'id': 'history',
        'name': 'History',
        'description': 'World History, National History',
        'icon': Icons.account_balance_outlined,
        'color': const Color(0xFF92400E),
        'selected': false,
      },
      {
        'id': 'geography',
        'name': 'Geography',
        'description': 'Physical, Human Geography',
        'icon': Icons.public_outlined,
        'color': const Color(0xFF059669),
        'selected': false,
      },
      {
        'id': 'economics',
        'name': 'Economics',
        'description': 'Microeconomics, Macroeconomics',
        'icon': Icons.trending_up_outlined,
        'color': const Color(0xFF7C3AED),
        'selected': false,
      },
    ],
    'Arts': [
      {
        'id': 'art',
        'name': 'Visual Arts',
        'description': 'Drawing, Painting, Design',
        'icon': Icons.palette_outlined,
        'color': const Color(0xFFDC2626),
        'selected': false,
      },
      {
        'id': 'music',
        'name': 'Music',
        'description': 'Theory, Performance, Composition',
        'icon': Icons.music_note_outlined,
        'color': const Color(0xFF7C2D12),
        'selected': false,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserSubjects();
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
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _staggerController.forward();
    });
  }

  void _loadUserSubjects() {
    final user = ref.read(currentUserProvider);
    if (user?.preferences.subjects.isNotEmpty == true) {
      setState(() {
        _selectedSubjects.addAll(user!.preferences.subjects);
        _updateSubjectSelections();
      });
    }
  }

  void _updateSubjectSelections() {
    for (final category in _subjectCategories.values) {
      for (final subject in category) {
        subject['selected'] = _selectedSubjects.contains(subject['id']);
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _toggleSubject(String subjectId) {
    setState(() {
      if (_selectedSubjects.contains(subjectId)) {
        _selectedSubjects.remove(subjectId);
      } else {
        _selectedSubjects.add(subjectId);
      }
      _updateSubjectSelections();
    });
  }

  Future<void> _handleContinue() async {
    if (_selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one subject'),
          backgroundColor: DesignTokens.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update user preferences with selected subjects
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final updatedPreferences = user.preferences.copyWith(
          subjects: _selectedSubjects,
        );

        await ref
            .read(authProvider.notifier)
            .updateProfileData(preferences: updatedPreferences);
      }

      // Navigate to Helpy customization
      if (mounted) {
        context.go(AppRoutes.helpyCustomization);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving subjects: $e'),
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

  Widget _buildSubjectCard(Map<String, dynamic> subject, int index) {
    final isSelected = subject['selected'] as bool;
    final delay = Duration(milliseconds: 100 * index);

    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final slideValue = Curves.easeOutCubic.transform(
          (_staggerController.value - (index * 0.1)).clamp(0.0, 1.0),
        );

        return Transform.translate(
          offset: Offset(0, 50 * (1 - slideValue)),
          child: Opacity(opacity: slideValue, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _toggleSubject(subject['id']),
        child: AnimatedContainer(
          duration: DesignTokens.animationFast,
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: DesignTokens.spaceM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (subject['color'] as Color).withValues(alpha: 0.2),
                      (subject['color'] as Color).withValues(alpha: 0.1),
                    ],
                  )
                : null,
            border: Border.all(
              color: isSelected
                  ? subject['color'] as Color
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceM),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? subject['color'] as Color
                        : (subject['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                  ),
                  child: Icon(
                    subject['icon'] as IconData,
                    color: isSelected
                        ? Colors.white
                        : subject['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject['name'],
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? subject['color'] as Color
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: DesignTokens.spaceXS),
                      Text(
                        subject['description'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  duration: DesignTokens.animationFast,
                  turns: isSelected ? 0.25 : 0,
                  child: AnimatedScale(
                    duration: DesignTokens.animationFast,
                    scale: isSelected ? 1.2 : 1.0,
                    child: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.add_circle_outline,
                      color: isSelected
                          ? subject['color'] as Color
                          : Theme.of(context).colorScheme.outline,
                      size: 24,
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

  Widget _buildCategorySection(
    String category,
    List<Map<String, dynamic>> subjects,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceS,
            vertical: DesignTokens.spaceM,
          ),
          child: Text(
            category,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignTokens.accent,
            ),
          ),
        ),
        ...subjects.asMap().entries.map((entry) {
          final index = entry.key;
          final subject = entry.value;
          return _buildSubjectCard(subject, index);
        }),
        const SizedBox(height: DesignTokens.spaceL),
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
                              'Choose Your Subjects',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignTokens.spaceM),

                        // Progress indicator
                        LinearProgressIndicator(
                          value: 0.66, // Step 2 of 3
                          backgroundColor: colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            DesignTokens.accent,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spaceS),
                        Text(
                          'Step 2 of 3',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                        ),
                        const SizedBox(height: DesignTokens.spaceM),

                        // Selected count
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.spaceM,
                            vertical: DesignTokens.spaceS,
                          ),
                          decoration: BoxDecoration(
                            color: DesignTokens.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusS,
                            ),
                          ),
                          child: Text(
                            '${_selectedSubjects.length} subjects selected',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: DesignTokens.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Subject categories
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceL,
                      ),
                      child: Column(
                        children: _subjectCategories.entries.map((entry) {
                          return _buildCategorySection(entry.key, entry.value);
                        }).toList(),
                      ),
                    ),
                  ),

                  // Continue button
                  Padding(
                    padding: const EdgeInsets.all(DesignTokens.spaceL),
                    child: GradientButton(
                      onPressed: _isLoading ? null : _handleContinue,
                      text: 'Continue to Helpy Setup',
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
