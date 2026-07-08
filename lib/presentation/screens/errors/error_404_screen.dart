import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';

class Error404Screen extends StatelessWidget {
  const Error404Screen({super.key});

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
              // Por ahora dejamos un icono elegante con el color de acento de tu app
              Icon(
                Icons.movie_filter_outlined,
                size: 120,
                color: AppColors.accentColor.withOpacity(0.8),
              ),
              const SizedBox(height: 32),
              const Text(
                '¿Te has perdido en el cine?',
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
                'La página o sección que buscas no está disponible en nuestra cartelera.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => context.go('/'),
                  child: const Text(
                    'Volver al Inicio',
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