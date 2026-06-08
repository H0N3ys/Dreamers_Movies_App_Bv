import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// IMPORTANTE: Verifica que estas rutas sean correctas según tu proyecto
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
    // En lugar de ir directo al login, llamamos a nuestra función evaluadora
    _evaluarRutaInicial();
  }

  Future<void> _evaluarRutaInicial() async {
    // Esperamos 3 segundos para que luzca el logo y la animación
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    // Abrimos la "memoria" del teléfono
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    final bool huellaActiva = prefs.getBool('huella_enabled') ?? false;

    // Aplicamos la lógica de redirección
    if (token != null) {
      if (huellaActiva) {
        // Tiene token y activó la huella -> Lo mandamos a tu pantalla de biometría
        context.goNamed(LocalAuthScreen.name);
      } else {
        // Tiene token pero NO activó la huella -> Va directo al inicio
        // OJO: Cambia '/home' por la ruta real que use tu compañero para la pantalla principal
        context.go('/'); 
      }
    } else {
      // NO tiene token (es su primera vez o cerró sesión) -> Va al Login
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