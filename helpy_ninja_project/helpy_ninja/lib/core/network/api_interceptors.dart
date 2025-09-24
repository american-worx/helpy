import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../storage/secure_storage.dart';
import '../errors/api_exception.dart';

/// Authentication interceptor to add tokens to requests
class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  final Logger _logger = Logger();

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Skip auth for login/register endpoints
      if (_shouldSkipAuth(options.path)) {
        return handler.next(options);
      }

      final token = await _secureStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        _logger.d('Added auth token to request: ${options.path}');
      }

      handler.next(options);
    } catch (e) {
      _logger.e('Error in auth interceptor', error: e);
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 unauthorized errors
    if (err.response?.statusCode == 401) {
      _logger.w('Received 401, attempting token refresh');
      
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the original request
          final clonedRequest = await _retryRequest(err.requestOptions);
          return handler.resolve(clonedRequest);
        }
      } catch (e) {
        _logger.e('Token refresh failed', error: e);
        // Clear tokens and redirect to login
        await _secureStorage.clearTokens();
      }
    }

    handler.next(err);
  }

  bool _shouldSkipAuth(String path) {
    final authSkipPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/verify-email',
      '/auth/reset-password',
    ];
    return authSkipPaths.any((skipPath) => path.contains(skipPath));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      // TODO: Implement actual refresh token call
      // This is a placeholder implementation
      _logger.d('Token refresh would be implemented here');
      return false;
    } catch (e) {
      _logger.e('Token refresh error', error: e);
      return false;
    }
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final dio = Dio();
    final token = await _secureStorage.getAccessToken();
    
    if (token != null) {
      requestOptions.headers['Authorization'] = 'Bearer $token';
    }

    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
    );
  }
}

/// Error interceptor to handle and transform API errors
class ErrorInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('API Error: ${err.message}', error: err);

    final apiException = _mapDioErrorToApiException(err);
    handler.next(DioException(
      requestOptions: err.requestOptions,
      error: apiException,
      type: err.type,
      response: err.response,
      message: apiException.message,
    ));
  }

  ApiException _mapDioErrorToApiException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: 408,
          type: ApiExceptionType.timeout,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled',
          statusCode: 499,
          type: ApiExceptionType.cancelled,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Connection error. Please check your internet connection.',
          statusCode: 0,
          type: ApiExceptionType.network,
        );

      default:
        return ApiException(
          message: 'An unexpected error occurred',
          statusCode: 500,
          type: ApiExceptionType.unknown,
        );
    }
  }

  ApiException _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode ?? 500;
    final responseData = error.response?.data;

    String message = 'An error occurred';
    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] ?? 
                responseData['error'] ?? 
                'Server error occurred';
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          message: message,
          statusCode: statusCode,
          type: ApiExceptionType.badRequest,
          details: responseData,
        );
      case 401:
        return ApiException(
          message: 'Authentication failed',
          statusCode: statusCode,
          type: ApiExceptionType.unauthorized,
        );
      case 403:
        return ApiException(
          message: 'Access forbidden',
          statusCode: statusCode,
          type: ApiExceptionType.forbidden,
        );
      case 404:
        return ApiException(
          message: 'Resource not found',
          statusCode: statusCode,
          type: ApiExceptionType.notFound,
        );
      case 422:
        return ApiException(
          message: 'Validation failed',
          statusCode: statusCode,
          type: ApiExceptionType.validation,
          details: responseData,
        );
      case 500:
        return ApiException(
          message: 'Internal server error',
          statusCode: statusCode,
          type: ApiExceptionType.serverError,
        );
      default:
        return ApiException(
          message: message,
          statusCode: statusCode,
          type: ApiExceptionType.unknown,
        );
    }
  }
}

/// Logging interceptor for debugging
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('''
🚀 REQUEST
Method: ${options.method}
URL: ${options.baseUrl}${options.path}
Headers: ${options.headers}
Query: ${options.queryParameters}
Body: ${options.data}
''');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('''
✅ RESPONSE
Status: ${response.statusCode}
URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}
Headers: ${response.headers}
Body: ${response.data}
''');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('''
❌ ERROR
Method: ${err.requestOptions.method}
URL: ${err.requestOptions.baseUrl}${err.requestOptions.path}
Status: ${err.response?.statusCode}
Message: ${err.message}
Data: ${err.response?.data}
''');
    handler.next(err);
  }
}