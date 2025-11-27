import 'device.dart';

/// Estado del hijo
enum ChildStatus {
  active('ACTIVE'),
  inactive('INACTIVE');

  final String value;
  const ChildStatus(this.value);

  static ChildStatus fromString(String value) {
    return ChildStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ChildStatus.active,
    );
  }
}

/// Entidad de Hijo/Estudiante
class Child {
  final int id;
  final String fullName;
  final int age;
  final String grade;
  final ChildStatus status;
  final int? parentId;
  final int? schoolId;
  final List<Device>? devices;
  final DateTime? createdAt;

  const Child({
    required this.id,
    required this.fullName,
    required this.age,
    required this.grade,
    this.status = ChildStatus.active,
    this.parentId,
    this.schoolId,
    this.devices,
    this.createdAt,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      age: json['age'] as int,
      grade: json['grade'] as String,
      status: ChildStatus.fromString(json['status'] as String? ?? 'ACTIVE'),
      parentId: json['parentId'] as int?,
      schoolId: json['schoolId'] as int?,
      devices: json['devices'] != null
          ? (json['devices'] as List)
                .map((d) => Device.fromJson(d as Map<String, dynamic>))
                .toList()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'age': age,
      'grade': grade,
      'status': status.value,
      if (parentId != null) 'parentId': parentId,
      if (schoolId != null) 'schoolId': schoolId,
      if (devices != null) 'devices': devices!.map((d) => d.toJson()).toList(),
    };
  }

  /// Iniciales para avatar
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  /// Verifica si tiene dispositivo vinculado
  bool get hasDevice => devices != null && devices!.isNotEmpty;

  /// Obtiene el dispositivo principal (primero de la lista)
  Device? get primaryDevice => hasDevice ? devices!.first : null;

  /// Nivel de batería del dispositivo principal
  int? get batteryLevel => primaryDevice?.lastBatteryLevel;

  Child copyWith({
    int? id,
    String? fullName,
    int? age,
    String? grade,
    ChildStatus? status,
    int? parentId,
    int? schoolId,
    List<Device>? devices,
  }) {
    return Child(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      grade: grade ?? this.grade,
      status: status ?? this.status,
      parentId: parentId ?? this.parentId,
      schoolId: schoolId ?? this.schoolId,
      devices: devices ?? this.devices,
    );
  }

  @override
  String toString() => 'Child(id: $id, fullName: $fullName, age: $age)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Child && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
