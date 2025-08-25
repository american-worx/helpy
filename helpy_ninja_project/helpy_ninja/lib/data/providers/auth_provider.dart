import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  AuthNotifier() : super(const AuthState()) {
    _initializeAuth();
  }

  late Box _authBox;

  /// Initialize authentication state from local storage
  Future<void> _initializeAuth() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      _authBox = await Hive.openBox('auth');

      // Check if user has completed onboarding
      final hasCompletedOnboarding = _authBox.get(
        AppConstants.onboardingCompleteKey,
        defaultValue: false,
      );

      // Check for stored user token
      final token = _authBox.get(AppConstants.userTokenKey);

      if (token != null && hasCompletedOnboarding) {
        // Validate token and restore user session
        await _restoreUserSession(token);
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isFirstTime: !hasCompletedOnboarding,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to initialize authentication: $e',
      );
    }
  }

  /// Restore user session from stored token
  Future<void> _restoreUserSession(String token) async {
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
    } catch (e) {
      // Clear invalid token
      await _authBox.delete(AppConstants.userTokenKey);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Session expired. Please login again.',
      );
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      // TODO: Implement actual authentication with backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

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

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isFirstTime: false,
      );
    } catch (e) {
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
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      // TODO: Implement actual registration with backend
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

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

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isFirstTime: true, // New user needs onboarding
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Registration failed: $e',
      );
    }
  }

  /// Complete onboarding process
  Future<void> completeOnboarding() async {
    await _authBox.put(AppConstants.onboardingCompleteKey, true);
    state = state.copyWith(isFirstTime: false);
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Clear stored authentication data
      await _authBox.delete(AppConstants.userTokenKey);
      await _authBox.delete(AppConstants.onboardingCompleteKey);

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        error: null,
        isFirstTime: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to sign out: $e',
      );
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Update user profile
  Future<void> updateUserProfile(User updatedUser) async {
    if (state.user != null) {
      state = state.copyWith(user: updatedUser);
      // TODO: Sync with backend
    }
  }

  /// Update profile data during onboarding
  Future<void> updateProfileData({
    String? name,
    String? email,
    UserPreferences? preferences,
  }) async {
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(
        name: name ?? state.user!.name,
        email: email ?? state.user!.email,
        preferences: preferences ?? state.user!.preferences,
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(user: updatedUser);

      // Store updated profile data
      await _authBox.put('user_profile', updatedUser.toJson());

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

      // Store profile data
      await _authBox.put('user_profile', tempUser.toJson());
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
