import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';
import 'shared/providers/theme_notifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'GeoKids',
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
