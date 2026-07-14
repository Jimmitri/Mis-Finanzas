import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AppTheme {

  static ThemeData lightTheme = ThemeData(

    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.textPrimary,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(

      style: ElevatedButton.styleFrom(

        backgroundColor: AppColors.primary,

        foregroundColor: Colors.white,

        minimumSize: const Size(double.infinity, 55),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),

      ),

    ),

    inputDecorationTheme: InputDecorationTheme(

      filled: true,

      fillColor: Colors.white,

      border: OutlineInputBorder(

        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(
          color: AppColors.border,
        ),

      ),

      enabledBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(
          color: AppColors.border,
        ),

      ),

      focusedBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),

      ),

    ),

    cardTheme: CardThemeData(

      color: Colors.white,

      elevation: 3,

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(18),

      ),

    ),

  );

}