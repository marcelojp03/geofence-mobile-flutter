/// Respuesta genérica de la API
/// Envuelve todas las respuestas del backend con formato consistente
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? code;
  final List<String>? details;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.code,
    this.details,
  });

  /// Verifica si la respuesta fue exitosa
  bool get isSuccess => success;

  /// Verifica si hubo error
  bool get isError => !success;

  /// Factory para parsear JSON con un parser genérico
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(dynamic data) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Error desconocido',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      code: json['code'] as String?,
      details: json['details'] != null
          ? List<String>.from(json['details'] as List)
          : null,
    );
  }

  /// Factory simple cuando no hay data que parsear
  factory ApiResponse.simple(Map<String, dynamic> json) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Error desconocido',
      code: json['code'] as String?,
      details: json['details'] != null
          ? List<String>.from(json['details'] as List)
          : null,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T data)? toJsonT) {
    return {
      'success': success,
      'message': message,
      if (data != null && toJsonT != null) 'data': toJsonT(data as T),
      if (code != null) 'code': code,
      if (details != null) 'details': details,
    };
  }

  /// Copia con nuevos valores
  ApiResponse<T> copyWith({
    bool? success,
    String? message,
    T? data,
    String? code,
    List<String>? details,
  }) {
    return ApiResponse<T>(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
      code: code ?? this.code,
      details: details ?? this.details,
    );
  }

  @override
  String toString() =>
      'ApiResponse(success: $success, message: $message, data: $data)';
}
