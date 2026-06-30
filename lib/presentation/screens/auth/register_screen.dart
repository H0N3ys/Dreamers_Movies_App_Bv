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
  
  // --- NODOS DE ENFOQUE (FocusNodes) ---
  final FocusNode _nombresFocus = FocusNode();
  final FocusNode _apellidosFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  
  final UserRepository _userRepository = UserRepository();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final RegExp _nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  
  // --- VARIABLES PARA LAS REGLAS EN VIVO ---
  // Reglas de Nombres
  bool _showNameRules = false;
  bool _isNameEmpty = true;
  bool _nameStartsWithUpper = false;
  bool _nameOnlyLetters = false;
  bool _nameCorrectCasing = false;

  // Reglas de Apellidos
  bool _showLastNameRules = false;
  bool _isLastNameEmpty = true;
  bool _lastNameStartsWithUpper = false;
  bool _lastNameOnlyLetters = false;
  bool _lastNameCorrectCasing = false;

  // Reglas de Correo
  bool _showEmailRules = false;
  bool _isEmailEmpty = true;
  bool _emailValidFormat = false;

  // Reglas de Contraseña 1
  bool _showPasswordRules = false;
  bool _isPasswordEmpty = true;
  bool _hasMinMax = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;

  // --- NUEVO: Reglas de Confirmar Contraseña ---
  bool _showConfirmPasswordRules = false;
  bool _isConfirmPasswordEmpty = true;
  bool _confirmHasMinMax = false;
  bool _confirmHasUppercase = false;
  bool _confirmHasNumber = false;
  bool _confirmHasSpecial = false;
  bool _passwordsMatch = false;

  // Variable para guardar el código seleccionado del paquete
  String _selectedCountryCode = '+52';

  @override
  void initState() {
    super.initState();
    _nombresFocus.addListener(_onFocusChange);
    _apellidosFocus.addListener(_onFocusChange);
    _emailFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
    _confirmPasswordFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _showNameRules = _nombresFocus.hasFocus;
      _showLastNameRules = _apellidosFocus.hasFocus;
      _showEmailRules = _emailFocus.hasFocus;
      
      // Separamos los focus de las contraseñas
      _showPasswordRules = _passwordFocus.hasFocus;
      _showConfirmPasswordRules = _confirmPasswordFocus.hasFocus;
    });
  }

  // --- LÓGICA DE VALIDACIÓN EN VIVO ---
  void _checkNameRules(String value) {
    setState(() {
      _isNameEmpty = value.isEmpty;
      _nameStartsWithUpper = value.isNotEmpty && RegExp(r'^[A-ZÁÉÍÓÚÑ]').hasMatch(value);
      _nameOnlyLetters = value.isNotEmpty && _nameRegex.hasMatch(value);
      _nameCorrectCasing = value.isNotEmpty && RegExp(r'^[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+(\s[a-záéíóúñ]+)*$').hasMatch(value);
    });
  }

  void _checkLastNameRules(String value) {
    setState(() {
      _isLastNameEmpty = value.isEmpty;
      _lastNameStartsWithUpper = value.isNotEmpty && RegExp(r'^[A-ZÁÉÍÓÚÑ]').hasMatch(value);
      _lastNameOnlyLetters = value.isNotEmpty && _nameRegex.hasMatch(value);
      _lastNameCorrectCasing = value.isNotEmpty && RegExp(r'^[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+(\s[a-záéíóúñ]+)*$').hasMatch(value);
    });
  }

  void _checkEmailRules(String value) {
    setState(() {
      _isEmailEmpty = value.isEmpty;
      _emailValidFormat = value.isNotEmpty && _emailRegex.hasMatch(value.trim());
    });
  }

  void _checkPasswordRules(String value) {
    setState(() {
      _isPasswordEmpty = value.isEmpty;
      _hasMinMax = value.length >= 8 && value.length <= 16;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasNumber = value.contains(RegExp(r'[0-9]'));
      _hasSpecial = value.contains(RegExp(r'[\W_]'));
      
      // Validamos en tiempo real si ya coincide con lo que hay en confirmar
      _passwordsMatch = value.isNotEmpty && value == _confirmPasswordController.text;
    });
  }

  // --- NUEVO: Validar la segunda contraseña ---
  void _checkConfirmPasswordRules(String value) {
    setState(() {
      _isConfirmPasswordEmpty = value.isEmpty;
      _confirmHasMinMax = value.length >= 8 && value.length <= 16;
      _confirmHasUppercase = value.contains(RegExp(r'[A-Z]'));
      _confirmHasNumber = value.contains(RegExp(r'[0-9]'));
      _confirmHasSpecial = value.contains(RegExp(r'[\W_]'));
      
      // Valida si coinciden de forma exacta
      _passwordsMatch = value.isNotEmpty && value == _passwordController.text;
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_passwordsMatch) {
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

  // Generador de reglas genérico para usarlo en todos lados
  Widget _buildDynamicRule(String text, bool isValid, bool isEmpty) {
    Color color;
    IconData icon;
    if (isEmpty) {
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
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 12),
            ),
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
                  
                  // --- SECCIÓN NOMBRES ---
                  CustomTextField(
                    label: 'Nombre(s)',
                    hintText: 'Ej. Carlos adrian', 
                    icon: Icons.person_outline,
                    controller: _nombresController,
                    focusNode: _nombresFocus,
                    onChanged: _checkNameRules,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Ingresa tu(s) nombre(s)';
                      if (value.trim().length < 3) return 'El nombre es muy corto';
                      if (!_nameStartsWithUpper || !_nameOnlyLetters || !_nameCorrectCasing) return 'Revisa las reglas de nombre';
                      return null;
                    },
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      height: _showNameRules ? null : 0,
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDynamicRule('Iniciar con mayúscula', _nameStartsWithUpper, _isNameEmpty),
                          _buildDynamicRule('Solo letras (sin números ni símbolos)', _nameOnlyLetters, _isNameEmpty),
                          _buildDynamicRule('Coherencia (siguientes palabras en minúscula)', _nameCorrectCasing, _isNameEmpty),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // --- SECCIÓN APELLIDOS ---
                  CustomTextField(
                    label: 'Apellido(s)',
                    hintText: 'Ej. Zamorano rodriguez',
                    icon: Icons.person_outline,
                    controller: _apellidosController,
                    focusNode: _apellidosFocus,
                    onChanged: _checkLastNameRules,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Ingresa tu(s) apellido(s)';
                      if (value.trim().length < 3) return 'El apellido es muy corto';
                      if (!_lastNameStartsWithUpper || !_lastNameOnlyLetters || !_lastNameCorrectCasing) return 'Revisa las reglas de apellido';
                      return null;
                    },
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      height: _showLastNameRules ? null : 0,
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDynamicRule('Iniciar con mayúscula', _lastNameStartsWithUpper, _isLastNameEmpty),
                          _buildDynamicRule('Solo letras (sin números ni símbolos)', _lastNameOnlyLetters, _isLastNameEmpty),
                          _buildDynamicRule('Coherencia (siguientes palabras en minúscula)', _lastNameCorrectCasing, _isLastNameEmpty),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // --- SECCIÓN CORREO ---
                  CustomTextField(
                    label: 'Correo Electrónico',
                    hintText: 'ejemplo@correo.com',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: _checkEmailRules,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Ingresa tu correo';
                      if (!_emailValidFormat) return 'Ingresa un formato de correo válido';
                      return null;
                    },
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      height: _showEmailRules ? null : 0,
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDynamicRule('Formato válido (ej. correo@dominio.com)', _emailValidFormat, _isEmailEmpty),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    label: 'Teléfono (10 dígitos)',
                    hintText: '9981234567',
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
                      showDropDownButton: true, 
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
                  
                  // --- SECCIÓN CONTRASEÑA ---
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
                          _buildDynamicRule('De 8 a 16 caracteres', _hasMinMax, _isPasswordEmpty),
                          _buildDynamicRule('Al menos 1 letra mayúscula', _hasUppercase, _isPasswordEmpty),
                          _buildDynamicRule('Al menos 1 número', _hasNumber, _isPasswordEmpty),
                          _buildDynamicRule('Al menos 1 carácter especial', _hasSpecial, _isPasswordEmpty),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // --- SECCIÓN CONFIRMAR CONTRASEÑA ---
                  CustomTextField(
                    label: 'Confirmar Contraseña',
                    hintText: 'Repite tu contraseña',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    onChanged: _checkConfirmPasswordRules,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirma tu contraseña';
                      }
                      if (!_passwordsMatch) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),

                  // Caja de reglas exclusiva para Confirmar Contraseña
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      height: _showConfirmPasswordRules ? null : 0,
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDynamicRule('De 8 a 16 caracteres', _confirmHasMinMax, _isConfirmPasswordEmpty),
                          _buildDynamicRule('Al menos 1 letra mayúscula', _confirmHasUppercase, _isConfirmPasswordEmpty),
                          _buildDynamicRule('Al menos 1 número', _confirmHasNumber, _isConfirmPasswordEmpty),
                          _buildDynamicRule('Al menos 1 carácter especial', _confirmHasSpecial, _isConfirmPasswordEmpty),
                          // LA NUEVA REGLA REINA
                          _buildDynamicRule('Las contraseñas coinciden exactamente', _passwordsMatch, _isConfirmPasswordEmpty),
                        ],
                      ),
                    ),
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
    _nombresFocus.removeListener(_onFocusChange);
    _apellidosFocus.removeListener(_onFocusChange);
    _emailFocus.removeListener(_onFocusChange);
    _passwordFocus.removeListener(_onFocusChange);
    _confirmPasswordFocus.removeListener(_onFocusChange);

    _nombresFocus.dispose();
    _apellidosFocus.dispose();
    _emailFocus.dispose();
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