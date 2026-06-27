import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;

  const MovieCard({super.key, required this.movie, this.onTap});

  String _getPrimaryGenreName(List<int> genreIds) {
    if (genreIds.isEmpty) return 'Sin género';
    
    final genres = {
      28: "Acción", 12: "Aventura", 16: "Animación", 35: "Comedia",
      80: "Crimen", 99: "Documental", 18: "Drama", 10751: "Familia",
      14: "Fantasía", 36: "Historia", 27: "Terror", 10402: "Música",
      9648: "Misterio", 10749: "Romance", 878: "Ciencia Ficción",
      10770: "Película de TV", 53: "Suspense", 10752: "Bélica", 37: "Western"
    };

    final names = genreIds.map((id) => genres[id]).where((name) => name != null).cast<String>();
    
    // Para las tarjetas pequeñas, es mejor mostrar solo el PRIMER género 
    // para que el texto no se salga de la pantalla.
    return names.isEmpty ? 'Desconocido' : names.first; 
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2440),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      movie.posterPath,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF1A2440),
                        child: const Icon(Icons.movie_outlined,
                            color: Colors.white24, size: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
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
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.secondaryFont,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _getPrimaryGenreName(movie.genreIds),
                    style: TextStyle(
                      fontFamily: AppTheme.secondaryFont,
                      color: Colors.white38,
                      fontSize: 11,
                    ),
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
