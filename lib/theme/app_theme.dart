import 'package:flutter/material.dart';
class AppTheme {
  //ThemeData es una clae que representa toda la configuraxcion visual de nuesta app

  ThemeData getTheme () => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0XFF2862F5)
  );
}