import 'package:flutter/material.dart';

/// Design tokens pulled from the BECU Figma libraries.
abstract final class AppColors {
  static const becuRed = Color(0xFFD62B2F);
  static const teal = Color(0xFF007C89);
  static const navy = Color(0xFF0D141C);
  static const ink = Color(0xFF192838);
  static const slate = Color(0xFF5A7184);
  static const support = Color(0xFF4D5F69);
  static const fieldBorder = Color(0xFF768A9B);
  static const borderSubtle = Color(0xFFDDE3E6);
  static const pageBackground = Color(0xFFF0F2F5);
  static const monthBar = Color(0xFFAEBEC5);
  static const zellePurple = Color(0xFF6D1ED4);
  static const browserBlue = Color(0xFF2E7CF6);
}

abstract final class AppTextStyles {
  /// Section labels above card groups ("Pending (3)", "Account Details"...).
  static const sectionLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
}

abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        primary: AppColors.teal,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.navy,
        displayColor: AppColors.navy,
      ),
      dividerColor: AppColors.borderSubtle,
      // Figma CTAs are flat; suppress the Material elevation shadow.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(elevation: 0),
      ),
    );
  }
}
