import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

class LocalAuthScreen extends StatefulWidget {
  static const name = 'local-auth-screen';

  const LocalAuthScreen({super.key});

  @override
  State<LocalAuthScreen> createState() => _LocalAuthScreenState();
}

class _LocalAuthScreenState extends State<LocalAuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _estado = 'Por favor, verifica tu identidad';
  bool _estaAutenticando = false;

  Future<void> _autenticar() async {
    try {
      setState(() {
        _estaAutenticando = true;
        _estado = 'Autenticando...';
      });

      final bool autenticado = await auth.authenticate(
        localizedReason: 'Accede a tu cuenta de Cinexa con tu huella digital',
        biometricOnly: true, // Antes iba dentro de "options"
        persistAcrossBackgrounding: true, // Esto es el nuevo "stickyAuth"
      );

      setState(() => _estaAutenticando = false);

      if (autenticado && mounted) {
        // Si la huella es correcta, va directo a la pantalla principal
        context.goNamed('home-screen'); // Reemplaza por el nombre real de tu Home
      } else {
        setState(() => _estado = 'No se pudo verificar la huella');
      }
    } catch (e) {
      setState(() {
        _estaAutenticando = false;
        _estado = 'Error de biometría: $e';
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
                const Icon(
                  Icons.fingerprint,
                  size: 120,
                  color: AppColors.accentColor,
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
                  style: const TextStyle(fontFamily: AppTheme.secondaryFont),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _estaAutenticando ? null : _autenticar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  child: _estaAutenticando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Ingresar con huella',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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