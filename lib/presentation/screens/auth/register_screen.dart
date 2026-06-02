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
                  Image.asset(
                    'assets/images/logoBueno.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const AuthHeader(
                    title: 'Crear Cuenta',
                    icon: Icons.person_add_alt_1_rounded,
                  ),
                  const SizedBox(height: 40),

                  const CustomTextField(
                    label: 'Nombre completo',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  const CustomTextField(
                    label: 'Correo electrónico',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  const CustomTextField(
                    label: 'Contraseña',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),

                  const CustomTextField(
                    label: 'Confirmar contraseña',
                    icon: Icons.lock_reset_outlined,
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),

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
