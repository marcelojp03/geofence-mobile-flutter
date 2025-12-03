import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de entorno para la aplicación
/// Lee las variables desde el archivo .env
class Env {
  /// Inicializar dotenv - llamar en main() antes de runApp()
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  // URL base del backend
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';

  // Timeouts
  static Duration get connectTimeout => Duration(
    seconds: int.tryParse(dotenv.env['CONNECT_TIMEOUT'] ?? '30') ?? 30,
  );

  static Duration get receiveTimeout => Duration(
    seconds: int.tryParse(dotenv.env['RECEIVE_TIMEOUT'] ?? '30') ?? 30,
  );

  // Configuración de tracking
  static Duration get trackingInterval => Duration(
    seconds: int.tryParse(dotenv.env['TRACKING_INTERVAL'] ?? '30') ?? 30,
  );

  static Duration get backgroundTrackingInterval => Duration(
    seconds:
        int.tryParse(dotenv.env['BACKGROUND_TRACKING_INTERVAL'] ?? '300') ??
        300,
  );

  // School ID por defecto
  static int get defaultSchoolId =>
      int.tryParse(dotenv.env['DEFAULT_SCHOOL_ID'] ?? '1') ?? 1;

  // Firebase configuration
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';

  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';

  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';

  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  static String get firebaseStorageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';

  // Keys para SharedPreferences
  static const String tokenKey = 'auth_token';
  static const String deviceUidKey = 'device_uid';
  static const String modeKey = 'app_mode'; // 'parent' o 'child'
  static const String themeKey = 'theme_mode'; // 'dark' o 'light'
}
