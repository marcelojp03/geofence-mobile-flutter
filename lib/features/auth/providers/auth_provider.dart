import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/analytics_service.dart';
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
      final isValid = await _repository.checkSession();
      if (isValid) {
        // Obtener datos del usuario
        final response = await _repository.getProfile();
        if (response.isSuccess && response.data != null) {
          state = AuthState.authenticated(response.data!);
          return;
        }
      }
      state = AuthState.unauthenticated();
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
        state = AuthState.authenticated(loginData.user);

        // Analytics: registrar login exitoso
        final analytics = AnalyticsService();
        await analytics.logLogin(method: 'email');
        await analytics.setUserId(loginData.user.id.toString());
        await analytics.setUserRole(loginData.user.role.name);

        return true;
      } else {
        state = AuthState.unauthenticated(response.message);
        return false;
      }
    } catch (e) {
      state = AuthState.unauthenticated('Error inesperado: ${e.toString()}');
      return false;
    }
  }

  /// Registra un nuevo usuario
  Future<bool> register({
    required int schoolId,
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      state = state.copyWith(errorMessage: null);

      final response = await _repository.register(
        schoolId: schoolId,
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      if (response.isSuccess) {
        // Después de registrar, hacer login automático
        return await loginUser(email: email, password: password);
      } else {
        state = AuthState.unauthenticated(response.message);
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

      // Analytics: registrar logout
      final analytics = AnalyticsService();
      await analytics.logLogout();
      await analytics.setUserId(null);

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

/// Provider para obtener el usuario actual
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

/// Provider para verificar si está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
