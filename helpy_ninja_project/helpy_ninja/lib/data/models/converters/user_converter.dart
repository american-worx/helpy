import '../../../domain/entities/user.dart';
import '../api/auth_models.dart';

/// Converter for User entity and API models
class UserConverter {
  /// Convert UserResponse from API to User entity
  static User fromApiResponse(UserResponse response) {
    return User(
      id: response.id,
      email: response.email,
      name: response.name,
      profileImageUrl: response.profileImageUrl,
      preferences: response.preferences != null
          ? UserPreferences.fromJson(response.preferences!)
          : const UserPreferences(),
      createdAt: DateTime.parse(response.createdAt),
      updatedAt: response.lastActive != null
          ? DateTime.parse(response.lastActive!)
          : null,
    );
  }

  /// Convert User entity to API request format
  static Map<String, dynamic> toApiRequest(User user) {
    return {
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'profileImageUrl': user.profileImageUrl,
      'preferences': user.preferences.toJson(),
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt?.toIso8601String(),
    };
  }

  /// Convert User entity to UserResponse for testing/mocking
  static UserResponse toApiResponse(User user) {
    return UserResponse(
      id: user.id,
      email: user.email,
      name: user.name,
      profileImageUrl: user.profileImageUrl,
      createdAt: user.createdAt.toIso8601String(),
      lastActive: user.updatedAt?.toIso8601String(),
      preferences: user.preferences.toJson(),
    );
  }

  /// Convert UserPreferences to JSON (uses existing toJson method)
  static Map<String, dynamic> preferencesToJson(UserPreferences prefs) {
    return prefs.toJson();
  }

  /// Convert JSON to UserPreferences (uses existing fromJson method)
  static UserPreferences preferencesFromJson(Map<String, dynamic> json) {
    return UserPreferences.fromJson(json);
  }
}