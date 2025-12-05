import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

/// Servicio de tracking en primer plano con notificación persistente
/// Más confiable que WorkManager para tracking continuo
class ForegroundTrackingService {
  static final ForegroundTrackingService _instance =
      ForegroundTrackingService._internal();
  factory ForegroundTrackingService() => _instance;
  ForegroundTrackingService._internal();

  final FlutterBackgroundService _service = FlutterBackgroundService();
  bool _isInitialized = false;
  bool _initFailed = false;

  /// Inicializar el servicio de background
  Future<void> init() async {
    if (_isInitialized || _initFailed) return;

    try {
      await _service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: _onStart,
          autoStart: false,
          autoStartOnBoot:
              false, // Solo iniciar cuando modo hijo está configurado
          isForegroundMode: true,
          notificationChannelId: 'geofence_tracking',
          initialNotificationTitle: 'Geofence Tracking',
          initialNotificationContent: 'Ubicación activa',
          foregroundServiceNotificationId: 888,
          foregroundServiceTypes: [AndroidForegroundType.location],
        ),
        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: _onStart,
          onBackground: _onIosBackground,
        ),
      );

      _isInitialized = true;
      debugPrint('✅ [ForegroundService] Inicializado');
    } catch (e) {
      _initFailed = true;
      debugPrint('⚠️ [ForegroundService] Error al inicializar: $e');
      debugPrint('   Usando solo WorkManager como fallback');
    }
  }

  /// Iniciar el servicio de tracking
  Future<void> startService() async {
    if (_initFailed) {
      debugPrint('⚠️ [ForegroundService] No disponible, usando WorkManager');
      return;
    }

    if (!_isInitialized) await init();
    if (_initFailed) return;

    try {
      final isRunning = await _service.isRunning();
      if (isRunning) {
        debugPrint('⚠️ [ForegroundService] Ya está corriendo');
        return;
      }

      await _service.startService();
      debugPrint('🚀 [ForegroundService] Servicio iniciado');
    } catch (e) {
      debugPrint('⚠️ [ForegroundService] Error al iniciar: $e');
    }
  }

  /// Detener el servicio
  Future<void> stopService() async {
    if (_initFailed || !_isInitialized) return;

    try {
      final isRunning = await _service.isRunning();
      if (!isRunning) return;

      _service.invoke('stopService');
      debugPrint('🛑 [ForegroundService] Servicio detenido');
    } catch (e) {
      debugPrint('⚠️ [ForegroundService] Error al detener: $e');
    }
  }

  /// Verificar si está corriendo
  Future<bool> isRunning() async {
    if (_initFailed || !_isInitialized) return false;
    try {
      return await _service.isRunning();
    } catch (e) {
      return false;
    }
  }

  /// Actualizar notificación
  void updateNotification(String title, String content) {
    if (_initFailed || !_isInitialized) return;
    try {
      _service.invoke('updateNotification', {
        'title': title,
        'content': content,
      });
    } catch (e) {
      debugPrint('⚠️ [ForegroundService] Error al actualizar notificación: $e');
    }
  }
}

/// Handler para iOS background
@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

/// Handler principal del servicio - DEBE ser top-level
@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  debugPrint('🔄 [ForegroundService] Servicio iniciado');

  // Verificar configuración ANTES de iniciar
  final prefs = await SharedPreferences.getInstance();
  final int? childId = prefs.getInt('child_mode_child_id');
  final String? deviceUid = prefs.getString('child_mode_device_uid');

  if (childId == null || deviceUid == null) {
    debugPrint(
      '⚠️ [ForegroundService] No hay configuración - deteniendo inmediatamente',
    );
    service.stopSelf();
    return;
  }

  debugPrint('✅ [ForegroundService] Config encontrada: childId=$childId');

  // Timer para enviar ubicación cada 30 segundos
  Timer? locationTimer;

  // Escuchar comandos
  service.on('stopService').listen((event) {
    locationTimer?.cancel();
    service.stopSelf();
    debugPrint('🛑 [ForegroundService] Servicio detenido por comando');
  });

  service.on('updateNotification').listen((event) {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: event?['title'] ?? 'Geofence Tracking',
        content: event?['content'] ?? 'Ubicación activa',
      );
    }
  });

  // Configurar como foreground con notificación
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  // Iniciar tracking
  locationTimer = Timer.periodic(
    const Duration(seconds: 30),
    (_) => _sendLocationUpdate(service),
  );

  // Enviar primera ubicación inmediatamente
  await _sendLocationUpdate(service);
}

/// Enviar actualización de ubicación al backend
Future<void> _sendLocationUpdate(ServiceInstance service) async {
  try {
    debugPrint('📍 [ForegroundService] Obteniendo ubicación...');

    // 1. Leer configuración
    final prefs = await SharedPreferences.getInstance();
    final int? childId = prefs.getInt('child_mode_child_id');
    final String? deviceUid = prefs.getString('child_mode_device_uid');

    if (childId == null || deviceUid == null) {
      debugPrint(
        '⚠️ [ForegroundService] No hay configuración de modo hijo - deteniendo servicio',
      );
      service.stopSelf();
      return;
    }

    // 2. Verificar permisos
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('⚠️ [ForegroundService] Sin permisos de ubicación');
      return;
    }

    // 3. Verificar que el servicio de ubicación esté habilitado
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('⚠️ [ForegroundService] Servicio de ubicación deshabilitado');
      return;
    }

    // 4. Obtener ubicación
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );

    // 5. Obtener batería
    final battery = Battery();
    final batteryLevel = await battery.batteryLevel;

    // 6. Enviar al backend
    final baseUrl =
        prefs.getString('api_base_url') ??
        'https://i8s2qej2p3.us-east-1.awsapprunner.com/api';

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final response = await dio.post(
      '/tracking/positions',
      data: {
        'deviceUid': deviceUid, // ← Campo correcto
        'lat': position.latitude,
        'lng': position.longitude,
        'accuracy': position.accuracy,
        'speed': position.speed,
        'heading': position.heading,
        'altitude': position.altitude,
        'batteryLevel': batteryLevel,
      },
    );

    debugPrint(
      '✅ [ForegroundService] Posición enviada: ${response.statusCode}',
    );
    debugPrint(
      '   Lat: ${position.latitude}, Lng: ${position.longitude}, Bat: $batteryLevel%',
    );

    // 7. Guardar timestamp
    await prefs.setString(
      'child_mode_last_sent',
      DateTime.now().toIso8601String(),
    );

    // 8. Actualizar notificación
    if (service is AndroidServiceInstance) {
      final now = DateTime.now();
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      service.setForegroundNotificationInfo(
        title: 'Geofence - Tracking activo',
        content: 'Última actualización: $timeStr • Batería: $batteryLevel%',
      );
    }
  } catch (e) {
    debugPrint('❌ [ForegroundService] Error: $e');

    // Actualizar notificación con error
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: 'Geofence - Tracking activo',
        content: 'Error al enviar ubicación. Reintentando...',
      );
    }
  }
}
