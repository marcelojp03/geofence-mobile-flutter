import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/env.dart';
import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';
import 'core/services/analytics_service.dart';
import 'core/services/notification_service.dart';
import 'features/child_mode/background/background_tracking_service.dart';
import 'features/child_mode/background/foreground_tracking_service.dart';
import 'shared/providers/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar variables de entorno
  await Env.init();

  // Inicializar Firebase con opciones desde variables de entorno
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: Env.firebaseApiKey,
      appId: Env.firebaseAppId,
      messagingSenderId: Env.firebaseMessagingSenderId,
      projectId: Env.firebaseProjectId,
      storageBucket: Env.firebaseStorageBucket,
    ),
  );

  // Registrar evento de app iniciada en Analytics
  AnalyticsService().logScreenView(screenName: 'app_launch');

  // Inicializar servicio de notificaciones
  await NotificationService().init();

  // Inicializar WorkManager para background tracking (backup)
  await BackgroundTrackingService().init();

  // Inicializar Foreground Service para tracking confiable
  await ForegroundTrackingService().init();

  runApp(const ProviderScope(child: MainApp()));
}

/// Widget principal de la aplicación
class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Leer el estado del tema desde Riverpod
    final isDarkMode = ref.watch(themeNotifierProvider);

    // Configuración de orientación (solo portrait en móviles)
    final media = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    );
    final shortestSide = media.size.shortestSide;
    final isTablet = shortestSide >= 600;
    final isMobilePlatform =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;

    if (isMobilePlatform && !isTablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }

    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Geofence',
      debugShowCheckedModeBanner: false,

      // Configuración de tema
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),

      // Builder para deshabilitar animaciones si es necesario
      builder: (context, child) {
        final data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(disableAnimations: false),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
