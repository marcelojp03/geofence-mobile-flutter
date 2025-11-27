/// Entidad de Dispositivo
class Device {
  final int id;
  final String deviceUid;
  final String name;
  final String? model;
  final String? manufacturer;
  final String? osVersion;
  final String? platform;
  final String? fcmToken;
  final int? lastBatteryLevel;
  final DateTime? lastSeen;
  final int? childId;
  final String status;

  const Device({
    required this.id,
    required this.deviceUid,
    required this.name,
    this.model,
    this.manufacturer,
    this.osVersion,
    this.platform,
    this.fcmToken,
    this.lastBatteryLevel,
    this.lastSeen,
    this.childId,
    this.status = 'ACTIVE',
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as int,
      deviceUid: json['deviceUid'] as String? ?? '',
      name: json['name'] as String,
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

  /// Formatea el nivel de batería
  String get batteryDisplay =>
      lastBatteryLevel != null ? '$lastBatteryLevel%' : 'N/A';

  @override
  String toString() => 'Device(id: $id, name: $name, model: $model)';
}
