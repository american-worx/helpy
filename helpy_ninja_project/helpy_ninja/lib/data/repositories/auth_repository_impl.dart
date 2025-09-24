import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/errors/api_exception.dart';
import '../models/api/auth_models.dart';
import '../models/converters/user_converter.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepositoryImpl implements IAuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  final Logger _logger = Logger();

  AuthRepositoryImpl(this._apiClient, this._secureStorage);

  @override
  Future<User> signInWithEmail(String email, String password) async {
    try {
      _logger.d('Attempting sign in for email: $email');
      
      final loginRequest = LoginRequest(email: email, password: password);
      final response = await _apiClient.post('/auth/login', data: loginRequest.toJson());

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
        final user = UserConverter.fromApiResponse(authResponse.user);

        // Store tokens securely
        await _secureStorage.storeTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );

        // Store user credentials
        await _secureStorage.storeUserCredentials(
          userId: user.id,
          email: user.email,
        );

        _logger.d('Sign in successful for user: ${user.id}');
        return user;
      } else {
        throw ApiException(
          message: 'Sign in failed',
          statusCode: response.statusCode ?? 500,
          type: ApiExceptionType.unauthorized,
        );
      }
    } catch (e) {
      _logger.e('Sign in error', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Sign in failed: ${e.toString()}',
        statusCode: 500,
        type: ApiExceptionType.unknown,
      );
    }
  }

  @override
  Future<User> signUpWithEmail(String email, String password, String name) async {
    try {
      _logger.d('Attempting sign up for email: $email');
      
      final registerRequest = RegisterRequest(email: email, password: password, name: name);
      final response = await _apiClient.post('/auth/register', data: registerRequest.toJson());

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
        final user = UserConverter.fromApiResponse(authResponse.user);

        // Store tokens securely
        await _secureStorage.storeTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );

        // Store user credentials
        await _secureStorage.storeUserCredentials(
          userId: user.id,
          email: user.email,
        );

        _logger.d('Sign up successful for user: ${user.id}');
        return user;
      } else {
        throw ApiException(
          message: 'Sign up failed',
          statusCode: response.statusCode ?? 500,
          type: ApiExceptionType.badRequest,
        );
      }
    } catch (e) {
      _logger.e('Sign up error', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Sign up failed: ${e.toString()}',
        statusCode: 500,
        type: ApiExceptionType.unknown,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      _logger.d('Attempting sign out');
      
      // Try to call logout endpoint (optional - may fail if offline)
      try {
        await _apiClient.post('/auth/logout');
      } catch (e) {
        _logger.w('Logout endpoint failed, continuing with local signout', error: e);
      }

      // Clear local storage
      await _secureStorage.clearAll();
      
      _logger.d('Sign out completed');
    } catch (e) {
      _logger.e('Sign out error', error: e);
      // Even if there's an error, we should clear local storage
      await _secureStorage.clearAll();
      rethrow;
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      _logger.d('Attempting token refresh');
      
      final refreshRequest = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _apiClient.post('/auth/refresh', data: refreshRequest.toJson());

      if (response.statusCode == 200) {
        final tokenResponse = TokenRefreshResponse.fromJson(response.data as Map<String, dynamic>);

        // Store new tokens
        await _secureStorage.storeAccessToken(tokenResponse.accessToken);
        if (tokenResponse.refreshToken != null) {
          await _secureStorage.storeRefreshToken(tokenResponse.refreshToken!);
        }

        _logger.d('Token refresh successful');
        return tokenResponse.accessToken;
      } else {
        throw ApiException(
          message: 'Token refresh failed',
          statusCode: response.statusCode ?? 500,
          type: ApiExceptionType.unauthorized,
        );
      }
    } catch (e) {
      _logger.e('Token refresh error', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Token refresh failed: ${e.toString()}',
        statusCode: 500,
        type: ApiExceptionType.unknown,
      );
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      _logger.d('Getting current user');
      
      final userId = await _secureStorage.getUserId();
      if (userId == null) {
        _logger.d('No stored user ID found');
        return null;
      }

      final response = await _apiClient.get('/users/profile');

      if (response.statusCode == 200) {
        final userResponse = UserResponse.fromJson(response.data as Map<String, dynamic>);
        final user = UserConverter.fromApiResponse(userResponse);
        _logger.d('Current user retrieved: ${user.id}');
        return user;
      } else {
        _logger.w('Failed to get current user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Get current user error', error: e);
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final isLoggedIn = await _secureStorage.isLoggedIn();
      _logger.d('Authentication status: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      _logger.e('Check authentication error', error: e);
      return false;
    }
  }

  @override
  Future<void> verifyEmail(String token) async {
    try {
      _logger.d('Verifying email with token');
      
      final verificationRequest = EmailVerificationRequest(token: token);
      final response = await _apiClient.post('/auth/verify-email', data: verificationRequest.toJson());

      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Email verification failed',
          statusCode: response.statusCode ?? 500,
          type: ApiExceptionType.badRequest,
        );
      }

      _logger.d('Email verification successful');
    } catch (e) {
      _logger.e('Email verification error', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Email verification failed: ${e.toString()}',
        statusCode: 500,
        type: ApiExceptionType.unknown,
      );
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      _logger.d('Requesting password reset for: $email');
      
      final resetRequest = PasswordResetRequest(email: email);
      final response = await _apiClient.post('/auth/reset-password', data: resetRequest.toJson());

      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Password reset request failed',
          statusCode: response.statusCode ?? 500,
          type: ApiExceptionType.badRequest,
        );
      }

      _logger.d('Password reset request successful');
    } catch (e) {
      _logger.e('Password reset error', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Password reset failed: ${e.toString()}',
        statusCode: 500,
        type: ApiExceptionType.unknown,
      );
    }
  }

  @override
  Future<User> updateProfile(User user) async {
    try {
      _logger.d('Updating profile for user: ${user.id}');
      
      final updateData = UserConverter.toApiRequest(user);
      final response = await _apiClient.put('/users/profile', data: updateData);

      if (response.statusCode == 200) {
        final userResponse = UserResponse.fromJson(response.data as Map<String, dynamic>);
        final updatedUser = UserConverter.fromApiResponse(userResponse);
        _logger.d('Profile update successful');
        return updatedUser;
      } else {
        throw ApiException(
          message: 'Profile update failed',
          statusCode: response.statusCode ?? 500,
          type: ApiExceptionType.badRequest,
        );
      }
    } catch (e) {
      _logger.e('Profile update error', error: e);
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: 'Profile update failed: ${e.toString()}',
        statusCode: 500,
        type: ApiExceptionType.unknown,
      );
    }
  }

  @override
  Future<void> storeToken(String token, String refreshToken) async {
    try {
      await _secureStorage.storeTokens(
        accessToken: token,
        refreshToken: refreshToken,
      );
      _logger.d('Tokens stored successfully');
    } catch (e) {
      _logger.e('Store token error', error: e);
      rethrow;
    }
  }

  @override
  Future<String?> getStoredToken() async {
    try {
      return await _secureStorage.getAccessToken();
    } catch (e) {
      _logger.e('Get stored token error', error: e);
      return null;
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await _secureStorage.clearTokens();
      _logger.d('Tokens cleared successfully');
    } catch (e) {
      _logger.e('Clear tokens error', error: e);
      rethrow;
    }
  }
}