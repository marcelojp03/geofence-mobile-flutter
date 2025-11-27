# ✅ Checklist del Proyecto GeoKids Mobile

---

## 📋 M0 - Bootstrap (COMPLETADO)

### Estructura de Proyecto
- [x] Proyecto Flutter creado
- [x] Estructura de carpetas implementada
- [x] Carpeta `config/` con env, router, theme
- [x] Carpeta `core/` preparada para servicios
- [x] Carpeta `shared/` con providers y widgets
- [x] Carpeta `features/` con módulos por funcionalidad

### Configuración
- [x] `env.dart` creado con variables de entorno
- [x] `app_theme.dart` con temas claro y oscuro
- [x] `theme_notifier.dart` con persistencia
- [x] `app_router.dart` con GoRouter configurado
- [x] `main.dart` actualizado con Riverpod

### Dependencias
- [x] flutter_riverpod instalado
- [x] go_router instalado
- [x] dio instalado
- [x] geolocator instalado
- [x] device_info_plus instalado
- [x] battery_plus instalado
- [x] shared_preferences instalado
- [x] firebase_core instalado
- [x] firebase_messaging instalado
- [x] flutter_local_notifications instalado
- [x] permission_handler instalado
- [x] Todas las dependencias sin conflictos

### Pantallas
- [x] SplashScreen creada
- [x] ModeSelectorScreen creada
- [x] LoginScreen creada
- [x] HomeParentScreen creada con 4 tabs
- [x] TrackingScreen creada

### Testing
- [x] Test básico actualizado
- [x] App compila sin errores
- [x] Solo warnings menores de estilo

### Documentación
- [x] README.md creado
- [x] SPRINTS.md con plan completo
- [x] QUICKSTART.md con guía de inicio
- [x] RESUMEN.md con estado actual
- [x] CHECKLIST.md (este archivo)

---

## 🔄 M1 - Login + Home Básico (EN PROGRESO)

### Core - Networking
- [ ] Crear `lib/core/network/dio_client.dart`
- [ ] Implementar interceptor de autenticación
- [ ] Implementar interceptor de logging
- [ ] Manejar errores de red (401, 500, timeout)

### Auth - Data Layer
- [ ] Crear `lib/features/auth/data/models/user_model.dart`
- [ ] Crear `lib/features/auth/data/models/token_pair_model.dart`
- [ ] Crear `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- [ ] Crear `lib/features/auth/data/repositories/auth_repository_impl.dart`
- [ ] Implementar `login(email, password)`
- [ ] Implementar `logout()`
- [ ] Implementar `isAuthenticated()`

### Auth - Presentation Layer
- [ ] Crear `lib/features/auth/presentation/providers/auth_provider.dart`
- [ ] Crear `AuthState` class
- [ ] Crear `AuthNotifier` class
- [ ] Crear providers (dioClient, authRepository, authNotifier)

### Auth - UI
- [ ] Conectar LoginScreen con authNotifierProvider
- [ ] Manejar estados de loading
- [ ] Mostrar errores al usuario
- [ ] Navegar al home al login exitoso
- [ ] Guardar token en SharedPreferences

### SplashScreen
- [ ] Verificar autenticación al iniciar
- [ ] Navegar a `/parent` si hay token válido
- [ ] Navegar a `/mode` si no hay token

### Parent - Data Layer
- [ ] Crear `lib/features/parent/data/models/child_model.dart`
- [ ] Crear `lib/features/parent/data/datasources/children_remote_datasource.dart`
- [ ] Crear `lib/features/parent/data/repositories/children_repository_impl.dart`
- [ ] Implementar `getMyChildren()`

### Parent - Presentation
- [ ] Crear `lib/features/parent/presentation/providers/children_provider.dart`
- [ ] Conectar HomeParentScreen con API
- [ ] Mostrar lista real de hijos
- [ ] Implementar pull to refresh
- [ ] Mostrar estado (dentro/fuera)
- [ ] Mostrar batería
- [ ] Mostrar última actualización

### Testing M1
- [ ] Probar login con credenciales válidas
- [ ] Probar login con credenciales inválidas
- [ ] Verificar que se guarda el token
- [ ] Verificar navegación automática con token
- [ ] Verificar lista de hijos desde backend
- [ ] Probar pull to refresh

---

## 📱 M2 - Registrar Dispositivo (PENDIENTE)

### Device - Data Layer
- [ ] Crear `lib/features/device/data/models/device_model.dart`
- [ ] Crear `lib/features/device/data/datasources/device_remote_datasource.dart`
- [ ] Crear `lib/features/device/data/repositories/device_repository_impl.dart`

### Device Utils
- [ ] Crear `lib/core/utils/device_utils.dart`
- [ ] Implementar `getOrCreateDeviceUid()`
- [ ] Implementar `getDeviceInfo()`

### Firebase Setup
- [ ] Descargar `google-services.json` (Android)
- [ ] Configurar en `android/app/`
- [ ] Descargar `GoogleService-Info.plist` (iOS)
- [ ] Configurar en `ios/Runner/`
- [ ] Crear `lib/core/notifications/fcm_service.dart`
- [ ] Implementar `getFcmToken()`

### Child Setup Screen
- [ ] Crear `lib/features/child_mode/presentation/child_setup_screen.dart`
- [ ] Obtener/generar deviceUid
- [ ] Obtener info del dispositivo
- [ ] Obtener fcmToken
- [ ] Registrar dispositivo en backend
- [ ] Mostrar código/QR para vincular

### Linking
- [ ] Implementar flujo de vinculación con código
- [ ] O implementar scanner de QR
- [ ] Llamar a `/devices/link`

---

## 📍 M3 - Tracking Foreground (PENDIENTE)

### Permisos
- [ ] Crear `lib/core/permissions/location_permission_handler.dart`
- [ ] Solicitar permisos de ubicación
- [ ] Manejar permisos denegados

### Location Service
- [ ] Crear `lib/core/location/location_service.dart`
- [ ] Implementar `getCurrentPosition()`
- [ ] Implementar `getPositionStream()`

### Battery Service
- [ ] Crear `lib/core/device/battery_service.dart`
- [ ] Implementar `getBatteryLevel()`
- [ ] Implementar `getBatteryStream()`

### Tracking - Data Layer
- [ ] Crear `lib/features/tracking/data/models/position_model.dart`
- [ ] Crear `lib/features/tracking/data/datasources/tracking_remote_datasource.dart`
- [ ] Crear `lib/features/tracking/data/repositories/tracking_repository_impl.dart`
- [ ] Implementar `sendPosition()`

### Tracking - Presentation
- [ ] Crear `lib/features/tracking/presentation/providers/tracking_provider.dart`
- [ ] Implementar `startTracking()`
- [ ] Implementar `stopTracking()`
- [ ] Enviar posición cada 30 segundos

### TrackingScreen Updates
- [ ] Conectar con trackingNotifierProvider
- [ ] Mostrar lat/lng en tiempo real
- [ ] Mostrar batería en tiempo real
- [ ] Botón para iniciar/pausar tracking
- [ ] Indicador visual de estado

### Testing M3
- [ ] Verificar que se piden permisos
- [ ] Verificar que se obtiene ubicación
- [ ] Verificar que se envía al backend cada 30s
- [ ] Verificar en admin/web que se ven los puntos
- [ ] Verificar que se disparan alertas ENTER/EXIT

---

## 🛰️ M4 - Background Tracking (PENDIENTE)

### Background Service
- [ ] Agregar `workmanager` o `flutter_background_service`
- [ ] Crear `lib/core/background/background_tracking_service.dart`
- [ ] Registrar tarea periódica

### Permisos Background
- [ ] Solicitar `ACCESS_BACKGROUND_LOCATION` (Android)
- [ ] Explicar al usuario por qué se necesita

### Notificaciones
- [ ] Configurar `flutter_local_notifications`
- [ ] Notificación permanente cuando tracking activo
- [ ] Notificaciones de alertas críticas

### FCM Push
- [ ] Manejar mensajes en background
- [ ] Mostrar alertas desde backend
- [ ] Navegación desde notificación

---

## 🗺️ M5 - Mapa Tiempo Real (PENDIENTE)

### Maps Setup
- [ ] Elegir librería (Google Maps o OpenStreetMap)
- [ ] Configurar API key si es Google Maps
- [ ] Agregar dependencia

### Map Screen
- [ ] Agregar tab "Mapa" en HomeParentScreen
- [ ] Mostrar mapa centrado en hijos
- [ ] Markers por cada hijo
- [ ] Info window con detalles

### Geofences
- [ ] Obtener geofences desde backend
- [ ] Dibujar polígonos en mapa
- [ ] Diferenciar colores por tipo

### Updates en Tiempo Real
- [ ] Refrescar posiciones cada 30s
- [ ] Animar movimiento de markers
- [ ] Mostrar trail de ubicaciones

---

## 📊 M6 - Historial (PENDIENTE)

- [ ] Tab "Historial" funcional
- [ ] Selector de fecha/rango
- [ ] Lista de eventos
- [ ] Ver ruta del día en mapa
- [ ] Exportar reporte

---

## 🔧 M7 - Ajustes (PENDIENTE)

- [ ] Pantalla de perfil
- [ ] Editar datos del hijo
- [ ] Configuración de notificaciones
- [ ] Cambio de contraseña
- [ ] Gestión de dispositivos
- [ ] Tutorial/onboarding

---

## 🚀 M8 - Deploy (PENDIENTE)

- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] CI/CD configurado
- [ ] Build release APK
- [ ] Build release IPA
- [ ] Subir a Play Store
- [ ] Subir a App Store

---

## 📈 Progreso General

```
█████████░░░░░░░░░░░░░░░░ 30% Completado

M0: ████████████████████ 100%
M1: ░░░░░░░░░░░░░░░░░░░░   0%
M2: ░░░░░░░░░░░░░░░░░░░░   0%
M3: ░░░░░░░░░░░░░░░░░░░░   0%
M4: ░░░░░░░░░░░░░░░░░░░░   0%
M5: ░░░░░░░░░░░░░░░░░░░░   0%
M6: ░░░░░░░░░░░░░░░░░░░░   0%
M7: ░░░░░░░░░░░░░░░░░░░░   0%
M8: ░░░░░░░░░░░░░░░░░░░░   0%
```

---

## 🎯 Siguiente Tarea

**Implementar M1 - Login Real**

1. Abrir `QUICKSTART.md`
2. Copiar código de `DioClient`
3. Crear `AuthRepository`
4. Crear providers de Auth
5. Conectar LoginScreen
6. ¡Probar!

---

_Última actualización: Sprint M0 completado - Noviembre 2025_
