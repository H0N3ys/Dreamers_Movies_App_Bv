import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/theme/app_theme.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const AuthHeader({
    super.key,
    required this.title,
    this.icon = Icons.movie_creation_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 100, color: AppTheme.primaryColor),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
