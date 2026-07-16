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

    if (widget.errorType == CinexaErrorType.noConnection) {
      _retryTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        _checkStatusAndReturn();
      });
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatusAndReturn() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final response = await _dio.get(
        'https://google.com',
        options: Options(
          receiveTimeout: const Duration(seconds: 2),
          sendTimeout: const Duration(seconds: 2),
        ),
      );

      if (response.statusCode == 200) {
        _retryTimer?.cancel();

        if (mounted) {
          context.go('/');
        }
      }
    } catch (_) {
      // Sigue sin conexión
    } finally {
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    String bigText;
    
    // Utilizamos el color azul de tu clase global
    Color accentColor = AppColors.secondaryColor;

    switch (widget.errorType) {
      case CinexaErrorType.notFound404:
        bigText = "404";
        break;

      case CinexaErrorType.server500:
        bigText = "500"; 
        break;

      case CinexaErrorType.noConnection:
        bigText = "OFF";
        break;
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF202020),
                Color(0xFF101010),
                Colors.black,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    /// Número gigante de fondo
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        
                        // FittedBox previene que el texto se deforme en pantallas pequeñas
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            bigText,
                            style: TextStyle(
                              fontSize: 180,
                              fontWeight: FontWeight.w900,
                              // AUMENTAMOS LA OPACIDAD DE .08 a .30 PARA QUE SEA MÁS VISIBLE
                              color: accentColor.withOpacity(0.3),
                              letterSpacing: 10,
                            ),
                          ),
                        ),

                        CinexaAnimatedLogo(
                          errorType: widget.errorType,
                          size: 170,
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 17,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 55),

                    if (widget.errorType == CinexaErrorType.noConnection)
                      Column(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: accentColor, 
                            ),
                          ),

                          const SizedBox(height: 18),

                          Text(
                            "Reconectando...",
                            style: TextStyle(
                              color: accentColor, 
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}