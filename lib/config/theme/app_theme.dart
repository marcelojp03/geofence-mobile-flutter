import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema principal de la aplicación Geofence
class AppTheme {
  // ===== Colores de marca =====
  static const Color primaryColor = Color(0xFF6366F1); // Indigo vibrante
  static const Color secondaryColor = Color(0xFF8B5CF6); // Purple elegante
  static const Color accentColor = Color(0xFF06B6D4); // Cyan para acentos
  static const Color errorColor = Color(0xFFDC2626); // Rojo accesible

  // Colores de estado para geofence
  static const Color insideColor = Color(0xFF10B981); // Verde esmeralda
  static const Color outsideColor = Color(0xFFEF4444); // Rojo coral
  static const Color warningColor = Color(0xFFF59E0B); // Ámbar
  static const Color infoColor = Color(0xFF3B82F6); // Azul info
  static const Color noSignalColor = Color(0xFF6B7280); // Gris neutro

  // Colores de estado en modo claro
  static const Color successColorLight = Color(0xFF34D399);
  static const Color warningColorLight = Color(0xFFFBBF24);
  static const Color infoColorLight = Color(0xFF60A5FA);
  static const Color errorColorLight = Color(0xFFF87171);

  // Texto sobre estados
  static const Color onSuccessLight = Color(0xFF064E3B);
  static const Color onWarningLight = Color(0xFF92400E);
  static const Color onInfoLight = Color(0xFF1E40AF);
  static const Color onErrorLight = Color(0xFFFFFFFF);

  // Superficies
  static const Color surfaceLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceCardLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceCardDark = Color(0xFF1E293B); // Slate 800

  // ===== Tema claro =====
  static ThemeData lightTheme() {
    return FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: primaryColor,
        primaryContainer: Color(0xFFE0E7FF),
        secondary: secondaryColor,
        secondaryContainer: Color(0xFFF3E8FF),
        tertiary: accentColor,
        tertiaryContainer: Color(0xFFCFFAFE),
        error: errorColor,
      ),
      useMaterial3: true,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 4,
      visualDensity: VisualDensity.standard,
      scaffoldBackground: surfaceLight,
      surface: surfaceCardLight,
      appBarStyle: FlexAppBarStyle.primary,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 8,
        blendOnColors: false,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        // Navigation bar
        bottomNavigationBarMutedUnselectedLabel: false,
        bottomNavigationBarMutedUnselectedIcon: false,
        bottomNavigationBarShowSelectedLabels: true,
        bottomNavigationBarShowUnselectedLabels: true,
        bottomNavigationBarType: BottomNavigationBarType.fixed,
        bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
        // Border radius - más suaves y modernos
        cardRadius: 16.0,
        elevatedButtonRadius: 12.0,
        filledButtonRadius: 12.0,
        outlinedButtonRadius: 12.0,
        textButtonRadius: 12.0,
        inputDecoratorRadius: 12.0,
        fabRadius: 16.0,
        chipRadius: 10.0,
        dialogRadius: 20.0,
        timePickerDialogRadius: 20.0,
        snackBarRadius: 10.0,
        // Input fields
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorUnfocusedHasBorder: true,
        inputDecoratorFocusedHasBorder: true,
        inputDecoratorBorderWidth: 1.5,
        inputDecoratorFocusedBorderWidth: 2.0,
        // Tabs
        tabBarIndicatorWeight: 3.0,
        tabBarIndicatorTopRadius: 3.0,
        tabBarDividerColor: Colors.transparent,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
        keepPrimary: true,
      ),
      textTheme: _buildTextTheme(Brightness.light),
      primaryTextTheme: _buildTextTheme(Brightness.light),
    );
  }

  // ===== Tema oscuro =====
  static ThemeData darkTheme() {
    return FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primary: Color(0xFF818CF8), // Indigo más claro para dark
        primaryContainer: Color(0xFF4338CA),
        secondary: Color(0xFFA78BFA), // Purple más claro
        secondaryContainer: Color(0xFF6B21A8),
        tertiary: Color(0xFF22D3EE), // Cyan más brillante
        tertiaryContainer: Color(0xFF0E7490),
        error: Color(0xFFFCA5A5),
      ),
      useMaterial3: true,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 10,
      visualDensity: VisualDensity.standard,
      scaffoldBackground: surfaceDark,
      surface: surfaceCardDark,
      appBarStyle: FlexAppBarStyle.background,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 15,
        blendOnColors: false,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        // Navigation bar
        bottomNavigationBarMutedUnselectedLabel: false,
        bottomNavigationBarMutedUnselectedIcon: false,
        bottomNavigationBarShowSelectedLabels: true,
        bottomNavigationBarShowUnselectedLabels: true,
        bottomNavigationBarType: BottomNavigationBarType.fixed,
        bottomNavigationBarBackgroundSchemeColor: SchemeColor.surface,
        bottomNavigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
        bottomNavigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
        // Border radius
        cardRadius: 16.0,
        elevatedButtonRadius: 12.0,
        filledButtonRadius: 12.0,
        outlinedButtonRadius: 12.0,
        textButtonRadius: 12.0,
        inputDecoratorRadius: 12.0,
        fabRadius: 16.0,
        chipRadius: 10.0,
        dialogRadius: 20.0,
        timePickerDialogRadius: 20.0,
        snackBarRadius: 10.0,
        // Input fields
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorUnfocusedHasBorder: true,
        inputDecoratorFocusedHasBorder: true,
        inputDecoratorBorderWidth: 1.5,
        inputDecoratorFocusedBorderWidth: 2.0,
        // Tabs
        tabBarIndicatorWeight: 3.0,
        tabBarIndicatorTopRadius: 3.0,
        tabBarDividerColor: Colors.transparent,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
        keepPrimary: true,
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      primaryTextTheme: _buildTextTheme(Brightness.dark),
    );
  }

  /// Construye el tema de texto con Inter optimizado
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    return GoogleFonts.interTextTheme(baseTheme).copyWith(
      // Display - para títulos grandes
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      // Headlines
      headlineLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      // Titles
      titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      // Body - más pequeño y legible
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ),
      // Labels
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );
  }

  // ===== Constantes de diseño =====
  // Spacing - sistema de 4px
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // Legacy spacing (mantener compatibilidad)
  static const double spacingSmall = 8.0;
  static const double spacingNormal = 12.0;
  static const double spacingMedium = 20.0;
  static const double spacingLarge = 32.0;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusFull = 999.0;

  // Legacy radius (mantener compatibilidad)
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusNormal = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusPremium = 20.0;

  // Shadows
  static List<BoxShadow> shadowSmall(bool isDark) => [
    BoxShadow(
      color: isDark
          ? Colors.black.withOpacity(0.3)
          : Colors.black.withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMedium(bool isDark) => [
    BoxShadow(
      color: isDark
          ? Colors.black.withOpacity(0.4)
          : Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLarge(bool isDark) => [
    BoxShadow(
      color: isDark
          ? Colors.black.withOpacity(0.5)
          : Colors.black.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // Durations para animaciones
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationVerySlow = Duration(milliseconds: 600);

  // Curves
  static const Curve curveDefault = Curves.easeOutCubic;
  static const Curve curveEmphasized = Curves.easeInOutCubic;
  static const Curve curveSpring = Curves.elasticOut;
}
