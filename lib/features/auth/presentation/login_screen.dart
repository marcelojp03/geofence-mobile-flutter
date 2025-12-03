import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_theme.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/widgets.dart';
// TODO: Descomentar cuando Firebase esté configurado
// import '../../notifications/providers/fcm_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/login_form_provider.dart';

/// Pantalla de login para padres
/// Con animaciones, glassmorphism y manejo de estados completo
class LoginScreen extends ConsumerWidget {
  static const String name = 'login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = context.responsive;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colores adaptativos
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.8)
        : Colors.black54;

    return GestureDetector(
      // Cerrar teclado al tocar fuera
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: AnimatedBackground(
        style: BackgroundStyle.surface,
        animated: true,
        intensity: 0.6,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.spacingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Botón de regreso
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () => context.go('/mode'),
                                icon: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: textColor,
                                ),
                              ),
                            ),

                            SizedBox(height: r.hp(2)),

                            // Logo / Icono
                            Center(
                              child: Hero(
                                tag: 'app_logo',
                                child: Container(
                                  padding: EdgeInsets.all(r.wp(6)),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.1),
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    size: r.dp(10),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: r.hp(3)),

                            // Título
                            Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: r.dp(3),
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: r.hp(1)),

                            // Subtítulo
                            Text(
                              'Ingresa tus datos para continuar',
                              style: TextStyle(
                                fontSize: r.dp(1.8),
                                color: subtitleColor,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: r.hp(3)),

                            // Formulario en GlassCard
                            const _LoginForm(),

                            SizedBox(height: r.hp(2)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Formulario de login con estado
class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm();

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final loginForm = ref.watch(loginFormProvider);
    final authState = ref.watch(authProvider);
    final r = context.responsive;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final linkColor = isDark ? Colors.white : AppTheme.primaryColor;

    // Listener para navegar cuando el login es exitoso
    ref.listen(authProvider, (previous, next) {
      // Limpiar errores al entrar
      if (previous == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(authProvider.notifier).clearError();
        });
      }

      // Login exitoso
      if (next.status == AuthStatus.authenticated &&
          previous?.status != next.status) {
        if (context.mounted) {
          _showSuccessDialog(context, r, isDark);
        }
      }
    });

    return GlassCard(
      padding: EdgeInsets.all(AppTheme.spacingLarge),
      borderRadius: AppTheme.borderRadiusLarge,
      child: Column(
        children: [
          // Mensajes de error
          _buildErrorMessage(authState, loginForm, r),

          // Email
          CustomInputField(
            label: 'Correo electrónico',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: ref.read(loginFormProvider.notifier).onEmailChange,
            errorMessage: loginForm.emailError,
            isFormPosted: loginForm.isFormPosted,
          ),

          SizedBox(height: r.hp(2.5)),

          // Contraseña
          CustomInputField(
            label: 'Contraseña',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onChanged: ref.read(loginFormProvider.notifier).onPasswordChange,
            errorMessage: loginForm.passwordError,
            isFormPosted: loginForm.isFormPosted,
            onFieldSubmitted: (_) => _handleSubmit(),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              splashRadius: 20,
              tooltip: _obscurePassword
                  ? 'Mostrar contraseña'
                  : 'Ocultar contraseña',
            ),
          ),

          SizedBox(height: r.hp(4)),

          // Botón de login
          CustomFilledButton(
            text: 'Iniciar sesión',
            isLoading: loginForm.isPosting,
            onPressed: loginForm.isPosting ? null : _handleSubmit,
            buttonColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  /// Construye el mensaje de error si existe
  Widget _buildErrorMessage(
    AuthState authState,
    LoginFormState loginForm,
    Responsive r,
  ) {
    final errorMessage = authState.errorMessage ?? loginForm.errorMessage;

    if (errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppTheme.spacingNormal),
      margin: EdgeInsets.only(bottom: AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.errorColorLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
        border: Border.all(
          color: AppTheme.errorColorLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColorLight,
            size: r.dp(2.2),
          ),
          SizedBox(width: r.wp(2)),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: AppTheme.errorColorLight,
                fontSize: r.dp(1.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Maneja el envío del formulario
  Future<void> _handleSubmit() async {
    // Cerrar teclado
    FocusManager.instance.primaryFocus?.unfocus();

    // Enviar formulario
    await ref.read(loginFormProvider.notifier).onFormSubmit();
  }

  /// Muestra diálogo de éxito y navega al home
  void _showSuccessDialog(BuildContext context, Responsive r, bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingLarge),
          child: GlassCard(
            padding: EdgeInsets.all(AppTheme.spacingLarge),
            borderRadius: AppTheme.borderRadiusLarge,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(r.wp(4)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.insideColor.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppTheme.insideColor,
                    size: r.dp(6),
                  ),
                ),
                SizedBox(height: AppTheme.spacingMedium),
                Text(
                  'Acceso Autorizado',
                  style: TextStyle(
                    fontSize: r.dp(2.2),
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppTheme.spacingSmall),
                Text(
                  'Sesión iniciada correctamente.\nRedirigiendo...',
                  style: TextStyle(
                    fontSize: r.dp(1.6),
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Navegar después del delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Cerrar dialog

      // TODO: Descomentar cuando Firebase esté configurado
      // Registrar FCM token en el backend (no bloqueante)
      // ref.read(fcmTokenNotifierProvider.notifier).registerToken();

      context.go('/parent');
    });
  }
}
