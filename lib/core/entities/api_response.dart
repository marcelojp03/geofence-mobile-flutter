/// Respuesta genérica de la API
/// Envuelve todas las respuestas del backend con formato consistente
class ApiResponse<T> {
  final int codigo;
  final String mensaje;
  final T? data;

  const ApiResponse({required this.codigo, required this.mensaje, this.data});

  /// Verifica si la respuesta fue exitosa (código 200-299)
  bool get isSuccess => codigo >= 200 && codigo < 300;

  /// Verifica si hubo error
  bool get isError => !isSuccess;

  /// Factory para parsear JSON con un parser genérico
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(Map<String, dynamic>? data) fromJsonT,
  ) {
    return ApiResponse<T>(
      codigo: json['codigo'] as int? ?? 500,
      mensaje: json['mensaje'] as String? ?? 'Error desconocido',
      data: json['data'] != null
          ? fromJsonT(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T data)? toJsonT) {
    return {
      'codigo': codigo,
      'mensaje': mensaje,
      if (data != null && toJsonT != null) 'data': toJsonT(data as T),
    };
  }

  /// Copia con nuevos valores
  ApiResponse<T> copyWith({int? codigo, String? mensaje, T? data}) {
    return ApiResponse<T>(
      codigo: codigo ?? this.codigo,
      mensaje: mensaje ?? this.mensaje,
      data: data ?? this.data,
    );
  }

  @override
  String toString() =>
      'ApiResponse(codigo: $codigo, mensaje: $mensaje, data: $data)';
}
