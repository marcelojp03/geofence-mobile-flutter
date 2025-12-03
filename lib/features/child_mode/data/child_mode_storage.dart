import 'package:shared_preferences/shared_preferences.dart';

/// Almacenamiento de preferencias para el modo hijo
class ChildModeStorage {
  static const String _childIdKey = 'child_mode_child_id';
  static const String _schoolIdKey = 'child_mode_school_id';
  static const String _deviceUidKey = 'child_mode_device_uid';
  static const String _childNameKey = 'child_mode_child_name';
  static const String _isConfiguredKey = 'child_mode_is_configured';
  static const String _lastSentKey = 'child_mode_last_sent';

  /// Guarda la configuración del modo hijo
  Future<void> saveConfig({
    required int childId,
    required String deviceUid,
    String? childName,
    int? schoolId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_childIdKey, childId);
    await prefs.setString(_deviceUidKey, deviceUid);
    if (childName != null) {
      await prefs.setString(_childNameKey, childName);
    }
    if (schoolId != null) {
      await prefs.setInt(_schoolIdKey, schoolId);
    }
    await prefs.setBool(_isConfiguredKey, true);
  }

  /// Obtiene el childId guardado
  Future<int?> getChildId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_childIdKey);
  }

  /// Obtiene el schoolId guardado
  Future<int?> getSchoolId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_schoolIdKey);
  }

  /// Obtiene el deviceUid guardado
  Future<String?> getDeviceUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceUidKey);
  }

  /// Obtiene el nombre del hijo
  Future<String?> getChildName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_childNameKey);
  }

  /// Verifica si el modo hijo está configurado
  Future<bool> isConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isConfiguredKey) ?? false;
  }

  /// Guarda la última vez que se envió una posición
  Future<void> setLastSent(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSentKey, dateTime.toIso8601String());
  }

  /// Obtiene la última vez que se envió una posición
  Future<DateTime?> getLastSent() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastSentKey);
    return value != null ? DateTime.parse(value) : null;
  }

  /// Limpia toda la configuración del modo hijo
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_childIdKey);
    await prefs.remove(_schoolIdKey);
    await prefs.remove(_deviceUidKey);
    await prefs.remove(_childNameKey);
    await prefs.remove(_isConfiguredKey);
    await prefs.remove(_lastSentKey);
  }
}
