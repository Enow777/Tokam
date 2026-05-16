import 'package:flutter/material.dart';
import 'package:tokam/core/constants/colors.dart';

class HighContrastTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryAccent,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryAccent,
        secondary: AppColors.secondaryAccent,
        surface: AppColors.lightBackground,
        error: Colors.red,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'PoppinsBold',
          color: AppColors.lightTextPrimary,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'PoppinsMedium',
          color: AppColors.lightTextPrimary,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'PoppinsRegular',
          color: AppColors.lightTextPrimary,
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
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryAccent,
        secondary: AppColors.secondaryAccent,
        surface: AppColors.darkBackground,
        error: Colors.redAccent,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'PoppinsBold',
          color: AppColors.darkTextPrimary,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'PoppinsMedium',
          color: AppColors.darkTextPrimary,
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'PoppinsRegular',
          color: AppColors.darkTextPrimary,
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
