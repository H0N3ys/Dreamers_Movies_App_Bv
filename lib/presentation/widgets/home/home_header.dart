import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Lado Izquierdo: Logo y texto (Estilo Figma)
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24, 
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/logoBueno.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: AppTheme.primaryFont,
                    fontWeight: FontWeight.bold,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Ci',
                      style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                    TextSpan(
                      text: 'nexa',
                      style: TextStyle(color: Colors.white), 
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Lado Derecho: Ícono de Búsqueda
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white, size: 28),
            onPressed: () {
              // Navegar a la pantalla de búsqueda
              context.push('/search'); 
            },
          ),
        ],
      ),
    );
  }
}