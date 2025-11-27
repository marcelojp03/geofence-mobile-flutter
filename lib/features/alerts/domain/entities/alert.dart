import '../../../children/domain/entities/child.dart';

/// Tipo de alerta
enum AlertType {
  enterArea('ENTER_AREA'),
  exitArea('EXIT_AREA');

  final String value;
  const AlertType(this.value);

  static AlertType fromString(String value) {
    return AlertType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => AlertType.exitArea,
    );
  }

  String get displayName {
    switch (this) {
      case AlertType.enterArea:
        return 'Entrada a zona segura';
      case AlertType.exitArea:
        return 'Salida de zona segura';
    }
  }

  String get emoji {
    switch (this) {
      case AlertType.enterArea:
        return '✅';
      case AlertType.exitArea:
        return '⚠️';
    }
  }
}

/// Entidad de Alerta
class Alert {
  final int id;
  final AlertType type;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final int? childId;
  final Child? child;

  const Alert({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.childId,
    this.child,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as int,
      type: AlertType.fromString(json['type'] as String),
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      childId: json['childId'] as int?,
      child: json['child'] != null
          ? Child.fromJson(json['child'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      if (childId != null) 'childId': childId,
    };
  }

  /// Tiempo desde que se creó la alerta
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Hace ${diff.inSeconds}s';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours}h';
    return 'Hace ${diff.inDays}d';
  }

  /// Nombre del hijo (si está disponible)
  String get childName => child?.fullName ?? 'Desconocido';

  Alert copyWith({
    int? id,
    AlertType? type,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    int? childId,
    Child? child,
  }) {
    return Alert(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      childId: childId ?? this.childId,
      child: child ?? this.child,
    );
  }

  @override
  String toString() => 'Alert(id: $id, type: ${type.value}, isRead: $isRead)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alert && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
