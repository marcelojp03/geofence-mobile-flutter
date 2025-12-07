import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geofence_mobile_flutter/core/services/notification_service.dart';
import 'package:geofence_mobile_flutter/core/services/device_service.dart';
import 'package:geofence_mobile_flutter/features/devices/data/devices_repository.dart';
import 'package:geofence_mobile_flutter/features/children/providers/children_provider.dart';
import 'package:flutter/foundation.dart';

/// Provider para obtener el FCM token
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  return await NotificationService().getToken();
});

/// Provider del repositorio de dispositivos
final devicesRepositoryProvider = Provider((ref) => DevicesRepository());

/// Provider del servicio de dispositivos
final deviceServiceProvider = Provider((ref) => DeviceService());

/// Notifier para manejar el registro del dispositivo del padre para FCM
class ParentDeviceNotifier extends StateNotifier<AsyncValue<bool>> {
  final Ref _ref;

  ParentDeviceNotifier(this._ref) : super(const AsyncValue.data(false));

  /// Registra el dispositivo del padre para recibir notificaciones de todos sus hijos
  Future<void> registerParentDeviceForAllChildren() async {
    state = const AsyncValue.loading();

    try {
      // 1. Obtener FCM token
      final fcmToken = await NotificationService().getToken();
      if (fcmToken == null) {
        debugPrint('❌ No se pudo obtener FCM token');
        state = const AsyncValue.data(false);
        return;
      }

      // 2. Obtener información del dispositivo
      final deviceService = _ref.read(deviceServiceProvider);
      final deviceData = await deviceService.getDeviceData();

      // 3. Obtener lista de hijos del padre
      final childrenAsync = await _ref.read(myChildrenProvider.future);

      if (childrenAsync.isEmpty) {
        debugPrint('ℹ️ El padre no tiene hijos registrados');
        state = const AsyncValue.data(true);
        return;
      }

      // 4. Registrar dispositivo del padre para cada hijo
      final devicesRepo = _ref.read(devicesRepositoryProvider);
      int successCount = 0;

      for (final child in childrenAsync) {
        final result = await devicesRepo.registerParentDevice(
          childId: child.id,
          deviceUid: deviceData.deviceUid,
          fcmToken: fcmToken,
          name: deviceData.name,
          model: deviceData.model,
          platform: Platform.isIOS ? 'ios' : 'android',
        );

        if (result.success) {
          successCount++;
          debugPrint(
            '✅ Dispositivo padre registrado para hijo ${child.fullName}',
          );
        } else {
          debugPrint(
            '⚠️ Error registrando para hijo ${child.fullName}: ${result.message}',
          );
        }
      }

      debugPrint(
        '📱 Dispositivos padre registrados: $successCount/${childrenAsync.length}',
      );
      state = AsyncValue.data(successCount > 0);

      // 5. Configurar listener para cuando cambie el token
      _setupTokenRefreshListener(deviceData.deviceUid);
    } catch (e, st) {
      debugPrint('❌ Error registrando dispositivo padre: $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// Configura listener para actualizar token cuando cambie
  void _setupTokenRefreshListener(String deviceUid) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('🔄 FCM token actualizado, sincronizando...');
      final devicesRepo = _ref.read(devicesRepositoryProvider);
      final result = await devicesRepo.updateFcmToken(
        deviceUid: deviceUid,
        fcmToken: newToken,
      );

      if (result.success) {
        debugPrint('✅ Token FCM actualizado en backend');
      } else {
        debugPrint('❌ Error actualizando token: ${result.message}');
      }
    });
  }

  /// Registra dispositivo del padre para un hijo específico (ej: al vincular nuevo hijo)
  Future<bool> registerForChild(int childId) async {
    try {
      final fcmToken = await NotificationService().getToken();
      if (fcmToken == null) return false;

      final deviceService = _ref.read(deviceServiceProvider);
      final deviceData = await deviceService.getDeviceData();

      final devicesRepo = _ref.read(devicesRepositoryProvider);
      final result = await devicesRepo.registerParentDevice(
        childId: childId,
        deviceUid: deviceData.deviceUid,
        fcmToken: fcmToken,
        name: deviceData.name,
        model: deviceData.model,
        platform: Platform.isIOS ? 'ios' : 'android',
      );

      return result.success;
    } catch (e) {
      debugPrint('❌ Error registrando para hijo $childId: $e');
      return false;
    }
  }
}

final parentDeviceNotifierProvider =
    StateNotifierProvider<ParentDeviceNotifier, AsyncValue<bool>>((ref) {
      return ParentDeviceNotifier(ref);
    });

/// Provider legacy (mantener por compatibilidad)
class FcmTokenNotifier extends StateNotifier<AsyncValue<bool>> {
  FcmTokenNotifier() : super(const AsyncValue.data(false));

  Future<void> registerToken() async {
    // Deprecated: usar parentDeviceNotifierProvider en su lugar
    debugPrint('⚠️ FcmTokenNotifier.registerToken() está deprecated');
  }
}

final fcmTokenNotifierProvider =
    StateNotifierProvider<FcmTokenNotifier, AsyncValue<bool>>((ref) {
      return FcmTokenNotifier();
    });
