/// Estado de ubicación actual de un hijo
/// Incluye información enriquecida del backend (hasSignal, status, etc.)
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
  });

  factory ChildCurrentLocation.fromJson(Map<String, dynamic> json) {
    // Parsear status string a enum
    ChildLocationStatus statusEnum;
    final statusStr = json['status'] as String?;
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

    return ChildCurrentLocation(
      childId: json['childId'] as int,
      fullName: json['fullName'] as String,
      grade: json['grade'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      batteryLevel: json['batteryLevel'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      isInsideGeofence: json['isInsideGeofence'] as bool?,
      hasSignal: json['hasSignal'] as bool? ?? false,
      status: statusEnum,
      minutesSinceUpdate: json['minutesSinceUpdate'] as int?,
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

  /// Color del estado para UI
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

  @override
  String toString() =>
      'ChildCurrentLocation(childId: $childId, fullName: $fullName, status: $status, hasSignal: $hasSignal)';
}
