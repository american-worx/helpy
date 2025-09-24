import '../entities/user.dart';

/// Repository interface for authentication operations
abstract class IAuthRepository {
  /// Sign in with email and password
  Future<User> signInWithEmail(String email, String password);

  /// Sign up with email, password, and name
  Future<User> signUpWithEmail(String email, String password, String name);

  /// Sign out current user
  Future<void> signOut();

  /// Refresh authentication token
  Future<String> refreshToken(String refreshToken);

  /// Get current authenticated user
  Future<User?> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Verify email address
  Future<void> verifyEmail(String token);

  /// Reset password
  Future<void> resetPassword(String email);

  /// Update user profile
  Future<User> updateProfile(User user);

  /// Store authentication token
  Future<void> storeToken(String token, String refreshToken);

  /// Get stored token
  Future<String?> getStoredToken();

  /// Clear stored tokens
  Future<void> clearTokens();
}