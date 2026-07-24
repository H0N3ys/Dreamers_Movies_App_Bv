import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

class ProfileListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final bool isAddButton;
  final String? avatarUrl;
  final VoidCallback onTap;

  const ProfileListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.isSelected = false,
    this.isAddButton = false,
    this.avatarUrl,
    required this.onTap,
  });

  ImageProvider<Object>? _buildAvatarProvider() {
    if (isAddButton) return null;

    final source = avatarUrl?.trim() ?? '';
    if (source.isEmpty) {
      return NetworkImage('https://i.pravatar.cc/150?u=${title.replaceAll(' ', '')}');
    }

    if (source.startsWith('http')) {
      return NetworkImage(source);
    }

    final file = File(source);
    if (file.existsSync()) {
      return FileImage(file);
    }

    return NetworkImage('https://i.pravatar.cc/150?u=${title.replaceAll(' ', '')}');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isAddButton ? Colors.black26 : Colors.transparent,
              backgroundImage: _buildAvatarProvider(),
              child: isAddButton ? const Icon(Icons.add, color: Colors.white54, size: 28) : null,
            ),
            const SizedBox(width: 16),
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
                  ],
                ],
              ),
            ),
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
