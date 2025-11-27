import 'school.dart';

/// Rol del usuario en el sistema
enum UserRole {
  schoolAdmin('SCHOOL_ADMIN'),
  parent('PARENT');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.parent,
    );
  }
}

/// Entidad de Usuario
/// Representa al usuario autenticado en la aplicación
class User {
  final int id;
  final String email;
  final String fullName;
  final String? phone;
  final UserRole role;
  final int schoolId;
  final School? school;
  final String status;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    required this.schoolId,
    this.school,
    this.status = 'ACTIVE',
  });

  /// Iniciales para avatar
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  /// Verifica si es administrador del colegio
  bool get isAdmin => role == UserRole.schoolAdmin;

  /// Verifica si es padre
  bool get isParent => role == UserRole.parent;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'PARENT'),
      schoolId: json['schoolId'] as int,
      school: json['school'] != null
          ? School.fromJson(json['school'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      if (phone != null) 'phone': phone,
      'role': role.value,
      'schoolId': schoolId,
      if (school != null) 'school': school!.toJson(),
      'status': status,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? fullName,
    String? phone,
    UserRole? role,
    int? schoolId,
    School? school,
    String? status,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      schoolId: schoolId ?? this.schoolId,
      school: school ?? this.school,
      status: status ?? this.status,
    );
  }

  @override
  String toString() =>
      'User(id: $id, email: $email, fullName: $fullName, role: ${role.value})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
