import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../data/providers/providers.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/onboarding/welcome_screen.dart';
import '../presentation/screens/onboarding/profile_setup_screen.dart';
import '../presentation/screens/onboarding/subject_selection_screen.dart';
import '../presentation/screens/onboarding/helpy_customization_screen.dart';
import '../presentation/screens/demo/component_demo_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/chat/chat_list_screen.dart' as chat_list;
import '../presentation/screens/chat/chat_screen.dart' as chat;
import '../config/constants.dart';

// Import screens for learning session routes
import '../presentation/screens/learning/lesson_viewer_screen.dart';

/// Custom refresh listenable for Go Router to react to auth changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Route paths constants
class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/onboarding/welcome';
  static const String profileSetup = '/onboarding/profile';
  static const String onboardingSubjects = '/onboarding/subjects';
  static const String helpyCustomization = '/onboarding/helpy';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';

  static const String home = '/home';
  static const String dashboard = '/home/dashboard';
  static const String subjects = '/home/subjects';
  static const String progress = '/home/progress';

  static const String chatList = '/chat';
  static const String chat = '/chat/:id';
  static const String groupChat = '/chat/group/:id';
  static const String chatSettings = '/chat/settings/:id';

  static const String lesson = '/learning/lesson/:id';
  static const String practice = '/learning/practice/:subjectId';
  static const String assessment = '/learning/assessment/:id';
  static const String whiteboard = '/learning/whiteboard';

  static const String profile = '/profile';
  static const String settings = '/profile/settings';
  static const String subscription = '/profile/subscription';
  static const String demo = '/demo';

  static const String parentDashboard = '/parent/dashboard';
  static const String childProgress = '/parent/child/:id';
}

/// Navigation shell for bottom navigation
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: const ModernBottomNav());
  }
}

/// Modern bottom navigation placeholder
class ModernBottomNav extends StatelessWidget {
  const ModernBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              context,
              Icons.home_rounded,
              'Home',
              AppRoutes.dashboard,
            ),
            _buildNavItem(
              context,
              Icons.chat_bubble_rounded,
              'Chat',
              AppRoutes.chatList,
            ),
            _buildNavItem(
              context,
              Icons.school_rounded,
              'Learn',
              AppRoutes.subjects,
            ),
            _buildNavItem(
              context,
              Icons.person_rounded,
              'Profile',
              AppRoutes.profile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    final currentPath = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.path;
    final isSelected = currentPath == route;

    return GestureDetector(
      onTap: () => context.go(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder screens (will be replaced with actual implementations)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Welcome')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Welcome to Helpy Ninja'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Get Started'),
          ),
        ],
      ),
    ),
  );
}

// DashboardScreen is now imported from ../presentation/screens/dashboard/dashboard_screen.dart

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});
  @override
  Widget build(BuildContext context) => const chat_list.ChatListScreen();
}

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Subjects')));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Profile')));
}

/// Go Router configuration provider
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // Refresh when auth state changes
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authProvider.notifier).stream,
    ),

    // Route configuration
    routes: [
      // Splash screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding routes
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeOnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingSubjects,
        builder: (context, state) => const SubjectSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpyCustomization,
        builder: (context, state) => const HelpyCustomizationScreen(),
      ),

      // Authentication routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      // Add other auth routes here as separate GoRoutes

      // Demo route for showcasing components (outside shell for easy access)
      GoRoute(
        path: '/demo',
        builder: (context, state) => const ComponentDemoScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Home/Dashboard routes
          GoRoute(
            path: '/home/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/home/subjects',
            builder: (context, state) => const SubjectsScreen(),
          ),
          GoRoute(
            path: '/home/progress',
            builder: (context, state) => const DashboardScreen(),
          ),

          // Chat routes
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final chatId = state.pathParameters['id'];
                  return chat.ChatScreen(conversationId: chatId!);
                },
              ),
            ],
          ),

          // Learning routes
          GoRoute(
            path: '/learning/lesson/:id',
            builder: (context, state) {
              final lessonId = state.pathParameters['id']!;
              return LessonViewerScreen(lessonId: lessonId);
            },
          ),
          GoRoute(
            path: '/learning/practice/:subjectId',
            builder: (context, state) {
              // For now, we'll use the subjectId in the future when we implement practice mode
              return const SubjectsScreen();
            },
          ),
          GoRoute(
            path: '/learning/assessment/:id',
            builder: (context, state) {
              // For now, we'll use the id in the future when we implement assessment
              return const SubjectsScreen();
            },
          ),
          GoRoute(
            path: '/learning/whiteboard',
            builder: (context, state) => const SubjectsScreen(),
          ),

          // Profile routes
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'settings',
                builder: (context, state) => Scaffold(
                  appBar: AppBar(title: const Text('Settings')),
                  body: const Center(child: Text('Settings Screen')),
                ),
              ),
            ],
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),

    // Route redirect logic with optional authentication bypass for development
    redirect: (context, state) {
      final currentPath = state.uri.path;

      // DEVELOPMENT: Bypass authentication if disabled
      if (!AppConstants.enableAuthDuringDevelopment) {
        if (currentPath == '/') {
          return AppRoutes.dashboard;
        }
        // Allow access to all routes during development
        return null;
      }

      // PRODUCTION: Normal authentication flow
      final authState = ref.read(authProvider);

      // Handle splash screen
      if (currentPath == '/') {
        if (authState.status == AuthStatus.initial ||
            authState.status == AuthStatus.loading) {
          return null; // Stay on splash while loading
        }

        if (authState.isAuthenticated) {
          return authState.isFirstTime
              ? AppRoutes.welcome
              : AppRoutes.dashboard;
        } else {
          return AppRoutes.welcome;
        }
      }

      // Protect authenticated routes
      final protectedRoutes = ['/home/', '/chat', '/profile', '/learning'];
      final isProtectedRoute = protectedRoutes.any(
        (route) => currentPath.startsWith(route),
      );

      if (isProtectedRoute && !authState.isAuthenticated) {
        return AppRoutes.login;
      }

      // Redirect authenticated users away from auth screens
      final authRoutes = ['/auth/', '/onboarding/'];
      final isAuthRoute = authRoutes.any(
        (route) => currentPath.startsWith(route),
      );

      if (isAuthRoute && authState.isAuthenticated) {
        return authState.isFirstTime ? AppRoutes.welcome : AppRoutes.dashboard;
      }

      // Redirect /home to dashboard
      if (currentPath == '/home') {
        return AppRoutes.dashboard;
      }

      return null; // No redirect needed
    },
  );
});
