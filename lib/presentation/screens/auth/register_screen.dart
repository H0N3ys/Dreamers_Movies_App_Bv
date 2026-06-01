import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importa tus widgets modulares
import 'package:dreamers_movies_app_bv/presentation/widgets/auth/auth_header.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_text_field.dart';

class RegisterScreen extends StatelessWidget {
  static const name = 'register-screen';

  const RegisterScreen({super.key});

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
                  
                  // 1. Encabezado (Le pasamos el ícono específico de Registro)
                  const AuthHeader(
                    title: 'Crear Cuenta',
                    icon: Icons.person_add_alt_1_rounded,
                  ),
                  const SizedBox(height: 40),

                  // 2. Campo: Nombre
                  const CustomTextField(
                    label: 'Nombre completo',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  // 3. Campo: Correo
                  const CustomTextField(
                    label: 'Correo electrónico',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // 4. Campo: Contraseña
                  const CustomTextField(
                    label: 'Contraseña',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),

                  // 5. Campo: Confirmar Contraseña
                  const CustomTextField(
                    label: 'Confirmar contraseña',
                    icon: Icons.lock_reset_outlined,
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),

                  // 6. Botón de texto para ir al Login
                  TextButton(
                    onPressed: () {
                      context.push('/login');
                    },
                    child: const Text('¿Ya tienes cuenta? Inicia sesión'),
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