import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart'; 
import 'package:dreamers_movies_app_bv/presentation/screens/auth/register_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_text_field.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_filled_button.dart';

class LoginScreen extends StatelessWidget {
  static const name = 'login-screen';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                    height: 152,
                    fit: BoxFit.contain,
                  ),
                  
                  RichText(
                    text: TextSpan(
                      style: textTheme.displayLarge?.copyWith(
                        fontSize: 36,
                        fontFamily: AppTheme.primaryFont, 
                      ),
                      children: const [
                        TextSpan(
                          text: 'Ci',
                          style: TextStyle(color: AppColors.accentColor),
                        ),
                        TextSpan(
                          text: 'nexa',
                          style: TextStyle(color: AppColors.secondaryColor),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 46),
                                
                  Text(
                    'Mas que películas, experiencias.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTheme.secondaryFont, 
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  const CustomTextField(
                    label: 'Correo electrónico',
                    hintText: 'ejemplo@correo.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  
                  const CustomTextField(
                    label: 'Contraseña',
                    hintText: 'Ingresa tu contraseña',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: null, 
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryColor,
                          fontFamily: AppTheme.primaryFont, 
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  CustomFilledButton(
                    text: 'Iniciar Sesión',
                    onPressed: () {
                      context.pushNamed('blank-screen');
                    },
                  ),

                  const SizedBox(height: 24),
                  
                  TextButton(
                    onPressed: () {
                      context.pushNamed(RegisterScreen.name);
                    },
                    child: Text(
                      '¿No tienes cuenta? Regístrate aquí',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                        fontFamily: AppTheme.primaryFont, 
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