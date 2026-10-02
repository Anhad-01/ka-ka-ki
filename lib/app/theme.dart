import 'package:flutter/material.dart';

/// Playful, colorful theme for ka-kā-ki.
class AppTheme {
  AppTheme._();

  // ── Brand colours ──────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF6C63FF); // Vibrant purple
  static const Color secondaryColor = Color(0xFFFF6584); // Playful pink
  static const Color accentColor = Color(0xFF00D9A6); // Bright teal
  static const Color warningColor = Color(0xFFFFB74D); // Warm orange
  static const Color errorColor = Color(0xFFEF5350); // Red

  // ── Shape colours ──────────────────────────────────────────────
  static const Color squareColor = Color(0xFF4FC3F7); // Sky blue
  static const Color pentagonColor = Color(0xFFFFD54F); // Golden yellow
  static const Color circleColor = Color(0xFFFF8A65); // Coral orange

  // ── Background ─────────────────────────────────────────────────
  static const Color backgroundColor = Color(0xFFF5F0FF); // Soft lavender
  static const Color surfaceColor = Colors.white;
  static const Color boardColor = Color(0xFFEDE7F6); // Light purple
  static const Color cellColor = Color(0xFFF3E5F5); // Lighter purple
  static const Color cellBorderColor = Color(0xFFCE93D8); // Medium purple

  // ── Text ───────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2D2B55); // Deep purple-navy
  static const Color textSecondary = Color(0xFF7C7A9C); // Muted purple
  static const Color textLight = Colors.white;

  // ── Player indicator colours ───────────────────────────────────
  static const List<Color> playerColors = [
    Color(0xFF6C63FF), // Purple
    Color(0xFFFF6584), // Pink
    Color(0xFF00D9A6), // Teal
    Color(0xFFFFB74D), // Orange
    Color(0xFF42A5F5), // Blue
    Color(0xFFAB47BC), // Violet
  ];

  /// The main app theme.
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Poppins',

      // ── AppBar ───────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      // ── Buttons ──────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textLight,
          elevation: 4,
          shadowColor: primaryColor.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input decoration ────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cellBorderColor.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cellBorderColor.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: textSecondary,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          color: textSecondary.withValues(alpha: 0.6),
        ),
      ),

      // ── Cards ────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shadowColor: primaryColor.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // ── Text ─────────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
    );
  }
}
