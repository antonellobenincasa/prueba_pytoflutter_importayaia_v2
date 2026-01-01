import 'package:flutter/material.dart';

class AppColors {
  static const Color darkBlueBackground = Color(0xFF050A14);
  static const Color cardSurface = Color(0xFF111C2E);
  static const Color surface = Color(0xFF0F1623); // Added from HTML design
  static const Color neonGreen = Color(0xFFA4F40B);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color textWhite = Color(0xFFF2F6FF);
  static const Color textGrey = Color(0xFF94A3B8);
  static const Color surfaceDark = Color(0xFF111826);
  static const Color cardColor = Color(0xFF1E293B);
  static const Color primaryTeal = Color(0xFF00Cba9);
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBlueBackground,
    primaryColor: AppColors.darkBlueBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.neonGreen,
      secondary: AppColors.neonCyan,
      surface: AppColors.cardSurface,
    ),
  );
}
