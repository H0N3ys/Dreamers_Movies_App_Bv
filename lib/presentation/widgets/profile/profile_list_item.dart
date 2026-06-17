import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

class ProfileListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final bool isAddButton;
  final VoidCallback onTap;

  const ProfileListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.isSelected = false,
    this.isAddButton = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // El Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAddButton ? Colors.black26 : Colors.white54,
              ),
              child: isAddButton 
                  ? const Icon(Icons.add, color: Colors.white54, size: 28)
                  : null, // Aquí podrías poner un NetworkImage si tuvieras avatares
            ),
            
            const SizedBox(width: 16),
            
            // Los Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTheme.secondaryFont,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontFamily: AppTheme.secondaryFont,
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            
            // Etiqueta de "Seleccionado"
            if (isSelected)
              Text(
                'Seleccionado',
                style: TextStyle(
                  fontFamily: AppTheme.secondaryFont,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}