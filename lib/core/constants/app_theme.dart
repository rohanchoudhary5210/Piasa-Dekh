import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => forTheme('mana_purple');

  /// Primary accent for a coin-shop theme id.
  static Color accentFor(String themeId) {
    switch (themeId) {
      case 'emerald_grove':
        return const Color(0xFF10B981);
      case 'cyberpunk_neon':
        return const Color(0xFF22D3EE);
      case 'obsidian_gold':
        return const Color(0xFFFBBF24);
      case 'mana_purple':
      default:
        return AppColors.manaPurple;
    }
  }

  /// Secondary accent for a coin-shop theme id.
  static Color secondaryFor(String themeId) {
    switch (themeId) {
      case 'emerald_grove':
        return const Color(0xFF84CC16);
      case 'cyberpunk_neon':
        return const Color(0xFFF472B6);
      case 'obsidian_gold':
        return const Color(0xFFD4AF37);
      case 'mana_purple':
      default:
        return AppColors.safeGreen;
    }
  }

  /// App theme for the equipped coin-shop theme.
  static ThemeData forTheme(String themeId) {
    final accent = accentFor(themeId);
    final secondary = secondaryFor(themeId);
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: accent,
      cardColor: AppColors.surface,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: secondary,
        surface: AppColors.surface,
        error: AppColors.dangerRed,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
    );
  }
}
