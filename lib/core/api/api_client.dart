import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../../config/env.dart';

/// Cliente HTTP centralizado para la API
/// Maneja interceptores, autenticación y configuración base
class ApiClient {
  late final Dio _dio;
  String? _token;

  ApiClient() {
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

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Agregar token si existe
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }

          developer.log(
            '📤 ${options.method} ${options.path}',
            name: 'ApiClient',
          );

          if (options.data != null) {
            // Ocultar password en logs
            final logData = Map<String, dynamic>.from(
              options.data is Map ? options.data : {},
            );
            if (logData.containsKey('password')) {
              logData['password'] = '***';
            }
            developer.log('   Body: $logData', name: 'ApiClient');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log(
            '📥 ${response.statusCode} ${response.requestOptions.path}',
            name: 'ApiClient',
          );
          // Log response body
          if (response.data != null) {
            developer.log('   Response: ${response.data}', name: 'ApiClient');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          // 404 es esperado en algunos casos (no hay datos), no es un error real
          final statusCode = error.response?.statusCode;
          final icon = statusCode == 404 ? '📭' : '❌';
          developer.log(
            '$icon $statusCode ${error.requestOptions.path}',
            name: 'ApiClient',
          );
          if (error.response?.data != null) {
            developer.log(
              '   Error: ${error.response?.data}',
              name: 'ApiClient',
            );
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Establece el token de autenticación
  void setToken(String token) {
    _token = token;
    developer.log('🔑 Token establecido', name: 'ApiClient');
  }

  /// Limpia el token de autenticación
  void clearToken() {
    _token = null;
    developer.log('🔓 Token eliminado', name: 'ApiClient');
  }

  /// Verifica si hay token
  bool get hasToken => _token != null && _token!.isNotEmpty;

  /// Getter para acceder al cliente Dio
  Dio get dio => _dio;

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}

/// Singleton para acceso global
final apiClient = ApiClient();
