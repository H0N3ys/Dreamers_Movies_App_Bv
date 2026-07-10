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

    final activeMovie = widget.movies[_currentIndex];
    
    // 🔥 Calculamos el ancho exacto del carrusel (75% de la pantalla)
    final double carouselWidth = MediaQuery.of(context).size.width * 0.75;

    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 10),
      child: Column(
        children: [
          // =========================================================
          // 1. INFORMACIÓN SUPERIOR (Limitada al ancho de la película)
          // =========================================================
          SizedBox(
            width: carouselWidth, // 🔥 Esto "ancla" el texto a la imagen
            child: Column(
              children: [
                // TÍTULO
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    activeMovie.title,
                    key: ValueKey("title_${activeMovie.id}"),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.secondaryFont,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),

                // ETIQUETA IMDB Y GÉNEROS (Usando Wrap por si ocupan 2 líneas)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Wrap(
                    key: ValueKey("info_${activeMovie.id}"),
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8, // Espacio horizontal
                    runSpacing: 8, // Espacio vertical si bajan de línea
                    children: [
                      // Contenedor IMDb
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "IMDb ${activeMovie.voteAverage.toStringAsFixed(1)}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      
                      // Pastillas de géneros
                      ..._getGenresList(activeMovie.genreIds).map((genre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white54, width: 1.0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            genre,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // =========================================================
          // 2. EL CARRUSEL (CON EFECTO 3D Y FILTRO OSCURO)
          // =========================================================
          CarouselSlider.builder(
            itemCount: widget.movies.length,
            options: CarouselOptions(
              height: 380.0,
              autoPlay: true, 
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              enlargeStrategy: CenterPageEnlargeStrategy.zoom, 
              enlargeFactor: 0.35, // Profundidad 3D extrema
              viewportFraction: 0.75, // Mismo 75% del SizedBox superior
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
                    child: ColorFiltered(
                      // Filtro mágico que oscurece un 60% a las películas del fondo
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(isActive ? 0.0 : 0.6), 
                        BlendMode.darken,
                      ),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),

          // =========================================================
          // 3. INDICADORES (DOTS) EN LA PARTE INFERIOR
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