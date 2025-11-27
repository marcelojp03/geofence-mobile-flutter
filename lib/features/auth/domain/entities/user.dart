/// Entidad de Usuario
/// Representa al usuario autenticado en la aplicación
class User {
  final String id;
  final String email;
  final String? nombres;
  final String? apellidoP;
  final String? apellidoM;
  final String token;

  const User({
    required this.id,
    required this.email,
    this.nombres,
    this.apellidoP,
    this.apellidoM,
    required this.token,
  });

  /// Nombre completo del usuario
  String get fullName {
    final parts = [
      nombres,
      apellidoP,
      apellidoM,
    ].where((s) => s != null && s.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(' ') : email;
  }

  /// Iniciales para avatar
  String get initials {
    if (nombres != null && nombres!.isNotEmpty) {
      final first = nombres![0].toUpperCase();
      if (apellidoP != null && apellidoP!.isNotEmpty) {
        return '$first${apellidoP![0].toUpperCase()}';
      }
      return first;
    }
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      nombres: json['nombres'] as String?,
      apellidoP: json['apellidoP'] as String?,
      apellidoM: json['apellidoM'] as String?,
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombres': nombres,
      'apellidoP': apellidoP,
      'apellidoM': apellidoM,
      'token': token,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? nombres,
    String? apellidoP,
    String? apellidoM,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nombres: nombres ?? this.nombres,
      apellidoP: apellidoP ?? this.apellidoP,
      apellidoM: apellidoM ?? this.apellidoM,
      token: token ?? this.token,
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email, fullName: $fullName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
