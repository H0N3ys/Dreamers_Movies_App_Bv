import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_text_field.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_filled_button.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/login_screen.dart';
import 'package:dreamers_movies_app_bv/domain/repositories/user_repositories.dart';

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
  
  final UserRepository _userRepository = UserRepository();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Expresiones regulares para validaciones estrictas
  final RegExp _nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp _passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,16}$');

  

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _userRepository.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nombres: _nombresController.text.trim(),
        apellidos: _apellidosController.text.trim(),
        telefono: _telefonoController.text.trim(),
      );

      if (user != null && mounted) {
        // 1. ANTES DE NAVEGAR, le damos su "pase VIP" al usuario guardando la sesión
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', user.id); // Si tu entidad tiene ID
        await prefs.setString('user_nombres', user.nombres ?? '');
        await prefs.setString('user_apellidos', user.apellidos ?? '');
        await prefs.setString('user_email', user.email);
        await prefs.setBool('is_logged_in', true);
        await prefs.setBool('session_unlocked', true);
        await prefs.setBool('first_login_completed', true);

        // Mostrar éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro exitoso! Bienvenido'),
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
        
        context.go('/');
      }
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      // Llamamos al repositorio que se encarga de todo el flujo
      final user = await _userRepository.loginWithGoogle();
      
      if (user != null && mounted) {
        // 1. ANTES DE NAVEGAR, le damos su "pase VIP" al usuario guardando la sesión
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', user.id); // Si tu entidad tiene ID
        await prefs.setString('user_nombres', user.nombres ?? '');
        await prefs.setString('user_apellidos', user.apellidos ?? '');
        await prefs.setString('user_email', user.email);
        await prefs.setBool('is_logged_in', true);
        await prefs.setBool('session_unlocked', true);
        await prefs.setBool('first_login_completed', true);

        // Mostrar éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro exitoso! Bienvenido'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Redirigir a la pantalla principal de tu app (Cinexa)
        
        context.go('/');
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
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  
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
                    label: 'Nombre(s)',
                    hintText: 'Ej. Carlos Adrian',
                    icon: Icons.person_outline,
                    controller: _nombresController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tu(s) nombre(s)';
                      }
                      if (value.trim().length < 3) {
                        return 'El nombre es muy corto';
                      }
                      if (!_nameRegex.hasMatch(value)) {
                        return 'Solo se permiten letras';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    label: 'Apellido(s)',
                    hintText: 'Ej. Zamorano Rodriguez',
                    icon: Icons.person_outline,
                    controller: _apellidosController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tu(s) apellido(s)';
                      }
                      if (value.trim().length < 3) {
                        return 'El apellido es muy corto';
                      }
                      if (!_nameRegex.hasMatch(value)) {
                        return 'Solo se permiten letras';
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
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tu correo';
                      }
                      if (!_emailRegex.hasMatch(value.trim())) {
                        return 'Ingresa un formato de correo válido';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // NOTA: Asegúrate de que tu CustomTextField acepte la propiedad 'inputFormatters' y 'maxLength' si quieres limitar la UI.
                  // Si no la tiene, la validación de abajo de todos modos bloqueará el envío.
                  CustomTextField(
                    label: 'Teléfono (10 dígitos)',
                    hintText: 'Ej. 9981234567',
                    icon: Icons.phone_iphone_outlined,
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    
                    maxLength: 10, // 👈 Bloquea el teclado al llegar a 10 caracteres
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // 👈 Bloquea y no deja escribir letras ni símbolos
                      LengthLimitingTextInputFormatter(10),   // 👈 Refuerza el límite máximo de 10
                    ],
                    
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (value.length != 10) {
                          return 'Debe tener exactamente 10 dígitos';
                        }
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    label: 'Contraseña',
                    hintText: 'Ingrese Contraseña',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa una contraseña';
                      }
                      if (!_passwordRegex.hasMatch(value)) {
                        return 'Debe tener 8-16 caracteres, 1 mayúscula, 1 número y 1 carácter especial';
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

                  // Botón de Google Sign In
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Image.network(
                      'https://cdn.freebiesupply.com/logos/thumbs/2x/google-g-2015-logo.png',
                      height: 24,
                    ), // Puedes cambiar esto por un asset local si prefieres
                    label: Text(
                      'Continuar con Google',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
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