import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/config/router/app_router.dart';
import 'package:dreamers_movies_app_bv/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    //,router hace que cambie su forma de navegacion a una mas moderna en un manejo automatico de rutas 
    return MaterialApp.router(
      routerConfig: appRouter, //Sistema de rutas que utilizamos
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
    );
  }
}
