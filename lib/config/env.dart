/// Configuración de entorno para la aplicación
class Env {
  // URL base del backend
  static const String baseUrl = 'http://localhost:3000/api';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Configuración de tracking
  static const Duration trackingInterval = Duration(seconds: 30);
  static const Duration backgroundTrackingInterval = Duration(minutes: 5);

  // School ID por defecto (puedes cambiarlo según tu caso)
  static const int defaultSchoolId = 1;

  // Keys para SharedPreferences
  static const String tokenKey = 'auth_token';
  static const String deviceUidKey = 'device_uid';
  static const String modeKey = 'app_mode'; // 'parent' o 'child'
  static const String themeKey = 'theme_mode'; // 'dark' o 'light'
}
