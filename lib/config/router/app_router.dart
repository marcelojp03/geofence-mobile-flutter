import 'package:go_router/go_router.dart';
import 'package:geofence_mobile_flutter/features/splash/presentation/splash_screen.dart';
import 'package:geofence_mobile_flutter/features/mode_selector/presentation/mode_selector_screen.dart';
import 'package:geofence_mobile_flutter/features/auth/presentation/login_screen.dart';
import 'package:geofence_mobile_flutter/features/parent/presentation/home_parent_screen.dart';
import 'package:geofence_mobile_flutter/features/child_mode/presentation/tracking_screen.dart';

/// Router principal de la aplicación
final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash inicial
    GoRoute(
      path: '/splash',
      name: SplashScreen.name,
      builder: (context, state) => const SplashScreen(),
    ),

    // Selector de modo (Padre/Hijo)
    GoRoute(
      path: '/mode',
      name: ModeSelectorScreen.name,
      builder: (context, state) => const ModeSelectorScreen(),
    ),

    // Login para padres
    GoRoute(
      path: '/login',
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen(),
    ),

    // Home del padre
    GoRoute(
      path: '/parent',
      name: HomeParentScreen.name,
      builder: (context, state) => const HomeParentScreen(),
    ),

    // Modo hijo - Tracking
    GoRoute(
      path: '/child/setup',
      name: 'child-setup',
      builder: (context, state) => const TrackingScreen(),
    ),
  ],
);
