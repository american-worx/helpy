import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../../config/constants.dart';
import '../../domain/entities/user.dart';

/// Authentication state enum
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Authentication state model
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final bool isFirstTime;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.isFirstTime = true,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? isFirstTime,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error && error != null;
}

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 100,
      colors: false,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  AuthNotifier() : super(const AuthState()) {
    _logger.d('AuthNotifier initialized');
    _initializeAuth();
  }

  late Box _authBox;

  /// Initialize authentication state from local storage
  Future<void> _initializeAuth() async {
    _logger.d('Initializing authentication state');
    state = state.copyWith(status: AuthStatus.loading);

    try {
      _authBox = await Hive.openBox('auth');
      _logger.d('Auth box opened successfully');

      // DEVELOPMENT: Auto-authenticate with mock user if auth is disabled
      if (!AppConstants.enableAuthDuringDevelopment) {
        _logger.d('Development mode: Auto-authenticating with mock user');
        final mockUser = User(
          id: 'dev_user_001',
          email: 'dev@helpy.ninja',
          name: 'Developer User',
          profileImageUrl: null,
          preferences: const UserPreferences(),
          createdAt: DateTime.now(),
        );

        // Store mock token and mark onboarding as complete
        await _authBox.put(AppConstants.userTokenKey, 'dev_mock_token');
        await _authBox.put(AppConstants.onboardingCompleteKey, true);
        _logger.d('Stored mock token and marked onboarding as complete');

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: mockUser,
          isFirstTime: false,
        );
        _logger.d('Development user authenticated successfully');
        return;
      }

      // PRODUCTION: Check if user has completed onboarding
      final hasCompletedOnboarding = _authBox.get(
        AppConstants.onboardingCompleteKey,
        defaultValue: false,
      );
      _logger.d(
        'Onboarding status: ${hasCompletedOnboarding ? 'completed' : 'not completed'}',
      );

      // Check for stored user token
      final token = _authBox.get(AppConstants.userTokenKey);
      _logger.d('Token found: ${token != null}');

      if (token != null && hasCompletedOnboarding) {
        // Validate token and restore user session
        _logger.d('Valid token found, restoring user session');
        await _restoreUserSession(token);
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isFirstTime: !hasCompletedOnboarding,
        );
        _logger.d(
          'User is unauthenticated, first time: ${!hasCompletedOnboarding}',
        );
      }
    } catch (e) {
      _logger.e('Failed to initialize authentication: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to initialize authentication: $e',
      );
    }
  }

  /// Restore user session from stored token
  Future<void> _restoreUserSession(String token) async {
    _logger.d('Restoring user session from token');
    try {
      // TODO: Validate token with backend
      // For now, create a mock user
      final user = User(
        id: 'user_123',
        email: 'demo@helpy.ninja',
        name: 'Demo User',
        profileImageUrl: null,
        preferences: const UserPreferences(),
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isFirstTime: false,
      );
      _logger.d('User session restored successfully');
    } catch (e) {
      _logger.e('Failed to restore user session: $e');
      // Clear invalid token
      await _authBox.delete(AppConstants.userTokenKey);
      _logger.d('Invalid token cleared from storage');

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Session expired. Please login again.',
      );
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    _logger.d('Signing in with email: $email');
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      // TODO: Implement actual authentication with backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      _logger.d('API call simulated for sign in');

      // Mock successful authentication
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: email.split('@').first.replaceAll('.', ' ').toUpperCase(),
        profileImageUrl: null,
        preferences: const UserPreferences(),
        createdAt: DateTime.now(),
      );

      // Store authentication token
      const mockToken = 'mock_jwt_token_123';
      await _authBox.put(AppConstants.userTokenKey, mockToken);
      await _authBox.put(AppConstants.onboardingCompleteKey, true);
      _logger.d(
        'Authentication token stored and onboarding marked as complete',
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isFirstTime: false,
      );
      _logger.d('User signed in successfully');
    } catch (e) {
      _logger.e('Sign in failed: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Login failed: $e',
      );
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    _logger.d('Signing up with email: $email, name: $name');
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      // TODO: Implement actual registration with backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      _logger.d('API call simulated for sign up');

      // Mock successful registration
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        profileImageUrl: null,
        preferences: const UserPreferences(),
        createdAt: DateTime.now(),
      );

      // Store authentication token
      const mockToken = 'mock_jwt_token_456';
      await _authBox.put(AppConstants.userTokenKey, mockToken);
      _logger.d('Authentication token stored');

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isFirstTime: true, // New user needs onboarding
      );
      _logger.d('User signed up successfully, requires onboarding');
    } catch (e) {
      _logger.e('Sign up failed: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Registration failed: $e',
      );
    }
  }

  /// Complete onboarding process
  Future<void> completeOnboarding() async {
    _logger.d('Completing onboarding process');
    await _authBox.put(AppConstants.onboardingCompleteKey, true);
    state = state.copyWith(isFirstTime: false);
    _logger.d('Onboarding completed successfully');
  }

  /// Sign out
  Future<void> signOut() async {
    _logger.d('Signing out user');
    try {
      // Clear stored authentication data
      await _authBox.delete(AppConstants.userTokenKey);
      await _authBox.delete(AppConstants.onboardingCompleteKey);
      _logger.d('Authentication data cleared from storage');

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        error: null,
        isFirstTime: true,
      );
      _logger.d('User signed out successfully');
    } catch (e) {
      _logger.e('Failed to sign out: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to sign out: $e',
      );
    }
  }

  /// Clear error state
  void clearError() {
    _logger.d('Clearing error state');
    state = state.copyWith(error: null);
    _logger.d('Error state cleared');
  }

  /// Update user profile
  Future<void> updateUserProfile(User updatedUser) async {
    _logger.d('Updating user profile for userId: ${updatedUser.id}');
    if (state.user != null) {
      state = state.copyWith(user: updatedUser);
      // TODO: Sync with backend
      _logger.d('User profile updated in state');
    }
  }

  /// Update profile data during onboarding
  Future<void> updateProfileData({
    String? name,
    String? email,
    UserPreferences? preferences,
  }) async {
    _logger.d(
      'Updating profile data during onboarding - hasName: ${name != null}, hasEmail: ${email != null}, hasPreferences: ${preferences != null}',
    );

    if (state.user != null) {
      final updatedUser = state.user!.copyWith(
        name: name ?? state.user!.name,
        email: email ?? state.user!.email,
        preferences: preferences ?? state.user!.preferences,
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(user: updatedUser);
      _logger.d('User profile updated during onboarding');

      // Store updated profile data
      await _authBox.put('user_profile', updatedUser.toJson());
      _logger.d('User profile stored to local storage');

      // TODO: Sync with backend
    } else {
      // Create temporary user for onboarding flow
      final tempUser = User(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        email: email ?? 'temp@helpy.ninja',
        name: name ?? 'Temp User',
        preferences: preferences ?? const UserPreferences(),
        createdAt: DateTime.now(),
      );

      state = state.copyWith(status: AuthStatus.authenticated, user: tempUser);
      _logger.d('Temporary user created for onboarding');

      // Store profile data
      await _authBox.put('user_profile', tempUser.toJson());
      _logger.d('Temporary user profile stored to local storage');
    }
  }
}

/// Authentication provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Current user provider (convenience)
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Authentication status provider (convenience)
final authStatusProvider = Provider<AuthStatus>((ref) {
  return ref.watch(authProvider).status;
});

/// Is authenticated provider (convenience)
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Is first time user provider (convenience)
final isFirstTimeUserProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isFirstTime;
});
