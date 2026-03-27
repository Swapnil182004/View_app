import 'package:flutter/material.dart';

class AppColor {
  
  // ========================================
  // PRIMARY BRAND COLORS - Enthusiastic Green & Orange "Airy" Theme
  // ========================================
  
  // Main Brand Colors
  static const enthusiasticGreen = Color(0xFF1A56DB);   // Primary - Gorgeous Professional Blue
  static const vibrantOrange = Color(0xFF2563EB);        // Secondary/Accent - Vibrant Blue
  static const offWhite = Color(0xFFF8F9FA);             // Base/Background - very light off-white
  static const pureWhite = Color(0xFFFFFFFF);            // Alternate Background

  // ========================================
  // CORE THEME MAPPINGS
  // ========================================
  static const primary = enthusiasticGreen;              // Main brand color - Text, Active states, Primary buttons
  static const secondary = vibrantOrange;                // Accent color - Badges, Highlights, Secondary buttons
  static const tertiary = enthusiasticGreen;             // Consistency with primary
  static const accent = vibrantOrange;                   // Highlight color

  // ========================================
  // SURFACE & BACKGROUND COLORS
  // ========================================
  
  // Light Theme
  static const surface = pureWhite;
  static const surfaceVariant = offWhite;
  static const background = offWhite;                    // Screen backgrounds
  static const cardColor = pureWhite;

  // Dark Theme
  static const surfaceDark = Color(0xFF1E1E1E);
  static const surfaceVariantDark = Color(0xFF2C2C2C);
  static const backgroundDark = Color(0xFF121212);
  static const cardColorDark = Color(0xFF2C2C2C);

  // Legacy Support
  static const bg_dark = surfaceVariantDark;
  static const appBgColor = background;
  static const appBarColor = pureWhite;                  // White/transparent AppBar
  static const bottomBarColor = surface;
  static const textBoxColor = surface;

  // ========================================
  // TEXT COLORS
  // ========================================
  static const textColor = Color(0xFF1A1A1A);            // Primary text - Dark Gray
  static const textSecondary = Color(0xFF757575);        // Secondary text
  static const textTertiary = Color(0xFF9E9E9E);         // Tertiary text
  static const labelColor = textSecondary;               // Labels

  // Special text colors
  static const textOnGreen = pureWhite;                  // Text on green background
  static const textOnOrange = pureWhite;                 // White text on orange buttons

  // Dark theme text
  static const textColorDark = Color(0xFFE8E8E8);
  static const textSecondaryDark = Color(0xFFBDBDBD);

  // Legacy support
  static const glassTextColor = Colors.white;
  static const glassLabelColor = Colors.white;

  // ========================================
  // STATE COLORS
  // ========================================
  static const Color onPrimary = pureWhite;              // Text on green
  static const Color onSecondary = pureWhite;            // Text on orange
  static const Color onSurface = textColor;
  static const Color onBackground = textColor;
  static const Color onError = pureWhite;

  // Interactive states
  static const actionColor = enthusiasticGreen;
  static const inActiveColor = Color(0xFF9E9E9E);
  static const darker = Color(0xFF3E4249);
  static const mainColor = enthusiasticGreen;

  // ========================================
  // SEMANTIC COLORS
  // ========================================
  static const error = Color(0xFFEF4444);                // Red warning
  static const success = Color(0xFF1A56DB);              // Blue for consistency
  static const warning = vibrantOrange;                  // Blue for warnings
  static const info = Color(0xFF3498DB);                 // Soft blue for info

  // ========================================
  // UTILITY COLORS
  // ========================================
  static const shadowColor = Color(0x0A000000);          // ~4% black — very soft, diffuse
  static const dividerColor = Color(0xFFE0E0E0);
  static const outlineColor = Color(0xFFBDBDBD);

  // ========================================
  // SHADES & TINTS OF BRAND COLORS
  // ========================================
  
  // Blue Shades (Replacing Green)
  static const greenLight = Color(0xFF60A5FA);           // Lighter blue
  static const greenDark = Color(0xFF1E40AF);            // Darker blue
  static const greenExtraLight = Color(0xFFDBEAFE);      // Very light blue background

  // Orange Shades
  static const orangeLight = Color(0xFFFFBE66);          // Light orange
  static const orangeDark = Color(0xFFE07800);           // Darker orange
  static const orangeExtraLight = Color(0xFFFFF4E6);     // Very light orange background

  // Legacy aliases (for backward compatibility)
  static const blueLight = greenLight;
  static const blueDark = greenDark;
  static const blueExtraLight = greenExtraLight;
  static const goldenLight = orangeLight;
  static const goldenDark = orangeDark;
  static const goldenExtraLight = orangeExtraLight;
  static const royalBlue = enthusiasticGreen;
  static const goldenYellow = vibrantOrange;
  static const indigo = enthusiasticGreen;
  static const indigoLight = greenLight;
  static const indigoDark = greenDark;
  static const indigoExtraLight = greenExtraLight;

  // ========================================
  // ADDITIONAL SAFE COLORS
  // ========================================
  static const yellow = Color(0xFFFFC107);
  static const blueBrand = enthusiasticGreen;
  static const lightBlueBrand = greenLight;
  static const orange = vibrantOrange;
  static const blue = Color(0xFF42A5F5);
  static const teal = Color(0xFF26A69A);

  // ========================================
  // GRADIENT DEFINITIONS
  // ========================================
  
  // Primary gradient - Green variations
  static const List<Color> primaryGradient = [
    enthusiasticGreen,
    greenLight,
  ];
  
  // Accent gradient - Orange variations
  static const List<Color> accentGradient = [
    vibrantOrange,
    orangeLight,
  ];
  
  // Brand gradient - Green to Orange
  static const List<Color> brandGradient = [
    enthusiasticGreen,
    greenLight,
    vibrantOrange,
  ];
  
  // Success gradient
  static const List<Color> successGradient = [
    enthusiasticGreen,
    greenLight,
  ];
  
  // Warm gradient
  static const List<Color> warmGradient = [
    vibrantOrange,
    orangeLight,
  ];

  // ========================================
  // COLOR LISTS (for category chips, tags, etc.)
  // ========================================
  
  // Primary list - Brand colors only
  static const List<Color> brandColors = [
    enthusiasticGreen,
    greenLight,
    vibrantOrange,
    greenDark,
    orangeLight,
  ];
  
  // Safe color list
  static const List<Color> listColors = [
    enthusiasticGreen,
    vibrantOrange,
    greenLight,
    teal,
    blue,
    orangeDark,
    Color(0xFF5CC9A0),
    orangeLight,
  ];
  
  // Pastel list for backgrounds
  static const List<Color> pastelColors = [
    greenExtraLight,
    orangeExtraLight,
    Color(0xFFE6F7F0),
    Color(0xFFFFF4E6),
    Color(0xFFE0F2F1),
  ];
  
  // Extended color list
  static const List<Color> extendedListColors = [
    enthusiasticGreen,
    vibrantOrange,
    greenLight,
    greenDark,
    orangeLight,
    teal,
    blue,
    Color(0xFF5CC9A0),
    Color(0xFF26A69A),
    Color(0xFF81D8B4),
    Color(0xFFFFA726),
    Color(0xFF42A5F5),
  ];

  static Color? get white => null;
  
  // ========================================
  // HELPER METHODS
  // ========================================
  
  /// Get a brand color by index (cycles through if index > length)
  static Color getBrandColor(int index) {
    return brandColors[index % brandColors.length];
  }
  
  /// Get a random brand color
  static Color getRandomBrandColor() {
    return brandColors[(DateTime.now().millisecondsSinceEpoch % brandColors.length)];
  }
  
  /// Get color with opacity
  static Color withAlpha(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Check if color follows brand guidelines
  static bool isBrandSafe(Color color) {
    if (color.red > 200 && color.green < 100 && color.blue < 100) return false;
    if (color.blue > 150 && color.red < 100 && color.green < 100) return false;
    if (color.red > 100 && color.blue > 100 && color.green < 100) return false;
    return true;
  }
}
