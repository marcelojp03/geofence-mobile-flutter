import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:battery_plus/battery_plus.dart';
import 'dart:developer' as developer;
import '../../../core/services/location_service.dart';
import '../../../core/services/device_service.dart';
import '../../tracking/data/tracking_repository.dart';
import '../../devices/data/devices_repository.dart';
import '../data/child_mode_storage.dart';
import '../background/background_tracking_service.dart';

/// Estado del tracker
class TrackerState {
  final bool isRunning;
  final bool isConfigured;
  final DateTime? lastSentAt;
  final String? lastError;
  final double? lastLat;
  final double? lastLng;
  final int? lastBattery;
  final int sendCount;
  final String? childName;

  const TrackerState({
    this.isRunning = false,
    this.isConfigured = false,
    this.lastSentAt,
    this.lastError,
    this.lastLat,
    this.lastLng,
    this.lastBattery,
    this.sendCount = 0,
    this.childName,
  });

  TrackerState copyWith({
    bool? isRunning,
    bool? isConfigured,
    DateTime? lastSentAt,
    String? lastError,
    double? lastLat,
    double? lastLng,
    int? lastBattery,
    int? sendCount,
    String? childName,
  }) {
    return TrackerState(
      isRunning: isRunning ?? this.isRunning,
      isConfigured: isConfigured ?? this.isConfigured,
      lastSentAt: lastSentAt ?? this.lastSentAt,
      lastError: lastError,
      lastLat: lastLat ?? this.lastLat,
      lastLng: lastLng ?? this.lastLng,
      lastBattery: lastBattery ?? this.lastBattery,
      sendCount: sendCount ?? this.sendCount,
      childName: childName ?? this.childName,
    );
  }

  static const initial = TrackerState();
}

/// Notifier para controlar el tracking
class TrackerNotifier extends StateNotifier<TrackerState> {
  final LocationService _locationService;
  final TrackingRepository _trackingRepository;
  final DevicesRepository _devicesRepository;
  final DeviceService _deviceService;
  final ChildModeStorage _storage;
  final Battery _battery = Battery();

  Timer? _timer;
  String? _deviceUid;
  int? _childId;

  TrackerNotifier(
    this._locationService,
    this._trackingRepository,
    this._devicesRepository,
    this._deviceService,
    this._storage,
  ) : super(TrackerState.initial) {
    _loadConfig();
  }

  /// Carga la configuración guardada
  Future<void> _loadConfig() async {
    final isConfigured = await _storage.isConfigured();
    final childName = await _storage.getChildName();
    final lastSent = await _storage.getLastSent();

    if (isConfigured) {
      _childId = await _storage.getChildId();
      _deviceUid = await _storage.getDeviceUid();
    }

    state = state.copyWith(
      isConfigured: isConfigured,
      childName: childName,
      lastSentAt: lastSent,
    );
  }

  /// Configura el modo hijo con un childId (desde QR)
  /// Flujo: 1) Registrar dispositivo, 2) Vincular al hijo, 3) Guardar config local
  Future<bool> configure({
    required int childId,
    required String childName,
    int? schoolId,
  }) async {
    try {
      // 1. Obtener datos del dispositivo (incluye FCM token)
      final deviceData = await _deviceService.getDeviceData();
      _deviceUid = deviceData.deviceUid;
      _childId = childId;

      developer.log(
        'Configuring device: ${deviceData.deviceUid}',
        name: 'TrackerNotifier',
      );

      // 2. Registrar dispositivo en el backend (POST /devices)
      final registerResponse = await _devicesRepository.registerDevice(
        deviceUid: deviceData.deviceUid,
        name: deviceData.name,
        model: deviceData.model,
        manufacturer: deviceData.manufacturer,
        osVersion: deviceData.osVersion,
        platform: deviceData.platform,
        fcmToken: deviceData.fcmToken,
      );

      if (!registerResponse.success) {
        // Si el dispositivo ya existe (409), continuar con el link
        developer.log(
          'Device register response: ${registerResponse.message}',
          name: 'TrackerNotifier',
        );
      }

      // 3. Vincular dispositivo al hijo (POST /devices/link)
      final linkResponse = await _devicesRepository.linkDeviceToChild(
        deviceUid: deviceData.deviceUid,
        childId: childId,
      );

      if (!linkResponse.success) {
        state = state.copyWith(lastError: linkResponse.message);
        developer.log(
          'Error linking device: ${linkResponse.message}',
          name: 'TrackerNotifier',
        );
        return false;
      }

      // 4. Guardar configuración local
      await _storage.saveConfig(
        childId: childId,
        deviceUid: deviceData.deviceUid,
        childName: childName,
        schoolId: schoolId,
      );

      state = state.copyWith(
        isConfigured: true,
        childName: childName,
        lastError: null,
      );

      developer.log(
        'Child mode configured: childId=$childId, deviceUid=$_deviceUid',
        name: 'TrackerNotifier',
      );

      return true;
    } catch (e) {
      developer.log('Error configuring: $e', name: 'TrackerNotifier');
      state = state.copyWith(lastError: 'Error al configurar: $e');
      return false;
    }
  }

  /// Inicia el tracking
  Future<void> startTracking({
    Duration interval = const Duration(seconds: 30),
  }) async {
    if (state.isRunning) return;

    // Verificar configuración
    if (!state.isConfigured || _childId == null || _deviceUid == null) {
      state = state.copyWith(
        lastError: 'Dispositivo no configurado. Configura primero.',
      );
      return;
    }

    // Verificar permisos
    final hasPermission = await _locationService.checkAndRequestPermission();
    if (!hasPermission) {
      state = state.copyWith(lastError: 'Sin permisos de ubicación');
      return;
    }

    state = state.copyWith(isRunning: true, lastError: null);

    developer.log(
      'Starting tracking every ${interval.inSeconds}s',
      name: 'TrackerNotifier',
    );

    // Iniciar background tracking con WorkManager
    await BackgroundTrackingService().startBackgroundTracking();

    // Enviar posición inicial
    await _sendPosition();

    // Iniciar timer para foreground
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _sendPosition());
  }

  /// Detiene el tracking
  Future<void> stopTracking() async {
    _timer?.cancel();
    _timer = null;

    // Detener background tracking
    await BackgroundTrackingService().stopBackgroundTracking();

    state = state.copyWith(isRunning: false);
    developer.log('Tracking stopped', name: 'TrackerNotifier');
  }

  /// Envía la posición actual
  Future<void> _sendPosition() async {
    if (_deviceUid == null) return;

    try {
      // Obtener posición
      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // Obtener batería
      final batteryLevel = await _battery.batteryLevel;

      // Enviar al servidor
      final response = await _trackingRepository.sendPosition(
        deviceUid: _deviceUid!,
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
        heading: position.heading,
        altitude: position.altitude,
        batteryLevel: batteryLevel,
      );

      final now = DateTime.now();
      await _storage.setLastSent(now);

      if (response.success) {
        state = state.copyWith(
          lastSentAt: now,
          lastLat: position.latitude,
          lastLng: position.longitude,
          lastBattery: batteryLevel,
          sendCount: state.sendCount + 1,
          lastError: null,
        );

        developer.log(
          'Position sent: ${position.latitude}, ${position.longitude}',
          name: 'TrackerNotifier',
        );
      } else {
        state = state.copyWith(lastError: response.message, lastSentAt: now);
      }
    } catch (e) {
      developer.log('Error sending position: $e', name: 'TrackerNotifier');
      state = state.copyWith(lastError: 'Error: ${e.toString()}');
    }
  }

  /// Envía una posición manualmente
  Future<void> sendNow() async {
    await _sendPosition();
  }

  /// Limpia la configuración
  Future<void> clearConfig() async {
    await stopTracking();
    await _storage.clear();
    _childId = null;
    _deviceUid = null;
    state = TrackerState.initial;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Providers
final childModeStorageProvider = Provider<ChildModeStorage>((ref) {
  return ChildModeStorage();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final deviceServiceProvider = Provider<DeviceService>((ref) {
  return DeviceService();
});

final devicesRepositoryProvider = Provider<DevicesRepository>((ref) {
  return DevicesRepository();
});

final trackerNotifierProvider =
    StateNotifierProvider<TrackerNotifier, TrackerState>((ref) {
      final locationService = ref.read(locationServiceProvider);
      final trackingRepo = ref.read(trackingRepositoryProvider);
      final devicesRepo = ref.read(devicesRepositoryProvider);
      final deviceService = ref.read(deviceServiceProvider);
      final storage = ref.read(childModeStorageProvider);

      return TrackerNotifier(
        locationService,
        trackingRepo,
        devicesRepo,
        deviceService,
        storage,
      );
    });

// Re-export del tracking repository provider
final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepository();
});
