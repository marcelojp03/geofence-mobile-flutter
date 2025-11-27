import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema principal de la aplicación GeoKids
class AppTheme {
  // ===== Colores de marca (Geofencing) =====
  static const Color primaryColor = Color(0xFF6366F1); // Indigo (principal)
  static const Color secondaryColor = Color(0xFF8B5CF6); // Purple
  static const Color errorColor = Color(0xFFB00020); // Error accesible

  // Colores de estado para geofence
  static const Color insideColor = Color(0xFF22C55E); // Verde (dentro)
  static const Color outsideColor = Color(0xFFEF4444); // Rojo (fuera)
  static const Color warningColor = Color(0xFFF59E0B); // Naranja (alerta)
  static const Color infoColor = Color(0xFF3B82F6); // Azul (info)

  // Colores de estado en modo claro
  static const Color successColorLight = Color(0xFF4ADE80);
  static const Color warningColorLight = Color(0xFFFBBF24);
  static const Color infoColorLight = Color(0xFF60A5FA);
  static const Color errorColorLight = Color(0xFFF87171);

  // Texto sobre estados
  static const Color onSuccessLight = Color(0xFF064E3B);
  static const Color onWarningLight = Color(0xFF92400E);
  static const Color onInfoLight = Color(0xFF0B3C7C);
  static const Color onErrorLight = Color(0xFFFFFFFF);

  // Superficies
  static const Color surfaceLight = Color(0xFFF9FAFB); // Gris muy claro
  static const Color surfaceCardLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF0B1220); // Azul-neutro oscuro
  static const Color surfaceCardDark = Color(0xFF121826);

  // ===== Tema claro =====
  static ThemeData lightTheme() {
    return FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: primaryColor,
        primaryContainer: Color(0xFFE0E7FF), // Indigo claro
        secondary: secondaryColor,
        secondaryContainer: Color(0xFFF3E8FF), // Purple claro
        tertiary: insideColor, // Verde para estados positivos
        tertiaryContainer: Color(0xFFD1FAE5), // Verde claro
        error: errorColor,
      ),
      useMaterial3: true,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 6,
      visualDensity: VisualDensity.standard,
      scaffoldBackground: surfaceLight,
      surface: surfaceCardLight,
      appBarStyle: FlexAppBarStyle.primary,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
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
        cardRadius: 14.0,
        elevatedButtonRadius: 12.0,
        filledButtonRadius: 12.0,
        outlinedButtonRadius: 12.0,
        textButtonRadius: 12.0,
        inputDecoratorRadius: 10.0,
        fabRadius: 16.0,
        chipRadius: 8.0,
        dialogRadius: 18.0,
        timePickerDialogRadius: 18.0,
        snackBarRadius: 8.0,
        tabBarIndicatorWeight: 3.0,
        tabBarIndicatorTopRadius: 3.0,
        tabBarDividerColor: Colors.transparent,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
        keepPrimary: true,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      primaryTextTheme: GoogleFonts.interTextTheme(),
    );
  }

  // ===== Tema oscuro =====
  static ThemeData darkTheme() {
    return FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primary: primaryColor,
        primaryContainer: Color(0xFF4338CA), // Indigo oscurecido
        secondary: secondaryColor,
        secondaryContainer: Color(0xFF6B21A8), // Purple oscurecido
        tertiary: insideColor, // Verde para estados positivos
        tertiaryContainer: Color(0xFF065F46), // Verde oscuro
        error: errorColor,
      ),
      useMaterial3: true,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 12,
      visualDensity: VisualDensity.standard,
      scaffoldBackground: surfaceDark,
      surface: surfaceCardDark,
      appBarStyle: FlexAppBarStyle.background,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 18,
        blendOnColors: false,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
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
        cardRadius: 14.0,
        elevatedButtonRadius: 12.0,
        filledButtonRadius: 12.0,
        outlinedButtonRadius: 12.0,
        textButtonRadius: 12.0,
        inputDecoratorRadius: 10.0,
        fabRadius: 16.0,
        chipRadius: 8.0,
        dialogRadius: 18.0,
        timePickerDialogRadius: 18.0,
        snackBarRadius: 8.0,
        tabBarIndicatorWeight: 3.0,
        tabBarIndicatorTopRadius: 3.0,
        tabBarDividerColor: Colors.transparent,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
        keepPrimary: true,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      primaryTextTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    );
  }

  // ===== Constantes de diseño =====
  // Font sizes
  static const double fontSizeH1 = 24.0;
  static const double fontSizeH2 = 20.0;
  static const double fontSizeH3 = 16.0;
  static const double fontSizeBodyNormal = 14.0;
  static const double fontSizeBodyMedium = 19.0;
  static const double fontSizeBodyLarge = 26.0;

  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingNormal = 12.0;
  static const double spacingMedium = 24.0;
  static const double spacingLarge = 32.0;

  // Border radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusNormal = 14.0; // Cards modernas
  static const double borderRadiusLarge = 18.0; // Cards grandes
  static const double borderRadiusPremium = 20.0; // Modales/sheets
}
