import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../../../core/entities/api_response.dart';
import '../domain/entities/entities.dart';

/// Repositorio para gestión de hijos
/// Endpoints: /children/*
class ChildrenRepository {
  final ApiClient _api = apiClient;

  /// Obtiene la lista de hijos del padre autenticado
  /// GET /children/my-children
  Future<ApiResponse<List<Child>>> getMyChildren() async {
    try {
      final response = await _api.get('/children/my-children');
      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        final List<dynamic> data = json['data'] as List;
        final children = data
            .map((item) => Child.fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse<List<Child>>(
          success: true,
          message: json['message'] ?? 'OK',
          data: children,
        );
      }

      return ApiResponse<List<Child>>(
        success: false,
        message: json['message'] ?? 'Error al obtener hijos',
      );
    } on DioException catch (e) {
      return _handleError<List<Child>>(e);
    } catch (e) {
      developer.log('Error: $e', name: 'ChildrenRepository');
      return ApiResponse<List<Child>>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Obtiene el detalle de un hijo
  /// GET /children/:childId
  Future<ApiResponse<Child>> getChildDetail(int childId) async {
    try {
      final response = await _api.get('/children/$childId');
      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        return ApiResponse<Child>(
          success: true,
          message: json['message'] ?? 'OK',
          data: Child.fromJson(json['data'] as Map<String, dynamic>),
        );
      }

      return ApiResponse<Child>(
        success: false,
        message: json['message'] ?? 'Error al obtener detalle',
      );
    } on DioException catch (e) {
      return _handleError<Child>(e);
    } catch (e) {
      return ApiResponse<Child>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Crea un nuevo hijo
  /// POST /children
  Future<ApiResponse<Child>> createChild({
    required String fullName,
    required int age,
    required String grade,
    int? parentId,
  }) async {
    try {
      final response = await _api.post(
        '/children',
        data: {
          'fullName': fullName,
          'age': age,
          'grade': grade,
          if (parentId != null) 'parentId': parentId,
        },
      );

      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        return ApiResponse<Child>(
          success: true,
          message: json['message'] ?? 'Hijo creado',
          data: Child.fromJson(json['data'] as Map<String, dynamic>),
        );
      }

      return ApiResponse<Child>(
        success: false,
        message: json['message'] ?? 'Error al crear hijo',
      );
    } on DioException catch (e) {
      return _handleError<Child>(e);
    } catch (e) {
      return ApiResponse<Child>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Actualiza un hijo
  /// PATCH /children/:childId
  Future<ApiResponse<Child>> updateChild({
    required int childId,
    String? fullName,
    int? age,
    String? grade,
  }) async {
    try {
      final response = await _api.patch(
        '/children/$childId',
        data: {
          if (fullName != null) 'fullName': fullName,
          if (age != null) 'age': age,
          if (grade != null) 'grade': grade,
        },
      );

      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        return ApiResponse<Child>(
          success: true,
          message: json['message'] ?? 'Hijo actualizado',
          data: Child.fromJson(json['data'] as Map<String, dynamic>),
        );
      }

      return ApiResponse<Child>(
        success: false,
        message: json['message'] ?? 'Error al actualizar',
      );
    } on DioException catch (e) {
      return _handleError<Child>(e);
    } catch (e) {
      return ApiResponse<Child>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Elimina un hijo
  /// DELETE /children/:childId
  Future<ApiResponse<void>> deleteChild(int childId) async {
    try {
      final response = await _api.delete('/children/$childId');
      final json = response.data as Map<String, dynamic>;

      return ApiResponse<void>(
        success: json['success'] ?? false,
        message: json['message'] ?? 'Hijo eliminado',
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
