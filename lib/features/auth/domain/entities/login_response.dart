import 'user.dart';

/// Respuesta del endpoint /auth/login
class LoginResponse {
  final String accessToken;
  final User user;

  const LoginResponse({required this.accessToken, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken, 'user': user.toJson()};
  }

  @override
  String toString() => 'LoginResponse(user: ${user.email})';
}
