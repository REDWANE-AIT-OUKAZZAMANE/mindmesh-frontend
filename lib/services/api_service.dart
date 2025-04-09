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
    
    // Updated production URL with exact link from user
    // We're removing the /api suffix as it might be causing issues
    const backendDomain = 'https://mindmesh-backend-yp1t.onrender.com';
    
    // Check if we're on Android emulator for local development
    if (kDebugMode && (envUrl == null || envUrl.contains('localhost'))) {
      if (Platform.isAndroid) {
        // Use the special IP for Android emulator to connect to host
        return 'http://10.0.2.2:8080';
      }
    }
    
    // If using environment URL, make sure it doesn't have the /api context path
    if (envUrl != null) {
      return envUrl.endsWith('/api') 
          ? envUrl.substring(0, envUrl.length - 4) 
          : envUrl;
    }
    
    // Default to production URL
    return backendDomain;
  }

  Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30), // Increased timeout
        receiveTimeout: const Duration(seconds: 30), // Increased timeout
        sendTimeout: const Duration(seconds: 30),    // Added send timeout
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        validateStatus: (status) {
          return status != null && status < 500; // Accept all non-server error responses
        },
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
          // Fix path handling - don't prepend baseUrl if it's already a full URL
          if (!options.path.startsWith('http')) {
            // Correctly format the URL
            String path = options.path;
            
            // Handle paths with or without leading slash
            if (path.startsWith('/')) {
              path = path.substring(1);
            }
            
            // All API endpoints should include /api
            if (!path.startsWith('api/') && path != 'api') {
              path = 'api/' + path;
            }
            
            // Ensure base URL doesn't end with slash
            String baseUrl = _baseUrl;
            if (baseUrl.endsWith('/')) {
              baseUrl = baseUrl.substring(0, baseUrl.length - 1);
            }
            
            // Create the full URL
            options.path = baseUrl + '/' + path;
          }
          
          if (kDebugMode) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
            print('FULL URL: ${options.uri}');
            print('HEADERS: ${options.headers}');
            if (options.data != null) {
              print('REQUEST DATA: ${options.data}');
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
            print('RESPONSE DATA: ${response.data}');
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
            if (e.response != null) {
              print('ERROR RESPONSE: ${e.response?.data}');
            }
          }
          
          // Handle connectivity errors
          if (e.error is SocketException || 
              e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: 'No internet connection or server unreachable',
                type: DioExceptionType.connectionError,
              ),
            );
          }
          
          // Handle unauthorized errors (token expired)
          if (e.response?.statusCode == 401) {
            // Token handling will be added in auth_service.dart
            return handler.reject(e);
          }
          
          return handler.reject(e);
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
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  // Generic POST request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  // Generic PUT request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await dio.put(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  // Generic DELETE request
  Future<Response> delete(String path) async {
    try {
      return await dio.delete(path);
    } catch (e) {
      rethrow;
    }
  }
  
  // Method to check API connectivity by using direct request to avoid interceptors
  Future<bool> checkConnectivity() async {
    try {
      // Create a separate Dio instance for this test
      final testDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      
      // Try direct URL with different formats
      final urls = [
        '$_baseUrl/api/health',
        'https://mindmesh-backend-yp1t.onrender.com/api/health',
        'https://mindmesh-backend-yp1t.onrender.com/health',
      ];
      
      bool success = false;
      String? errorMsg;
      
      for (final url in urls) {
        try {
          if (kDebugMode) {
            print('Trying connectivity check with URL: $url');
          }
          
          final response = await testDio.get(url);
          
          if (response.statusCode == 200) {
            if (kDebugMode) {
              print('Connectivity check succeeded with URL: $url');
              print('Response: ${response.data}');
            }
            success = true;
            break;
          }
        } catch (e) {
          errorMsg = e.toString();
          if (kDebugMode) {
            print('Connectivity check failed for URL $url: $e');
          }
          // Continue to next URL
          continue;
        }
      }
      
      if (!success && errorMsg != null) {
        if (kDebugMode) {
          print('All connectivity checks failed. Last error: $errorMsg');
        }
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('General connectivity check error: $e');
      }
      return false;
    }
  }
}

// Provider for ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
}); 