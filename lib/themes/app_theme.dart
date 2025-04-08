import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color palette used throughout the app
class AppColors {
  // Primary Colors
  static const Color primaryLight = Color(0xFF2962FF); // Primary blue
  static const Color primaryDark = Color(0xFF2979FF);
  
  // Secondary Colors
  static const Color secondaryLight = Color(0xFFFF6D00); // Orange
  static const Color secondaryDark = Color(0xFFFF9100);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF121212);
  
  // Surface Colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Error Colors
  static const Color errorLight = Color(0xFFB00020);
  static const Color errorDark = Color(0xFFCF6679);
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF424242);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  
  // Thought Type Colors
  static const Color thoughtTypeEmotional = Color(0xFFE91E63); // Pink
  static const Color thoughtTypeCreative = Color(0xFFFF9800); // Orange
  static const Color thoughtTypeAnalytical = Color(0xFF4CAF50); // Green
  
  // Emotion Colors
  static const Color emotionHappy = Color(0xFFFFD54F); // Amber
  static const Color emotionNeutral = Color(0xFF90CAF9); // Light Blue
  static const Color emotionSad = Color(0xFF78909C); // Blue Grey
}

class AppTheme {
  // Text Themes
  static TextTheme _buildTextTheme(TextTheme base, Color textColor, Color secondaryTextColor) {
    final fontFamily = GoogleFonts.outfit().fontFamily;
    
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w300,
      ),
      displayMedium: base.displayMedium?.copyWith(
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w300,
      ),
      displaySmall: base.displaySmall?.copyWith(
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.normal,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: secondaryTextColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.normal,
      ),
      labelLarge: base.labelLarge?.copyWith(
        color: textColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      background: AppColors.backgroundLight,
      surface: AppColors.surfaceLight,
      error: AppColors.errorLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryLight,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.surfaceLight,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    ),
    textTheme: _buildTextTheme(
      ThemeData.light().textTheme, 
      AppColors.textPrimaryLight, 
      AppColors.textSecondaryLight
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
      background: AppColors.backgroundDark,
      surface: AppColors.surfaceDark,
      error: AppColors.errorDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.surfaceDark,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    ),
    textTheme: _buildTextTheme(
      ThemeData.dark().textTheme, 
      AppColors.textPrimaryDark, 
      AppColors.textSecondaryDark
    ),
  );
} 