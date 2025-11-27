import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// Estado del formulario de login
class LoginFormState {
  final String email;
  final String password;
  final bool isPosting;
  final bool isFormPosted;
  final String? errorMessage;

  const LoginFormState({
    this.email = '',
    this.password = '',
    this.isPosting = false,
    this.isFormPosted = false,
    this.errorMessage,
  });

  /// Valida si el formulario tiene datos válidos
  bool get isValid =>
      email.trim().isNotEmpty && password.isNotEmpty && _isValidEmail(email);

  /// Valida formato de email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
  }

  /// Valida si el email tiene formato correcto
  String? get emailError {
    if (!isFormPosted) return null;
    if (email.trim().isEmpty) return 'El correo es requerido';
    if (!_isValidEmail(email)) return 'Ingresa un correo válido';
    return null;
  }

  /// Valida si el password está presente
  String? get passwordError {
    if (!isFormPosted) return null;
    if (password.isEmpty) return 'La contraseña es requerida';
    if (password.length < 4) return 'Mínimo 4 caracteres';
    return null;
  }

  /// Copia con nuevos valores
  LoginFormState copyWith({
    String? email,
    String? password,
    bool? isPosting,
    bool? isFormPosted,
    String? errorMessage,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier para manejar el estado del formulario de login
class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final Ref ref;

  LoginFormNotifier(this.ref) : super(const LoginFormState());

  /// Actualiza el email
  void onEmailChange(String value) {
    state = state.copyWith(email: value, errorMessage: null);
  }

  /// Actualiza el password
  void onPasswordChange(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  /// Envía el formulario
  Future<bool> onFormSubmit() async {
    // Marcar como enviado para mostrar errores
    state = state.copyWith(isFormPosted: true, errorMessage: null);

    // Validar formulario
    if (!state.isValid) {
      return false;
    }

    // Iniciar loading
    state = state.copyWith(isPosting: true);

    try {
      // Intentar login
      final success = await ref
          .read(authProvider.notifier)
          .loginUser(email: state.email.trim(), password: state.password);

      if (!success) {
        // Obtener mensaje de error del auth provider
        final authState = ref.read(authProvider);
        state = state.copyWith(
          isPosting: false,
          errorMessage: authState.errorMessage ?? 'Error al iniciar sesión',
        );
      } else {
        state = state.copyWith(isPosting: false);
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isPosting: false,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
      return false;
    }
  }

  /// Limpia el formulario
  void reset() {
    state = const LoginFormState();
  }
}

/// Provider del formulario de login
/// AutoDispose: se limpia cuando no hay listeners
final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
      return LoginFormNotifier(ref);
    });
