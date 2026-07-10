import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

class HomeBottomNav extends StatelessWidget {
  
  const HomeBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    
    final String location = GoRouterState.of(context).uri.toString();
    
    int currentIndex = 0;
    if (location == '/') currentIndex = 0;
    else if (location.startsWith('/search')) currentIndex = 1;
    else if (location.startsWith('/favorites')) currentIndex = 2; // Favoritos
    else if (location.startsWith('/saved')) currentIndex = 3; // Guardados
    else if (location.startsWith('/profile')) currentIndex = 4; // Perfil

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1829),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_filled,
              label: 'Inicio',
              index: 0,
              currentIndex: currentIndex,
              onTap: (_) => context.go('/'), 
            ),
            _NavItem(
              icon: Icons.search_rounded,
              label: 'Buscar', 
              index: 1,
              currentIndex: currentIndex,
              onTap: (_) => context.go('/search'), 
            ),
            _NavItem(
              icon: Icons.favorite_rounded, 
              label: 'Favoritos',
              index: 2,
              currentIndex: currentIndex,
              onTap: (_) => context.go('/favorites'), 
            ),
            _NavItem(
              icon: Icons.bookmark_rounded, // Icono de guardados
              label: 'Guardados',
              index: 3,
              currentIndex: currentIndex,
              onTap: (_) => context.go('/saved'), 
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              label: 'Perfil',
              index: 4,
              currentIndex: currentIndex,
              onTap: (_) => context.go('/profile'), 
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected && label.isNotEmpty ? 18 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondaryColor.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white38,
              size: 24,
            ),
            if (isSelected && label.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.secondaryFont,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}