import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dreamers_movies_app_bv/app_router.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("⚠️ .env no cargado, usando valores por defecto");
  }
  
  
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('session_unlocked', false); 
  
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