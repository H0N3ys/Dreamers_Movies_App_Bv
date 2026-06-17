// lib/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_text_field.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_filled_button.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/login_screen.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/supabase_datasource.dart';

class RegisterScreen extends StatefulWidget {
  static const name = 'register-screen';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Las contraseñas no coinciden');
      return;
    }
    
    if (_passwordController.text.length < 6) {
      _showError('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'nombres': _nombresController.text.trim(),
          'apellidos': _apellidosController.text.trim(),
          'telefono': _telefonoController.text.trim(),
        },
      );

      if (response.user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro exitoso! Ahora inicia sesión'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        _nombresController.clear();
        _apellidosController.clear();
        _emailController.clear();
        _telefonoController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        
        context.pushNamed(LoginScreen.name);
      }
    } on AuthException catch (e) {
      _showError(SupabaseHelper.getErrorMessage(e));
    } catch (e) {
      _showError('Error al registrar: $e');
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
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  
                  // Título
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 28,
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
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Crear cuenta',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontFamily: AppTheme.secondaryFont,
                        ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  CustomTextField(
                    label: 'Nombres',
                    hintText: 'Carlos Adrian',
                    icon: Icons.person_outline,
                    controller: _nombresController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tus nombres';
                      }
                      if (value.length < 2) {
                        return 'Nombre muy corto';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    label: 'Apellidos',
                    hintText: 'Zamorano Rodriguez',
                    icon: Icons.person_outline,
                    controller: _apellidosController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tus apellidos';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    label: 'Correo Electrónico',
                    hintText: 'ejemplo@correo.com',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu correo';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    label: 'Teléfono (opcional)',
                    hintText: '998 000 0000',
                    icon: Icons.phone_iphone_outlined,
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.isNotEmpty && value.length < 8) {
                        return 'Teléfono inválido';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    label: 'Contraseña',
                    hintText: 'Mínimo 6 caracteres',
                    icon: Icons.lock_outline,
                    obscureText: true, 
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa una contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    label: 'Confirmar Contraseña',
                    hintText: 'Repite tu contraseña',
                    icon: Icons.lock_outline,
                    obscureText: true,  
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirma tu contraseña';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  CustomFilledButton(
                    text: _isLoading ? 'Creando cuenta...' : 'Crear Cuenta',
                    onPressed: _isLoading ? null : _handleRegister,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TextButton(
                    onPressed: () {
                      context.pushNamed(LoginScreen.name);
                    },
                    child: Text(
                      '¿Ya tienes cuenta? Inicia sesión aquí',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: AppTheme.primaryFont,
                            color: AppColors.secondaryColor,
                          ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
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
    _nombresController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}