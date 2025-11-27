/// Respuesta del endpoint de login
class LoginResponse {
  final String email;
  final String token;
  final String? userId;
  final String? nombres;
  final String? apellidoP;
  final String? apellidoM;

  const LoginResponse({
    required this.email,
    required this.token,
    this.userId,
    this.nombres,
    this.apellidoP,
    this.apellidoM,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      email: json['email'] as String? ?? '',
      token: json['token'] as String? ?? '',
      userId: json['id']?.toString() ?? json['_id']?.toString(),
      nombres: json['nombres'] as String?,
      apellidoP: json['apellidoP'] as String?,
      apellidoM: json['apellidoM'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'token': token,
      if (userId != null) 'id': userId,
      if (nombres != null) 'nombres': nombres,
      if (apellidoP != null) 'apellidoP': apellidoP,
      if (apellidoM != null) 'apellidoM': apellidoM,
    };
  }

  @override
  String toString() =>
      'LoginResponse(email: $email, token: ${token.substring(0, 10)}...)';
}
