import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@singleton
class SecureStorage {
  final FlutterSecureStorage _storage;
  final Logger _logger = Logger();

  SecureStorage() : _storage = const FlutterSecureStorage();

  // Token storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'email';

  /// Store access token
  Future<void> storeAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
      _logger.d('Access token stored successfully');
    } catch (e) {
      _logger.e('Failed to store access token', error: e);
      rethrow;
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      _logger.d('Access token retrieved: ${token != null ? 'found' : 'not found'}');
      return token;
    } catch (e) {
      _logger.e('Failed to retrieve access token', error: e);
      return null;
    }
  }

  /// Store refresh token
  Future<void> storeRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
      _logger.d('Refresh token stored successfully');
    } catch (e) {
      _logger.e('Failed to store refresh token', error: e);
      rethrow;
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: _refreshTokenKey);
      _logger.d('Refresh token retrieved: ${token != null ? 'found' : 'not found'}');
      return token;
    } catch (e) {
      _logger.e('Failed to retrieve refresh token', error: e);
      return null;
    }
  }

  /// Store both tokens
  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        storeAccessToken(accessToken),
        storeRefreshToken(refreshToken),
      ]);
      _logger.d('Both tokens stored successfully');
    } catch (e) {
      _logger.e('Failed to store tokens', error: e);
      rethrow;
    }
  }

  /// Store user credentials
  Future<void> storeUserCredentials({
    required String userId,
    required String email,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _userIdKey, value: userId),
        _storage.write(key: _emailKey, value: email),
      ]);
      _logger.d('User credentials stored successfully');
    } catch (e) {
      _logger.e('Failed to store user credentials', error: e);
      rethrow;
    }
  }

  /// Get stored user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      _logger.e('Failed to retrieve user ID', error: e);
      return null;
    }
  }

  /// Get stored email
  Future<String?> getEmail() async {
    try {
      return await _storage.read(key: _emailKey);
    } catch (e) {
      _logger.e('Failed to retrieve email', error: e);
      return null;
    }
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
      ]);
      _logger.d('Tokens cleared successfully');
    } catch (e) {
      _logger.e('Failed to clear tokens', error: e);
      rethrow;
    }
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      _logger.d('All secure storage cleared');
    } catch (e) {
      _logger.e('Failed to clear all storage', error: e);
      rethrow;
    }
  }

  /// Check if user is logged in (has valid tokens)
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      return accessToken != null && refreshToken != null;
    } catch (e) {
      _logger.e('Failed to check login status', error: e);
      return false;
    }
  }

  /// Store generic data
  Future<void> store(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      _logger.d('Data stored with key: $key');
    } catch (e) {
      _logger.e('Failed to store data with key: $key', error: e);
      rethrow;
    }
  }

  /// Retrieve generic data
  Future<String?> retrieve(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      _logger.e('Failed to retrieve data with key: $key', error: e);
      return null;
    }
  }

  /// Delete specific data
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      _logger.d('Data deleted with key: $key');
    } catch (e) {
      _logger.e('Failed to delete data with key: $key', error: e);
      rethrow;
    }
  }
}