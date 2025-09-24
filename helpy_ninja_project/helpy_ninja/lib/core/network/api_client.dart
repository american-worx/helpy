import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../config/constants.dart';
import '../storage/secure_storage.dart';
import 'api_interceptors.dart';

@singleton
class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();

  ApiClient(SecureStorage secureStorage) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(secureStorage),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    // Check if network requests are disabled for development
    if (!AppConstants.enableNetworkRequests || !AppConstants.enableApiCalls) {
      _logger.w('API calls disabled for development. Returning mock response for GET $path');
      return _createMockResponse<T>(path);
    }
    
    try {
      _logger.d('GET Request: $path');
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      _logger.e('GET Request failed: $path', error: e);
      rethrow;
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    // Check if network requests are disabled for development
    if (!AppConstants.enableNetworkRequests || !AppConstants.enableApiCalls) {
      _logger.w('API calls disabled for development. Returning mock response for POST $path');
      return _createMockResponse<T>(path, data: data);
    }
    
    try {
      _logger.d('POST Request: $path');
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      _logger.e('POST Request failed: $path', error: e);
      rethrow;
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    // Check if network requests are disabled for development
    if (!AppConstants.enableNetworkRequests || !AppConstants.enableApiCalls) {
      _logger.w('API calls disabled for development. Returning mock response for PUT $path');
      return _createMockResponse<T>(path, data: data);
    }
    
    try {
      _logger.d('PUT Request: $path');
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      _logger.e('PUT Request failed: $path', error: e);
      rethrow;
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    // Check if network requests are disabled for development
    if (!AppConstants.enableNetworkRequests || !AppConstants.enableApiCalls) {
      _logger.w('API calls disabled for development. Returning mock response for DELETE $path');
      return _createMockResponse<T>(path, data: data);
    }
    
    try {
      _logger.d('DELETE Request: $path');
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      _logger.e('DELETE Request failed: $path', error: e);
      rethrow;
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    // Check if network requests are disabled for development
    if (!AppConstants.enableNetworkRequests || !AppConstants.enableApiCalls) {
      _logger.w('API calls disabled for development. Returning mock response for PATCH $path');
      return _createMockResponse<T>(path, data: data);
    }
    
    try {
      _logger.d('PATCH Request: $path');
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      _logger.e('PATCH Request failed: $path', error: e);
      rethrow;
    }
  }

  /// Upload file
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String? fileName,
    Map<String, dynamic>? fields,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    // Check if network requests are disabled for development
    if (!AppConstants.enableNetworkRequests || !AppConstants.enableApiCalls) {
      _logger.w('API calls disabled for development. Returning mock response for UPLOAD $path');
      return _createMockResponse<T>(path);
    }
    
    try {
      _logger.d('Upload Request: $path');
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        ...?fields,
      });

      final response = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      _logger.e('Upload Request failed: $path', error: e);
      rethrow;
    }
  }

  /// Download file
  Future<Response> downloadFile(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    // Check if network requests are disabled for development
    if (!AppConstants.enableNetworkRequests || !AppConstants.enableApiCalls) {
      _logger.w('API calls disabled for development. Returning mock response for DOWNLOAD $path');
      return _createMockResponse(path);
    }
    
    try {
      _logger.d('Download Request: $path');
      final response = await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      _logger.e('Download Request failed: $path', error: e);
      rethrow;
    }
  }

  /// Create mock response for offline development
  Response<T> _createMockResponse<T>(String path, {dynamic data}) {
    _logger.i('Creating mock response for: $path');
    
    // Generate appropriate mock data based on the endpoint
    Map<String, dynamic> mockData = {};
    
    if (path.contains('/auth/login')) {
      mockData = {
        'success': true,
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': 'user_123',
          'email': 'test@example.com',
          'name': 'Test User',
        },
      };
    } else if (path.contains('/auth/register')) {
      mockData = {
        'success': true,
        'message': 'User registered successfully',
        'user': {
          'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
          'email': data?['email'] ?? 'test@example.com',
          'name': data?['name'] ?? 'Test User',
        },
      };
    } else if (path.contains('/chat/conversations')) {
      mockData = {
        'success': true,
        'conversations': [],
      };
    } else if (path.contains('/chat/messages')) {
      mockData = {
        'success': true,
        'messages': [],
      };
    } else if (path.contains('/users/profile')) {
      mockData = {
        'success': true,
        'user': {
          'id': 'user_123',
          'email': 'test@example.com',
          'name': 'Test User',
          'avatar': null,
        },
      };
    } else {
      // Generic success response
      mockData = {
        'success': true,
        'message': 'Mock response for $path',
        'data': null,
      };
    }
    
    return Response<T>(
      data: mockData as T,
      statusCode: 200,
      statusMessage: 'OK',
      requestOptions: RequestOptions(path: path),
    );
  }
}