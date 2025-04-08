import 'package:mindmesh/models/user.dart';

class AuthResponse {
  final String token;
  final String? refreshToken;
  final User user;

  AuthResponse({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // If user object is directly in the response
    if (json.containsKey('username') && json.containsKey('email')) {
      return AuthResponse(
        token: json['token'],
        refreshToken: json['refreshToken'],
        user: User.fromPartialJson({
          'username': json['username'],
          'email': json['email'],
          'fullName': json['fullName'] ?? '',
        }),
      );
    }
    
    // If user is a nested object
    return AuthResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
} 