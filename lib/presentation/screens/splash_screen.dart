import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dreamers_movies_app_bv/presentation/screens/auth/login_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/local_auth_screen.dart';

class SplashScreen extends StatefulWidget {
  static const name = 'splash-screen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    _evaluarRutaInicial();
  }

  Future<void> _evaluarRutaInicial() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    final bool huellaActiva = prefs.getBool('huella_enabled') ?? false;

    if (token != null) {
      if (huellaActiva) {
        context.goNamed(LocalAuthScreen.name);
      } else {
        
        context.go('/'); 
      }
    } else {
      context.goNamed(LoginScreen.name); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Logo
            Image.asset(
              'assets/images/logoBueno.png',
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
            
            // Indicador de carga animado
            const CircularProgressIndicator(
              color: Colors.blueAccent, 
            ),
          ],
        ),
      ),
    );
  }
}