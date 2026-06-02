import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFFFFFF); 
  static const Color secondaryColor = Color(0xFF152A72); 
  static const Color accentColor = Color(0xFF020202); 


  static const String _primaryFont = 'Output';
  static const String _secondaryFont = 'WorkSans';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      fontFamily: _primaryFont,

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
          textStyle: const TextStyle(
            fontFamily: _primaryFont, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontFamily: _secondaryFont, 
          color: accentColor, 
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        bodyLarge: TextStyle(
          color: accentColor,
          fontSize: 16,
        ),
      ),
    );
  }
}