/// Modern Widget Library for Helpy Ninja
///
/// This library provides a comprehensive set of modern, glassmorphic UI components
/// following the design system specifications for tech-conscious youth.
///
/// All components feature:
/// - Glassmorphic design elements
/// - Smooth animations and micro-interactions
/// - Material 3 theming integration
/// - Accessibility support
/// - Responsive design
library modern_widgets;

// Authentication Components
export 'auth/auth_form_field.dart';
export 'auth/glassmorphic_container.dart';

// Card Components
export 'cards/modern_cards.dart';

// Navigation Components
export 'navigation/modern_navigation.dart';

// Input Components
export 'inputs/modern_inputs.dart';

// Feedback Components
export 'feedback/modern_feedback.dart';

// Layout Components
export 'layout/modern_layout.dart';

// Common Components
export 'common/gradient_button.dart';

/// Widget Categories for Quick Reference:
/// 
/// ## Authentication & Forms
/// - `AuthFormField` - Animated form field for authentication
/// - `SearchFormField` - Specialized search input field
/// 
/// ## Cards & Display
/// - `SubjectCard` - Subject/course display card with progress
/// - `LessonCard` - Individual lesson display card
/// - `ProgressCard` - Statistics and progress display
/// - `AchievementCard` - Badge and achievement display
/// 
/// ## Navigation
/// - `ModernAppBar` - Glassmorphic app bar with profile integration
/// - `ModernBottomNavBar` - Modern bottom navigation with animations
/// - `ModernDrawer` - Side navigation drawer
/// - `ModernFAB` - Floating action button with custom styling
/// 
/// ## Inputs & Controls
/// - `ModernTextField` - Advanced text input with animations
/// - `ModernSlider` - Glassmorphic slider component
/// - `ModernToggle` - Animated toggle switch
/// - `ModernCheckbox` - Custom checkbox with animations
/// - `ModernRadio` - Custom radio button component
/// 
/// ## Feedback & Loading
/// - `ModernLoadingIndicator` - Various loading animation styles
/// - `ModernProgressIndicator` - Progress bars with labels
/// - `ModernSnackBar` - Toast notifications
/// - `ModernDialog` - Dialog with glassmorphic design
/// - `ModernBottomSheet` - Bottom sheet with modern styling
/// - `ModernTooltip` - Enhanced tooltip component
/// 
/// ## Layout & Structure
/// - `ModernSection` - Section container with headers
/// - `ModernGrid` - Responsive grid layout
/// - `ModernList` - List with built-in spacing
/// - `ModernStack` - Enhanced stack container
/// - `ModernResponsiveLayout` - Responsive layout builder
/// - `ModernContainer` - Container with elevation and effects
/// - `ModernWrap` - Wrap layout with spacing
/// - `ModernDivider` - Customizable dividers
/// - `Space` - Spacing utility widgets
/// 
/// ## Glassmorphic Components
/// - `GlassmorphicContainer` - Main glassmorphic container
/// - `GlassmorphicCard` - Card variant with glassmorphic effects
/// - `GlassmorphicAppBar` - App bar with glassmorphic styling
/// 
/// ## Button Components
/// - `GradientButton` - Primary button with gradient and animations
/// - `OutlineButton` - Secondary button with outline styling
/// 
/// ## Usage Examples:
/// 
/// ```dart
/// import 'package:helpy_ninja/presentation/widgets/modern_widgets.dart';
/// 
/// // Using a subject card
/// SubjectCard(
///   title: 'Mathematics',
///   description: 'Algebra, Geometry, Calculus',
///   icon: Icons.calculate,
///   color: Colors.blue,
///   progress: 0.7,
///   onTap: () => Navigator.push(...),
/// )
/// 
/// // Using modern text field
/// ModernTextField(
///   controller: controller,
///   label: 'Enter your name',
///   prefixIcon: Icon(Icons.person),
///   validator: (value) => value?.isEmpty == true ? 'Required' : null,
/// )
/// 
/// // Using modern section
/// ModernSection(
///   title: 'Recent Lessons',
///   showGlassmorphism: true,
///   child: ModernList(
///     children: lessons.map((lesson) => LessonCard(...)).toList(),
///   ),
/// )
/// ```