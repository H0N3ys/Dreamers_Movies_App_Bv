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

  String _getGenres(List<int> genreIds) {
    if (genreIds.isEmpty) return 'Película';
    final genres = {
      28: "Acción", 12: "Aventura", 16: "Animación", 35: "Comedia", 80: "Crimen",
      99: "Documental", 18: "Drama", 10751: "Familia", 14: "Fantasía", 36: "Historia",
      27: "Terror", 10402: "Música", 9648: "Misterio", 10749: "Romance", 878: "Ciencia Ficción",
      10770: "Película de TV", 53: "Suspense", 10752: "Bélica", 37: "Western",
    };
    final names = genreIds.map((id) => genres[id]).where((name) => name != null).cast<String>().take(3);
    return names.isEmpty ? 'Película' : names.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    final activeMovie = widget.movies[_currentIndex];

    return Container(
      // ⬇️⬇️⬇️ AQUÍ MODIFICAS LA ANCHURA DEL CONTENEDOR TRANSPARENTE ⬇️⬇️⬇️
      // "horizontal: 0" hace que el fondo abarque el 100% de la pantalla.
      // Si quieres que se despegue de los bordes del celular, súbelo a 4, 8 o 10.
      margin: const EdgeInsets.symmetric(horizontal: 12), 
      // ⬆️⬆️⬆️ ============================================================ ⬆️⬆️⬆️

      padding: const EdgeInsets.only(top: 25, bottom: 20),
      decoration: BoxDecoration(
        
        // ⬇️⬇️⬇️ AQUÍ MODIFICAS EL COLOR Y LA TRANSPARENCIA DEL CONTENEDOR ⬇️⬇️⬇️
        // Colors.black define el color (puedes cambiarlo a Colors.blue.shade900, por ejemplo).
        // .withOpacity(0.3) es la transparencia (0.0 es invisible, 1.0 es color sólido).
        color: const Color.fromARGB(255, 4, 12, 74).withOpacity(0.0),

        // ⬆️⬆️⬆️ ============================================================== ⬆️⬆️⬆️

        // Si el margin es 0, tal vez quieras bajar este 35 a 15 para que no sea tan curvo en los extremos.
        borderRadius: BorderRadius.circular(15), 
      ),
      child: Column(
        children: [
          // EL CARRUSEL
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
              enlargeFactor: 0.22, // Ajusta qué tan "atrás" se ven las cartas secundarias
              
              // ⬇️⬇️⬇️ AQUÍ MODIFICAS LA ANCHURA DE LAS PELÍCULAS ⬇️⬇️⬇️
              // viewportFraction determina el % de pantalla que ocupa la carta.
              // Lo subí de 0.65 a 0.75 para que la película principal se vea mucho más ancha.
              // Si le pones 0.85 se hará gigantesca.
              viewportFraction: 0.75, 
              // ⬆️⬆️⬆️ ================================================= ⬆️⬆️⬆️
              
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
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // Borde mantenido en 10
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.7),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),

          // TÍTULO DE LA PELÍCULA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedSwitcher(
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
                  fontSize: 22,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),

          // ETIQUETA IMDB Y GÉNEROS
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Row(
              key: ValueKey("info_${activeMovie.id}"),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const SizedBox(width: 12),
                Text(
                  _getGenres(activeMovie.genreIds),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // INDICADORES (DOTS)
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