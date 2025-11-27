import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import '../../config/env.dart';

/// Datos del dispositivo para registro
class DeviceData {
  final String deviceUid;
  final String name;
  final String? model;
  final String? manufacturer;
  final String? osVersion;
  final String platform;
  final String? fcmToken;

  const DeviceData({
    required this.deviceUid,
    required this.name,
    this.model,
    this.manufacturer,
    this.osVersion,
    required this.platform,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceUid': deviceUid,
      'name': name,
      if (model != null) 'model': model,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (osVersion != null) 'osVersion': osVersion,
      'platform': platform,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }
}

/// Servicio para obtener información del dispositivo
class DeviceService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Obtiene los datos del dispositivo actual
  Future<DeviceData> getDeviceData() async {
    String deviceUid = '';
    String name = '';
    String? model;
    String? manufacturer;
    String? osVersion;
    String platform = '';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceUid = androidInfo.id;
        name = androidInfo.device;
        model = androidInfo.model;
        manufacturer = androidInfo.manufacturer;
        osVersion = 'Android ${androidInfo.version.release}';
        platform = 'android';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceUid = iosInfo.identifierForVendor ?? '';
        name = iosInfo.name;
        model = iosInfo.model;
        manufacturer = 'Apple';
        osVersion = 'iOS ${iosInfo.systemVersion}';
        platform = 'ios';
      }

      // Guardar deviceUid localmente
      await _saveDeviceUid(deviceUid);

      // Obtener FCM token
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        developer.log('Error getting FCM token: $e', name: 'DeviceService');
      }

      return DeviceData(
        deviceUid: deviceUid,
        name: name,
        model: model,
        manufacturer: manufacturer,
        osVersion: osVersion,
        platform: platform,
        fcmToken: fcmToken,
      );
    } catch (e) {
      developer.log('Error getting device info: $e', name: 'DeviceService');
      rethrow;
    }
  }

  /// Obtiene solo el deviceUid (para envío de posiciones)
  Future<String?> getDeviceUid() async {
    // Primero intentar obtener del storage
    final prefs = await SharedPreferences.getInstance();
    final savedUid = prefs.getString(Env.deviceUidKey);
    if (savedUid != null && savedUid.isNotEmpty) {
      return savedUid;
    }

    // Si no existe, obtener del dispositivo
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        final uid = androidInfo.id;
        await _saveDeviceUid(uid);
        return uid;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        final uid = iosInfo.identifierForVendor ?? '';
        await _saveDeviceUid(uid);
        return uid;
      }
    } catch (e) {
      developer.log('Error getting device UID: $e', name: 'DeviceService');
    }

    return null;
  }

  /// Guarda el deviceUid en SharedPreferences
  Future<void> _saveDeviceUid(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Env.deviceUidKey, uid);
  }

  /// Actualiza el FCM token
  Future<String?> refreshFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      developer.log('Error refreshing FCM token: $e', name: 'DeviceService');
      return null;
    }
  }
}
