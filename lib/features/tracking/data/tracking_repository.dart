import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../../../core/entities/api_response.dart';
import '../../../config/env.dart';
import '../domain/entities/position.dart';

/// Repositorio para tracking de posiciones GPS
/// Endpoints: /tracking/*
class TrackingRepository {
  final ApiClient _api = apiClient;

  /// Cliente Dio sin autenticación para envío de posiciones
  late final Dio _publicDio;

  TrackingRepository() {
    _publicDio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: Env.connectTimeout,
        receiveTimeout: Env.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  /// Envía una posición GPS (endpoint público)
  /// POST /tracking/positions
  /// ⚠️ NO requiere autenticación - usado por el modo hijo
  Future<ApiResponse<PositionResponse>> sendPosition({
    required String deviceUid,
    required double lat,
    required double lng,
    double? accuracy,
    double? speed,
    double? heading,
    double? altitude,
    int? batteryLevel,
  }) async {
    try {
      final response = await _publicDio.post(
        '/tracking/positions',
        data: {
          'deviceUid': deviceUid,
          'lat': lat,
          'lng': lng,
          if (accuracy != null) 'accuracy': accuracy,
          if (speed != null) 'speed': speed,
          if (heading != null) 'heading': heading,
          if (altitude != null) 'altitude': altitude,
          if (batteryLevel != null) 'batteryLevel': batteryLevel,
        },
      );

      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        return ApiResponse<PositionResponse>(
          success: true,
          message: json['message'] ?? 'OK',
          data: PositionResponse.fromJson(json['data'] as Map<String, dynamic>),
        );
      }

      return ApiResponse<PositionResponse>(
        success: false,
        message: json['message'] ?? 'Error al enviar posición',
      );
    } on DioException catch (e) {
      developer.log(
        'Error sending position: ${e.message}',
        name: 'TrackingRepository',
      );
      return _handleError<PositionResponse>(e);
    } catch (e) {
      developer.log('Error: $e', name: 'TrackingRepository');
      return ApiResponse<PositionResponse>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Obtiene la última posición de un hijo
  /// GET /tracking/child/:childId/last
  Future<ApiResponse<Position>> getChildLastPosition(int childId) async {
    try {
      final response = await _api.get('/tracking/child/$childId/last');
      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        return ApiResponse<Position>(
          success: true,
          message: json['message'] ?? 'OK',
          data: Position.fromJson(json['data'] as Map<String, dynamic>),
        );
      }

      return ApiResponse<Position>(
        success: false,
        message: json['message'] ?? 'Error al obtener posición',
      );
    } on DioException catch (e) {
      return _handleError<Position>(e);
    } catch (e) {
      return ApiResponse<Position>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Obtiene el historial de posiciones de un hijo
  /// GET /tracking/child/:childId/history
  Future<ApiResponse<List<Position>>> getChildPositionHistory(
    int childId, {
    int limit = 50,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};
      if (from != null) queryParams['from'] = from.toIso8601String();
      if (to != null) queryParams['to'] = to.toIso8601String();

      final response = await _api.get(
        '/tracking/child/$childId/history',
        queryParameters: queryParams,
      );
      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        final List<dynamic> data = json['data'] as List;
        final positions = data
            .map((item) => Position.fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse<List<Position>>(
          success: true,
          message: json['message'] ?? 'OK',
          data: positions,
        );
      }

      return ApiResponse<List<Position>>(
        success: false,
        message: json['message'] ?? 'Error al obtener historial',
      );
    } on DioException catch (e) {
      return _handleError<List<Position>>(e);
    } catch (e) {
      return ApiResponse<List<Position>>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Obtiene todas las posiciones actuales (para admin)
  /// GET /tracking/current
  Future<ApiResponse<List<Position>>> getAllCurrentPositions() async {
    try {
      final response = await _api.get('/tracking/current');
      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        final List<dynamic> data = json['data'] as List;
        final positions = data
            .map((item) => Position.fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse<List<Position>>(
          success: true,
          message: json['message'] ?? 'OK',
          data: positions,
        );
      }

      return ApiResponse<List<Position>>(
        success: false,
        message: json['message'] ?? 'Error al obtener posiciones',
      );
    } on DioException catch (e) {
      return _handleError<List<Position>>(e);
    } catch (e) {
      return ApiResponse<List<Position>>(
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
