import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

enum MovieBadgeType { premium, free }

class SearchMovieResultCard extends StatelessWidget {
  final Movie movie;
  final MovieBadgeType badge;
  final VoidCallback? onTap;

  const SearchMovieResultCard({
    super.key,
    required this.movie,
    this.badge = MovieBadgeType.premium,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPremium = badge == MovieBadgeType.premium;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    movie.posterPath,
                    width: 120,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 140,
                      color: const Color(0xFF1A2440),
                      child: const Icon(Icons.movie_outlined,
                          color: Colors.white24, size: 40),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFB800), size: 13),
                        const SizedBox(width: 3),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Color(0xFFFFB800),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // Informacion
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPremium
                          ? const Color(0xFFFF7A00)
                          : const Color(0xFF00C2C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isPremium ? 'Premium' : 'Free',
                      style: TextStyle(
                        fontFamily: AppTheme.secondaryFont,
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Titulo
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.secondaryFont,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // el año
                  _MetaRow(
                    icon: Icons.calendar_today_outlined,
                    text: movie.releaseDate.year.toString(),
                  ),

                  const SizedBox(height: 6),

                  // Duracion y clasificación
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          color: Colors.white38, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '148 Minutes',
                        style: TextStyle(
                          fontFamily: AppTheme.secondaryFont,
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent, width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PG-13',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Genre + type
                  Row(
                    children: [
                      const Icon(Icons.grid_view_rounded,
                          color: Colors.white38, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Action',
                        style: TextStyle(
                          fontFamily: AppTheme.secondaryFont,
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                          width: 1, height: 12, color: Colors.white24),
                      const SizedBox(width: 10),
                      Text(
                        'Movie',
                        style: TextStyle(
                          fontFamily: AppTheme.secondaryFont,
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 14),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontFamily: AppTheme.secondaryFont,
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
