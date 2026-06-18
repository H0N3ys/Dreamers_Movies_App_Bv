// lib/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/register_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_text_field.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_filled_button.dart';
import 'package:dreamers_movies_app_bv/domain/repositories/user_repositories.dart';

class LoginScreen extends StatefulWidget {
  static const name = 'login-screen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserRepository _userRepository = UserRepository();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  Future<void> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    
    if (isLoggedIn && mounted) {
      context.go('/');
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _userRepository.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null && mounted) {
        // Guardar en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', user.id);
        await prefs.setString('user_email', user.email);
        await prefs.setString('user_nombres', user.nombres ?? '');
        await prefs.setString('user_apellidos', user.apellidos ?? '');
        await prefs.setString('user_telefono', user.telefono ?? '');
        await prefs.setBool('is_logged_in', true);
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Bienvenido!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
        
        if (mounted) {
          context.go('/');
        }
      } else {
        _showError('Credenciales inválidas. Verifica tu email y contraseña.');
      }
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showRecuperarPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Para recuperar tu contraseña, contacta al administrador.\n\n'
              'En una app local, la recuperación de contraseña debe hacerse '
              'manualmente desde la base de datos.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
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
                  // Logo
                  Image.asset(
                    'assets/images/logoBueno.png',
                    height: 152,
                    fit: BoxFit.contain,
                  ),
                  
                  // Título
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
                  
                  const SizedBox(height: 8),
                  
                  // Subtítulo
                  Text(
                    'Más que películas, experiencias.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppTheme.secondaryFont,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Campo Email
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
                  
                  // Campo Contraseña
                  CustomTextField(
                    label: 'Contraseña',
                    hintText: 'Ingresa tu contraseña',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Olvidé mi contraseña
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showRecuperarPasswordDialog,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryColor,
                          fontFamily: AppTheme.primaryFont,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botón Iniciar Sesión
                  CustomFilledButton(
                    text: _isLoading ? 'Iniciando sesión...' : 'Iniciar Sesión',
                    onPressed: _isLoading ? null : _handleLogin,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Separador
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'o',
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Botón de huella digital
                  OutlinedButton(
                    onPressed: () {
                      context.pushNamed('local-auth-screen');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentColor,
                      side: BorderSide(color: AppColors.accentColor.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.fingerprint),
                        SizedBox(width: 12),
                        Text(
                          'Ingresar con huella',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Link a registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes cuenta?',
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.7),
                          fontFamily: AppTheme.primaryFont,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.pushNamed(RegisterScreen.name);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        child: Text(
                          'Regístrate aquí',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryColor,
                            fontFamily: AppTheme.primaryFont,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}