import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../auth/data/auth_repository.dart';
import '../../child_mode/data/child_mode_storage.dart';

/// Pantalla de splash inicial
class SplashScreen extends ConsumerStatefulWidget {
  static const String name = 'splash';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Esperar un momento para mostrar el splash
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // 1. Verificar si el modo hijo está configurado
    final childModeStorage = ChildModeStorage();
    final isChildModeConfigured = await childModeStorage.isConfigured();
    developer.log(
      'Child mode configured: $isChildModeConfigured',
      name: 'Splash',
    );

    if (isChildModeConfigured) {
      // Ya está configurado como dispositivo de hijo
      developer.log('Navigating to /child/tracking', name: 'Splash');
      context.go('/child/tracking');
      return;
    }

    // 2. Verificar si hay sesión de padre activa
    final authRepository = AuthRepository();
    final isAuthenticated = await authRepository.isAuthenticated();
    developer.log('Parent authenticated: $isAuthenticated', name: 'Splash');

    if (isAuthenticated) {
      // Verificar que el token siga siendo válido
      final profileResponse = await authRepository.getProfile();
      developer.log(
        'Profile response success: ${profileResponse.success}',
        name: 'Splash',
      );
      if (profileResponse.success) {
        developer.log('Navigating to /parent', name: 'Splash');
        context.go('/parent');
        return;
      }
      // Si el token expiró, limpiar y mostrar selector
      await authRepository.logout();
    }

    // 3. No hay configuración previa, mostrar selector de modo
    developer.log('Navigating to /mode', name: 'Splash');
    context.go('/mode');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'Geofence',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Seguridad para tus hijos',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
