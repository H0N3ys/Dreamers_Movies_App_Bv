import 'package:flutter/material.dart';

class AppTheme {

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
}