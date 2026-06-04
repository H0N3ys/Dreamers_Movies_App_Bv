import 'package:flutter/material.dart';
import '../colors/colors.dart';  

class AppTheme {
  static const String primaryFont = 'Output';
  static const String secondaryFont = 'WorkSans';

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
}