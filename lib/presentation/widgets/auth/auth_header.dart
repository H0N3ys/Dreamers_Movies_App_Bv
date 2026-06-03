import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/theme/app_colors.dart';

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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Icon(icon, size: 100, color: AppColors.accentColor),
        const SizedBox(height: 20),
        Text(
          title,
          style: textTheme.titleLarge,
        ),
      ],
    );
  }
}