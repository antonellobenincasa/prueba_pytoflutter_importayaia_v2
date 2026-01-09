import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Core Design Vision Colors
  static const Color darkBlueBackground = Color(0xFF050A14);
  static const Color cardSurface = Color(0xFF111C2E);
  static const Color surface = Color(0xFF0F1623);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF0F2F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Primary Actions - Neon Lime
  static const Color neonGreen = Color(0xFFA4F40B);
  static const Color primaryLime = Color(0xFFA4F40B);

  // Darker Green for Light Mode text legibility on green buttons
  static const Color oliveGreen = Color(0xFF4B7A05);

  // Secondary - Teal
  static const Color primaryTeal = Color(0xFF00CBA9);
  static const Color neonCyan = Color(0xFF00F0FF);

  // Text Colors (Dark Mode)
  static const Color textWhite = Color(0xFFF2F6FF);

  // Text Colors (Light Mode)
  static const Color textBlack = Color(0xFF1A1A1A);
  static const Color textDarkGrey = Color(0xFF334155);

  static const Color textGrey = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Surface Variants
  static const Color surfaceDark = Color(0xFF111826);
  static const Color cardColor = Color(0xFF1E293B);
  static const Color surfaceHighlight = Color(0xFF1A2332);

  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
}

// TEXT THEME GENERATOR
TextTheme _buildTextTheme(TextTheme base, Color primaryTextColor) {
  // Space Grotesk for headings
  final headingFont = GoogleFonts.spaceGrotesk(
    color: primaryTextColor,
    fontWeight: FontWeight.bold,
  );

  // Noto Sans for body text
  final bodyFont = GoogleFonts.notoSans(
    color: primaryTextColor,
  );

  return base.copyWith(
    // Display styles
    displayLarge: headingFont.copyWith(fontSize: 57, letterSpacing: -0.25),
    displayMedium: headingFont.copyWith(fontSize: 45),
    displaySmall: headingFont.copyWith(fontSize: 36),

    // Headline styles
    headlineLarge: headingFont.copyWith(fontSize: 32),
    headlineMedium: headingFont.copyWith(fontSize: 28),
    headlineSmall: headingFont.copyWith(fontSize: 24),

    // Title styles
    titleLarge: headingFont.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium:
        headingFont.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: headingFont.copyWith(fontSize: 14, fontWeight: FontWeight.w600),

    // Body styles
    bodyLarge: bodyFont.copyWith(fontSize: 16),
    bodyMedium: bodyFont.copyWith(fontSize: 14),
    bodySmall: bodyFont.copyWith(fontSize: 12, color: AppColors.textGrey),

    // Label styles
    labelLarge: bodyFont.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
    labelMedium: bodyFont.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: bodyFont.copyWith(fontSize: 11, color: AppColors.textGrey),
  );
}

ThemeData appTheme() {
  // DARK THEME (Legacy name kept for compatibility)
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBlueBackground,
    primaryColor: AppColors.neonGreen,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.neonGreen,
      secondary: AppColors.primaryTeal,
      surface: AppColors.cardSurface,
      error: AppColors.error,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: AppColors.textWhite,
    ),
    textTheme: _buildTextTheme(base.textTheme, AppColors.textWhite),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBlueBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          color: AppColors.textWhite,
          fontWeight: FontWeight.bold),
      iconTheme: const IconThemeData(color: AppColors.textWhite),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: AppColors.neonGreen.withAlpha(25)), // ~0.1 opacity
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neonGreen,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textGrey.withAlpha(51)), // ~0.2
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textGrey.withAlpha(51)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.neonGreen, width: 2),
      ),
      labelStyle: GoogleFonts.notoSans(color: AppColors.textGrey),
      hintStyle: GoogleFonts.notoSans(color: AppColors.textMuted),
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.textGrey.withAlpha(25), // ~0.1
      thickness: 1,
    ),
  );
}

ThemeData appLightTheme() {
  // NEW LIGHT THEME
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.neonGreen,
    colorScheme: const ColorScheme.light(
      primary: AppColors.neonGreen,
      secondary: AppColors.primaryTeal,
      surface: AppColors.lightSurface,
      error: AppColors.error,
      onPrimary: Colors.black, // Dark text on Neon Green
      onSecondary: Colors.black,
      onSurface: AppColors.textBlack,
    ),
    textTheme: _buildTextTheme(base.textTheme, AppColors.textBlack),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          color: AppColors.textBlack,
          fontWeight: FontWeight.bold),
      iconTheme: const IconThemeData(color: AppColors.textBlack),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 2,
      shadowColor: Colors.black.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withAlpha(30)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neonGreen,
        foregroundColor: Colors.black,
        elevation: 2,
        shadowColor: AppColors.neonGreen.withAlpha(100),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withAlpha(70)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.withAlpha(70)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: AppColors.oliveGreen,
            width: 2), // Darker green for contrast on white
      ),
      labelStyle: GoogleFonts.notoSans(color: AppColors.textDarkGrey),
      hintStyle: GoogleFonts.notoSans(color: AppColors.textGrey),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.withAlpha(50),
      thickness: 1,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textDarkGrey,
    ),
  );
}
