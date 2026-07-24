import 'dart:ui'; // 🔥 IMPORTANTE: Necesario para el efecto de desenfoque (blur)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

class HomeBannerCarousel extends StatefulWidget {
  final List<Movie> movies;

  const HomeBannerCarousel({super.key, required this.movies});

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  int _currentIndex = 0;

  // Helper que devuelve la lista de géneros
  List<String> _getGenresList(List<int> genreIds) {
    if (genreIds.isEmpty) return ['Película'];
    final genres = {
      28: "Acción", 12: "Aventura", 16: "Animación", 35: "Comedia", 80: "Crimen",
      99: "Documental", 18: "Drama", 10751: "Familia", 14: "Fantasía", 36: "Historia",
      27: "Terror", 10402: "Música", 9648: "Misterio", 10749: "Romance", 878: "Ciencia Ficción",
      10770: "Película de TV", 53: "Suspense", 10752: "Bélica", 37: "Western",
    };
    final names = genreIds.map((id) => genres[id]).whereType<String>().take(3).toList();
    return names.isEmpty ? ['Película'] : names;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 10),
      child: Column(
        children: [
          // =========================================================
          // 1. EL CARRUSEL (CON EFECTO 3D, PUNTUACIÓN Y GÉNEROS INTEGRADOS)
          // =========================================================
          CarouselSlider.builder(
            itemCount: widget.movies.length,
            options: CarouselOptions(
              height: 400.0, // 🔥 Aumenté un poco la altura para lucir mejor el póster
              autoPlay: true, 
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              enlargeStrategy: CenterPageEnlargeStrategy.zoom, 
              enlargeFactor: 0.35, 
              viewportFraction: 0.75, 
              enableInfiniteScroll: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            itemBuilder: (context, index, realIndex) {
              final movie = widget.movies[index];
              final imageUrl = movie.posterPath.isNotEmpty
                  ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
                  : 'https://image.tmdb.org/t/p/w500${movie.backdropPath}';

              final isActive = _currentIndex == index;

              return GestureDetector(
                onTap: () => context.pushNamed('movie-details', extra: movie),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15), 
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.95),
                              blurRadius: 25,
                              spreadRadius: 2,
                              offset: const Offset(0, 15),
                            )
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 1. Imagen de fondo original con su filtro para los inactivos
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(isActive ? 0.0 : 0.6), 
                            BlendMode.darken,
                          ),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
                          ),
                        ),
                        
                        // 🔥 2. Puntuación (Esquina superior derecha) - Solo se muestra en la peli central
                        if (isActive)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    movie.voteAverage.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // 🔥 3. Contenedor inferior translúcido para Géneros - Solo en la peli central
                        if (isActive)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: ClipRRect(
                              // Redondeamos solo la parte de abajo para que encaje con la imagen
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4), // Fondo oscuro translúcido
                                  ),
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: _getGenresList(movie.genreIds).map((genre) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white30, width: 1.0),
                                        ),
                                        child: Text(
                                          genre,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),

          // =========================================================
          // 2. INDICADORES (DOTS) EN LA PARTE INFERIOR
          // =========================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.movies.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: _currentIndex == index ? 24 : 6,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}