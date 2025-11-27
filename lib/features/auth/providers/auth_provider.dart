import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../domain/entities/entities.dart';

/// Estados posibles de autenticación
enum AuthStatus {
  checking, // Verificando sesión inicial
  authenticated, // Usuario autenticado
  unauthenticated, // Sin sesión
}

/// Estado de autenticación
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.checking,
    this.user,
    this.errorMessage,
  });

  /// Estado inicial
  factory AuthState.initial() => const AuthState(status: AuthStatus.checking);

  /// Estado autenticado
  factory AuthState.authenticated(User user) =>
      AuthState(status: AuthStatus.authenticated, user: user);

  /// Estado no autenticado
  factory AuthState.unauthenticated([String? error]) =>
      AuthState(status: AuthStatus.unauthenticated, errorMessage: error);

  /// Copia con nuevos valores
  AuthState copyWith({AuthStatus? status, User? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  /// Helpers
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isChecking => status == AuthStatus.checking;
  bool get hasError => errorMessage != null;

  @override
  String toString() =>
      'AuthState(status: $status, user: $user, error: $errorMessage)';
}

/// Notifier para manejar el estado de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState.initial()) {
    // Verificar sesión al iniciar
    checkAuthStatus();
  }

  /// Verifica si hay una sesión activa
  Future<void> checkAuthStatus() async {
    try {
      final isAuth = await _repository.isAuthenticated();
      if (isAuth) {
        // TODO: En producción, validar token con el servidor y obtener datos del usuario
        // Por ahora, solo marcamos como no autenticado si no hay token
        // Podrías guardar los datos del usuario en SharedPreferences
        state = AuthState.unauthenticated();
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.unauthenticated();
    }
  }

  /// Inicia sesión
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      // Limpiar error previo
      state = state.copyWith(errorMessage: null);

      final response = await _repository.login(
        email: email,
        password: password,
      );

      if (response.isSuccess && response.data != null) {
        final loginData = response.data!;

        // Crear usuario desde la respuesta
        final user = User(
          id: loginData.userId ?? '',
          email: loginData.email,
          nombres: loginData.nombres,
          apellidoP: loginData.apellidoP,
          apellidoM: loginData.apellidoM,
          token: loginData.token,
        );

        state = AuthState.authenticated(user);
        return true;
      } else {
        state = AuthState.unauthenticated(response.mensaje);
        return false;
      }
    } catch (e) {
      state = AuthState.unauthenticated('Error inesperado: ${e.toString()}');
      return false;
    }
  }

  /// Cierra sesión
  Future<void> logout() async {
    try {
      await _repository.logout();
      state = AuthState.unauthenticated();
    } catch (e) {
      // Aún así cerrar sesión localmente
      state = AuthState.unauthenticated();
    }
  }

  /// Limpia el mensaje de error
  void clearError() {
    if (state.hasError) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

/// Provider del repositorio de auth
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider principal de autenticación
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
