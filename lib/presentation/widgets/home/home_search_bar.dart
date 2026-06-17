import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12, width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search_rounded, color: Colors.white54, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Busca una película',
                style: TextStyle(
                  fontFamily: AppTheme.secondaryFont,
                  color: Colors.white38,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              width: 1,
              height: 24,
              color: Colors.white12,
            ),
            const SizedBox(width: 14),
            const Icon(Icons.tune_rounded, color: Colors.white54, size: 20),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
