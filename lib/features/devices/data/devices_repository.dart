import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../../../core/entities/api_response.dart';
import '../../children/domain/entities/device.dart';

/// Repositorio para gestión de dispositivos
/// Endpoints: /devices/*
class DevicesRepository {
  final ApiClient _api = apiClient;

  /// Registra un nuevo dispositivo
  /// POST /devices
  Future<ApiResponse<Device>> registerDevice({
    required String deviceUid,
    required String name,
    String? model,
    String? manufacturer,
    String? osVersion,
    String? platform,
    String? fcmToken,
  }) async {
    try {
      final response = await _api.post(
        '/devices',
        data: {
          'deviceUid': deviceUid,
          'name': name,
          if (model != null) 'model': model,
          if (manufacturer != null) 'manufacturer': manufacturer,
          if (osVersion != null) 'osVersion': osVersion,
          if (platform != null) 'platform': platform,
          if (fcmToken != null) 'fcmToken': fcmToken,
        },
      );

      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        return ApiResponse<Device>(
          success: true,
          message: json['message'] ?? 'Dispositivo registrado',
          data: Device.fromJson(json['data'] as Map<String, dynamic>),
        );
      }

      return ApiResponse<Device>(
        success: false,
        message: json['message'] ?? 'Error al registrar dispositivo',
      );
    } on DioException catch (e) {
      return _handleError<Device>(e);
    } catch (e) {
      developer.log('Error: $e', name: 'DevicesRepository');
      return ApiResponse<Device>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Vincula un dispositivo a un hijo
  /// POST /devices/link
  Future<ApiResponse<void>> linkDeviceToChild({
    required String deviceUid,
    required int childId,
  }) async {
    try {
      final response = await _api.post(
        '/devices/link',
        data: {'deviceUid': deviceUid, 'childId': childId},
      );

      final json = response.data as Map<String, dynamic>;

      return ApiResponse<void>(
        success: json['success'] ?? false,
        message: json['message'] ?? 'Dispositivo vinculado',
      );
    } on DioException catch (e) {
      return _handleError<void>(e);
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Registra y vincula un dispositivo a un hijo en una sola llamada
  /// POST /devices/pair (público - no requiere autenticación)
  Future<ApiResponse<PairDeviceResponse>> pairDevice({
    required int schoolId,
    required int childId,
    required String deviceUid,
    required String name,
    String? model,
    String? manufacturer,
    String? osVersion,
    String? platform,
    String? fcmToken,
  }) async {
    try {
      final response = await _api.post(
        '/devices/pair',
        data: {
          'schoolId': schoolId,
          'childId': childId,
          'deviceUid': deviceUid,
          'name': name,
          if (model != null) 'model': model,
          if (manufacturer != null) 'manufacturer': manufacturer,
          if (osVersion != null) 'osVersion': osVersion,
          if (platform != null) 'platform': platform,
          if (fcmToken != null) 'fcmToken': fcmToken,
        },
      );

      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        return ApiResponse<PairDeviceResponse>(
          success: true,
          message: json['message'] ?? 'Dispositivo vinculado',
          data: PairDeviceResponse.fromJson(json),
        );
      }

      return ApiResponse<PairDeviceResponse>(
        success: false,
        message: json['message'] ?? 'Error al vincular dispositivo',
      );
    } on DioException catch (e) {
      return _handleError<PairDeviceResponse>(e);
    } catch (e) {
      developer.log('Error pairing device: $e', name: 'DevicesRepository');
      return ApiResponse<PairDeviceResponse>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Obtiene la lista de dispositivos
  /// GET /devices
  Future<ApiResponse<List<Device>>> getDevices() async {
    try {
      final response = await _api.get('/devices');
      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        final List<dynamic> data = json['data'] as List;
        final devices = data
            .map((item) => Device.fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse<List<Device>>(
          success: true,
          message: json['message'] ?? 'OK',
          data: devices,
        );
      }

      return ApiResponse<List<Device>>(
        success: false,
        message: json['message'] ?? 'Error al obtener dispositivos',
      );
    } on DioException catch (e) {
      return _handleError<List<Device>>(e);
    } catch (e) {
      return ApiResponse<List<Device>>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Obtiene detalle de un dispositivo
  /// GET /devices/:id
  Future<ApiResponse<Device>> getDeviceDetail(int deviceId) async {
    try {
      final response = await _api.get('/devices/$deviceId');
      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        return ApiResponse<Device>(
          success: true,
          message: json['message'] ?? 'OK',
          data: Device.fromJson(json['data'] as Map<String, dynamic>),
        );
      }

      return ApiResponse<Device>(
        success: false,
        message: json['message'] ?? 'Error al obtener dispositivo',
      );
    } on DioException catch (e) {
      return _handleError<Device>(e);
    } catch (e) {
      return ApiResponse<Device>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Actualiza un dispositivo
  /// PATCH /devices/:id
  Future<ApiResponse<Device>> updateDevice({
    required int deviceId,
    String? name,
    String? fcmToken,
  }) async {
    try {
      final response = await _api.patch(
        '/devices/$deviceId',
        data: {
          if (name != null) 'name': name,
          if (fcmToken != null) 'fcmToken': fcmToken,
        },
      );

      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        return ApiResponse<Device>(
          success: true,
          message: json['message'] ?? 'Dispositivo actualizado',
          data: Device.fromJson(json['data'] as Map<String, dynamic>),
        );
      }

      return ApiResponse<Device>(
        success: false,
        message: json['message'] ?? 'Error al actualizar',
      );
    } on DioException catch (e) {
      return _handleError<Device>(e);
    } catch (e) {
      return ApiResponse<Device>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Elimina un dispositivo
  /// DELETE /devices/:id
  Future<ApiResponse<void>> deleteDevice(int deviceId) async {
    try {
      final response = await _api.delete('/devices/$deviceId');
      final json = response.data as Map<String, dynamic>;

      return ApiResponse<void>(
        success: json['success'] ?? false,
        message: json['message'] ?? 'Dispositivo eliminado',
      );
    } on DioException catch (e) {
      return _handleError<void>(e);
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Registra el dispositivo del padre para recibir notificaciones de un hijo
  /// POST /devices/register-parent (requiere JWT)
  Future<ApiResponse<Device>> registerParentDevice({
    required int childId,
    required String deviceUid,
    required String fcmToken,
    String? name,
    String? model,
    String? platform,
  }) async {
    try {
      final response = await _api.post(
        '/devices/register-parent',
        data: {
          'childId': childId,
          'deviceUid': deviceUid,
          'fcmToken': fcmToken,
          if (name != null) 'name': name,
          if (model != null) 'model': model,
          if (platform != null) 'platform': platform,
        },
      );

      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        return ApiResponse<Device>(
          success: true,
          message: json['message'] ?? 'Dispositivo del padre registrado',
          data: Device.fromJson(json['device'] as Map<String, dynamic>),
        );
      }

      return ApiResponse<Device>(
        success: false,
        message: json['message'] ?? 'Error al registrar dispositivo',
      );
    } on DioException catch (e) {
      return _handleError<Device>(e);
    } catch (e) {
      developer.log(
        'Error registering parent device: $e',
        name: 'DevicesRepository',
      );
      return ApiResponse<Device>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Actualiza el token FCM de un dispositivo
  /// PATCH /devices/fcm-token (público)
  Future<ApiResponse<void>> updateFcmToken({
    required String deviceUid,
    required String fcmToken,
  }) async {
    try {
      final response = await _api.patch(
        '/devices/fcm-token',
        data: {'deviceUid': deviceUid, 'fcmToken': fcmToken},
      );

      final json = response.data as Map<String, dynamic>;

      return ApiResponse<void>(
        success: json['success'] ?? false,
        message: json['message'] ?? 'Token actualizado',
      );
    } on DioException catch (e) {
      return _handleError<void>(e);
    } catch (e) {
      developer.log('Error updating FCM token: $e', name: 'DevicesRepository');
      return ApiResponse<void>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  ApiResponse<T> _handleError<T>(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final json = e.response!.data as Map<String, dynamic>;
      return ApiResponse<T>(
        success: false,
        message: json['message'] ?? 'Error de conexión',
        code: json['code'],
      );
    }
    return ApiResponse<T>(success: false, message: 'Error de conexión');
  }
}

/// Respuesta del endpoint POST /devices/pair
class PairDeviceResponse {
  final Device device;
  final PairedChild child;

  PairDeviceResponse({required this.device, required this.child});

  factory PairDeviceResponse.fromJson(Map<String, dynamic> json) {
    return PairDeviceResponse(
      device: Device.fromJson(json['device'] as Map<String, dynamic>),
      child: PairedChild.fromJson(json['child'] as Map<String, dynamic>),
    );
  }
}

/// Información del hijo vinculado
class PairedChild {
  final int id;
  final String fullName;
  final String? grade;
  final PairedParent? parent;

  PairedChild({
    required this.id,
    required this.fullName,
    this.grade,
    this.parent,
  });

  factory PairedChild.fromJson(Map<String, dynamic> json) {
    return PairedChild(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      grade: json['grade'] as String?,
      parent: json['parent'] != null
          ? PairedParent.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Información del padre del hijo vinculado
class PairedParent {
  final int id;
  final String fullName;

  PairedParent({required this.id, required this.fullName});

  factory PairedParent.fromJson(Map<String, dynamic> json) {
    return PairedParent(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
    );
  }
}
