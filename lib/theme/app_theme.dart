// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color Palette ──────────────────────────────────────────
  static const Color primary = Color(0xFFEADDFF); // Lavender background
  static const Color accent = Color(0xFF673AB7);  // Deep Purple
  static const Color accentGold = Color(0xFFFFBB00);
  static const Color surface = Color(0xFFF2E6FF);
  static const Color cardBg = Color(0xFFFFFFFF);  // Clean white cards
  static const Color textPrimary = Color(0xFF1D1B20);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color divider = Color(0xFFCAC4D0);
  static const Color urduAccent = Color(0xFF00C2A8);

  static ThemeData get dark { // Kept name 'dark' to prevent breaking main.dart, though this is a light theme
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: primary,
      primaryColor: accent,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: accentGold,
        surface: surface,
        background: primary,
      ),
      textTheme: GoogleFonts.sourceSans3TextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 32),
          titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
          titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 14, height: 1.6),
          labelSmall: TextStyle(color: textSecondary, fontSize: 11, letterSpacing: 1.2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Playfair',
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: textSecondary),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }
}
