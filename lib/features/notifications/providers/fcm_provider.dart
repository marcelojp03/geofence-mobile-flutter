import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geofence_mobile_flutter/core/services/notification_service.dart';
import 'package:geofence_mobile_flutter/core/api/api_client.dart';
import 'package:flutter/foundation.dart';

/// Provider para obtener el FCM token
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  return await NotificationService().getToken();
});

/// Provider para registrar el FCM token en el backend
final registerFcmTokenProvider = FutureProvider.family<bool, String>((
  ref,
  token,
) async {
  try {
    final response = await apiClient.dio.post(
      '/devices/fcm-token',
      data: {'fcmToken': token},
    );
    debugPrint('✅ FCM token registrado en backend');
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    debugPrint('❌ Error registrando FCM token: $e');
    return false;
  }
});

/// Notifier para manejar el registro del FCM token
class FcmTokenNotifier extends StateNotifier<AsyncValue<bool>> {
  FcmTokenNotifier() : super(const AsyncValue.data(false));

  /// Registrar el token FCM en el backend
  Future<void> registerToken() async {
    state = const AsyncValue.loading();

    try {
      final token = await NotificationService().getToken();

      if (token == null) {
        state = AsyncValue.error(
          'No se pudo obtener el FCM token',
          StackTrace.current,
        );
        return;
      }

      final response = await apiClient.dio.post(
        '/devices/fcm-token',
        data: {'fcmToken': token},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ FCM token registrado exitosamente');
        state = const AsyncValue.data(true);
      } else {
        state = AsyncValue.error('Error del servidor', StackTrace.current);
      }
    } catch (e, st) {
      debugPrint('❌ Error registrando FCM token: $e');
      state = AsyncValue.error(e, st);
    }
  }
}

final fcmTokenNotifierProvider =
    StateNotifierProvider<FcmTokenNotifier, AsyncValue<bool>>((ref) {
      return FcmTokenNotifier();
    });
