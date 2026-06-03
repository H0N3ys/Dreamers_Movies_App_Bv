import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static const String _primaryFont = 'Output';
  static const String _secondaryFont = 'WorkSans';

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: _primaryFont,
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
              fontFamily: _primaryFont,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontFamily: _secondaryFont,
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
}