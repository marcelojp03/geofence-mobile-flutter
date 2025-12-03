import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/app_theme.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/widgets.dart';

/// Pantalla para seleccionar el modo de la aplicación
class ModeSelectorScreen extends ConsumerWidget {
  static const String name = 'mode';

  const ModeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = context.responsive;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return AnimatedBackground(
      style: BackgroundStyle.surface,
      animated: true,
      intensity: 0.6,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo / Icono
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    padding: EdgeInsets.all(r.wp(6)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.family_restroom,
                      size: r.dp(8),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                SizedBox(height: r.hp(3)),

                // Título
                Text(
                  '¿Cómo vas a usar la app?',
                  style: TextStyle(
                    fontSize: r.dp(2.8),
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: r.hp(1)),

                Text(
                  'Selecciona el modo según tu rol',
                  style: TextStyle(fontSize: r.dp(1.7), color: subtitleColor),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: r.hp(5)),

                // Tarjeta Modo Padre
                _ModeCard(
                  icon: Icons.supervisor_account,
                  title: 'Soy Padre/Madre',
                  subtitle: 'Monitorea la ubicación de tus hijos',
                  isPrimary: true,
                  onTap: () => context.go('/login'),
                ),

                SizedBox(height: r.hp(2)),

                // Tarjeta Modo Hijo
                _ModeCard(
                  icon: Icons.phone_android,
                  title: 'Celular de mi hijo/a',
                  subtitle: 'Configura este dispositivo como rastreador',
                  isPrimary: false,
                  onTap: () => context.go('/child/setup'),
                ),

                SizedBox(height: r.hp(4)),

                // Nota
                Text(
                  'Puedes cambiar esto más tarde en la configuración',
                  style: TextStyle(fontSize: r.dp(1.4), color: subtitleColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta de selección de modo con glassmorphism
class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.all(r.wp(5)),
      borderRadius: AppTheme.borderRadiusLarge,
      backgroundColor: isPrimary
          ? primaryColor.withValues(alpha: isDark ? 0.2 : 0.1)
          : null,
      borderColor: isPrimary ? primaryColor.withValues(alpha: 0.3) : null,
      child: Row(
        children: [
          // Icono
          Container(
            padding: EdgeInsets.all(r.wp(3)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPrimary
                  ? primaryColor.withValues(alpha: 0.2)
                  : (isDark
                        ? Colors.white12
                        : Colors.black.withValues(alpha: 0.05)),
            ),
            child: Icon(
              icon,
              size: r.dp(3.5),
              color: isPrimary
                  ? primaryColor
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
          ),

          SizedBox(width: r.wp(4)),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: r.dp(2),
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: r.hp(0.5)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: r.dp(1.5),
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Flecha
          Icon(
            Icons.arrow_forward_ios,
            size: r.dp(2),
            color: isDark ? Colors.white38 : Colors.black26,
          ),
        ],
      ),
    );
  }
}
