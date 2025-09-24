import '../entities/user.dart';

/// Repository interface for user operations
abstract class IUserRepository {
  /// Get user by ID
  Future<User?> getUserById(String userId);

  /// Get user by email
  Future<User?> getUserByEmail(String email);

  /// Update user profile
  Future<User> updateUser(User user);

  /// Delete user
  Future<void> deleteUser(String userId);

  /// Update user preferences
  Future<User> updatePreferences(String userId, UserPreferences preferences);

  /// Get user settings
  Future<Map<String, dynamic>> getUserSettings(String userId);

  /// Update user settings
  Future<void> updateUserSettings(String userId, Map<String, dynamic> settings);

  /// Get user's learning progress
  Future<Map<String, dynamic>> getLearningProgress(String userId);

  /// Update learning progress
  Future<void> updateLearningProgress(
    String userId, 
    Map<String, dynamic> progress,
  );

  /// Check if username is available
  Future<bool> isUsernameAvailable(String username);

  /// Search users by criteria
  Future<List<User>> searchUsers({
    String? query,
    String? role,
    int? limit,
    String? lastUserId,
  });
}