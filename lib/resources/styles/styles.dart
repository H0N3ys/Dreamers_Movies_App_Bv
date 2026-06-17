import 'package:flutter/material.dart';
import '../colors/colors.dart';  

class AppTheme {
  static const String primaryFont = 'Output';
  static const String secondaryFont = 'WorkSans';






  static const Color primaryColor = Color(0xFFFFFFFF); // Blanco
  static const Color secondaryColor = Color(0xFF152A72); // Azul
  static const Color accentColor = Color(0xFF020202); // Negro

 static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: primaryFont,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.secondaryColor,
          brightness: Brightness.light, 
        ),
        scaffoldBackgroundColor: Colors.white, // <-- Regresa a blanco para el Login
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // <-- Textos oscuros arriba
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryColor,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontFamily: primaryFont,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontFamily: secondaryFont,
            color: Colors.black87, // <-- Textos oscuros para que se lean en el Login
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          bodyLarge: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Colors.black87,
          ),
        ),
      );

}