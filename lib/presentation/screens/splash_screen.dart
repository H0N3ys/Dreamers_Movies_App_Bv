import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    
    //Esperamos 3 segundos y luego navegamos al Login
    Future.delayed(const Duration(seconds: 3), () {
      // Usamos context.go() para destruir el Splash Screen.
      if (mounted) {
        context.go('/login');
      }
    });
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