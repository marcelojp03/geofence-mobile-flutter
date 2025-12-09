/// Tipo de propietario del dispositivo
enum DeviceOwnerType {
  child('CHILD'),
  parent('PARENT');

  final String value;
  const DeviceOwnerType(this.value);

  static DeviceOwnerType fromString(String? value) {
    if (value == null) return DeviceOwnerType.child;
    return DeviceOwnerType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => DeviceOwnerType.child,
    );
  }
}

/// Entidad de Dispositivo
class Device {
  final int id;
  final String deviceUid;
  final String? name;
  final String? model;
  final String? manufacturer;
  final String? osVersion;
  final String? platform;
  final String? fcmToken;
  final int? lastBatteryLevel;
  final DateTime? lastSeen;
  final int? childId;
  final String status;
  final DeviceOwnerType ownerType;

  const Device({
    required this.id,
    required this.deviceUid,
    this.name,
    this.model,
    this.manufacturer,
    this.osVersion,
    this.platform,
    this.fcmToken,
    this.lastBatteryLevel,
    this.lastSeen,
    this.childId,
    this.status = 'ACTIVE',
    this.ownerType = DeviceOwnerType.child,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as int,
      deviceUid: json['deviceUid'] as String? ?? '',
      name: json['name'] as String?,
      model: json['model'] as String?,
      manufacturer: json['manufacturer'] as String?,
      osVersion: json['osVersion'] as String?,
      platform: json['platform'] as String?,
      fcmToken: json['fcmToken'] as String?,
      lastBatteryLevel: json['lastBatteryLevel'] as int?,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
      childId: json['childId'] as int?,
      status: json['status'] as String? ?? 'ACTIVE',
      ownerType: DeviceOwnerType.fromString(json['ownerType'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceUid': deviceUid,
      'name': name,
      if (model != null) 'model': model,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (osVersion != null) 'osVersion': osVersion,
      if (platform != null) 'platform': platform,
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (lastBatteryLevel != null) 'lastBatteryLevel': lastBatteryLevel,
      if (lastSeen != null) 'lastSeen': lastSeen!.toIso8601String(),
      if (childId != null) 'childId': childId,
      'status': status,
    };
  }

  /// Verifica si el dispositivo está vinculado a un hijo
  bool get isLinked => childId != null;

  /// Verifica si es un dispositivo del hijo (no del padre)
  bool get isChildDevice => ownerType == DeviceOwnerType.child;

  /// Verifica si es un dispositivo del padre
  bool get isParentDevice => ownerType == DeviceOwnerType.parent;

  /// Formatea el nivel de batería
  String get batteryDisplay =>
      lastBatteryLevel != null ? '$lastBatteryLevel%' : 'N/A';

  /// Nombre para mostrar
  String get displayName => name ?? 'Dispositivo $id';

  @override
  String toString() => 'Device(id: $id, name: $name, model: $model)';
}
