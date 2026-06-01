import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importa tus widgets (ajusta las rutas según tu proyecto)
import 'package:dreamers_movies_app_bv/presentation/widgets/auth/auth_header.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_text_field.dart';

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
                  
                  // 1. Encabezado Modular
                  const AuthHeader(title: 'Bienvenido a Cinexa'),
                  const SizedBox(height: 40),

                  // 2. Campo de Correo Modular
                  const CustomTextField(
                    label: 'Correo electrónico',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // 3. Campo de Contraseña Modular
                  const CustomTextField(
                    label: 'Contraseña',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 40), // Espacio extra donde iría el botón de ingreso

                  // 4. Botón de texto para registro
                  TextButton(
                    onPressed: () {
                      // Acción para ir al registro
                    },
                    child: const Text('¿No tienes cuenta? Regístrate aquí'),
                  )
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}