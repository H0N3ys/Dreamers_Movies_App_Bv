import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';

class Error500Screen extends StatelessWidget {
  const Error500Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor, // Fondo idéntico a tu Home
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // === PUNTO 3: ESPACIO RESERVADO PARA TU FUTURO LOGO ===
              Icon(
                Icons.wifi_off_rounded,
                size: 120,
                color: Colors.redAccent.withOpacity(0.8),
              ),
              const SizedBox(height: 32),
              const Text(
                'Conexión interrumpida',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Nuestros servidores de películas están tomando un respiro. Por favor, intenta de nuevo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => context.go('/'),
                  child: const Text(
                    'Reintentar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}