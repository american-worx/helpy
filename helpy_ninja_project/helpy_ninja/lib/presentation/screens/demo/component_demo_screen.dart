import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/design_tokens.dart';
import '../../widgets/modern_widgets.dart';

/// Simplified demo screen to showcase UI components without viewport issues
class ComponentDemoScreen extends ConsumerStatefulWidget {
  const ComponentDemoScreen({super.key});

  @override
  ConsumerState<ComponentDemoScreen> createState() =>
      _ComponentDemoScreenState();
}

class _ComponentDemoScreenState extends ConsumerState<ComponentDemoScreen> {
  final _textController = TextEditingController();
  double _sliderValue = 0.5;
  bool _toggleValue = true;
  bool _checkboxValue = false;
  String _radioValue = 'option1';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('UI Components Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Modern UI Components',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: DesignTokens.primary,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceL),

            // Card Components Section
            _buildSection('Card Components', [
              SubjectCard(
                title: 'Mathematics',
                description: 'Algebra, Geometry, Calculus, Statistics',
                icon: Icons.calculate,
                color: DesignTokens.primary,
                progress: 0.75,
                lessonCount: 12,
                completedLessons: 9,
                onTap: () => _showSnackBar('Mathematics tapped'),
              ),
              const SizedBox(height: DesignTokens.spaceM),
              LessonCard(
                title: 'Introduction to Calculus',
                description: 'Learn the fundamentals of differential calculus',
                duration: '45 min',
                difficulty: 'Medium',
                completionPercentage: 0.3,
                onTap: () => _showSnackBar('Lesson tapped'),
              ),
              const SizedBox(height: DesignTokens.spaceM),
              Row(
                children: [
                  Expanded(
                    child: ProgressCard(
                      title: 'Lessons',
                      value: '24',
                      subtitle: 'Completed this week',
                      icon: Icons.school,
                      color: DesignTokens.success,
                      trend: 'up',
                      trendValue: '+12%',
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceM),
                  Expanded(
                    child: AchievementCard(
                      title: 'Math Master',
                      description: 'Complete 10 math lessons',
                      icon: Icons.star,
                      color: DesignTokens.warning,
                      isUnlocked: true,
                    ),
                  ),
                ],
              ),
            ]),

            const SizedBox(height: DesignTokens.spaceXL),

            // Input Components Section
            _buildSection('Input Components', [
              ModernTextField(
                controller: _textController,
                label: 'Your Name',
                hint: 'Enter your full name',
                prefixIcon: const Icon(Icons.person_outline),
                validator: (value) {
                  if (value?.isEmpty == true) return 'Name is required';
                  return null;
                },
              ),
              const SizedBox(height: DesignTokens.spaceM),
              ModernSlider(
                value: _sliderValue,
                onChanged: (value) => setState(() => _sliderValue = value),
                label: '${(_sliderValue * 100).round()}%',
              ),
              const SizedBox(height: DesignTokens.spaceM),
              Row(
                children: [
                  const Text('Enable notifications'),
                  const Spacer(),
                  ModernToggle(
                    value: _toggleValue,
                    onChanged: (value) => setState(() => _toggleValue = value),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spaceM),
              Row(
                children: [
                  ModernCheckbox(
                    value: _checkboxValue,
                    onChanged: (value) =>
                        setState(() => _checkboxValue = value),
                  ),
                  const SizedBox(width: DesignTokens.spaceM),
                  const Text('I agree to the terms and conditions'),
                ],
              ),
              const SizedBox(height: DesignTokens.spaceM),
              Row(
                children: [
                  Row(
                    children: [
                      ModernRadio<String>(
                        value: 'option1',
                        groupValue: _radioValue,
                        onChanged: (value) =>
                            setState(() => _radioValue = value),
                      ),
                      const SizedBox(width: DesignTokens.spaceS),
                      const Text('Option 1'),
                    ],
                  ),
                  const SizedBox(width: DesignTokens.spaceL),
                  Row(
                    children: [
                      ModernRadio<String>(
                        value: 'option2',
                        groupValue: _radioValue,
                        onChanged: (value) =>
                            setState(() => _radioValue = value),
                      ),
                      const SizedBox(width: DesignTokens.spaceS),
                      const Text('Option 2'),
                    ],
                  ),
                ],
              ),
            ]),

            const SizedBox(height: DesignTokens.spaceXL),

            // Feedback Components Section
            _buildSection('Feedback Components', [
              const Center(
                child: ModernLoadingIndicator(
                  type: LoadingType.helpy,
                  size: 64,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceL),
              ModernProgressIndicator(
                value: 0.65,
                label: 'Course Progress',
                showPercentage: true,
              ),
              const SizedBox(height: DesignTokens.spaceL),
              Wrap(
                spacing: DesignTokens.spaceM,
                runSpacing: DesignTokens.spaceM,
                children: [
                  GradientButton(
                    onPressed: () =>
                        _showSnackBar('Success message', SnackBarType.success),
                    text: 'Success',
                  ),
                  GradientButton(
                    onPressed: () =>
                        _showSnackBar('Error message', SnackBarType.error),
                    text: 'Error',
                    gradient: const LinearGradient(
                      colors: [DesignTokens.error, DesignTokens.errorDark],
                    ),
                  ),
                  GradientButton(
                    onPressed: _showDialog,
                    text: 'Show Dialog',
                    gradient: const LinearGradient(
                      colors: [DesignTokens.warning, DesignTokens.warningDark],
                    ),
                  ),
                ],
              ),
            ]),

            const SizedBox(height: DesignTokens.spaceXL),

            // Layout Components Section
            _buildSection('Layout & Container Components', [
              ModernContainer(
                elevation: 4,
                backgroundColor: DesignTokens.primary.withValues(alpha: 0.1),
                child: const Text(
                  'This is a modern container with elevation and custom background',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceL),
              const ModernDivider(type: DividerType.gradient),
              const SizedBox(height: DesignTokens.spaceL),
              GlassmorphicContainer(
                child: const Text(
                  'This is a glassmorphic container with blur effects',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceM),
              Row(
                children: [
                  Expanded(
                    child: GlassmorphicCard(
                      onTap: () => _showSnackBar('Card 1 tapped'),
                      child: const Text('Card 1', textAlign: TextAlign.center),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceM),
                  Expanded(
                    child: GlassmorphicCard(
                      onTap: () => _showSnackBar('Card 2 tapped'),
                      child: const Text('Card 2', textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ),
            ]),

            const SizedBox(height: DesignTokens.spaceXL),

            // Footer
            Center(
              child: Text(
                'All components are interactive! 🎯\nTry tapping buttons, cards, and toggles.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ModernFAB(
        onPressed: () => _showBottomSheet(),
        icon: Icons.add,
        label: 'Add Item',
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return GlassmorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignTokens.accent,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceL),
          ...children,
        ],
      ),
    );
  }

  void _showSnackBar(String message, [SnackBarType type = SnackBarType.info]) {
    ScaffoldMessenger.of(context).showSnackBar(
      ModernSnackBar.show(
        message: message,
        type: type,
        actionLabel: 'UNDO',
        onActionPressed: () {},
      ),
    );
  }

  void _showDialog() {
    ModernDialog.show(
      context: context,
      title: 'Confirmation',
      content: const Text('Are you sure you want to continue?'),
      icon: Icons.help_outline,
      type: DialogType.warning,
      actions: [
        OutlineButton(
          onPressed: () => Navigator.of(context).pop(),
          text: 'Cancel',
        ),
        const SizedBox(width: DesignTokens.spaceM),
        GradientButton(
          onPressed: () {
            Navigator.of(context).pop();
            _showSnackBar('Action confirmed!', SnackBarType.success);
          },
          text: 'Confirm',
        ),
      ],
    );
  }

  void _showBottomSheet() {
    ModernBottomSheet.show(
      context: context,
      title: 'Add New Item',
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spaceL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModernTextField(
              controller: TextEditingController(),
              label: 'Item Name',
              hint: 'Enter item name',
            ),
            const SizedBox(height: DesignTokens.spaceM),
            ModernTextField(
              controller: TextEditingController(),
              label: 'Description',
              hint: 'Enter description',
              maxLines: 3,
            ),
            const SizedBox(height: DesignTokens.spaceL),
            GradientButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSnackBar('Item added!', SnackBarType.success);
              },
              text: 'Add Item',
            ),
          ],
        ),
      ),
    );
  }
}
