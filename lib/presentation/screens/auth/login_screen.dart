// lib/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/register_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_text_field.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_filled_button.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/divider_with_text.dart';

class LoginScreen extends StatefulWidget {
  static const name = 'login-screen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLogin();
  }
// Función para verificar si es el primer inicio de sesión y mostrar la opción biométrica
  Future<void> _checkFirstLogin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showBiometric = prefs.getBool('first_login_completed') ?? false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
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
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
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
                  
                  const SizedBox(height: 48),

                  const Text(
                    'Mas que películas, experiencias.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTheme.secondaryFont,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  CustomTextField(
                    label: 'Correo electrónico',
                    hintText: 'ejemplo@correo.com',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu correo';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Correo inválido';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  CustomTextField(
                    label: 'Contraseña',
                    hintText: 'Ingresa tu contraseña',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showResetPasswordDialog,
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('auth_token', 'token_falso_12345');
                      await prefs.setBool('first_login_completed', true);

                      if (context.mounted) {
                        context.go('/');
                      }
                    },
                  ),
                  // Mostrar la sección biométrica solo si el usuario ya ha iniciado sesión al menos una vez
                 if (_showBiometric) ..._buildBiometricSection(context),


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

  List<Widget> _buildBiometricSection(BuildContext context) {
  return [
    const SizedBox(height: 24),
    
    // Un texto un poco más conversacional
    DividerWithText(
      text: 'o también',
      color: AppColors.secondaryColor,
    ),
    
    const SizedBox(height: 24),
    
    SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          context.pushNamed('local-auth-screen');
        },
        icon: const Icon(Icons.fingerprint_rounded), // Ícono con bordes redondeados
        
        // Texto humanizado y cercano
        label: const Text('Entrar con huella o rostro'), 
        
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondaryColor,
          side: const BorderSide(color: AppColors.secondaryColor, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 14), // Un poco más alto para que sea fácil de presionar con el pulgar
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordes más suaves y modernos
          ),
        ),
      ),
    ),
  ];
}
}