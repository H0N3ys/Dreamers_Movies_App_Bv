// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dreamers_movies_app_bv/config/router/app_router.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Cargar el archivo .env de la raíz
  await dotenv.load(fileName: ".env");
  
  // 2. Inicializar Supabase con las variables reales
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
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