import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamers_movies_app_bv/theme/app_theme.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/register_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/auth/auth_header.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_text_field.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_filled_button.dart';

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
                  Image.asset(
                    'assets/images/logoBueno.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Output',
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                      ),
                      children: [
                        TextSpan(
                          text: 'Ci',
                          style: TextStyle(color: AppTheme.accentColor),
                        ),
                        TextSpan(
                          text: 'nexa',
                          style: TextStyle(color: AppTheme.secondaryColor),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),
                  const Text(
                    'Mas que películas, experiencias.',
                    style: TextStyle(
                      fontFamily: 'Output',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(height: 40),
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
                  const SizedBox(height: 40),
                  CustomFilledButton(
                    text: 'Iniciar Sesión',
                    onPressed: () {
                      context.pushNamed(RegisterScreen.name);
                    },
                  ),

                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      context.pushNamed(RegisterScreen.name);
                    },
                    child: const Text(
                      '¿No tienes cuenta? Regístrate aquí',
                      style: TextStyle(
                        fontFamily: 'Output',
                        fontWeight: FontWeight.bold,
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
