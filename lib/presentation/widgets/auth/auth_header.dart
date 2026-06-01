import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/theme/app_colors.dart'; 

class AuthHeader extends StatelessWidget {
  final String title;
  final IconData icon; // <-- 1. Agregamos esta variable

  const AuthHeader({
    super.key, 
    required this.title,
    this.icon = Icons.movie_creation_rounded, // <-- 2. Ícono por defecto
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon, // <-- 3. Usamos la variable aquí
          size: 100, 
          color: AppColors.primary,
        ),
        const SizedBox(height: 20),
        Text(
          title, 
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}