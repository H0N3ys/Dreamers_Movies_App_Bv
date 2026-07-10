import 'package:dreamers_movies_app_bv/presentation/widgets/errors/CinexaAnimatedLogo_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'dart:async';
import 'package:dio/dio.dart';

class CinexaErrorScreen extends StatefulWidget {
  final CinexaErrorType errorType;
  final String title;
  final String message;

  const CinexaErrorScreen({
    super.key,
    required this.errorType,
    required this.title,
    required this.message,
  });

  @override
  State<CinexaErrorScreen> createState() => _CinexaErrorScreenState();
}

class _CinexaErrorScreenState extends State<CinexaErrorScreen> {
  Timer? _retryTimer;
  final Dio _dio = Dio();
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // Iniciamos un temporizador que se ejecuta cada 3 segundos
    _retryTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkStatusAndReturn();
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel(); // Limpiamos el timer al salir
    super.dispose();
  }

  Future<void> _checkStatusAndReturn() async {
    if (_isChecking) return; // Evitamos hacer peticiones dobles
    _isChecking = true;

    try {
      // Hacemos un ping rápido a un sitio muy estable (Google) 
      // para saber si ya regresó el internet.
      final response = await _dio.get(
        'https://google.com',
        options: Options(
          receiveTimeout: const Duration(seconds: 2),
          sendTimeout: const Duration(seconds: 2),
        ),
      );

      if (response.statusCode == 200) {
        // ¡Ya hay internet o el problema se solucionó!
        _retryTimer?.cancel();
        if (mounted) {
          // context.go('/') reemplaza la pila de navegación, 
          // obligando a la app a recargar el Home desde cero.
          context.go('/'); 
        }
      }
    } catch (e) {
      // Si sigue fallando, no hacemos nada. 
      // El temporizador lo volverá a intentar en 3 segundos.
    } finally {
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // PopScope es el widget mágico que bloquea el botón de "atrás" del celular
    return PopScope(
      canPop: false, 
      child: Scaffold(
        backgroundColor: AppColors.secondaryColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CinexaAnimatedLogo(errorType: widget.errorType, size: 160),
                
                const SizedBox(height: 40),
                
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 48),

                // Un indicador visual para que el usuario sepa que la app 
                // está intentando reconectar automáticamente
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(
                        color: Colors.amber, 
                        strokeWidth: 2
                      )
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Reconectando...',
                      style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}