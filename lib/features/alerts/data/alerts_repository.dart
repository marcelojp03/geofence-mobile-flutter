import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../../../core/entities/api_response.dart';
import '../domain/entities/alert.dart';

/// Repositorio para gestión de alertas
/// Endpoints: /alerts/*
class AlertsRepository {
  final ApiClient _api = apiClient;

  /// Obtiene las alertas del padre autenticado
  /// GET /alerts/my-alerts
  Future<ApiResponse<List<Alert>>> getMyAlerts({bool? isRead}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isRead != null) queryParams['isRead'] = isRead;

      final response = await _api.get(
        '/alerts/my-alerts',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        final List<dynamic> data = json['data'] as List;
        final alerts = data
            .map((item) => Alert.fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse<List<Alert>>(
          success: true,
          message: json['message'] ?? 'OK',
          data: alerts,
        );
      }

      return ApiResponse<List<Alert>>(
        success: false,
        message: json['message'] ?? 'Error al obtener alertas',
      );
    } on DioException catch (e) {
      return _handleError<List<Alert>>(e);
    } catch (e) {
      developer.log('Error: $e', name: 'AlertsRepository');
      return ApiResponse<List<Alert>>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Obtiene el conteo de alertas no leídas
  /// GET /alerts/unread-count
  Future<ApiResponse<int>> getUnreadCount() async {
    try {
      final response = await _api.get('/alerts/unread-count');
      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        final count = (json['data'] as Map<String, dynamic>)['count'] as int;
        return ApiResponse<int>(
          success: true,
          message: json['message'] ?? 'OK',
          data: count,
        );
      }

      return ApiResponse<int>(
        success: false,
        message: json['message'] ?? 'Error al obtener conteo',
        data: 0,
      );
    } on DioException catch (e) {
      return _handleError<int>(e);
    } catch (e) {
      return ApiResponse<int>(
        success: false,
        message: 'Error inesperado',
        data: 0,
      );
    }
  }

  /// Obtiene alertas de un hijo específico (filtro local)
  /// Usa GET /alerts/my-alerts y filtra por childId
  Future<ApiResponse<List<Alert>>> getAlertsByChild(int childId) async {
    try {
      final response = await _api.get('/alerts/my-alerts');
      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        final List<dynamic> data = json['data'] as List;
        final alerts = data
            .map((item) => Alert.fromJson(item as Map<String, dynamic>))
            .where((alert) => alert.childId == childId)
            .toList();

        return ApiResponse<List<Alert>>(
          success: true,
          message: json['message'] ?? 'OK',
          data: alerts,
        );
      }

      return ApiResponse<List<Alert>>(
        success: false,
        message: json['message'] ?? 'Error al obtener alertas del hijo',
      );
    } on DioException catch (e) {
      return _handleError<List<Alert>>(e);
    } catch (e) {
      developer.log('Error: $e', name: 'AlertsRepository');
      return ApiResponse<List<Alert>>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Marca una alerta como leída
  /// PATCH /alerts/:id/mark-read
  Future<ApiResponse<void>> markAsRead(int alertId) async {
    try {
      final response = await _api.patch('/alerts/$alertId/mark-read');
      final json = response.data as Map<String, dynamic>;

      return ApiResponse<void>(
        success: json['success'] ?? false,
        message: json['message'] ?? 'Alerta marcada como leída',
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

  /// Marca todas las alertas como leídas
  /// PATCH /alerts/mark-all-read
  Future<ApiResponse<void>> markAllAsRead() async {
    try {
      final response = await _api.patch('/alerts/mark-all-read');
      final json = response.data as Map<String, dynamic>;

      return ApiResponse<void>(
        success: json['success'] ?? false,
        message: json['message'] ?? 'Todas las alertas marcadas como leídas',
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

  /// Obtiene todas las alertas (para admin)
  /// GET /alerts
  Future<ApiResponse<List<Alert>>> getAllAlerts({
    String? type,
    bool? isRead,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type;
      if (isRead != null) queryParams['isRead'] = isRead;

      final response = await _api.get(
        '/alerts',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        final List<dynamic> data = json['data'] as List;
        final alerts = data
            .map((item) => Alert.fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse<List<Alert>>(
          success: true,
          message: json['message'] ?? 'OK',
          data: alerts,
        );
      }

      return ApiResponse<List<Alert>>(
        success: false,
        message: json['message'] ?? 'Error al obtener alertas',
      );
    } on DioException catch (e) {
      return _handleError<List<Alert>>(e);
    } catch (e) {
      return ApiResponse<List<Alert>>(
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
