/// Estado del dispositivo del hijo
enum DeviceStatus {
  noDevice, // Sin dispositivo vinculado
  online, // En línea (lastSeen ≤ 5 min)
  recent, // Hace poco (lastSeen 5-30 min)
  noSignal, // Sin señal (lastSeen > 30 min)
}

/// Estado de ubicación del hijo
enum LocationStatus {
  inside, // Dentro del geofence
  outside, // Fuera del geofence
  unknown, // Sin datos (no_device o no_signal)
}

/// Estado de ubicación actual de un hijo (LEGACY - mantener compatibilidad)
enum ChildLocationStatus {
  inside, // Dentro del geofence
  outside, // Fuera del geofence
  noSignal, // Sin señal (sin posición o muy antigua)
}

class ChildCurrentLocation {
  final int childId;
  final String fullName;
  final String? grade;
  final double? lat;
  final double? lng;
  final double? accuracy;
  final int? batteryLevel;
  final DateTime? createdAt;
  final bool? isInsideGeofence;
  final bool hasSignal;
  final ChildLocationStatus status;
  final int? minutesSinceUpdate;

  // Nuevos campos del backend
  final DeviceStatus deviceStatus;
  final LocationStatus locationStatus;
  final int? minutesSinceDeviceSeen;

  const ChildCurrentLocation({
    required this.childId,
    required this.fullName,
    this.grade,
    this.lat,
    this.lng,
    this.accuracy,
    this.batteryLevel,
    this.createdAt,
    this.isInsideGeofence,
    required this.hasSignal,
    required this.status,
    this.minutesSinceUpdate,
    this.deviceStatus = DeviceStatus.noDevice,
    this.locationStatus = LocationStatus.unknown,
    this.minutesSinceDeviceSeen,
  });

  factory ChildCurrentLocation.fromJson(Map<String, dynamic> json) {
    // Parsear deviceStatus (nuevo)
    DeviceStatus deviceStatusEnum;
    final deviceStatusStr = json['deviceStatus'] as String?;
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

    // Parsear locationStatus (nuevo)
    LocationStatus locationStatusEnum;
    final locationStatusStr = json['locationStatus'] as String?;
    switch (locationStatusStr) {
      case 'inside':
        locationStatusEnum = LocationStatus.inside;
        break;
      case 'outside':
        locationStatusEnum = LocationStatus.outside;
        break;
      case 'unknown':
      default:
        locationStatusEnum = LocationStatus.unknown;
        break;
    }

    // Parsear status string a enum (legacy) - derivar de los nuevos campos si no existe
    ChildLocationStatus statusEnum;
    final statusStr = json['status'] as String?;
    if (statusStr != null) {
      // Si el backend envía el campo legacy, usarlo
      switch (statusStr) {
        case 'inside':
          statusEnum = ChildLocationStatus.inside;
          break;
        case 'outside':
          statusEnum = ChildLocationStatus.outside;
          break;
        case 'no_signal':
        default:
          statusEnum = ChildLocationStatus.noSignal;
          break;
      }
    } else {
      // Derivar desde deviceStatus y locationStatus
      if (deviceStatusEnum == DeviceStatus.noDevice ||
          deviceStatusEnum == DeviceStatus.noSignal) {
        statusEnum = ChildLocationStatus.noSignal;
      } else {
        // Tiene señal (online o recent), usar locationStatus
        switch (locationStatusEnum) {
          case LocationStatus.inside:
            statusEnum = ChildLocationStatus.inside;
            break;
          case LocationStatus.outside:
            statusEnum = ChildLocationStatus.outside;
            break;
          case LocationStatus.unknown:
            statusEnum = ChildLocationStatus.noSignal;
            break;
        }
      }
    }

    return ChildCurrentLocation(
      childId: json['childId'] as int,
      fullName: json['fullName'] as String,
      grade: json['grade'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      batteryLevel: json['batteryLevel'] as int?,
      // Soportar tanto el nuevo 'lastPositionAt' como el legacy 'createdAt'
      createdAt: (json['lastPositionAt'] ?? json['createdAt']) != null
          ? DateTime.parse(
              (json['lastPositionAt'] ?? json['createdAt']) as String,
            )
          : null,
      isInsideGeofence: json['isInsideGeofence'] as bool?,
      // hasSignal ahora se calcula desde deviceStatus
      hasSignal:
          deviceStatusEnum != DeviceStatus.noDevice &&
          deviceStatusEnum != DeviceStatus.noSignal,
      status: statusEnum,
      minutesSinceUpdate: json['minutesSinceUpdate'] as int?,
      deviceStatus: deviceStatusEnum,
      locationStatus: locationStatusEnum,
      minutesSinceDeviceSeen: json['minutesSinceDeviceSeen'] as int?,
    );
  }

  /// Tiene ubicación válida
  bool get hasLocation => lat != null && lng != null;

  /// Tiempo desde la última actualización
  Duration? get timeSinceUpdate {
    if (createdAt == null) return null;
    return DateTime.now().difference(createdAt!);
  }

  /// Formatea el tiempo desde la última actualización
  String get timeAgo {
    if (minutesSinceUpdate == null) return 'Sin datos';
    if (minutesSinceUpdate! < 1) return 'Ahora';
    if (minutesSinceUpdate! < 60) return 'Hace ${minutesSinceUpdate}min';
    final hours = minutesSinceUpdate! ~/ 60;
    if (hours < 24) return 'Hace ${hours}h';
    final days = hours ~/ 24;
    return 'Hace ${days}d';
  }

  /// Verifica si la posición es reciente (menos de 5 minutos)
  bool get isRecent => minutesSinceUpdate != null && minutesSinceUpdate! < 5;

  /// Verifica si tiene dispositivo vinculado
  bool get hasDevice => deviceStatus != DeviceStatus.noDevice;

  /// Verifica si está en línea
  bool get isOnline => deviceStatus == DeviceStatus.online;

  /// Color del estado para UI (legacy)
  String get statusLabel {
    switch (status) {
      case ChildLocationStatus.inside:
        return 'En el colegio';
      case ChildLocationStatus.outside:
        return 'Fuera del colegio';
      case ChildLocationStatus.noSignal:
        return 'Sin señal';
    }
  }

  /// Label del estado del dispositivo (nuevo)
  String get deviceStatusLabel {
    switch (deviceStatus) {
      case DeviceStatus.noDevice:
        return 'Sin dispositivo';
      case DeviceStatus.online:
        return 'En línea';
      case DeviceStatus.recent:
        if (minutesSinceDeviceSeen != null) {
          return 'Hace ${minutesSinceDeviceSeen}min';
        }
        return 'Hace poco';
      case DeviceStatus.noSignal:
        return 'Sin señal';
    }
  }

  /// Label del estado de ubicación (nuevo)
  String get locationStatusLabel {
    switch (locationStatus) {
      case LocationStatus.inside:
        return 'En el colegio';
      case LocationStatus.outside:
        return 'Fuera del colegio';
      case LocationStatus.unknown:
        return 'Ubicación desconocida';
    }
  }

  @override
  String toString() =>
      'ChildCurrentLocation(childId: $childId, fullName: $fullName, status: $status, hasSignal: $hasSignal)';
}
