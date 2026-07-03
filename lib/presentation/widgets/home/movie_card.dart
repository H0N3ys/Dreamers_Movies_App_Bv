import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final int? activeGenreId; 

  const MovieCard({
    super.key, 
    required this.movie, 
    this.onTap,
    this.activeGenreId,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _isHovered = false;

  
  String _getPrimaryGenreName(List<int> genreIds, int? activeGenreId) {
    if (genreIds.isEmpty) return 'Sin género';
    
    final genres = {
      28: "Acción", 12: "Aventura", 16: "Animación", 35: "Comedia",
      80: "Crimen", 99: "Documental", 18: "Drama", 10751: "Familia",
      14: "Fantasía", 36: "Historia", 27: "Terror", 10402: "Música",
      9648: "Misterio", 10749: "Romance", 878: "Ciencia Ficción",
      10770: "Película de TV", 53: "Suspense", 10752: "Bélica", 37: "Western"
    };

    
    if (activeGenreId != null && activeGenreId != 0 && genreIds.contains(activeGenreId)) {
      return genres[activeGenreId] ?? 'Desconocido';
    }

    
    final names = genreIds.map((id) => genres[id]).where((name) => name != null).cast<String>();
    return names.isEmpty ? 'Desconocido' : names.first; 
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) {
          setState(() => _isHovered = false);
          
          if (widget.onTap != null) widget.onTap!(); 
        },
        onTapCancel: () => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0, 
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 130,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2440),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered ? Colors.white.withAlpha(50) : Colors.transparent,
                width: 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.white.withAlpha(30),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 0),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withAlpha(76),
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
                          widget.movie.posterPath,
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
                            color: Colors.black.withAlpha(165),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Color(0xFFFFB800), size: 13),
                              const SizedBox(width: 3),
                              Text(
                                widget.movie.voteAverage.toStringAsFixed(1),
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
                        widget.movie.title,
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
                        
                        _getPrimaryGenreName(widget.movie.genreIds, widget.activeGenreId),
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
        ),
      ),
    );
  }
}