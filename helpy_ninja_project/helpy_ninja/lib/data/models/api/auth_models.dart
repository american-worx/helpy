import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

/// Login request model matching backend DTO
@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

/// Register request model matching backend DTO
@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;
  final String name;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

/// Refresh token request model
@JsonSerializable()
class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({
    required this.refreshToken,
  });

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}

/// Authentication response model matching backend DTO
@JsonSerializable()
class AuthResponse {
  final UserResponse user;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

/// User response model matching backend DTO
@JsonSerializable()
class UserResponse {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final String role;
  final bool emailVerified;
  final String createdAt;
  final String? lastActive;
  final Map<String, dynamic>? preferences;
  final Map<String, dynamic>? subscription;

  const UserResponse({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    this.role = 'student',
    this.emailVerified = false,
    required this.createdAt,
    this.lastActive,
    this.preferences,
    this.subscription,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseToJson(this);
}

/// Token refresh response model
@JsonSerializable()
class TokenRefreshResponse {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final int expiresIn;

  const TokenRefreshResponse({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    required this.expiresIn,
  });

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenRefreshResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TokenRefreshResponseToJson(this);
}

/// Error response model for API errors
@JsonSerializable()
class ErrorResponse {
  final String message;
  final String? error;
  final int? statusCode;
  final String? timestamp;
  final String? path;
  final Map<String, dynamic>? details;
  final List<ValidationError>? validationErrors;

  const ErrorResponse({
    required this.message,
    this.error,
    this.statusCode,
    this.timestamp,
    this.path,
    this.details,
    this.validationErrors,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}

/// Validation error model for field-specific errors
@JsonSerializable()
class ValidationError {
  final String field;
  final String message;
  final dynamic rejectedValue;

  const ValidationError({
    required this.field,
    required this.message,
    this.rejectedValue,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) =>
      _$ValidationErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ValidationErrorToJson(this);
}

/// Email verification request model
@JsonSerializable()
class EmailVerificationRequest {
  final String token;

  const EmailVerificationRequest({
    required this.token,
  });

  factory EmailVerificationRequest.fromJson(Map<String, dynamic> json) =>
      _$EmailVerificationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EmailVerificationRequestToJson(this);
}

/// Password reset request model
@JsonSerializable()
class PasswordResetRequest {
  final String email;

  const PasswordResetRequest({
    required this.email,
  });

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordResetRequestToJson(this);
}