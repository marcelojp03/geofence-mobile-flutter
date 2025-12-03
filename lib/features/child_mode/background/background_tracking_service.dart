import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Nombre de la tarea de tracking en background
const String childTrackingTaskName = 'child_tracking_task';
const String childTrackingTaskId = 'child_tracking_unique';

/// Callback dispatcher para WorkManager - debe ser top-level function
@pragma('vm:entry-point')
void childTrackingCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('🔄 [Background] Ejecutando tarea: $task');

    try {
      // 1. Leer configuración del storage
      final prefs = await SharedPreferences.getInstance();
      final int? childId = prefs.getInt('child_mode_child_id');
      final String? deviceUid = prefs.getString('child_mode_device_uid');
      final String? token = prefs.getString('auth_token');

      if (childId == null || deviceUid == null) {
        debugPrint('⚠️ [Background] No hay configuración de modo hijo');
        return Future.value(true);
      }

      // 2. Verificar permisos de ubicación
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('⚠️ [Background] Sin permisos de ubicación');
        return Future.value(true);
      }

      // 3. Obtener ubicación actual
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );

      // 4. Obtener nivel de batería
      final battery = Battery();
      final batteryLevel = await battery.batteryLevel;

      // 5. Leer la URL base del API desde SharedPreferences
      // (guardada durante init de la app)
      final baseUrl =
          prefs.getString('api_base_url') ??
          'https://i8s2qej2p3.us-east-1.awsapprunner.com/api';

      // 6. Crear cliente HTTP
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      // 7. Enviar posición al backend
      final response = await dio.post(
        '/tracking/positions',
        data: {
          'childId': childId,
          'lat': position.latitude,
          'lng': position.longitude,
          'batteryLevel': batteryLevel,
          'deviceIdentifier': deviceUid,
          'source': 'background',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('✅ [Background] Posición enviada: ${response.statusCode}');
      debugPrint('   Lat: ${position.latitude}, Lng: ${position.longitude}');

      // 8. Guardar timestamp de último envío
      await prefs.setString(
        'child_mode_last_sent',
        DateTime.now().toIso8601String(),
      );

      return Future.value(true);
    } catch (e) {
      debugPrint('❌ [Background] Error: $e');
      // Retornar true para que WorkManager no marque como falla permanente
      return Future.value(true);
    }
  });
}

/// Servicio para manejar el tracking en background
class BackgroundTrackingService {
  static final BackgroundTrackingService _instance =
      BackgroundTrackingService._internal();
  factory BackgroundTrackingService() => _instance;
  BackgroundTrackingService._internal();

  bool _isInitialized = false;

  /// Inicializar WorkManager
  Future<void> init() async {
    if (_isInitialized) return;

    await Workmanager().initialize(childTrackingCallbackDispatcher);

    _isInitialized = true;
    debugPrint('✅ [Background] WorkManager inicializado');
  }

  /// Registrar tarea periódica de tracking
  Future<void> startBackgroundTracking({
    Duration frequency = const Duration(minutes: 15),
  }) async {
    if (!_isInitialized) await init();

    // Guardar la URL del API para que el worker la pueda leer
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'api_base_url',
      'https://i8s2qej2p3.us-east-1.awsapprunner.com/api',
    );

    await Workmanager().registerPeriodicTask(
      childTrackingTaskId,
      childTrackingTaskName,
      frequency: frequency,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 5),
    );

    debugPrint(
      '✅ [Background] Tarea periódica registrada (cada ${frequency.inMinutes} min)',
    );
  }

  /// Cancelar tarea de tracking
  Future<void> stopBackgroundTracking() async {
    await Workmanager().cancelByUniqueName(childTrackingTaskId);
    debugPrint('🛑 [Background] Tarea de tracking cancelada');
  }

  /// Ejecutar una tarea inmediata (para testing)
  Future<void> runOnce() async {
    if (!_isInitialized) await init();

    await Workmanager().registerOneOffTask(
      'child_tracking_once',
      childTrackingTaskName,
      constraints: Constraints(networkType: NetworkType.connected),
    );

    debugPrint('🚀 [Background] Tarea única registrada');
  }
}
