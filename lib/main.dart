// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dreamers_movies_app_bv/config/router/app_router.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar .env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error cargando .env: $e");
    dotenv.testLoad(fileInput: '''
      SUPABASE_URL=https://xclosftjhldcwalbbjzb.supabase.co
      SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjbG9zZnRqaGxkY3dhbGJianpiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE1NzQxNDUsImV4cCI6MjA5NzE1MDE0NX0.LQOFN4l9L0IAjk7bVqcqf-5OLy7GclYross-Y1kWmok
    ''');
  }
  
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