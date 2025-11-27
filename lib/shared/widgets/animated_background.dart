import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Estilos de fondo disponibles
enum BackgroundStyle {
  surface, // Gradiente de superficie (default)
  aurora, // Gradiente aurora (para auth)
}

/// Fondo animado con gradientes y partículas opcionales
/// Crea un efecto visual atractivo para pantallas de autenticación
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final BackgroundStyle style;
  final bool animated;
  final Duration animationDuration;
  final double intensity;
  final bool showParticles;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.style = BackgroundStyle.surface,
    this.animated = true,
    this.animationDuration = const Duration(seconds: 8),
    this.intensity = 0.7,
    this.showParticles = false,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Gradient _getGradient(bool isDark) {
    switch (widget.style) {
      case BackgroundStyle.surface:
        return isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0B1020), Color(0xFF0F172A)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE0E7FF), // Indigo 100 - azul muy claro
                  Color(0xFFF8FAFC), // Slate 50 - casi blanco
                  Color(0xFFFAF5FF), // Purple 50 - púrpura muy claro
                ],
                stops: [0.0, 0.5, 1.0],
              );
      case BackgroundStyle.aurora:
        return isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E1B4B),
                  Color(0xFF164E63),
                  Color(0xFF86198F),
                  Color(0xFF0F172A),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFDDD6FE), // Purple 200 - púrpura claro
                  Color(0xFFBFDBFE), // Blue 200 - azul claro
                  Color(0xFFF8FAFC), // Slate 50 - tirando a blanco
                  Color(0xFFFAF5FF), // Purple 50 - púrpura muy claro
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentGradient = _getGradient(isDark);
    final bool reduce = MediaQuery.of(context).disableAnimations;
    final bool shouldAnimate = widget.animated && !reduce;

    // Asegurar que el controller refleje el estado deseado
    if (shouldAnimate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldAnimate && _controller.isAnimating) {
      _controller.stop();
    }

    return Container(
      decoration: BoxDecoration(gradient: currentGradient),
      child: Stack(
        children: [
          // Capa de animación de gradiente
          if (shouldAnimate)
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        -1.0 + 2.0 * _rotationAnimation.value,
                        -1.0 + 2.0 * _rotationAnimation.value,
                      ),
                      radius: 2.0,
                      colors: [
                        currentGradient.colors.first.withValues(
                          alpha: widget.intensity * 0.3,
                        ),
                        currentGradient.colors.last.withValues(
                          alpha: widget.intensity * 0.1,
                        ),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                );
              },
            ),

          // Partículas flotantes (opcional)
          if (widget.showParticles) ..._buildParticles(),

          // Contenido principal
          widget.child,
        ],
      ),
    );
  }

  List<Widget> _buildParticles() {
    return List.generate(8, (index) {
      final delay = index * 200;
      return Positioned(
        left: 50.0 + (index * 40.0) % 300,
        top: 100.0 + (index * 80.0) % 600,
        child:
            Container(
                  width: 4.0 + (index % 3) * 2,
                  height: 4.0 + (index % 3) * 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .moveY(
                  delay: delay.ms,
                  duration: (3000 + index * 500).ms,
                  begin: 0,
                  end: -50,
                  curve: Curves.easeInOut,
                )
                .then()
                .moveY(
                  duration: (3000 + index * 500).ms,
                  begin: -50,
                  end: 0,
                  curve: Curves.easeInOut,
                )
                .fadeIn(delay: delay.ms, duration: 1000.ms)
                .then()
                .fadeOut(duration: 1000.ms),
      );
    });
  }
}

/// Fondo específico para pantalla de login/auth
class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      style: BackgroundStyle.aurora,
      animated: true,
      intensity: 0.8,
      showParticles: true,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.1),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.2),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}
