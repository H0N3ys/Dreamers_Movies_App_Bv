import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  static const name = 'login-screen';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // Logo
                  const Icon(
                    Icons.movie_creation_rounded,
                    size: 100,
                    color: AppTheme.secondaryColor,
                  ),

                  const SizedBox(height: 20),

                  // Título
                  const Text(
                    'Bienvenido a Cinexa',
                    style: TextStyle(
                      fontFamily: 'Output',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Inicia sesión para continuar',
                    style: TextStyle(
                      fontFamily: 'WorkSans',
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Correo
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      fontFamily: 'WorkSans',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      labelStyle: const TextStyle(
                        fontFamily: 'WorkSans',
                      ),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppTheme.secondaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Contraseña
                  TextFormField(
                    obscureText: true,
                    style: const TextStyle(
                      fontFamily: 'WorkSans',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: const TextStyle(
                        fontFamily: 'WorkSans',
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppTheme.secondaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Botón Login
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontFamily: 'WorkSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '¿No tienes cuenta? Regístrate aquí',
                      style: TextStyle(
                        fontFamily: 'WorkSans',
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}