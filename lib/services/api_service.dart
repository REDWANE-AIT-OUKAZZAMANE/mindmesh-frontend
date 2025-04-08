import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiService {
  late final Dio dio;
  final String _baseUrl;
  
  ApiService({String? baseUrl}) : _baseUrl = _getBaseUrl(baseUrl) {
    dio = _createDio();
    if (kDebugMode) {
      print('ApiService initialized with baseUrl: $_baseUrl');
    }
    _setupInterceptors();
  }

  // Helper method to determine the correct base URL
  static String _getBaseUrl(String? customUrl) {
    if (customUrl != null) return customUrl;
    
    final envUrl = dotenv.env['API_URL'];
    
    // Check if we're on Android emulator
    if (envUrl == null || envUrl.contains('localhost')) {
      if (Platform.isAndroid) {
        // Use the special IP for Android emulator to connect to host
        // Include the /api context path for Spring Boot
        return 'http://10.0.2.2:8080/api';
      }
    }
    
    // If using environment URL, make sure it has the /api context path
    if (envUrl != null) {
      return envUrl.endsWith('/api') ? envUrl : '$envUrl/api';
    }
    
    return 'http://10.0.2.2:8080/api';
  }

  Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
        },
      ),
    );
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Ensure the full URL is used (with baseUrl)
          if (!options.path.startsWith('http')) {
            options.path = _baseUrl + options.path;
          }
          
          if (kDebugMode) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
            print('FULL URL: ${options.uri}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (kDebugMode) {
            print('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
            print('ERROR TYPE: ${e.type}');
            print('ERROR MESSAGE: ${e.message}');
            if (e.error != null) {
              print('ERROR DETAILS: ${e.error}');
            }
          }
          
          // Handle connectivity errors
          if (e.error is SocketException || e.type == DioExceptionType.connectionError) {
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: 'No internet connection',
                type: DioExceptionType.connectionError,
              ),
            );
          }
          
          // Handle unauthorized errors (token expired)
          if (e.response?.statusCode == 401) {
            // Token handling will be added in auth_service.dart
            return handler.reject(e);
          }
          
          return handler.next(e);
        },
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  // Set authentication token
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear authentication token
  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }

  // Generic GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    // Don't use path directly as it might ignore baseUrl
    return dio.fetch(RequestOptions(
      path: path,
      method: 'GET',
      queryParameters: queryParameters,
      baseUrl: _baseUrl,
    ));
  }

  // Generic POST request
  Future<Response> post(String path, {dynamic data}) {
    // Don't use path directly as it might ignore baseUrl
    return dio.fetch(RequestOptions(
      path: path,
      method: 'POST',
      data: data,
      baseUrl: _baseUrl,
    ));
  }

  // Generic PUT request
  Future<Response> put(String path, {dynamic data}) {
    // Don't use path directly as it might ignore baseUrl
    return dio.fetch(RequestOptions(
      path: path,
      method: 'PUT',
      data: data,
      baseUrl: _baseUrl,
    ));
  }

  // Generic DELETE request
  Future<Response> delete(String path) {
    // Don't use path directly as it might ignore baseUrl
    return dio.fetch(RequestOptions(
      path: path,
      method: 'DELETE',
      baseUrl: _baseUrl,
    ));
  }
}

// Provider for ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
}); 