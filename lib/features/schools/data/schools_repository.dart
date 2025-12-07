import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../../../core/entities/api_response.dart';
import '../../auth/domain/entities/school.dart';

/// Repositorio para gestión de colegios
/// Endpoints: /schools/*
class SchoolsRepository {
  final ApiClient _api = apiClient;

  /// Obtiene el geofence de un colegio específico
  /// GET /schools/:id/geofence
  Future<ApiResponse<School>> getSchoolGeofence(int schoolId) async {
    try {
      final response = await _api.get('/schools/$schoolId/geofence');
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;

      return ApiResponse<School>(
        success: true,
        message: 'OK',
        data: School.fromJson(data),
      );
    } on DioException catch (e) {
      return _handleError<School>(e);
    } catch (e) {
      developer.log(
        'Error getting school geofence: $e',
        name: 'SchoolsRepository',
      );
      return ApiResponse<School>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Obtiene todos los colegios con sus geofences
  /// GET /schools/with-geofences
  Future<ApiResponse<List<School>>> getSchoolsWithGeofences() async {
    try {
      final response = await _api.get('/schools/with-geofences');
      final json = response.data as Map<String, dynamic>;
      final data = json['data'] as List;

      final schools = data
          .map((item) => School.fromJson(item as Map<String, dynamic>))
          .toList();

      return ApiResponse<List<School>>(
        success: true,
        message: 'OK',
        data: schools,
      );
    } on DioException catch (e) {
      return _handleError<List<School>>(e);
    } catch (e) {
      developer.log(
        'Error getting schools with geofences: $e',
        name: 'SchoolsRepository',
      );
      return ApiResponse<List<School>>(
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
      );
    }
    return ApiResponse<T>(success: false, message: 'Error de conexión');
  }
}
