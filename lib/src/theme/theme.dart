// lib/theme/theme.dart - ENTHUSIASTIC GREEN & ORANGE "AIRY" THEME
import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  // ========================================
  // LIGHT THEME - ENTHUSIASTIC GREEN & VIBRANT ORANGE
  // ========================================
  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xFF1A56DB),        // Gorgeous Professional Blue
      surfaceTint: Color(0xFF1A56DB),
      onPrimary: Color(0xFFFFFFFF),      // White text on blue
      primaryContainer: Color(0xFFDBEAFE), // Very light blue
      onPrimaryContainer: Color(0xFF1E40AF),
      secondary: Color(0xFF2563EB),      // Vibrant Blue
      onSecondary: Color(0xFFFFFFFF),    // White text on orange
      secondaryContainer: Color(0xFFFFF4E6),
      onSecondaryContainer: Color(0xFF5A3300),
      tertiary: Color(0xFF1A56DB),       // Blue consistency
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFDBEAFE),
      onTertiaryContainer: Color(0xFF1E40AF),
      error: Color(0xFFE67E22),          // Orange for errors
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFE8DD),
      onErrorContainer: Color(0xFF5A2800),
      background: Color(0xFFF8F9FA),     // Very light off-white
      onBackground: Color(0xFF1A1A1A),
      surface: Color(0xFFFFFFFF),        // Pure white surface
      onSurface: Color(0xFF1A1A1A),
      surfaceVariant: Color(0xFFF8F9FA),
      onSurfaceVariant: Color(0xFF424242),
      outline: Color(0xFFBDBDBD),
      outlineVariant: Color(0xFFE0E0E0),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF2C2C2C),
      inverseOnSurface: Color(0xFFF8F9FA),
      inversePrimary: Color(0xFF60A5FA),  // Lighter blue
      primaryFixed: Color(0xFFDBEAFE),
      onPrimaryFixed: Color(0xFF1E40AF),
      primaryFixedDim: Color(0xFF60A5FA),
      onPrimaryFixedVariant: Color(0xFF1A56DB),
      secondaryFixed: Color(0xFFFFF4E6),
      onSecondaryFixed: Color(0xFF5A3300),
      secondaryFixedDim: Color(0xFFFFBE66),
      onSecondaryFixedVariant: Color(0xFFE07800),
      tertiaryFixed: Color(0xFFDBEAFE),
      onTertiaryFixed: Color(0xFF1E40AF),
      tertiaryFixedDim: Color(0xFF60A5FA),
      onTertiaryFixedVariant: Color(0xFF1A56DB),
      surfaceDim: Color(0xFFE8E8E8),
      surfaceBright: Color(0xFFFFFFFF),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF8F9FA),
      surfaceContainer: Color(0xFFF5F5F5),
      surfaceContainerHigh: Color(0xFFEEEEEE),
      surfaceContainerHighest: Color(0xFFE8E8E8),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xFF087A54),
      surfaceTint: Color(0xFF1A56DB),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF34C48E),
      onPrimaryContainer: Color(0xFFFFFFFF),
      secondary: Color(0xFFE07800),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFFFBE66),
      onSecondaryContainer: Color(0xFF1A1A1A),
      tertiary: Color(0xFF087A54),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF34C48E),
      onTertiaryContainer: Color(0xFFFFFFFF),
      error: Color(0xFFD35400),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFE67E22),
      onErrorContainer: Color(0xFFFFFFFF),
      background: Color(0xFFF8F9FA),
      onBackground: Color(0xFF1A1A1A),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1A1A1A),
      surfaceVariant: Color(0xFFF8F9FA),
      onSurfaceVariant: Color(0xFF424242),
      outline: Color(0xFF757575),
      outlineVariant: Color(0xFF9E9E9E),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF2C2C2C),
      inverseOnSurface: Color(0xFFF8F9FA),
      inversePrimary: Color(0xFF34C48E),
      primaryFixed: Color(0xFF34C48E),
      onPrimaryFixed: Color(0xFFFFFFFF),
      primaryFixedDim: Color(0xFF0A8B5F),
      onPrimaryFixedVariant: Color(0xFFFFFFFF),
      secondaryFixed: Color(0xFFFFBE66),
      onSecondaryFixed: Color(0xFF1A1A1A),
      secondaryFixedDim: Color(0xFF2563EB),
      onSecondaryFixedVariant: Color(0xFF1A1A1A),
      tertiaryFixed: Color(0xFF34C48E),
      onTertiaryFixed: Color(0xFFFFFFFF),
      tertiaryFixedDim: Color(0xFF0A8B5F),
      onTertiaryFixedVariant: Color(0xFFFFFFFF),
      surfaceDim: Color(0xFFE8E8E8),
      surfaceBright: Color(0xFFFFFFFF),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF8F9FA),
      surfaceContainer: Color(0xFFF5F5F5),
      surfaceContainerHigh: Color(0xFFEEEEEE),
      surfaceContainerHighest: Color(0xFFE8E8E8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xFF054A33),
      surfaceTint: Color(0xFF1A56DB),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF087A54),
      onPrimaryContainer: Color(0xFFFFFFFF),
      secondary: Color(0xFF6B4000),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFE07800),
      onSecondaryContainer: Color(0xFFFFFFFF),
      tertiary: Color(0xFF054A33),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF087A54),
      onTertiaryContainer: Color(0xFFFFFFFF),
      error: Color(0xFF9C4100),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFD35400),
      onErrorContainer: Color(0xFFFFFFFF),
      background: Color(0xFFF8F9FA),
      onBackground: Color(0xFF000000),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF000000),
      surfaceVariant: Color(0xFFF8F9FA),
      onSurfaceVariant: Color(0xFF212121),
      outline: Color(0xFF424242),
      outlineVariant: Color(0xFF424242),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF2C2C2C),
      inverseOnSurface: Color(0xFFFFFFFF),
      inversePrimary: Color(0xFFE6F7F0),
      primaryFixed: Color(0xFF087A54),
      onPrimaryFixed: Color(0xFFFFFFFF),
      primaryFixedDim: Color(0xFF054A33),
      onPrimaryFixedVariant: Color(0xFFFFFFFF),
      secondaryFixed: Color(0xFFE07800),
      onSecondaryFixed: Color(0xFFFFFFFF),
      secondaryFixedDim: Color(0xFF6B4000),
      onSecondaryFixedVariant: Color(0xFFFFFFFF),
      tertiaryFixed: Color(0xFF087A54),
      onTertiaryFixed: Color(0xFFFFFFFF),
      tertiaryFixedDim: Color(0xFF054A33),
      onTertiaryFixedVariant: Color(0xFFFFFFFF),
      surfaceDim: Color(0xFFE8E8E8),
      surfaceBright: Color(0xFFFFFFFF),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF8F9FA),
      surfaceContainer: Color(0xFFF5F5F5),
      surfaceContainerHigh: Color(0xFFEEEEEE),
      surfaceContainerHighest: Color(0xFFE8E8E8),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  // ========================================
  // DARK THEME
  // ========================================
  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF60A5FA),         // Lighter blue for dark theme
      surfaceTint: Color(0xFF60A5FA),
      onPrimary: Color(0xFF1E40AF),
      primaryContainer: Color(0xFF1A56DB),
      onPrimaryContainer: Color(0xFFDBEAFE),
      secondary: Color(0xFFFFBE66),       // Lighter orange for dark theme
      onSecondary: Color(0xFF5A3300),
      secondaryContainer: Color(0xFFE07800),
      onSecondaryContainer: Color(0xFFFFF4E6),
      tertiary: Color(0xFF60A5FA),
      onTertiary: Color(0xFF1E40AF),
      tertiaryContainer: Color(0xFF1A56DB),
      onTertiaryContainer: Color(0xFFDBEAFE),
      error: Color(0xFFFFAB91),
      onError: Color(0xFF5A2800),
      errorContainer: Color(0xFFE67E22),
      onErrorContainer: Color(0xFFFFE8DD),
      background: Color(0xFF121212),
      onBackground: Color(0xFFE8E8E8),
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFE8E8E8),
      surfaceVariant: Color(0xFF424242),
      onSurfaceVariant: Color(0xFFBDBDBD),
      outline: Color(0xFF757575),
      outlineVariant: Color(0xFF424242),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE8E8E8),
      inverseOnSurface: Color(0xFF2C2C2C),
      inversePrimary: Color(0xFF1A56DB),
      primaryFixed: Color(0xFFDBEAFE),
      onPrimaryFixed: Color(0xFF1E40AF),
      primaryFixedDim: Color(0xFF60A5FA),
      onPrimaryFixedVariant: Color(0xFF1A56DB),
      secondaryFixed: Color(0xFFFFF4E6),
      onSecondaryFixed: Color(0xFF5A3300),
      secondaryFixedDim: Color(0xFFFFBE66),
      onSecondaryFixedVariant: Color(0xFFE07800),
      tertiaryFixed: Color(0xFFDBEAFE),
      onTertiaryFixed: Color(0xFF1E40AF),
      tertiaryFixedDim: Color(0xFF60A5FA),
      onTertiaryFixedVariant: Color(0xFF1A56DB),
      surfaceDim: Color(0xFF1E1E1E),
      surfaceBright: Color(0xFF424242),
      surfaceContainerLowest: Color(0xFF0D0D0D),
      surfaceContainerLow: Color(0xFF262626),
      surfaceContainer: Color(0xFF2C2C2C),
      surfaceContainerHigh: Color(0xFF373737),
      surfaceContainerHighest: Color(0xFF424242),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF5ADAA8),
      surfaceTint: Color(0xFF34C48E),
      onPrimary: Color(0xFF054A33),
      primaryContainer: Color(0xFF0A8B5F),
      onPrimaryContainer: Color(0xFF000000),
      secondary: Color(0xFFFFD699),
      onSecondary: Color(0xFF3D2F00),
      secondaryContainer: Color(0xFFFFBE66),
      onSecondaryContainer: Color(0xFF000000),
      tertiary: Color(0xFF5ADAA8),
      onTertiary: Color(0xFF054A33),
      tertiaryContainer: Color(0xFF0A8B5F),
      onTertiaryContainer: Color(0xFF000000),
      error: Color(0xFFFFB499),
      onError: Color(0xFF4A1E00),
      errorContainer: Color(0xFFE67E22),
      onErrorContainer: Color(0xFF000000),
      background: Color(0xFF121212),
      onBackground: Color(0xFFE8E8E8),
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFFAFAFA),
      surfaceVariant: Color(0xFF424242),
      onSurfaceVariant: Color(0xFFC5C5C5),
      outline: Color(0xFF9E9E9E),
      outlineVariant: Color(0xFF757575),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE8E8E8),
      inverseOnSurface: Color(0xFF292929),
      inversePrimary: Color(0xFF1A56DB),
      primaryFixed: Color(0xFFE6F7F0),
      onPrimaryFixed: Color(0xFF033622),
      primaryFixedDim: Color(0xFF34C48E),
      onPrimaryFixedVariant: Color(0xFF087A54),
      secondaryFixed: Color(0xFFFFF4E6),
      onSecondaryFixed: Color(0xFF2E2100),
      secondaryFixedDim: Color(0xFFFFBE66),
      onSecondaryFixedVariant: Color(0xFF6B4000),
      tertiaryFixed: Color(0xFFE6F7F0),
      onTertiaryFixed: Color(0xFF033622),
      tertiaryFixedDim: Color(0xFF34C48E),
      onTertiaryFixedVariant: Color(0xFF087A54),
      surfaceDim: Color(0xFF1E1E1E),
      surfaceBright: Color(0xFF424242),
      surfaceContainerLowest: Color(0xFF0D0D0D),
      surfaceContainerLow: Color(0xFF262626),
      surfaceContainer: Color(0xFF2C2C2C),
      surfaceContainerHigh: Color(0xFF373737),
      surfaceContainerHighest: Color(0xFF424242),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFF0FFF7),
      surfaceTint: Color(0xFF34C48E),
      onPrimary: Color(0xFF000000),
      primaryContainer: Color(0xFF5ADAA8),
      onPrimaryContainer: Color(0xFF000000),
      secondary: Color(0xFFFFFDF5),
      onSecondary: Color(0xFF000000),
      secondaryContainer: Color(0xFFFFD699),
      onSecondaryContainer: Color(0xFF000000),
      tertiary: Color(0xFFF0FFF7),
      onTertiary: Color(0xFF000000),
      tertiaryContainer: Color(0xFF5ADAA8),
      onTertiaryContainer: Color(0xFF000000),
      error: Color(0xFFFFF9F9),
      onError: Color(0xFF000000),
      errorContainer: Color(0xFFFFB499),
      onErrorContainer: Color(0xFF000000),
      background: Color(0xFF121212),
      onBackground: Color(0xFFE8E8E8),
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFFFFFFF),
      surfaceVariant: Color(0xFF424242),
      onSurfaceVariant: Color(0xFFFAFAFA),
      outline: Color(0xFFC5C5C5),
      outlineVariant: Color(0xFFC5C5C5),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE8E8E8),
      inverseOnSurface: Color(0xFF000000),
      inversePrimary: Color(0xFF054A33),
      primaryFixed: Color(0xFFF0FFF7),
      onPrimaryFixed: Color(0xFF000000),
      primaryFixedDim: Color(0xFF5ADAA8),
      onPrimaryFixedVariant: Color(0xFF054A33),
      secondaryFixed: Color(0xFFFFFCF0),
      onSecondaryFixed: Color(0xFF000000),
      secondaryFixedDim: Color(0xFFFFD699),
      onSecondaryFixedVariant: Color(0xFF3D2F00),
      tertiaryFixed: Color(0xFFF0FFF7),
      onTertiaryFixed: Color(0xFF000000),
      tertiaryFixedDim: Color(0xFF5ADAA8),
      onTertiaryFixedVariant: Color(0xFF054A33),
      surfaceDim: Color(0xFF1E1E1E),
      surfaceBright: Color(0xFF424242),
      surfaceContainerLowest: Color(0xFF0D0D0D),
      surfaceContainerLow: Color(0xFF262626),
      surfaceContainer: Color(0xFF2C2C2C),
      surfaceContainerHigh: Color(0xFF373737),
      surfaceContainerHighest: Color(0xFF424242),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme().toColorScheme());
  }

  // ========================================
  // THEME BUILDER — AIRY GREEN & ORANGE
  // ========================================
  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.brightness == Brightness.light
            ? const Color(0xFFF8F9FA)
            : colorScheme.surface,
        canvasColor: colorScheme.surface,

        // ✅ AppBar — White/transparent with blue text
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.brightness == Brightness.light
              ? Colors.white
              : colorScheme.surface,
          foregroundColor: colorScheme.brightness == Brightness.light
              ? const Color(0xFF1A56DB)   // Blue text
              : colorScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
          iconTheme: IconThemeData(
            color: colorScheme.brightness == Brightness.light
                ? const Color(0xFF1A56DB)
                : colorScheme.onSurface,
          ),
          actionsIconTheme: IconThemeData(
            color: colorScheme.brightness == Brightness.light
                ? const Color(0xFF1A56DB)
                : colorScheme.onSurface,
          ),
          titleTextStyle: TextStyle(
            color: colorScheme.brightness == Brightness.light
                ? const Color(0xFF1A56DB)
                : colorScheme.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),

        // ✅ Elevated buttons — Pill-shaped, Blue fill
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A56DB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            elevation: 0,
          ),
        ),

        // Text Button — Blue
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),

        // Outlined Button — Pill-shaped, Blue border
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF1A56DB), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),

        // FAB — Blue accent
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // Input Decoration — Rounded
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.brightness == Brightness.light
              ? Colors.white
              : colorScheme.surfaceContainerHigh,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1A56DB), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIconColor: const Color(0xFF1A56DB),
          suffixIconColor: const Color(0xFF757575),
        ),

        // ✅ Cards — Highly rounded, soft diffuse shadow
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          color: Colors.white,
          shadowColor: Colors.transparent,
        ),

        // Bottom Navigation Bar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF1A56DB),
          unselectedItemColor: Color(0xFF9E9E9E),
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),

        // Chips — Rounded
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFFFF4E6),
          selectedColor: const Color(0xFFE6F7F0),
          labelStyle: const TextStyle(color: Color(0xFF1A1A1A)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),

        // Progress Indicator — Blue
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF1A56DB),
          circularTrackColor: Color(0xFFE8E8E8),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE0E0E0),
          thickness: 1,
          space: 1,
        ),

        // Icon Theme
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: 24,
        ),

        // Snackbar — Blue bg
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF1A56DB),
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

  List<ExtendedColor> get extendedColors => [];
}

// ========================================
// MATERIAL SCHEME CLASS
// ========================================
class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary,
    required this.surfaceTint,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.inversePrimary,
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixedVariant,
    required this.secondaryFixed,
    required this.onSecondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixedVariant,
    required this.tertiaryFixed,
    required this.onTertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixedVariant,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

// ========================================
// EXTENSION TO CONVERT TO COLOR SCHEME
// ========================================
extension MaterialSchemeUtils on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
