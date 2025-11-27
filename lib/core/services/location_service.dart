import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:developer' as developer;
import '../../features/tracking/data/tracking_repository.dart';
import 'device_service.dart';

/// Servicio de ubicación para envío de posiciones GPS
class LocationService {
  final TrackingRepository _trackingRepo = TrackingRepository();
  final DeviceService _deviceService = DeviceService();
  final Battery _battery = Battery();

  /// Verifica y solicita permisos de ubicación
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      developer.log('Location services are disabled', name: 'LocationService');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        developer.log('Location permission denied', name: 'LocationService');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      developer.log(
        'Location permission permanently denied',
        name: 'LocationService',
      );
      return false;
    }

    return true;
  }

  /// Obtiene la posición actual del dispositivo
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      developer.log('Error getting position: $e', name: 'LocationService');
      return null;
    }
  }

  /// Obtiene el nivel de batería actual
  Future<int> getBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (e) {
      developer.log('Error getting battery: $e', name: 'LocationService');
      return -1;
    }
  }

  /// Envía la posición actual al servidor
  /// Retorna true si se envió exitosamente
  Future<bool> sendCurrentPosition() async {
    try {
      // Obtener deviceUid
      final deviceUid = await _deviceService.getDeviceUid();
      if (deviceUid == null || deviceUid.isEmpty) {
        developer.log('No deviceUid available', name: 'LocationService');
        return false;
      }

      // Obtener posición
      final position = await getCurrentPosition();
      if (position == null) {
        developer.log('Could not get position', name: 'LocationService');
        return false;
      }

      // Obtener batería
      final batteryLevel = await getBatteryLevel();

      // Enviar al servidor
      final response = await _trackingRepo.sendPosition(
        deviceUid: deviceUid,
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
        heading: position.heading,
        altitude: position.altitude,
        batteryLevel: batteryLevel >= 0 ? batteryLevel : null,
      );

      if (response.isSuccess) {
        developer.log(
          'Position sent: ${position.latitude}, ${position.longitude}',
          name: 'LocationService',
        );
        return true;
      } else {
        developer.log(
          'Failed to send position: ${response.message}',
          name: 'LocationService',
        );
        return false;
      }
    } catch (e) {
      developer.log('Error sending position: $e', name: 'LocationService');
      return false;
    }
  }

  /// Inicia el stream de posiciones
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }
}
