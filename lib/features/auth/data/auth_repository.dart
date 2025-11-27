import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import '../../../config/env.dart';
import '../../../core/api/api_client.dart';
import '../../../core/entities/api_response.dart';
import '../domain/entities/entities.dart';

/// Repositorio de autenticación
/// Maneja todas las operaciones relacionadas con auth: login, register, logout
class AuthRepository {
  final ApiClient _api = apiClient;

  /// Inicia sesión con email y contraseña
  /// POST /auth/login
  Future<ApiResponse<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        '/auth/login',
        data: {'email': email.trim().toLowerCase(), 'password': password},
      );

      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        final loginResponse = LoginResponse.fromJson(json['data']);

        // Guardar token
        await _saveToken(loginResponse.accessToken);
        _api.setToken(loginResponse.accessToken);

        return ApiResponse<LoginResponse>(
          success: true,
          message: json['message'] ?? 'OK',
          data: loginResponse,
        );
      }

      return ApiResponse<LoginResponse>(
        success: false,
        message: json['message'] ?? 'Error al iniciar sesión',
        code: json['code'],
      );
    } on DioException catch (e) {
      developer.log(
        'DioException: ${e.response?.data}',
        name: 'AuthRepository',
      );
      return _handleDioError<LoginResponse>(e);
    } catch (e) {
      developer.log('Unexpected error: $e', name: 'AuthRepository');
      return ApiResponse<LoginResponse>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Registra un nuevo usuario
  /// POST /auth/register
  Future<ApiResponse<void>> register({
    required int schoolId,
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _api.post(
        '/auth/register',
        data: {
          'schoolId': schoolId,
          'email': email.trim().toLowerCase(),
          'password': password,
          'fullName': fullName.trim(),
          if (phone != null) 'phone': phone,
          'role': 'PARENT',
        },
      );

      final json = response.data as Map<String, dynamic>;

      return ApiResponse<void>(
        success: json['success'] ?? false,
        message: json['message'] ?? 'Usuario registrado',
        code: json['code'],
      );
    } on DioException catch (e) {
      return _handleDioError<void>(e);
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Obtiene el perfil del usuario autenticado
  /// GET /auth/me
  Future<ApiResponse<User>> getProfile() async {
    try {
      final response = await _api.get('/auth/me');
      final json = response.data as Map<String, dynamic>;

      if (json['success'] == true) {
        return ApiResponse<User>(
          success: true,
          message: json['message'] ?? 'OK',
          data: User.fromJson(json['data']),
        );
      }

      return ApiResponse<User>(
        success: false,
        message: json['message'] ?? 'Error al obtener perfil',
      );
    } on DioException catch (e) {
      return _handleDioError<User>(e);
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Cierra la sesión del usuario
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Env.tokenKey);
      _api.clearToken();
      developer.log('Sesión cerrada', name: 'AuthRepository');
    } catch (e) {
      developer.log('Error on logout: $e', name: 'AuthRepository');
      rethrow;
    }
  }

  /// Verifica si hay una sesión activa y restaura el token
  Future<bool> checkSession() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return false;

      _api.setToken(token);

      // Verificar que el token sea válido
      final response = await getProfile();
      return response.isSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si hay una sesión activa
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Obtiene el token guardado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Env.tokenKey);
  }

  /// Guarda el token en SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Env.tokenKey, token);
    developer.log('Token guardado', name: 'AuthRepository');
  }

  /// Maneja errores de Dio
  ApiResponse<T> _handleDioError<T>(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final json = e.response!.data as Map<String, dynamic>;
      return ApiResponse<T>(
        success: false,
        message: json['message'] ?? _getErrorMessage(e),
        code: json['code'],
        details: json['details'] != null
            ? List<String>.from(json['details'])
            : null,
      );
    }

    return ApiResponse<T>(success: false, message: _getErrorMessage(e));
  }

  /// Obtiene mensaje de error amigable según el tipo de DioException
  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tiempo de conexión agotado. Verifica tu internet.';
      case DioExceptionType.sendTimeout:
        return 'Tiempo de envío agotado. Intenta de nuevo.';
      case DioExceptionType.receiveTimeout:
        return 'El servidor tardó demasiado en responder.';
      case DioExceptionType.connectionError:
        return 'No se pudo conectar al servidor. Verifica tu conexión.';
      case DioExceptionType.cancel:
        return 'Solicitud cancelada.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return 'Credenciales inválidas.';
        if (statusCode == 403) return 'No tienes permisos.';
        if (statusCode == 404) return 'Recurso no encontrado.';
        if (statusCode == 409) return 'El recurso ya existe.';
        return 'Error del servidor ($statusCode).';
      default:
        return 'Error de conexión. Intenta de nuevo.';
    }
  }
}
