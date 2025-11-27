import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/env.dart';
import '../../../core/entities/api_response.dart';
import '../domain/entities/entities.dart';
import 'dart:developer' as developer;

/// Repositorio de autenticación
/// Maneja todas las operaciones relacionadas con auth: login, logout, verificación
class AuthRepository {
  late final Dio _dio;

  AuthRepository() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: Env.connectTimeout,
        receiveTimeout: Env.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor para logs en desarrollo
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          developer.log(
            '🌐 REQUEST: ${options.method} ${options.path}',
            name: 'AuthRepository',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log(
            '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
            name: 'AuthRepository',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          developer.log(
            '❌ ERROR: ${error.message} ${error.requestOptions.path}',
            name: 'AuthRepository',
            error: error,
          );
          return handler.next(error);
        },
      ),
    );
  }

  /// Inicia sesión con email y contraseña
  Future<ApiResponse<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email.trim().toLowerCase(), 'password': password},
      );

      developer.log('LOGIN RESPONSE: ${response.data}', name: 'AuthRepository');

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data != null ? LoginResponse.fromJson(data) : null,
      );

      // Si login exitoso, guardar token
      if (apiResponse.isSuccess && apiResponse.data != null) {
        await _saveToken(apiResponse.data!.token);
      }

      return apiResponse;
    } on DioException catch (e) {
      developer.log(
        'DioException: ${e.response?.data}',
        name: 'AuthRepository',
        error: e,
      );

      // Si hay respuesta del servidor, parsear el error
      if (e.response?.data != null && e.response!.data is Map) {
        return ApiResponse.fromJson(
          e.response!.data as Map<String, dynamic>,
          (data) => data != null ? LoginResponse.fromJson(data) : null,
        );
      }

      // Error de conexión
      return ApiResponse<LoginResponse>(
        codigo: _getErrorCode(e),
        mensaje: _getErrorMessage(e),
      );
    } catch (e) {
      developer.log('Unexpected error: $e', name: 'AuthRepository', error: e);
      return ApiResponse<LoginResponse>(
        codigo: 500,
        mensaje: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Cierra la sesión del usuario
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Env.tokenKey);
      developer.log('Token removed, session closed', name: 'AuthRepository');
    } catch (e) {
      developer.log('Error on logout: $e', name: 'AuthRepository', error: e);
      rethrow;
    }
  }

  /// Verifica si hay una sesión activa
  Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
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
    developer.log('Token saved successfully', name: 'AuthRepository');
  }

  /// Obtiene el código de error según el tipo de DioException
  int _getErrorCode(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 408; // Request Timeout
      case DioExceptionType.connectionError:
        return 503; // Service Unavailable
      case DioExceptionType.cancel:
        return 499; // Client Closed Request
      default:
        return e.response?.statusCode ?? 500;
    }
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
        return e.response?.data?['mensaje'] ?? 'Error del servidor.';
      default:
        return 'Error de conexión. Intenta de nuevo.';
    }
  }
}
