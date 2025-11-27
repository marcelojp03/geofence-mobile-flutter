# 🚀 Inicio Rápido - GeoKids Mobile

Guía de inicio para comenzar a desarrollar después del bootstrap.

---

## ✅ Estado Actual

El proyecto **M0 (Bootstrap)** está COMPLETO:

- ✅ Estructura de carpetas implementada
- ✅ Sistema de temas (claro/oscuro) con persistencia
- ✅ Router configurado con GoRouter
- ✅ Pantallas base creadas
- ✅ Todas las dependencias instaladas

---

## 🎯 Próximos Pasos - M1 (Login Real)

### 1️⃣ Configurar tu Backend

En `lib/config/env.dart`, cambia la URL del backend:

```dart
static const String baseUrl = 'http://TU_IP:3000/api';
// O si usas ngrok:
static const String baseUrl = 'https://tu-app.ngrok.io/api';
```

### 2️⃣ Crear DioClient (Core Layer)

Crea `lib/core/network/dio_client.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/env.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: Env.connectTimeout,
        receiveTimeout: Env.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor para añadir token automáticamente
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(Env.tokenKey);
          
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);
        },
        onError: (error, handler) {
          // Manejo de errores
          if (error.response?.statusCode == 401) {
            // Token inválido, hacer logout
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
```

### 3️⃣ Crear AuthRepository

Crea `lib/features/auth/data/repositories/auth_repository.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/env.dart';
import '../../../../core/network/dio_client.dart';

class AuthRepository {
  final DioClient _dioClient;

  AuthRepository(this._dioClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final accessToken = response.data['accessToken'];
      
      // Guardar token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Env.tokenKey, accessToken);

      return response.data;
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Env.tokenKey);
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(Env.tokenKey);
  }
}
```

### 4️⃣ Crear Providers de Auth

Crea `lib/features/auth/presentation/providers/auth_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/auth_repository.dart';

// Provider del DioClient
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

// Provider del AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRepository(dioClient);
});

// Estado de autenticación
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error ?? this.error,
    );
  }
}

// Notifier para manejar el estado de auth
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.login(email, password);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = AuthState();
  }

  Future<void> checkAuth() async {
    final isAuth = await _repository.isAuthenticated();
    state = state.copyWith(isAuthenticated: isAuth);
  }
}

// Provider del estado de auth
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
```

### 5️⃣ Conectar LoginScreen

Actualiza `lib/features/auth/presentation/login_screen.dart`:

```dart
// En la parte superior, agregar imports:
import '../providers/auth_provider.dart';

// En _LoginScreenState, reemplazar _handleLogin:
Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  final email = _emailController.text.trim();
  final password = _passwordController.text;

  await ref.read(authNotifierProvider.notifier).login(email, password);

  if (!mounted) return;

  final authState = ref.read(authNotifierProvider);
  
  if (authState.isAuthenticated) {
    context.go('/parent');
  } else if (authState.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(authState.error!),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// En el build, escuchar el estado:
@override
Widget build(BuildContext context) {
  final authState = ref.watch(authNotifierProvider);
  
  // ... resto del código
  
  // Reemplazar el botón de login:
  ElevatedButton(
    onPressed: authState.isLoading ? null : _handleLogin,
    child: authState.isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Text(
            'Iniciar Sesión',
            style: TextStyle(fontSize: 16),
          ),
  ),
}
```

### 6️⃣ Actualizar SplashScreen

En `lib/features/splash/presentation/splash_screen.dart`, reemplaza `_checkAuthAndNavigate`:

```dart
// Importar provider
import '../../auth/presentation/providers/auth_provider.dart';

Future<void> _checkAuthAndNavigate() async {
  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return;

  // Verificar si está autenticado
  await ref.read(authNotifierProvider.notifier).checkAuth();
  final authState = ref.read(authNotifierProvider);

  if (authState.isAuthenticated) {
    context.go('/parent');
  } else {
    context.go('/mode');
  }
}
```

---

## ✅ Verificar que Funciona

1. **Ejecutar la app**:
   ```bash
   flutter run
   ```

2. **Probar el flujo**:
   - Splash → Mode Selector
   - Click en "Soy Padre"
   - Login con credenciales de tu backend
   - Debe navegar a HomeParentScreen

3. **Verificar el token**:
   - Abre las DevTools de Flutter
   - Ve a la sección de SharedPreferences
   - Debe estar guardado `auth_token`

---

## 📱 Siguiente: Conectar Lista de Hijos

Una vez que el login funcione, el siguiente paso es:

1. Crear `ChildrenRepository` en `lib/features/parent/data/repositories/`
2. Hacer llamada a `GET /api/children/my`
3. Mostrar la lista real en `HomeParentScreen`

Ver `SPRINTS.md` para más detalles.

---

## 🐛 Troubleshooting

### Error de conexión

- Verifica que el backend esté corriendo
- Si usas emulador Android, usa `http://10.0.2.2:3000/api`
- Si usas device físico, usa la IP de tu PC

### Error 401 Unauthorized

- Verifica las credenciales
- Revisa que el endpoint sea `/auth/login`
- Verifica el formato de la respuesta del backend

### Token no se guarda

- Verifica que el backend devuelva `accessToken` en la respuesta
- Chequea la consola para ver errores de SharedPreferences

---

## 📚 Recursos

- [Documentación de Dio](https://pub.dev/packages/dio)
- [Riverpod Docs](https://riverpod.dev/)
- [GoRouter Guide](https://pub.dev/packages/go_router)

---

**¡Éxito con el desarrollo! 🚀**
