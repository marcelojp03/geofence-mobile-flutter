import 'package:latlong2/latlong.dart';

/// Entidad de Colegio/Escuela
class School {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String status;
  final SchoolGeofence? geofence;

  const School({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.status = 'ACTIVE',
    this.geofence,
  });

  /// Indica si el colegio tiene un geofence definido
  bool get hasGeofence => geofence != null && geofence!.coordinates.isNotEmpty;

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      geofence: json['geofence'] != null
          ? SchoolGeofence.fromGeoJson(json['geofence'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      'status': status,
      if (geofence != null) 'geofence': geofence!.toGeoJson(),
    };
  }

  @override
  String toString() =>
      'School(id: $id, name: $name, hasGeofence: $hasGeofence)';
}

/// Representa el geofence de un colegio (polígono GeoJSON)
class SchoolGeofence {
  final String type;
  final List<LatLng> coordinates;

  const SchoolGeofence({this.type = 'Polygon', required this.coordinates});

  /// Crea un SchoolGeofence desde un GeoJSON
  factory SchoolGeofence.fromGeoJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'Polygon';
    final List<LatLng> coords = [];

    if (json['coordinates'] != null) {
      // GeoJSON Polygon tiene estructura: [[[lng, lat], [lng, lat], ...]]
      final coordsList = json['coordinates'] as List;
      if (coordsList.isNotEmpty) {
        final ring = coordsList[0] as List; // Primer anillo (exterior)
        for (final point in ring) {
          if (point is List && point.length >= 2) {
            // GeoJSON usa [lng, lat], LatLng usa (lat, lng)
            final lng = (point[0] as num).toDouble();
            final lat = (point[1] as num).toDouble();
            coords.add(LatLng(lat, lng));
          }
        }
      }
    }

    return SchoolGeofence(type: type, coordinates: coords);
  }

  /// Convierte a formato GeoJSON
  Map<String, dynamic> toGeoJson() {
    return {
      'type': type,
      'coordinates': [
        coordinates.map((c) => [c.longitude, c.latitude]).toList(),
      ],
    };
  }

  /// Calcula el centro del polígono (centroid aproximado)
  LatLng get center {
    if (coordinates.isEmpty) {
      return const LatLng(-17.7833, -63.1821); // Santa Cruz por defecto
    }

    double sumLat = 0, sumLng = 0;
    for (final coord in coordinates) {
      sumLat += coord.latitude;
      sumLng += coord.longitude;
    }

    return LatLng(sumLat / coordinates.length, sumLng / coordinates.length);
  }

  @override
  String toString() =>
      'SchoolGeofence(type: $type, points: ${coordinates.length})';
}
