import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart'; 
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_text_field.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_filled_button.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/login_screen.dart';

class RegisterScreen extends StatelessWidget {
  static const name = 'register-screen';

  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
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
                        fontSize: 35,
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
                  
                  const SizedBox(height: 30),
                  
                  Text(
                    'Crear cuenta',
                    style: textTheme.titleLarge?.copyWith(
                      fontFamily: AppTheme.secondaryFont, 
                    ),
                  ),
                  const SizedBox(height: 40),

                  const CustomTextField(
                    label: 'Ingresar Nombres',
                    hintText: 'Carlos Adrian',
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 16),

                  const CustomTextField(
                    label: 'Ingresar Apellidos',
                    hintText: 'Zamorano Rodriguez',
                    icon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 16),

                  const CustomTextField(
                    label: 'Correo Electronico',
                    hintText: 'ejemplo@correo.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  const CustomTextField(
                    label: 'Ingresar Numero',
                    hintText: '998 000 0000',
                    icon: Icons.phone_iphone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  const CustomTextField(
                    label: 'Contraseña',
                    hintText: 'Ingresa tu contraseña',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  
                  const SizedBox(height: 30),

                  CustomFilledButton(
                    text: 'Crear Cuenta',
                    onPressed: () {
                      context.pushNamed('blank-screen');
                    },
                  ),
                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: () {
                      context.pushNamed(LoginScreen.name);
                    },
                    child: Text(
                      'Si ya tienes cuenta, inicia sesión aquí',
                      style: textTheme.bodyMedium?.copyWith(
                        fontFamily: AppTheme.primaryFont,
                        color: AppColors.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}