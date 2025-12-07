import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Servicio centralizado de Firebase Analytics
/// Registra eventos clave para entender cómo los usuarios usan la app
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Obtener el observer para GoRouter/Navigator
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ═══════════════════════════════════════════════════════════════
  // EVENTOS DE AUTENTICACIÓN
  // ═══════════════════════════════════════════════════════════════

  /// Usuario inició sesión
  Future<void> logLogin({String? method}) async {
    await _analytics.logLogin(loginMethod: method ?? 'email');
    debugPrint('📊 [Analytics] login: method=$method');
  }

  /// Usuario cerró sesión
  Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
    debugPrint('📊 [Analytics] logout');
  }

  /// Usuario seleccionó modo (padre/hijo)
  Future<void> logModeSelected({required String mode}) async {
    await _analytics.logEvent(
      name: 'mode_selected',
      parameters: {'mode': mode},
    );
    debugPrint('📊 [Analytics] mode_selected: $mode');
  }

  // ═══════════════════════════════════════════════════════════════
  // EVENTOS DE TRACKING (MODO HIJO)
  // ═══════════════════════════════════════════════════════════════

  /// Tracking iniciado
  Future<void> logTrackingStarted({int? childId}) async {
    await _analytics.logEvent(
      name: 'tracking_started',
      parameters: {
        if (childId != null) 'child_id': childId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    debugPrint('📊 [Analytics] tracking_started: childId=$childId');
  }

  /// Tracking detenido
  Future<void> logTrackingStopped({int? childId, int? positionsSent}) async {
    await _analytics.logEvent(
      name: 'tracking_stopped',
      parameters: {
        if (childId != null) 'child_id': childId,
        if (positionsSent != null) 'positions_sent': positionsSent,
      },
    );
    debugPrint(
      '📊 [Analytics] tracking_stopped: childId=$childId, sent=$positionsSent',
    );
  }

  /// Posición enviada exitosamente
  Future<void> logPositionSent({
    int? childId,
    double? lat,
    double? lng,
    int? batteryLevel,
  }) async {
    await _analytics.logEvent(
      name: 'position_sent',
      parameters: {
        if (childId != null) 'child_id': childId,
        if (batteryLevel != null) 'battery_level': batteryLevel,
      },
    );
    // No imprimir cada posición para no saturar logs
  }

  /// Error al enviar posición
  Future<void> logPositionError({String? error}) async {
    await _analytics.logEvent(
      name: 'position_error',
      parameters: {
        if (error != null)
          'error': error.substring(0, error.length.clamp(0, 100)),
      },
    );
    debugPrint('📊 [Analytics] position_error: $error');
  }

  // ═══════════════════════════════════════════════════════════════
  // EVENTOS DE GEOFENCE / ALERTAS
  // ═══════════════════════════════════════════════════════════════

  /// Niño entró a zona segura (colegio)
  Future<void> logGeofenceEnter({int? childId, int? schoolId}) async {
    await _analytics.logEvent(
      name: 'geofence_enter',
      parameters: {
        if (childId != null) 'child_id': childId,
        if (schoolId != null) 'school_id': schoolId,
      },
    );
    debugPrint(
      '📊 [Analytics] geofence_enter: child=$childId, school=$schoolId',
    );
  }

  /// Niño salió de zona segura (colegio)
  Future<void> logGeofenceExit({int? childId, int? schoolId}) async {
    await _analytics.logEvent(
      name: 'geofence_exit',
      parameters: {
        if (childId != null) 'child_id': childId,
        if (schoolId != null) 'school_id': schoolId,
      },
    );
    debugPrint(
      '📊 [Analytics] geofence_exit: child=$childId, school=$schoolId',
    );
  }

  /// Alerta visualizada por el padre
  Future<void> logAlertViewed({int? alertId, String? alertType}) async {
    await _analytics.logEvent(
      name: 'alert_viewed',
      parameters: {
        if (alertId != null) 'alert_id': alertId,
        if (alertType != null) 'alert_type': alertType,
      },
    );
    debugPrint('📊 [Analytics] alert_viewed: id=$alertId, type=$alertType');
  }

  /// Padre abrió app desde notificación push
  Future<void> logNotificationOpened({int? childId, String? alertType}) async {
    await _analytics.logEvent(
      name: 'notification_opened',
      parameters: {
        if (childId != null) 'child_id': childId,
        if (alertType != null) 'alert_type': alertType,
      },
    );
    debugPrint('📊 [Analytics] notification_opened: child=$childId');
  }

  // ═══════════════════════════════════════════════════════════════
  // EVENTOS DE VINCULACIÓN (QR)
  // ═══════════════════════════════════════════════════════════════

  /// Hijo vinculado exitosamente via QR
  Future<void> logChildLinked({int? childId, int? schoolId}) async {
    await _analytics.logEvent(
      name: 'child_linked',
      parameters: {
        if (childId != null) 'child_id': childId,
        if (schoolId != null) 'school_id': schoolId,
      },
    );
    debugPrint('📊 [Analytics] child_linked: child=$childId');
  }

  /// QR generado por el padre
  Future<void> logQrGenerated({int? childId}) async {
    await _analytics.logEvent(
      name: 'qr_generated',
      parameters: {if (childId != null) 'child_id': childId},
    );
    debugPrint('📊 [Analytics] qr_generated: child=$childId');
  }

  /// QR escaneado (intento de vinculación)
  Future<void> logQrScanned({bool success = true, String? error}) async {
    await _analytics.logEvent(
      name: 'qr_scanned',
      parameters: {'success': success, if (error != null) 'error': error},
    );
    debugPrint('📊 [Analytics] qr_scanned: success=$success');
  }

  // ═══════════════════════════════════════════════════════════════
  // EVENTOS DE NAVEGACIÓN / PANTALLAS
  // ═══════════════════════════════════════════════════════════════

  /// Pantalla visualizada
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
    debugPrint('📊 [Analytics] screen_view: $screenName');
  }

  /// Ver mapa de hijos
  Future<void> logMapViewed({int? childrenCount}) async {
    await _analytics.logEvent(
      name: 'map_viewed',
      parameters: {if (childrenCount != null) 'children_count': childrenCount},
    );
    debugPrint('📊 [Analytics] map_viewed: children=$childrenCount');
  }

  /// Ver historial de rutas
  Future<void> logRouteHistoryViewed({int? childId, String? date}) async {
    await _analytics.logEvent(
      name: 'route_history_viewed',
      parameters: {
        if (childId != null) 'child_id': childId,
        if (date != null) 'date': date,
      },
    );
    debugPrint(
      '📊 [Analytics] route_history_viewed: child=$childId, date=$date',
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // USER PROPERTIES
  // ═══════════════════════════════════════════════════════════════

  /// Establecer ID del usuario (para análisis por usuario)
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
    debugPrint('📊 [Analytics] setUserId: $userId');
  }

  /// Establecer rol del usuario
  Future<void> setUserRole(String role) async {
    await _analytics.setUserProperty(name: 'user_role', value: role);
    debugPrint('📊 [Analytics] setUserProperty: role=$role');
  }

  /// Establecer ID del colegio
  Future<void> setSchoolId(int schoolId) async {
    await _analytics.setUserProperty(
      name: 'school_id',
      value: schoolId.toString(),
    );
    debugPrint('📊 [Analytics] setUserProperty: school_id=$schoolId');
  }

  /// Establecer cantidad de hijos (para padres)
  Future<void> setChildrenCount(int count) async {
    await _analytics.setUserProperty(
      name: 'children_count',
      value: count.toString(),
    );
    debugPrint('📊 [Analytics] setUserProperty: children_count=$count');
  }
}
