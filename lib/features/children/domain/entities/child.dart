import 'device.dart';
import '../../../tracking/domain/entities/child_current_location.dart';

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
  final int? age;
  final String grade;
  final ChildStatus status;
  final int? parentId;
  final int? schoolId;
  final List<Device>? devices; // Legacy: array de dispositivos
  final Device? device; // Nuevo: dispositivo CHILD singular
  final DeviceStatus? deviceStatus; // Nuevo: estado del dispositivo
  final int? minutesSinceLastSeen; // Nuevo: minutos desde última conexión
  final DateTime? createdAt;

  const Child({
    required this.id,
    required this.fullName,
    this.age,
    required this.grade,
    this.status = ChildStatus.active,
    this.parentId,
    this.schoolId,
    this.devices,
    this.device,
    this.deviceStatus,
    this.minutesSinceLastSeen,
    this.createdAt,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    // Parsear deviceStatus si existe
    DeviceStatus? deviceStatusEnum;
    final deviceStatusStr = json['deviceStatus'] as String?;
    if (deviceStatusStr != null) {
      switch (deviceStatusStr) {
        case 'online':
          deviceStatusEnum = DeviceStatus.online;
          break;
        case 'recent':
          deviceStatusEnum = DeviceStatus.recent;
          break;
        case 'no_signal':
          deviceStatusEnum = DeviceStatus.noSignal;
          break;
        case 'no_device':
        default:
          deviceStatusEnum = DeviceStatus.noDevice;
          break;
      }
    }

    return Child(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      age: json['age'] as int?,
      grade: json['grade'] as String? ?? '',
      status: ChildStatus.fromString(json['status'] as String? ?? 'ACTIVE'),
      parentId: json['parentId'] as int?,
      schoolId: json['schoolId'] as int?,
      // Soportar legacy 'devices' array
      devices: json['devices'] != null
          ? (json['devices'] as List)
                .map((d) => Device.fromJson(d as Map<String, dynamic>))
                .toList()
          : null,
      // Nuevo: 'device' singular
      device: json['device'] != null
          ? Device.fromJson(json['device'] as Map<String, dynamic>)
          : null,
      deviceStatus: deviceStatusEnum,
      minutesSinceLastSeen: json['minutesSinceLastSeen'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      if (age != null) 'age': age,
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

  /// Obtiene solo los dispositivos del hijo (no los del padre) - Legacy
  List<Device> get childDevices =>
      devices?.where((d) => d.isChildDevice).toList() ?? [];

  /// Verifica si tiene dispositivo del hijo vinculado
  /// Usa el nuevo campo 'device' o fallback a 'devices' legacy
  bool get hasDevice {
    // Primero verificar deviceStatus si existe
    if (deviceStatus != null) {
      return deviceStatus != DeviceStatus.noDevice;
    }
    // Fallback: usar 'device' singular
    if (device != null) return true;
    // Fallback legacy: usar 'devices' array
    return childDevices.isNotEmpty;
  }

  /// Obtiene el dispositivo principal del hijo
  /// Usa el nuevo campo 'device' o fallback a 'devices' legacy
  Device? get primaryDevice {
    if (device != null) return device;
    return childDevices.isNotEmpty ? childDevices.first : null;
  }

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
    Device? device,
    DeviceStatus? deviceStatus,
    int? minutesSinceLastSeen,
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
      device: device ?? this.device,
      deviceStatus: deviceStatus ?? this.deviceStatus,
      minutesSinceLastSeen: minutesSinceLastSeen ?? this.minutesSinceLastSeen,
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
