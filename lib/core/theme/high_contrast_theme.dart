import 'package:flutter/material.dart';
import 'package:tokam/core/constants/colors.dart';

class HighContrastTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryAccent,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryAccent,
        secondary: AppColors.secondaryAccent,
        surface: AppColors.backgroundLight,
        error: Colors.red,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'PoppinsBold',
          color: AppColors.textLight,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'PoppinsMedium',
          color: AppColors.textLight,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'PoppinsRegular',
          color: AppColors.textLight,
          fontSize: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryAccent,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryAccent,
        secondary: AppColors.secondaryAccent,
        surface: AppColors.backgroundDark,
        error: Colors.redAccent,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'PoppinsBold',
          color: AppColors.textDark,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'PoppinsMedium',
          color: AppColors.textDark,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'PoppinsRegular',
          color: AppColors.textDark,
          fontSize: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
