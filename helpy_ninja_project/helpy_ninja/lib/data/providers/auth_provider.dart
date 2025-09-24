import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../../config/constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../core/di/injection.dart';
import '../../core/errors/api_exception.dart';

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

/// Authentication state notifier with repository pattern
class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthRepository _authRepository;
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

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    _logger.d('AuthNotifier initialized with repository');
    _initializeAuth();
  }

  late Box _authBox;

  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    _logger.d('Initializing authentication state');
    state = state.copyWith(status: AuthStatus.loading);

    try {
      _authBox = await Hive.openBox('auth');
      _logger.d('Auth box opened successfully');

      // Check if user is authenticated using repository
      final isAuthenticated = await _authRepository.isAuthenticated();
      _logger.d('Authentication status from repository: $isAuthenticated');

      if (isAuthenticated) {
        // Try to get current user
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          final hasCompletedOnboarding = _authBox.get(
            AppConstants.onboardingCompleteKey,
            defaultValue: false,
          );

          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            isFirstTime: !hasCompletedOnboarding,
          );
          _logger.d('User authenticated and restored: ${user.id}');
        } else {
          // Token exists but user fetch failed - clear auth state
          await _authRepository.clearTokens();
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            isFirstTime: true,
          );
          _logger.w('Token exists but user fetch failed, cleared auth state');
        }
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isFirstTime: true,
        );
        _logger.d('User is not authenticated');
      }
    } catch (e) {
      _logger.e('Failed to initialize authentication: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        error: e is ApiException ? e.userMessage : 'Authentication initialization failed',
      );
    }
  }


  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    _logger.d('Signing in with email: $email');
    state = state.copyWith(status: AuthStatus.loading, error: null);

    try {
      final user = await _authRepository.signInWithEmail(email, password);
      
      // Mark onboarding as complete for existing users
      await _authBox.put(AppConstants.onboardingCompleteKey, true);
      _logger.d('Authentication successful and onboarding marked as complete');

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isFirstTime: false,
      );
      _logger.d('User signed in successfully: ${user.id}');
    } catch (e) {
      _logger.e('Sign in failed: $e');
      final errorMessage = e is ApiException ? e.userMessage : 'Login failed: ${e.toString()}';
      state = state.copyWith(
        status: AuthStatus.error,
        error: errorMessage,
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
      final user = await _authRepository.signUpWithEmail(email, password, name);
      
      _logger.d('Registration successful');

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isFirstTime: true, // New user needs onboarding
      );
      _logger.d('User signed up successfully, requires onboarding: ${user.id}');
    } catch (e) {
      _logger.e('Sign up failed: $e');
      final errorMessage = e is ApiException ? e.userMessage : 'Registration failed: ${e.toString()}';
      state = state.copyWith(
        status: AuthStatus.error,
        error: errorMessage,
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
      // Sign out using repository
      await _authRepository.signOut();
      
      // Clear local onboarding state
      await _authBox.delete(AppConstants.onboardingCompleteKey);
      _logger.d('Authentication data cleared');

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        error: null,
        isFirstTime: true,
      );
      _logger.d('User signed out successfully');
    } catch (e) {
      _logger.e('Failed to sign out: $e');
      final errorMessage = e is ApiException ? e.userMessage : 'Failed to sign out: ${e.toString()}';
      state = state.copyWith(
        status: AuthStatus.error,
        error: errorMessage,
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
    try {
      if (state.user != null) {
        final user = await _authRepository.updateProfile(updatedUser);
        state = state.copyWith(user: user);
        _logger.d('User profile updated successfully');
      }
    } catch (e) {
      _logger.e('Failed to update user profile: $e');
      final errorMessage = e is ApiException ? e.userMessage : 'Profile update failed: ${e.toString()}';
      state = state.copyWith(
        status: AuthStatus.error,
        error: errorMessage,
      );
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

      // Profile will be synced with backend when onboarding completes
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
  return AuthNotifier(getIt<IAuthRepository>());
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
