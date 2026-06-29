import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
// Importamos el nuevo paquete de banderas
import 'package:country_code_picker/country_code_picker.dart';

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
  
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  
  final UserRepository _userRepository = UserRepository();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final RegExp _nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  
  bool _isPasswordEmpty = true;
  bool _hasMinMax = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;
  bool _showPasswordRules = false;

  // Variable para guardar el código seleccionado del paquete
  String _selectedCountryCode = '+52';

  @override
  void initState() {
    super.initState();
    _passwordFocus.addListener(_onFocusChange);
    _confirmPasswordFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _showPasswordRules = _passwordFocus.hasFocus || _confirmPasswordFocus.hasFocus;
    });
  }

  void _checkPasswordRules(String value) {
    setState(() {
      _isPasswordEmpty = value.isEmpty;
      _hasMinMax = value.length >= 8 && value.length <= 16;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasNumber = value.contains(RegExp(r'[0-9]'));
      _hasSpecial = value.contains(RegExp(r'[\W_]'));
    });
  }

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
        // Juntamos el código seleccionado con el número limpio
        telefono: '$_selectedCountryCode ${_telefonoController.text.trim()}',
      );

      if (user != null && mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', user.id); 
        await prefs.setString('user_nombres', user.nombres ?? '');
        await prefs.setString('user_apellidos', user.apellidos ?? '');
        await prefs.setString('user_email', user.email);
        await prefs.setBool('is_logged_in', true);
        await prefs.setBool('session_unlocked', true);
        await prefs.setBool('first_login_completed', true);

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
      final user = await _userRepository.loginWithGoogle();
      
      if (user != null && mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', user.id); 
        await prefs.setString('user_nombres', user.nombres ?? '');
        await prefs.setString('user_apellidos', user.apellidos ?? '');
        await prefs.setString('user_email', user.email);
        await prefs.setBool('is_logged_in', true);
        await prefs.setBool('session_unlocked', true);
        await prefs.setBool('first_login_completed', true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro exitoso! Bienvenido'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
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

  Widget _buildPasswordRule(String text, bool isValid) {
    Color color;
    IconData icon;

    if (_isPasswordEmpty) {
      color = Colors.grey;
      icon = Icons.circle_outlined;
    } else if (isValid) {
      color = Colors.green;
      icon = Icons.check_circle;
    } else {
      color = Colors.red;
      icon = Icons.cancel;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12),
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
                  
             CustomTextField(
                    label: 'Teléfono (10 dígitos)',
                    hintText: '9981234567',
                    // Implementación Pro con indicador de menú
                    prefixWidget: CountryCodePicker(
                      onChanged: (countryCode) {
                        setState(() {
                          _selectedCountryCode = countryCode.dialCode ?? '+52';
                        });
                      },
                      initialSelection: 'MX',
                      favorite: const ['+52', 'MX', '+1', 'US'],
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: false,
                      // --- ESTA ES LA MEJORA ---
                      showDropDownButton: true, // Esto activa la flechita automática
                      // -------------------------
                      padding: const EdgeInsets.only(left: 4.0, right: 2.0),
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      flagWidth: 18,
                      searchDecoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Buscar país...',
                      ),
                    ),
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10, 
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, 
                      LengthLimitingTextInputFormatter(10),   
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
                    focusNode: _passwordFocus,
                    onChanged: _checkPasswordRules, 
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa una contraseña';
                      }
                      if (!_hasMinMax || !_hasUppercase || !_hasNumber || !_hasSpecial) {
                        return 'La contraseña no cumple todos los requisitos';
                      }
                      return null;
                    },
                  ),
                  
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      height: _showPasswordRules ? null : 0,
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPasswordRule('De 8 a 16 caracteres', _hasMinMax),
                          _buildPasswordRule('Al menos 1 letra mayúscula', _hasUppercase),
                          _buildPasswordRule('Al menos 1 número', _hasNumber),
                          _buildPasswordRule('Al menos 1 carácter especial', _hasSpecial),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    label: 'Confirmar Contraseña',
                    hintText: 'Repite tu contraseña',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
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
                    ), 
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
    _passwordFocus.removeListener(_onFocusChange);
    _confirmPasswordFocus.removeListener(_onFocusChange);
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    
    _nombresController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}