/// Entidad de Posición GPS
class Position {
  final int id;
  final int childId;
  final double lat;
  final double lng;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final double? altitude;
  final int? batteryLevel;
  final DateTime createdAt;

  const Position({
    required this.id,
    required this.childId,
    required this.lat,
    required this.lng,
    this.accuracy,
    this.speed,
    this.heading,
    this.altitude,
    this.batteryLevel,
    required this.createdAt,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'] as int,
      childId: json['childId'] as int,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      batteryLevel: json['batteryLevel'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'lat': lat,
      'lng': lng,
      if (accuracy != null) 'accuracy': accuracy,
      if (speed != null) 'speed': speed,
      if (heading != null) 'heading': heading,
      if (altitude != null) 'altitude': altitude,
      if (batteryLevel != null) 'batteryLevel': batteryLevel,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Tiempo desde la última actualización
  Duration get timeSinceUpdate => DateTime.now().difference(createdAt);

  /// Formatea el tiempo desde la última actualización
  String get timeAgo {
    final diff = timeSinceUpdate;
    if (diff.inSeconds < 60) return 'Hace ${diff.inSeconds}s';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }

  /// Verifica si la posición es reciente (menos de 5 minutos)
  bool get isRecent => timeSinceUpdate.inMinutes < 5;

  /// Formatea la velocidad en km/h
  String get speedKmh {
    if (speed == null) return 'N/A';
    final kmh = speed! * 3.6; // m/s a km/h
    return '${kmh.toStringAsFixed(1)} km/h';
  }

  @override
  String toString() => 'Position(lat: $lat, lng: $lng, time: $timeAgo)';
}

/// Respuesta del envío de posición
class PositionResponse {
  final Position position;
  final bool isWithinArea;
  final bool alertCreated;

  const PositionResponse({
    required this.position,
    required this.isWithinArea,
    required this.alertCreated,
  });

  factory PositionResponse.fromJson(Map<String, dynamic> json) {
    return PositionResponse(
      position: Position.fromJson(json['position'] as Map<String, dynamic>),
      isWithinArea: json['isWithinArea'] as bool? ?? true,
      alertCreated: json['alertCreated'] as bool? ?? false,
    );
  }
}
