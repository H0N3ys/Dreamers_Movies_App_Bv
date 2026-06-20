
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

class LocalAuthScreen extends StatefulWidget {
  static const name = 'local-auth-screen';
  const LocalAuthScreen({super.key});

  @override
  State<LocalAuthScreen> createState() => _LocalAuthScreenState();
}

class _LocalAuthScreenState extends State<LocalAuthScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  String _estado = 'Por favor, verifica tu identidad';
  bool _estaAutenticando = false;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      setState(() {
        _isBiometricAvailable = isAvailable && isDeviceSupported;
        if (!_isBiometricAvailable) {
          _estado = 'Tu dispositivo no soporta biometría';
        }
      });
    } catch (e) {
      setState(() {
        _estado = 'Error al verificar biometría';
      });
    }
  }

Future<void> _autenticar() async {
    if (!_isBiometricAvailable) {
      setState(() {
        _estado = 'Biometría no disponible en este dispositivo';
      });
      return;
    }

    try {
      setState(() {
        _estaAutenticando = true;
        _estado = 'Autenticando...';
      });

      final autenticado = await _localAuth.authenticate(
        localizedReason: 'Accede a tu cuenta de Cinexa con tu huella digital',
      );

      setState(() => _estaAutenticando = false);

      if (autenticado && mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('huella_enabled', true);
        
        // --- AQUÍ ESTÁ EL CAMBIO CLAVE ---
        await prefs.setBool('session_unlocked', true); 
        // ---------------------------------
        
        if (mounted) {
          context.go('/');
        }
      } else {
        setState(() {
          _estado = 'No se pudo verificar la huella';
        });
      }
    } catch (e) {
      setState(() {
        _estaAutenticando = false;
        _estado = 'Error de biometría: ${e.toString().split('\n').first}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 120,
                  color: _isBiometricAvailable 
                      ? AppColors.accentColor 
                      : Colors.grey,
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  'Acceso Seguro',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: AppTheme.primaryFont,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  _estado,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.secondaryFont,
                    color: _isBiometricAvailable ? Colors.black87 : Colors.red,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                ElevatedButton(
                  onPressed: _estaAutenticando || !_isBiometricAvailable 
                      ? null 
                      : _autenticar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _estaAutenticando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.fingerprint, color: Colors.white),
                            const SizedBox(width: 12),
                            const Text(
                              'Ingresar con huella',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                ),
                
                const SizedBox(height: 24),
                
                TextButton(
                  onPressed: () {
                    context.goNamed('login-screen');
                  },
                  child: Text(
                    'Usar correo y contraseña',
                    style: TextStyle(
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
    );
  }
}