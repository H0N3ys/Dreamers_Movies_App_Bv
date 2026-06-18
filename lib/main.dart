// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dreamers_movies_app_bv/config/router/app_router.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar .env con fallback para web
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // En web no carga .env, pero usamos la API key directamente
    print("⚠️ .env no cargado (normal en web), usando valores por defecto");
    // La API key se usa directamente en movie_api_datasource.dart
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'Cinexa',
      theme: AppTheme.lightTheme,
    );
  }
}