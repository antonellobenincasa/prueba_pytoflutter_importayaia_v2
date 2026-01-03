import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Core Design Vision Colors
  static const Color darkBlueBackground = Color(0xFF050A14);
  static const Color cardSurface = Color(0xFF111C2E);
  static const Color surface = Color(0xFF0F1623);

  // Primary Actions - Neon Lime
  static const Color neonGreen = Color(0xFFA4F40B);
  static const Color primaryLime = Color(0xFFA4F40B);

  // Secondary - Teal
  static const Color primaryTeal = Color(0xFF00CBA9);
  static const Color neonCyan = Color(0xFF00F0FF);

  // Text Colors
  static const Color textWhite = Color(0xFFF2F6FF);
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

ThemeData appTheme() {
  // Space Grotesk for headings
  final headingFont = GoogleFonts.spaceGrotesk(
    color: AppColors.textWhite,
    fontWeight: FontWeight.bold,
  );

  // Noto Sans for body text
  final bodyFont = GoogleFonts.notoSans(
    color: AppColors.textWhite,
  );

  return ThemeData(
    useMaterial3: true,
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

    // Text Theme with Google Fonts
    textTheme: TextTheme(
      // Display styles - Space Grotesk
      displayLarge: headingFont.copyWith(fontSize: 57, letterSpacing: -0.25),
      displayMedium: headingFont.copyWith(fontSize: 45),
      displaySmall: headingFont.copyWith(fontSize: 36),

      // Headline styles - Space Grotesk
      headlineLarge: headingFont.copyWith(fontSize: 32),
      headlineMedium: headingFont.copyWith(fontSize: 28),
      headlineSmall: headingFont.copyWith(fontSize: 24),

      // Title styles - Space Grotesk
      titleLarge:
          headingFont.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium:
          headingFont.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall:
          headingFont.copyWith(fontSize: 14, fontWeight: FontWeight.w600),

      // Body styles - Noto Sans
      bodyLarge: bodyFont.copyWith(fontSize: 16),
      bodyMedium: bodyFont.copyWith(fontSize: 14),
      bodySmall: bodyFont.copyWith(fontSize: 12, color: AppColors.textGrey),

      // Label styles - Noto Sans
      labelLarge: bodyFont.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: bodyFont.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: bodyFont.copyWith(fontSize: 11, color: AppColors.textGrey),
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBlueBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: headingFont.copyWith(fontSize: 18),
      iconTheme: const IconThemeData(color: AppColors.textWhite),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.neonGreen.withValues(alpha: 0.1)),
      ),
    ),

    // Elevated Button Theme
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

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: AppColors.textGrey.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: AppColors.textGrey.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.neonGreen, width: 2),
      ),
      labelStyle: bodyFont.copyWith(color: AppColors.textGrey),
      hintStyle: bodyFont.copyWith(color: AppColors.textMuted),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: AppColors.textGrey.withValues(alpha: 0.1),
      thickness: 1,
    ),
  );
}
