import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mindmesh/models/auth_response.dart';
import 'package:mindmesh/models/user.dart';
import 'package:mindmesh/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage;
  
  AuthService({
    required ApiService apiService,
    required FlutterSecureStorage secureStorage,
  })  : _apiService = apiService,
        _secureStorage = secureStorage;

  // JWT token constants
  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  // Get current user if logged in
  Future<User?> getCurrentUser() async {
    final userJson = await _secureStorage.read(key: _userKey);
    if (userJson == null) return null;
    
    try {
      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      await logout();
      return null;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Get the stored JWT token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Get the stored refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  // Login user with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Check if this is a verification required response
        if (response.data is Map && 
            response.data.containsKey('requiresVerification') && 
            response.data['requiresVerification'] == true) {
          
          return {
            'success': false,
            'requiresVerification': true,
            'message': response.data['message'] ?? 'Please check your email for verification code',
            'username': response.data['username'] ?? '',
            'email': response.data['email'] ?? email,
          };
        }
        
        // Normal authentication response
        final authResponse = AuthResponse.fromJson(response.data);
        
        // Store tokens securely
        await _secureStorage.write(key: _tokenKey, value: authResponse.token);
        if (authResponse.refreshToken != null) {
          await _secureStorage.write(key: _refreshTokenKey, value: authResponse.refreshToken);
        }
        await _secureStorage.write(key: _userKey, value: jsonEncode(authResponse.user.toJson()));
        
        // Set the auth token for future API calls
        _apiService.setAuthToken(authResponse.token);
        
        return {'success': true};
      }
      
      return {'success': false, 'message': 'Login failed. Please try again.'};
    } on DioException catch (e) {
      print('Login error: ${e.message}');
      String errorMessage = 'An unexpected error occurred';
      
      // Handle different error responses
      if (e.response != null) {
        // Check if this is the unverified account case
        if (e.response!.statusCode == 401 && 
            e.response!.data is Map && 
            e.response!.data.containsKey('message') &&
            e.response!.data['message'].toString().contains('not verified')) {
          
          return {
            'success': false,
            'requiresVerification': true,
            'message': e.response!.data['message'] ?? 'Email not verified. Please check your email for verification code.',
            'email': email,
          };
        }
        
        if (e.response!.statusCode == 401) {
          errorMessage = 'Invalid email or password';
        } else if (e.response!.statusCode == 400) {
          errorMessage = 'Invalid input. Please check your email and password.';
        } else if (e.response!.data != null) {
          try {
            final Map<String, dynamic> errorData = e.response!.data;
            if (errorData.containsKey('message')) {
              errorMessage = errorData['message'];
            }
            
            if (errorData.containsKey('errors')) {
              final errors = errorData['errors'];
              if (errors is Map && errors.containsKey('authentication')) {
                errorMessage = errors['authentication'];
              }
            }
          } catch (_) {
            // If we can't parse the error response, use the default message
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection.';
      }
      
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('Unexpected login error: $e');
      return {'success': false, 'message': 'An unexpected error occurred. Please try again.'};
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/signup',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'fullName': fullName,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // For API response that returns verification required format
        if (response.data is Map && 
            response.data.containsKey('requiresVerification') && 
            response.data['requiresVerification'] == true) {
          
          return {
            'success': true,
            'requiresVerification': true,
            'message': response.data['message'] ?? 'Please check your email for verification code',
            'username': response.data['username'] ?? username,
            'email': response.data['email'] ?? email,
          };
        } 
        // For backward compatibility with old API format
        else {
          try {
            final authResponse = AuthResponse.fromJson(response.data);
            
            // Store tokens securely
            await _secureStorage.write(key: _tokenKey, value: authResponse.token);
            if (authResponse.refreshToken != null) {
              await _secureStorage.write(key: _refreshTokenKey, value: authResponse.refreshToken);
            }
            await _secureStorage.write(key: _userKey, value: jsonEncode(authResponse.user.toJson()));
            
            // Set the auth token for future API calls
            _apiService.setAuthToken(authResponse.token);
            
            return {'success': true};
          } catch (e) {
            print('Error parsing auth response: $e');
            return {'success': false, 'message': 'Server returned unexpected response format'};
          }
        }
      }
      
      return {'success': false, 'message': 'Registration failed. Please try again.'};
    } on DioException catch (e) {
      print('Registration error: ${e.message}');
      String errorMessage = 'Registration failed. Please try again.';
      Map<String, String> fieldErrors = {};
      
      // Handle different error responses
      if (e.response != null) {
        if (e.response!.statusCode == 409) {
          // Conflict - usually username or email already exists
          errorMessage = 'Registration failed. Username or email already exists.';
          
          try {
            final Map<String, dynamic> errorData = e.response!.data;
            if (errorData.containsKey('errors')) {
              final errors = errorData['errors'];
              if (errors is Map) {
                if (errors.containsKey('username')) {
                  fieldErrors['username'] = errors['username'];
                  errorMessage = errors['username'];
                }
                if (errors.containsKey('email')) {
                  fieldErrors['email'] = errors['email'];
                  if (!fieldErrors.containsKey('username')) {
                    errorMessage = errors['email'];
                  }
                }
              }
            }
          } catch (_) {
            // If we can't parse the error response, use the default message
          }
        } else if (e.response!.statusCode == 400) {
          errorMessage = 'Invalid input. Please check your registration details.';
          
          try {
            final Map<String, dynamic> errorData = e.response!.data;
            if (errorData.containsKey('errors') && errorData['errors'] is Map) {
              final errors = errorData['errors'];
              if (errors.isNotEmpty) {
                // Just use the first error as the main message
                final firstField = errors.keys.first;
                errorMessage = errors[firstField];
                fieldErrors = Map<String, String>.from(errors);
              }
            }
          } catch (_) {
            // If we can't parse the error response, use the default message
          }
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection.';
      }
      
      return {
        'success': false, 
        'message': errorMessage,
        if (fieldErrors.isNotEmpty) 'fieldErrors': fieldErrors
      };
    } catch (e) {
      print('Unexpected registration error: $e');
      return {'success': false, 'message': 'An unexpected error occurred. Please try again.'};
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    final refreshToken = await getRefreshToken();
    
    if (refreshToken == null) {
      return false;
    }
    
    try {
      final response = await _apiService.dio.post(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        
        // Update tokens
        await _secureStorage.write(key: _tokenKey, value: authResponse.token);
        if (authResponse.refreshToken != null) {
          await _secureStorage.write(key: _refreshTokenKey, value: authResponse.refreshToken);
        }
        
        // Update user data if available
        if (authResponse.user != null) {
          await _secureStorage.write(key: _userKey, value: jsonEncode(authResponse.user.toJson()));
        }
        
        // Update auth token for future API calls
        _apiService.setAuthToken(authResponse.token);
        
        return true;
      }
      
      // If refresh fails, logout the user
      await logout();
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      await logout();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      // Try to call logout endpoint to invalidate token on the server
      final token = await getToken();
      if (token != null) {
        await _apiService.dio.post('/auth/logout').catchError((e) {
          // Ignore errors during logout API call
          print('Logout API error: $e');
        });
      }
    } catch (e) {
      // Ignore errors during logout
      print('Logout error: $e');
    } finally {
      // Clear tokens regardless of API call success
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _userKey);
      
      // Clear token from API service
      _apiService.clearAuthToken();
      
      // Clear any additional stored data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_sync');
    }
  }

  // Store a JWT token securely
  Future<void> _storeAuthToken(String token) async {
    // Store token securely
    await _secureStorage.write(key: _tokenKey, value: token);
    
    // Set the auth token for future API calls
    _apiService.setAuthToken(token);
  }
  
  // Store user information securely
  Future<void> _storeUserInfo(Map<String, dynamic> userInfo) async {
    try {
      // Create a simple User object from the provided info
      User user = User(
        username: userInfo['username'],
        email: userInfo['email'],
        fullName: userInfo['fullName'] ?? '',
      );
      
      // Store user data
      await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));
    } catch (e) {
      print('Error storing user info: $e');
    }
  }

  // Verify email with verification code
  Future<Map<String, dynamic>> verifyEmail(String email, String verificationCode) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/verify',
        data: {
          'email': email,
          'verificationCode': verificationCode,
        },
      );

      if (response.statusCode == 200) {
        // Check if the server returned a token for auto-login
        if (response.data.containsKey('token')) {
          // Store the auth token
          await _storeAuthToken(response.data['token']);
          
          // Store user info
          await _storeUserInfo({
            'username': response.data['username'],
            'email': response.data['email'],
            'fullName': response.data['fullName'],
          });
          
          return {
            'success': true,
            'message': response.data['message'] ?? 'Email verified successfully! You are now logged in.',
            'autoLogin': true,
          };
        }
        
        return {
          'success': true,
          'message': response.data['message'] ?? 'Email verified successfully!',
          'autoLogin': false,
        };
      }
      
      return {
        'success': false, 
        'message': response.data['message'] ?? 'Verification failed. Please try again.',
      };
    } on DioException catch (e) {
      print('Verification error: ${e.message}');
      String errorMessage = 'Verification failed. Please try again.';
      
      // Handle different error responses
      if (e.response != null) {
        if (e.response!.statusCode == 400) {
          errorMessage = e.response!.data['message'] ?? 'Invalid verification code.';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection.';
      }
      
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('Unexpected verification error: $e');
      return {'success': false, 'message': 'An unexpected error occurred. Please try again.'};
    }
  }
  
  // Resend verification code
  Future<Map<String, dynamic>> resendVerificationCode(String email, String username) async {
    try {
      // Re-register with the same credentials to trigger a new verification code
      final response = await _apiService.dio.post(
        '/auth/resend-verification',
        data: {
          'email': email,
          'username': username,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'A new verification code has been sent to your email',
        };
      }
      
      return {
        'success': false, 
        'message': response.data['message'] ?? 'Failed to resend verification code. Please try again.',
      };
    } on DioException catch (e) {
      print('Resend verification error: ${e.message}');
      String errorMessage = 'Failed to resend verification code. Please try again.';
      
      // Handle different error responses
      if (e.response != null) {
        if (e.response!.data is Map && e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection.';
      }
      
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('Unexpected resend verification error: $e');
      return {'success': false, 'message': 'An unexpected error occurred. Please try again.'};
    }
  }
  
  // Request password reset
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/forgot-password',
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Password reset email sent. Please check your inbox.',
        };
      }
      
      return {
        'success': false, 
        'message': response.data['message'] ?? 'Failed to request password reset. Please try again.',
      };
    } on DioException catch (e) {
      print('Password reset request error: ${e.message}');
      String errorMessage = 'Failed to request password reset. Please try again.';
      
      // Handle different error responses
      if (e.response != null) {
        if (e.response!.data is Map && e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection.';
      }
      
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('Unexpected password reset request error: $e');
      return {'success': false, 'message': 'An unexpected error occurred. Please try again.'};
    }
  }
  
  // Verify reset code without marking it as used
  Future<Map<String, dynamic>> verifyResetCode(String email, String resetCode) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/verify-reset-code',
        data: {
          'email': email,
          'resetCode': resetCode,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Code verified successfully.',
        };
      }
      
      return {
        'success': false, 
        'message': response.data['message'] ?? 'Invalid or expired reset code. Please try again.',
      };
    } on DioException catch (e) {
      print('Code verification error: ${e.message}');
      String errorMessage = 'Failed to verify code. Please try again.';
      
      // Handle different error responses
      if (e.response != null) {
        if (e.response!.data is Map && e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        }
        // If backend returns 400, it means the code is invalid
        if (e.response!.statusCode == 400) {
          errorMessage = 'Invalid or expired verification code. Please try again or request a new code.';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection.';
      }
      
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('Unexpected code verification error: $e');
      return {'success': false, 'message': 'An unexpected error occurred. Please try again.'};
    }
  }
  
  // Reset password with code
  Future<Map<String, dynamic>> resetPassword(String email, String resetCode, String newPassword) async {
    try {
      print('Attempting to reset password for email: $email with code: $resetCode');
      
      final response = await _apiService.dio.post(
        '/auth/reset-password',
        data: {
          'email': email,
          'resetCode': resetCode,
          'newPassword': newPassword,
        },
      );

      print('Reset password response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Password reset successful');
        return {
          'success': true,
          'message': response.data['message'] ?? 'Password reset successful. You can now log in with your new password.',
        };
      }
      
      print('Password reset failed with response: ${response.data}');
      return {
        'success': false, 
        'message': response.data['message'] ?? 'Failed to reset password. Please try again.',
      };
    } on DioException catch (e) {
      print('Password reset error: ${e.message}');
      if (e.response != null) {
        print('Error response status: ${e.response!.statusCode}');
        print('Error response data: ${e.response!.data}');
      }
      
      String errorMessage = 'Failed to reset password. Please try again.';
      
      // Handle different error responses
      if (e.response != null) {
        if (e.response!.data is Map && e.response!.data.containsKey('message')) {
          errorMessage = e.response!.data['message'];
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timed out. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection.';
      }
      
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('Unexpected password reset error: $e');
      return {'success': false, 'message': 'An unexpected error occurred. Please try again.'};
    }
  }
}

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final secureStorage = const FlutterSecureStorage();
  
  return AuthService(
    apiService: apiService,
    secureStorage: secureStorage,
  );
});

// Provider to access current user
final currentUserProvider = FutureProvider<User?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentUser();
});

// Provider to check authentication status
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.isAuthenticated();
}); 