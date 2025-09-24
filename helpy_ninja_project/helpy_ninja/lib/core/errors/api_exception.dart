/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final ApiExceptionType type;
  final Map<String, dynamic>? details;

  const ApiException({
    required this.message,
    required this.statusCode,
    required this.type,
    this.details,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode, Type: $type)';
  }

  /// Get user-friendly error message
  String get userMessage {
    switch (type) {
      case ApiExceptionType.network:
        return 'Please check your internet connection and try again.';
      case ApiExceptionType.timeout:
        return 'Request timed out. Please try again.';
      case ApiExceptionType.unauthorized:
        return 'You need to sign in to continue.';
      case ApiExceptionType.forbidden:
        return 'You don\'t have permission to access this resource.';
      case ApiExceptionType.notFound:
        return 'The requested resource was not found.';
      case ApiExceptionType.validation:
        return 'Please check your input and try again.';
      case ApiExceptionType.serverError:
        return 'Server error occurred. Please try again later.';
      case ApiExceptionType.cancelled:
        return 'Request was cancelled.';
      case ApiExceptionType.badRequest:
        return message.isNotEmpty ? message : 'Invalid request.';
      case ApiExceptionType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Check if this is a network-related error
  bool get isNetworkError {
    return type == ApiExceptionType.network || 
           type == ApiExceptionType.timeout;
  }

  /// Check if this is an authentication error
  bool get isAuthError {
    return type == ApiExceptionType.unauthorized;
  }

  /// Check if this is a validation error
  bool get isValidationError {
    return type == ApiExceptionType.validation;
  }

  /// Check if retry might help
  bool get canRetry {
    return type == ApiExceptionType.network ||
           type == ApiExceptionType.timeout ||
           type == ApiExceptionType.serverError;
  }

  /// Create from HTTP status code
  factory ApiException.fromStatusCode(
    int statusCode, {
    String? message,
    Map<String, dynamic>? details,
  }) {
    final type = ApiExceptionType.fromStatusCode(statusCode);
    return ApiException(
      message: message ?? _getDefaultMessage(statusCode),
      statusCode: statusCode,
      type: type,
      details: details,
    );
  }

  static String _getDefaultMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 422:
        return 'Validation failed';
      case 500:
        return 'Internal server error';
      default:
        return 'HTTP error $statusCode';
    }
  }
}

/// Types of API exceptions
enum ApiExceptionType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  serverError,
  badRequest,
  cancelled,
  unknown;

  /// Create from HTTP status code
  static ApiExceptionType fromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return ApiExceptionType.badRequest;
      case 401:
        return ApiExceptionType.unauthorized;
      case 403:
        return ApiExceptionType.forbidden;
      case 404:
        return ApiExceptionType.notFound;
      case 422:
        return ApiExceptionType.validation;
      case 500:
      case 502:
      case 503:
      case 504:
        return ApiExceptionType.serverError;
      default:
        return ApiExceptionType.unknown;
    }
  }
}

/// Exception for local storage errors
class StorageException implements Exception {
  final String message;
  final String operation;
  final Object? originalError;

  const StorageException({
    required this.message,
    required this.operation,
    this.originalError,
  });

  @override
  String toString() {
    return 'StorageException: $message (Operation: $operation)';
  }
}

/// Exception for validation errors
class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required this.message,
    this.fieldErrors,
  });

  @override
  String toString() {
    return 'ValidationException: $message';
  }

  /// Get errors for a specific field
  List<String> getFieldErrors(String field) {
    return fieldErrors?[field] ?? [];
  }

  /// Check if there are errors for a specific field
  bool hasFieldError(String field) {
    return fieldErrors?.containsKey(field) ?? false;
  }
}

/// Exception for authentication errors
class AuthException implements Exception {
  final String message;
  final AuthExceptionType type;

  const AuthException({
    required this.message,
    required this.type,
  });

  @override
  String toString() {
    return 'AuthException: $message (Type: $type)';
  }

  /// Get user-friendly message
  String get userMessage {
    switch (type) {
      case AuthExceptionType.invalidCredentials:
        return 'Invalid email or password. Please try again.';
      case AuthExceptionType.userNotFound:
        return 'User not found. Please check your email.';
      case AuthExceptionType.emailAlreadyExists:
        return 'An account with this email already exists.';
      case AuthExceptionType.tokenExpired:
        return 'Your session has expired. Please sign in again.';
      case AuthExceptionType.tokenInvalid:
        return 'Invalid authentication token. Please sign in again.';
      case AuthExceptionType.emailNotVerified:
        return 'Please verify your email address to continue.';
      case AuthExceptionType.accountDisabled:
        return 'Your account has been disabled. Please contact support.';
      case AuthExceptionType.tooManyAttempts:
        return 'Too many failed attempts. Please try again later.';
      default:
        return message;
    }
  }
}

/// Types of authentication exceptions
enum AuthExceptionType {
  invalidCredentials,
  userNotFound,
  emailAlreadyExists,
  tokenExpired,
  tokenInvalid,
  emailNotVerified,
  accountDisabled,
  tooManyAttempts,
  unknown,
}