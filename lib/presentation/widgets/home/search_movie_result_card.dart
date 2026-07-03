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

  // Helper para convertir el ID del género en texto
  String _getGenreName(List<int> genreIds) {
    if (genreIds.isEmpty) return 'Movie';
    final map = {
      28: 'Action', 12: 'Adventure', 16: 'Animation', 35: 'Comedy',
      80: 'Crime', 99: 'Documentary', 18: 'Drama', 10751: 'Family',
      14: 'Fantasy', 36: 'History', 27: 'Horror', 10402: 'Music',
      9648: 'Mystery', 10749: 'Romance', 878: 'Sci-Fi', 10770: 'TV Movie',
      53: 'Thriller', 10752: 'War', 37: 'Western'
    };
    return map[genreIds.first] ?? 'Movie';
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = badge == MovieBadgeType.premium;
    final mainGenre = _getGenreName(movie.genreIds); 

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
                      style: const TextStyle(
                        fontFamily: AppTheme.secondaryFont,
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Titulo dinámico
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTheme.secondaryFont,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // El año dinámico
                  _MetaRow(
                    icon: Icons.calendar_today_outlined,
                    text: movie.releaseDate.year.toString(),
                  ),

                  const SizedBox(height: 6),

                  // Idioma original y Clasificación (En negro)
                  Row(
                    children: [
                      const Icon(Icons.language_rounded,
                          color: Colors.white38, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        movie.originalLanguage.toUpperCase(),
                        style: const TextStyle(
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
                          color: Colors.black45, // Aquí aplicamos el fondo oscuro
                          border: Border.all(color: Colors.white24, width: 1), // Borde gris sutil
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '+13', 
                          style: TextStyle(
                            color: Colors.white70, // Texto más limpio
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Género dinámico + type
                  Row(
                    children: [
                      const Icon(Icons.grid_view_rounded,
                          color: Colors.white38, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        mainGenre,
                        style: const TextStyle(
                          fontFamily: AppTheme.secondaryFont,
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                          width: 1, height: 12, color: Colors.white24),
                      const SizedBox(width: 10),
                      const Text(
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
          style: const TextStyle(
            fontFamily: AppTheme.secondaryFont,
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}