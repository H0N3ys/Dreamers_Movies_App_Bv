import 'package:flutter/material.dart';
import '../colors/colors.dart';  

class AppTheme {
  static const String primaryFont = 'Output';
  static const String secondaryFont = 'WorkSans';

<<<<<<< HEAD


  static const String _primaryFont = 'Output';
  static const String _secondaryFont = 'WorkSans';

  static const Color primaryColor = Color(0xFFFFFFFF); // Blanco
  static const Color secondaryColor = Color(0xFF152A72); // Azul
  static const Color accentColor = Color(0xFF020202); // Negro

  ThemeData getTheme() => ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: secondaryColor,
      brightness: Brightness.light,
    ),

    scaffoldBackgroundColor: primaryColor,

    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: accentColor,
      centerTitle: true,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor,
        foregroundColor: primaryColor,
      ),
    ),
  );
=======
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: primaryFont,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.secondaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.primaryColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.accentColor,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryColor,
            foregroundColor: AppColors.primaryColor,
            textStyle: const TextStyle(
              fontFamily: primaryFont,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontFamily: secondaryFont,
            color: AppColors.accentColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          bodyLarge: TextStyle(
            color: AppColors.accentColor,
            fontSize: 16,
          ),
        ),
      );
>>>>>>> origin/ramaadrian2
}