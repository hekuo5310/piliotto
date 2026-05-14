class ZerexaUser {
  final String id;
  final int uid;
  final String username;
  final String role;
  final String? email;
  final String? gravatarUrl;
  final int? followerCount;
  final int? followingCount;
  final String? createdAt;

  ZerexaUser({
    required this.id,
    required this.uid,
    required this.username,
    required this.role,
    this.email,
    this.gravatarUrl,
    this.followerCount,
    this.followingCount,
    this.createdAt,
  });

  factory ZerexaUser.fromJson(Map<String, dynamic> json) {
    return ZerexaUser(
      id: json['id']?.toString() ?? '',
      uid: _toInt(json['uid']),
      username: json['username']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      email: json['email']?.toString(),
      gravatarUrl: json['gravatar_url']?.toString(),
      followerCount: _toInt(json['follower_count']),
      followingCount: _toInt(json['following_count']),
      createdAt: json['created_at']?.toString(),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  bool get isAdmin => role == 'admin';
}

class LoginResponse {
  final bool success;
  final String? token;
  final ZerexaUser? user;
  final String? error;
  final String? code;

  LoginResponse({
    required this.success,
    this.token,
    this.user,
    this.error,
    this.code,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] == true,
      token: json['token']?.toString(),
      user: json['user'] != null ? ZerexaUser.fromJson(json['user']) : null,
      error: json['error']?.toString(),
      code: json['code']?.toString(),
    );
  }
}

class SignInResponse {
  final bool success;
  final int? coins;

  SignInResponse({required this.success, this.coins});

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      success: json['success'] == true,
      coins: json['coins'] is int ? json['coins'] : null,
    );
  }
}
