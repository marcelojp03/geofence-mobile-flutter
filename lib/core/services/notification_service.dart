import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geofence_mobile_flutter/config/router/app_router.dart';

/// Handler para mensajes en background (debe ser top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📩 [FCM Background] ${message.messageId}');
}

/// Servicio de notificaciones push con Firebase Cloud Messaging
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Canal de notificaciones para Android - Alertas
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'geofence_alerts',
    'Alertas Geofence',
    description: 'Notificaciones de alertas de geofence',
    importance: Importance.high,
    playSound: true,
  );

  /// Canal de notificaciones para Android - Tracking
  static const AndroidNotificationChannel _trackingChannel =
      AndroidNotificationChannel(
        'geofence_tracking',
        'Geofence Tracking',
        description: 'Notificación de servicio de tracking activo',
        importance: Importance.low,
        playSound: false,
        showBadge: false,
      );

  /// Inicializar el servicio de notificaciones
  Future<void> init() async {
    // Registrar handler de background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Solicitar permisos
    await _requestPermissions();

    // Configurar notificaciones locales
    await _setupLocalNotifications();

    // Configurar handlers de mensajes
    _setupMessageHandlers();

    // Obtener y mostrar token (para debug)
    final token = await getToken();
    debugPrint('📱 FCM Token: $token');
  }

  /// Solicitar permisos de notificación
  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('📩 FCM Permission: ${settings.authorizationStatus}');
  }

  /// Configurar notificaciones locales (para mostrar cuando app está en foreground)
  Future<void> _setupLocalNotifications() async {
    // Configuración Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Configuración iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canal en Android - Alertas
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(_channel);

    // Crear canal en Android - Tracking (para foreground service)
    await androidPlugin?.createNotificationChannel(_trackingChannel);
  }

  /// Configurar handlers para mensajes FCM
  void _setupMessageHandlers() {
    // Mensaje recibido con app en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Mensaje tocado cuando app estaba en background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Verificar si la app fue abierta por una notificación (app cerrada)
    _checkInitialMessage();
  }

  /// Verificar si hay mensaje inicial (app abierta desde notificación)
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('📩 [FCM Initial] App abierta desde notificación');
      _navigateFromMessage(initialMessage);
    }
  }

  /// Manejar mensaje en foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📩 [FCM Foreground] ${message.notification?.title}');

    final notification = message.notification;
    final android = message.notification?.android;

    // Mostrar notificación local si hay contenido
    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title ?? 'Alerta Geofence',
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Manejar cuando se toca una notificación (app en background)
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('📩 [FCM OpenedApp] Usuario tocó notificación');
    _navigateFromMessage(message);
  }

  /// Manejar tap en notificación local
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📩 [Local Notification] Tapped: ${response.payload}');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _navigateFromData(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Navegar a la pantalla correspondiente desde un mensaje FCM
  void _navigateFromMessage(RemoteMessage message) {
    _navigateFromData(message.data);
  }

  /// Navegar basado en los datos del payload
  void _navigateFromData(Map<String, dynamic> data) {
    debugPrint('📍 Navegando con data: $data');

    // Extraer childId del payload
    final childId = data['childId'] ?? data['child_id'];

    if (childId != null) {
      // Navegar al detalle del hijo
      final id = childId is int ? childId : int.tryParse(childId.toString());
      if (id != null) {
        debugPrint('📍 Navegando a /children/$id');
        appRouter.push('/children/$id');
      }
    } else {
      // Si no hay childId, ir al home del padre
      debugPrint('📍 Navegando a /parent (sin childId)');
      appRouter.go('/parent');
    }
  }

  /// Obtener el FCM token del dispositivo
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Suscribirse a un topic (ej: alertas de un hijo específico)
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('📩 Suscrito a topic: $topic');
  }

  /// Desuscribirse de un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('📩 Desuscrito de topic: $topic');
  }
}
