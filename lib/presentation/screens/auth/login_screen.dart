import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';
import 'package:dreamers_movies_app_bv/presentation/screens/auth/register_screen.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_text_field.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/custom_filled_button.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/divider_with_text.dart';
import 'package:dreamers_movies_app_bv/domain/repositories/user_repositories.dart';

class LoginScreen extends StatefulWidget {
  static const name = 'login-screen';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final UserRepository _userRepository = UserRepository();
  bool _isLoading = false;
  final bool _obscurePassword = true;

  // Variables para la nueva UI de sesión guardada
  bool _hasAccountSaved = false;
  String _savedName = '';
  bool _showBiometric = false;

  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _loadSavedAccount();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  
  Future<void> _loadSavedAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAccount = prefs.getBool('is_logged_in') ?? false;

    if (hasAccount) {
      setState(() {
        _hasAccountSaved = true;
        _savedName = prefs.getString('user_nombres') ?? 'Usuario';
        
        _emailController.text = prefs.getString('user_email') ?? '';
        
        _showBiometric = prefs.getBool('huella_enabled') ?? prefs.getBool('first_login_completed') ?? false;
      });
    }
  }

  
  Future<void> _cambiarDeCuenta() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Borra la sesión local
    
    setState(() {
      _hasAccountSaved = false;
      _emailController.clear();
      _passwordController.clear();
      _showBiometric = false;
    });
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', user.id);
        await prefs.setString('user_email', user.email);
        await prefs.setString('user_nombres', user.nombres ?? '');
        await prefs.setString('user_apellidos', user.apellidos ?? '');
        await prefs.setString('user_telefono', user.telefono ?? '');
        
        await prefs.setBool('is_logged_in', true);
        await prefs.setBool('session_unlocked', true);
        await prefs.setBool('first_login_completed', true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Bienvenido!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );

        final activeProfileId = await _userRepository.ensureActiveProfile(user.id);

        if (mounted) {
          if (activeProfileId != null) {
            context.go('/profile-picker');
          } else {
            context.go('/');
          }
        }
      } else {
        _showError('Contraseña incorrecta. Inténtalo de nuevo.');
      }
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    
    try {
      
      final user = await _userRepository.loginWithGoogle();

      
      if (user != null && mounted) {
        final prefs = await SharedPreferences.getInstance();

        
        await prefs.setString('user_id', user.id);
        await prefs.setString('user_email', user.email);
        await prefs.setString('user_nombres', user.nombres ?? '');
        await prefs.setString('user_apellidos', user.apellidos ?? '');
        await prefs.setString('user_telefono', user.telefono ?? '');
        
        await prefs.setBool('is_logged_in', true);
        await prefs.setBool('session_unlocked', true);
        await prefs.setBool('first_login_completed', true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido ${user.nombres}!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );

        await _userRepository.ensureActiveProfile(user.id);
        context.go('/profile-picker'); 
      }
    } catch (e) {
      print('Error Google Sign-In: $e');
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
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Se envió un correo de recuperación'),
                ),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    height: 120,
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
                  
                  const SizedBox(height: 8),

                  Text(
                    _hasAccountSaved 
                      ? 'Hola de nuevo, $_savedName'
                      : 'Más que películas, experiencias.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppTheme.secondaryFont,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  if (!_hasAccountSaved) ...[
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
                        // Regex estricto idéntico al de registro
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Ingresa un correo electrónico válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  
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
                      // Actualizado a 8 caracteres para coincidir con el registro
                      if (value.length < 8) {
                        return 'La contraseña debe tener al menos 8 caracteres';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showRecuperarPasswordDialog,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
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
                  
                  _isLoading 
                    ? const CircularProgressIndicator()
                    : CustomFilledButton(
                        text: _hasAccountSaved ? 'Desbloquear' : 'Iniciar Sesión',
                        onPressed: _handleLogin,
                      ),
                  
                  if (_hasAccountSaved) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _cambiarDeCuenta,
                      child: Text(
                        'Ingresar con otra cuenta',
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  if (_showBiometric) ..._buildBiometricSection(context),

                  
                  if (!_hasAccountSaved) ...[
                    const SizedBox(height: 24),
                    const DividerWithText(
                      text: 'O INICIA SESIÓN CON',
                      color: AppColors.secondaryColor,
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Image.network(
                        'https://cdn.freebiesupply.com/logos/thumbs/2x/google-g-2015-logo.png',
                        height: 24,
                      ),
                      label: Text(
                        'Continuar con Google',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                    ),
                    
                    const SizedBox(height: 24),
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
                          child: const Text(
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
                  ],
                  
                  const SizedBox(height: 20),
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
      const DividerWithText(
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
          icon: const Icon(Icons.fingerprint_rounded), 
          label: const Text('Entrar con huella'), 
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.secondaryColor,
            side: const BorderSide(color: AppColors.secondaryColor, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), 
            ),
          ),
        ),
      ),
    ];
  }
}