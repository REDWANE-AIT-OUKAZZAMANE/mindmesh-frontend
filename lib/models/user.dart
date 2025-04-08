class User {
  final int? id;
  final String username;
  final String email;
  final String fullName;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final List<String>? roles;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.profileImageUrl,
    this.createdAt,
    this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
    );
  }
  
  // Create a user from partial data (used in AuthResponse)
  factory User.fromPartialJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      // If we don't have createdAt, use current time
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      'roles': roles ?? [],
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    String? profileImageUrl,
    DateTime? createdAt,
    List<String>? roles,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      roles: roles ?? this.roles,
    );
  }
} 