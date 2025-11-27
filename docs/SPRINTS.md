# 📅 Plan de Sprints - GeoKids Mobile

Plan detallado de implementación por sprints y en orden de prioridad.

---

## ✅ M0 – Bootstrap del proyecto Flutter

**Estado**: ✅ COMPLETADO

### Tareas Completadas:

- [x] Crear proyecto Flutter
- [x] Estructura base de carpetas implementada:
  ```
  lib/
    config/ (env, router, theme)
    core/
    shared/ (providers, widgets)
    features/ (splash, auth, parent, child_mode, mode_selector)
  ```
- [x] Dependencias agregadas al `pubspec.yaml`:
  - `flutter_riverpod` ✅
  - `dio` ✅
  - `device_info_plus` ✅
  - `battery_plus` ✅
  - `shared_preferences` ✅
  - `geolocator` ✅
  - `firebase_core` ✅
  - `firebase_messaging` ✅
  - `flutter_local_notifications` ✅
  - `go_router` ✅
  - `permission_handler` ✅
  
- [x] Crear `env.dart` con `baseUrl`, timeouts, schoolId
- [x] Crear tema de la app (AppTheme) con dark/light mode
- [x] Crear provider de tema con persistencia
- [x] Configurar GoRouter con todas las rutas
- [x] Pantallas base creadas

---

## 🔐 M1 – Modo Padre: Login + Home Básico

**Objetivo**: El padre puede loguearse y ver algo útil en pantalla.

**Duración estimada**: 2-3 días

### 📝 Tareas:

#### 1. Capa de Datos (Data Layer)

- [ ] Crear `lib/features/auth/data/models/`:
  - [ ] `user_model.dart` (modelo de usuario)
  - [ ] `token_pair_model.dart` (accessToken, refreshToken)
  
- [ ] Crear `lib/features/auth/data/datasources/`:
  - [ ] `auth_remote_datasource.dart` (llamadas HTTP con Dio)
  
- [ ] Crear `lib/features/auth/data/repositories/`:
  - [ ] `auth_repository_impl.dart`:
    ```dart
    Future<TokenPair> login(String email, String password)
    Future<void> logout()
    Future<bool> isAuthenticated()
    ```

#### 2. Capa de Dominio (Domain Layer) - Opcional para MVP

- [ ] Crear `lib/features/auth/domain/entities/`:
  - [ ] `user.dart`
  - [ ] `token_pair.dart`
  
- [ ] Crear `lib/features/auth/domain/repositories/`:
  - [ ] `auth_repository.dart` (contrato abstracto)

#### 3. Capa de Presentación (Presentation)

- [ ] Crear providers en `lib/features/auth/presentation/providers/`:
  - [ ] `auth_provider.dart`:
    ```dart
    final authRepositoryProvider = Provider<AuthRepository>((ref) => ...);
    final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>(...);
    ```
  
- [ ] Mejorar `login_screen.dart`:
  - [ ] Conectar con el repositorio real
  - [ ] Manejar estados: loading, error, success
  - [ ] Guardar token en SharedPreferences
  - [ ] Navegar a `/parent` al login exitoso

#### 4. DioClient (Core)

- [ ] Crear `lib/core/network/`:
  - [ ] `dio_client.dart`:
    ```dart
    class DioClient {
      final Dio _dio;
      
      DioClient() {
        _dio = Dio(BaseOptions(
          baseUrl: Env.baseUrl,
          connectTimeout: Env.connectTimeout,
          receiveTimeout: Env.receiveTimeout,
        ));
        
        _dio.interceptors.add(AuthInterceptor());
        _dio.interceptors.add(LoggingInterceptor());
      }
    }
    ```
  
- [ ] Crear `lib/core/network/interceptors/`:
  - [ ] `auth_interceptor.dart` (añadir token automáticamente)
  - [ ] `logging_interceptor.dart` (logs de requests/responses)

#### 5. HomeParentScreen

- [ ] Crear `lib/features/parent/data/`:
  - [ ] `models/child_model.dart`
  - [ ] `datasources/children_remote_datasource.dart`
  - [ ] `repositories/children_repository_impl.dart`
  
- [ ] Crear providers:
  - [ ] `children_provider.dart` (obtener lista de hijos)
  
- [ ] Conectar `HomeParentScreen` con API:
  - [ ] Llamar a `/children/my`
  - [ ] Mostrar lista de hijos con:
    - Nombre
    - Estado (dentro/fuera)
    - Batería
    - Última actualización
  - [ ] Pull to refresh

### ✅ Criterios de Aceptación:

- [ ] El padre puede hacer login con email y password
- [ ] Se guarda el token en local storage
- [ ] Al abrir la app con token válido, va directo a `/parent`
- [ ] En home padre se ve la lista de hijos desde el backend
- [ ] Cada hijo muestra su estado actualizado (dentro/fuera, batería, tiempo)
- [ ] Hay manejo de errores (red, credenciales inválidas, etc.)

---

## 📱 M2 – Registrar Dispositivo & Vincular Hijo

**Objetivo**: Que el teléfono se registre como "dispositivo hijo" en el backend.

**Duración estimada**: 2-3 días

### 📝 Tareas:

#### 1. Capa de Datos - Device

- [ ] Crear `lib/features/device/data/`:
  - [ ] `models/device_model.dart`
  - [ ] `datasources/device_remote_datasource.dart`
  - [ ] `repositories/device_repository_impl.dart`:
    ```dart
    Future<Device> registerDevice({
      required int schoolId,
      required String deviceUid,
      required String name,
      required String model,
      String? fcmToken,
    })
    
    Future<void> linkToChild(String deviceUid, int childId)
    ```

#### 2. Device UID Generation

- [ ] Crear `lib/core/utils/`:
  - [ ] `device_utils.dart`:
    ```dart
    Future<String> getOrCreateDeviceUid()
    Future<DeviceInfo> getDeviceInfo()
    ```

#### 3. Firebase Messaging Setup

- [ ] Configurar Firebase en Android (`google-services.json`)
- [ ] Configurar Firebase en iOS (`GoogleService-Info.plist`)
- [ ] Crear `lib/core/notifications/`:
  - [ ] `fcm_service.dart`:
    ```dart
    Future<String?> getFcmToken()
    void setupNotificationHandlers()
    ```

#### 4. Child Mode Setup Screen

- [ ] Crear `lib/features/child_mode/presentation/`:
  - [ ] `child_setup_screen.dart`:
    1. Obtener/generar `deviceUid`
    2. Obtener info del dispositivo
    3. Obtener `fcmToken`
    4. Registrar dispositivo en backend
    5. Mostrar código o QR para vincular con hijo

#### 5. Linking Flow

Opción 1: **Link Code** (MVP simple)
- [ ] Backend genera código de 6 dígitos
- [ ] Padre ve el código en la web/app
- [ ] Se ingresa en el dispositivo hijo
- [ ] Llama a `/devices/link`

Opción 2: **QR Code** (más adelante)
- [ ] Padre escanea QR desde el device hijo
- [ ] Auto-vincula

### ✅ Criterios de Aceptación:

- [ ] Al elegir "Este es el celular de mi hijo", se registra el device
- [ ] Se genera o recupera un `deviceUid` único
- [ ] Se obtiene información del dispositivo (modelo, OS, etc.)
- [ ] Se obtiene el `fcmToken` de Firebase
- [ ] El dispositivo queda registrado en el backend
- [ ] Hay algún mecanismo para vincular el device a un hijo (código o QR)

---

## 📍 M3 – Tracking en Foreground (MVP Real)

**Objetivo**: Enviar posiciones + batería al backend mientras la app está abierta.

**Duración estimada**: 3-4 días

### 📝 Tareas:

#### 1. Permisos de Ubicación

- [ ] Crear `lib/core/permissions/`:
  - [ ] `location_permission_handler.dart`:
    ```dart
    Future<bool> requestLocationPermission()
    Future<bool> hasLocationPermission()
    ```

#### 2. Location Service

- [ ] Crear `lib/core/location/`:
  - [ ] `location_service.dart`:
    ```dart
    Future<Position?> getCurrentPosition()
    Stream<Position> getPositionStream({Duration interval})
    ```

#### 3. Battery Service

- [ ] Crear `lib/core/device/`:
  - [ ] `battery_service.dart`:
    ```dart
    Future<int> getBatteryLevel()
    Stream<int> getBatteryStream()
    ```

#### 4. Tracking Repository

- [ ] Crear `lib/features/tracking/data/`:
  - [ ] `models/position_model.dart`
  - [ ] `datasources/tracking_remote_datasource.dart`
  - [ ] `repositories/tracking_repository_impl.dart`:
    ```dart
    Future<void> sendPosition({
      required String deviceUid,
      required double lat,
      required double lng,
      required int batteryLevel,
      double? accuracy,
      double? speed,
    })
    ```

#### 5. Tracking Provider

- [ ] Crear `lib/features/tracking/presentation/providers/`:
  - [ ] `tracking_provider.dart`:
    ```dart
    final trackingNotifierProvider = StateNotifierProvider<TrackingNotifier, TrackingState>
    
    class TrackingNotifier extends StateNotifier<TrackingState> {
      Timer? _timer;
      
      void startTracking() {
        _timer = Timer.periodic(Env.trackingInterval, (_) {
          _sendPosition();
        });
      }
      
      void stopTracking() {
        _timer?.cancel();
      }
      
      Future<void> _sendPosition() async {
        // 1. Obtener ubicación
        // 2. Obtener batería
        // 3. Enviar al backend
      }
    }
    ```

#### 6. Mejorar TrackingScreen

- [ ] Conectar con `trackingNotifierProvider`
- [ ] Botón Iniciar/Pausar tracking
- [ ] Mostrar en pantalla:
  - Estado del tracking (activo/pausado)
  - Lat/Lng actual
  - Batería
  - Última actualización
- [ ] Indicador visual de que está enviando

#### 7. Testing

- [ ] Verificar que se envían posiciones cada 30s
- [ ] Verificar que el backend las recibe correctamente
- [ ] Verificar que se disparan alerts ENTER/EXIT en backend

### ✅ Criterios de Aceptación:

- [ ] Al iniciar tracking, se obtienen permisos de ubicación
- [ ] Se envían posiciones + batería cada 30 segundos
- [ ] El backend recibe los datos y los guarda en `child_positions`
- [ ] En el admin/web se pueden ver los puntos en el mapa
- [ ] Se disparan alertas de geofence (ENTER/EXIT)
- [ ] La pantalla muestra info en tiempo real

---

## 🛰️ M4 – Background Tracking + Notificaciones

**Objetivo**: Tracking funciona con la app en background.

**Duración estimada**: 4-5 días

### 📝 Tareas:

#### 1. Background Service (Android)

Opción A: **WorkManager**
- [ ] Agregar `workmanager` al pubspec
- [ ] Crear `lib/core/background/`:
  - [ ] `background_tracking_service.dart`
  - [ ] Registrar tarea periódica cada 5-10 min

Opción B: **flutter_background_service**
- [ ] Más complejo pero más control
- [ ] Mejor para tracking continuo

#### 2. Background Location Permission

- [ ] Solicitar `ACCESS_BACKGROUND_LOCATION` en Android
- [ ] Explicar al usuario por qué se necesita
- [ ] Manejar permisos rechazados

#### 3. Local Notifications

- [ ] Configurar `flutter_local_notifications`
- [ ] Mostrar notificación permanente cuando tracking está activo
- [ ] Notificaciones de alertas críticas

#### 4. FCM Push Notifications

- [ ] Configurar manejo de mensajes en background
- [ ] Mostrar alertas cuando el backend envía EXIT crítico
- [ ] Navegación desde notificación

#### 5. Battery Optimization

- [ ] Ajustar intervalo según batería
- [ ] Pausar tracking si batería < 10%
- [ ] Notificar al padre si se pausó

### ✅ Criterios de Aceptación:

- [ ] Tracking continúa con pantalla apagada
- [ ] Se envían posiciones cada X minutos en background
- [ ] Hay una notificación permanente mostrando el tracking activo
- [ ] El padre recibe notificaciones push de alertas críticas
- [ ] Se optimiza consumo de batería

---

## 🗺️ M5 – Mapa en Tiempo Real (Padre)

**Objetivo**: Ver la ubicación de los hijos en un mapa interactivo.

**Duración estimada**: 3-4 días

### 📝 Tareas:

#### 1. Elegir librería de mapas

Opción A: **Google Maps**
- [ ] Agregar `google_maps_flutter`
- [ ] Configurar API key de Google Maps

Opción B: **OpenStreetMap (flutter_map)**
- [ ] Agregar `flutter_map`
- [ ] Más económico, sin API key

#### 2. Mapa en HomeParentScreen

- [ ] Agregar tab "Mapa" en el BottomNavigationBar
- [ ] Mostrar mapa centrado en los hijos
- [ ] Markers por cada hijo con:
  - Icono custom
  - Color según estado (dentro/fuera)
  - Info window con nombre y batería

#### 3. Polígonos de Geofences

- [ ] Obtener geofences desde backend
- [ ] Dibujar polígonos en el mapa
- [ ] Diferenciar colores por tipo de zona

#### 4. Actualización en Tiempo Real

- [ ] Refrescar posiciones cada 30s
- [ ] Animar movimiento del marker
- [ ] Mostrar ruta/trail de últimas posiciones

### ✅ Criterios de Aceptación:

- [ ] En el tab "Mapa" se ve un mapa interactivo
- [ ] Cada hijo tiene un marker con su ubicación actual
- [ ] Los geofences se dibujan como polígonos
- [ ] El mapa se actualiza automáticamente cada 30s
- [ ] Se puede hacer tap en un marker para ver detalles

---

## 📊 M6 – Historial y Reportes

**Objetivo**: Ver el historial de ubicaciones y generar reportes.

**Duración estimada**: 2-3 días

### 📝 Tareas:

- [ ] Tab "Historial" en HomeParentScreen
- [ ] Selector de fecha/rango
- [ ] Lista de eventos (ENTER, EXIT, alertas)
- [ ] Ver ruta del día en el mapa
- [ ] Exportar reporte en PDF o CSV

---

## 🔧 M7 – Ajustes y Mejoras

**Objetivo**: Pulir la app y agregar configuraciones.

### 📝 Tareas:

- [ ] Pantalla de perfil del padre
- [ ] Editar datos del hijo
- [ ] Configuración de notificaciones
- [ ] Cambio de contraseña
- [ ] Gestionar múltiples dispositivos por hijo
- [ ] Tutorial/onboarding inicial

---

## 🚀 M8 – Testing y Deploy

**Objetivo**: Preparar para producción.

### 📝 Tareas:

- [ ] Unit tests para repositories
- [ ] Widget tests para pantallas principales
- [ ] Integration tests
- [ ] Configurar CI/CD
- [ ] Build de release (APK/IPA)
- [ ] Subir a Play Store / App Store

---

## 📈 Prioridades

### 🔥 Crítico (Hacer YA):
1. **M1**: Login + Home Padre
2. **M2**: Registrar dispositivo hijo
3. **M3**: Tracking foreground

### 🎯 Importante (Siguiente):
4. **M4**: Background tracking
5. **M5**: Mapa tiempo real

### ✨ Nice to Have (Después):
6. **M6**: Historial
7. **M7**: Ajustes
8. **M8**: Deploy

---

## 🏁 ¿Por dónde empezar HOY?

### Sesión 1 (Hoy):
1. Implementar `DioClient` con interceptors
2. Crear `AuthRepository` y conectar login real
3. Probar login contra tu backend

### Sesión 2:
1. Implementar `ChildrenRepository`
2. Conectar `HomeParentScreen` con API `/children/my`
3. Mostrar lista de hijos desde backend

### Sesión 3:
1. Empezar M2: Registro de dispositivo
2. Implementar `DeviceRepository`
3. Crear pantalla de setup para modo hijo

---

**Nota**: Este plan es flexible y puede ajustarse según necesidades del proyecto.
