import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';

import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/movie_datasources.dart';
import 'package:dreamers_movies_app_bv/infrastructure/datasources/tmdb_datasource.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/local_reviews_datasource.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/database_helper.dart';

import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_header.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_search_bar.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_category_filter.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_section_header.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/movie_card.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_bottom_nav.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_reviews.dart'; 

class HomeScreen extends StatefulWidget {
  static const name = 'home-screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MovieDatasources _movieDatasource = TmdbDatasource();
  final LocalReviewsDatasource _reviewsDatasource = LocalReviewsDatasource();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Movie> _nowPlayingMovies = [];
  List<Movie> _popularMoviesApi = [];
  List<Movie> _topRatedMovies = [];
  List<Movie> _upcomingMovies = [];
  List<Movie> _mostViewedMovies = []; 
  List<Movie> _topMexicoMovies = []; 

  List<Movie> _allMoviesPool = []; 
  List<Movie> _filteredMovies = []; 
  
  List<Map<String, dynamic>> _recentReviews = [];

  bool _isLoadingMovies = true;
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Todo', 'id': 0},
    {'name': 'Acción', 'id': 28},
    {'name': 'Comedia', 'id': 35},
    {'name': 'Ciencia Ficción', 'id': 878},
    {'name': 'Animación', 'id': 16},
    {'name': 'Terror', 'id': 27},
  ];

  final List<ReviewData> _staticReviews = const [
    ReviewData(
      userName: 'María González',
      userAvatar: '',
      rating: 4.8,
      reviewText: 'Una película que te mantiene al borde del asiento. La fotografía es espectacular y las actuaciones son de primer nivel.',
      movieTitle: 'Dune: Parte Dos',
      reviewDate: 'Hoy',
    ),
    ReviewData(
      userName: 'Carlos Martínez',
      userAvatar: '',
      rating: 4.5,
      reviewText: 'Increíble secuela que supera a la primera entrega. Los efectos visuales son impresionantes.',
      movieTitle: 'El Planeta de los Simios: Nuevo Reino',
      reviewDate: 'Ayer',
    ),
    ReviewData(
      userName: 'Ana Rodríguez',
      userAvatar: '',
      rating: 5.0,
      reviewText: '¡Simplemente perfecta! No tengo palabras para describir lo mucho que disfruté esta película.',
      movieTitle: 'Oppenheimer',
      reviewDate: 'Hace 2 días',
    ),
    ReviewData(
      userName: 'Jorge Pérez',
      userAvatar: '',
      rating: 4.2,
      reviewText: 'Muy entretenida y con un mensaje profundo. Me encantó cómo desarrollaron los personajes.',
      movieTitle: 'Barbie',
      reviewDate: 'Hace 3 días',
    ),
    ReviewData(
      userName: 'Laura Sánchez',
      userAvatar: '',
      rating: 4.7,
      reviewText: 'Una historia emocionante que te hace reflexionar sobre la vida y las decisiones.',
      movieTitle: 'Poor Things',
      reviewDate: 'Hace 4 días',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait([
        _movieDatasource.getNowPlaying(),
        _movieDatasource.getPopular(),
        _movieDatasource.getTopRated(),
        _movieDatasource.getUpcoming(),
        _loadMostViewedMovies(), 
        _loadTopMexicoMovies(), 
        _loadRecentReviews(),
      ]);

      setState(() {
        _nowPlayingMovies = results[0] as List<Movie>;
        _popularMoviesApi = results[1] as List<Movie>;
        _topRatedMovies = results[2] as List<Movie>;
        _upcomingMovies = results[3] as List<Movie>;
        _mostViewedMovies = results[4] as List<Movie>;
        _topMexicoMovies = results[5] as List<Movie>;
        
        _allMoviesPool = [
          ..._nowPlayingMovies, 
          ..._popularMoviesApi, 
          ..._topRatedMovies, 
          ..._upcomingMovies,
          ..._mostViewedMovies,
          ..._topMexicoMovies,
        ];
        
        final Map<int, Movie> uniqueMovies = {for (var m in _allMoviesPool) m.id: m};
        _allMoviesPool = uniqueMovies.values.toList();
        
        _filteredMovies = _popularMoviesApi; 
        _isLoadingMovies = false;
      });
    } catch (e) {
      setState(() => _isLoadingMovies = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  // Trae películas de la PÁGINA 2 para que sean distintas
  Future<List<Movie>> _loadMostViewedMovies() async {
    try {
      final popular = await _movieDatasource.getPopular(page: 2);
      return popular.take(10).toList();
    } catch (e) {
      return [];
    }
  }

  // Trae estrenos de la PÁGINA 2 para que varíe la lista
  Future<List<Movie>> _loadTopMexicoMovies() async {
    try {
      final nowPlaying = await _movieDatasource.getNowPlaying(page: 2);
      return nowPlaying.take(10).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _loadRecentReviews() async {
    try {
      final db = await _dbHelper.database;
      final reviews = await db.rawQuery('''
        SELECT r.puntuacion, r.comentario, r.fecha_creacion, p.titulo, p.caratula_url, u.nombres as autor
        FROM resena r
        JOIN pelicula p ON r.id_pelicula = p.id_pelicula
        JOIN perfil pr ON r.id_perfil = pr.id_perfil
        JOIN usuario u ON pr.id_usuario = u.id_usuario
        ORDER BY r.fecha_creacion DESC
        LIMIT 5
      ''');
      setState(() => _recentReviews = reviews);
    } catch (e) {
      debugPrint('Error cargando reseñas: $e');
    }
  }

  void _filterByCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      if (index == 0) {
        _filteredMovies = _popularMoviesApi;
      } else {
        final int targetGenreId = _categories[index]['id'];
        _filteredMovies = _allMoviesPool.where((movie) {
          return movie.genreIds.contains(targetGenreId); 
        }).toList();
      }
    });
  }

  // CARRUSEL ACTUALIZADO CON EFECTO DE SOMBRA / "SHADE"
  Widget _buildAnimatedCarousel(List<Movie> movies) {
    if (movies.isEmpty) return const SizedBox();
    return CarouselSlider.builder(
      itemCount: movies.length,
      options: CarouselOptions(
        height: 220.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        viewportFraction: 0.85,
        enableInfiniteScroll: true,
      ),
      itemBuilder: (context, index, realIndex) {
        final movie = movies[index];
        return GestureDetector(
          onTap: () => context.pushNamed('movie-details', extra: movie),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // Añade profundidad y hace que la tarjeta "salte" a la vista
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              image: DecorationImage(
                image: NetworkImage('https://image.tmdb.org/t/p/w500${movie.backdropPath}'),
                fit: BoxFit.cover,
                // Quitamos el colorFilter plano de aquí
              ),
            ),
            child: Container(
              // Gradiente suave: Transparente arriba, negro oscuro abajo
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.95),
                  ],
                  stops: const [0.4, 0.7, 1.0],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMovieRow(List<Movie> movies) {
    if (movies.isEmpty) {
      return const SizedBox(
        height: 230, 
        child: Center(child: Text('No hay películas', style: TextStyle(color: Colors.white54)))
      );
    }
    return SizedBox(
      height: 230,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              AppColors.accentColor.withValues(alpha: 0.05),
              AppColors.accentColor,
              AppColors.accentColor,
              AppColors.accentColor.withValues(alpha: 0.05),
              Colors.transparent,
            ],
            stops: const [0.0, 0.03, 0.1, 0.88, 0.97, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return GestureDetector(
              onTap: () => context.pushNamed('movie-details', extra: movie),
              child: MovieCard(movie: movie),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categoryNames = _categories.map((c) => c['name'] as String).toList();

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      extendBody: true,
      body: _isLoadingMovies
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  const SliverToBoxAdapter(child: HomeHeader()),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  const SliverToBoxAdapter(child: HomeSearchBar()),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // Carrusel Destacado
                  SliverToBoxAdapter(child: _buildAnimatedCarousel(_nowPlayingMovies.take(6).toList())),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverToBoxAdapter(child: HomeSectionHeader(title: 'Explorar', onSeeAll: () => context.go('/search'))),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: HomeCategoryFilter(
                      categories: categoryNames,
                      selectedIndex: _selectedCategoryIndex,
                      onCategorySelected: _filterByCategory,
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(
                    child: HomeSectionHeader(
                      title: _selectedCategoryIndex == 0 ? 'Tendencias actuales' : 'Resultados de tu filtro',
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(child: _buildMovieRow(_filteredMovies)),

                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(
                    child: HomeSectionHeader(title: '🔥 Lo más visto'),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(child: _buildMovieRow(_mostViewedMovies)),

                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(
                    child: HomeSectionHeader(title: '🇲🇽 Top en México'),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(child: _buildMovieRow(_topMexicoMovies)),

                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(child: HomeSectionHeader(title: 'Próximos Estrenos')),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(child: _buildMovieRow(_upcomingMovies)),

                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(child: HomeSectionHeader(title: 'Aclamadas por la crítica')),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(child: _buildMovieRow(_topRatedMovies)),

                  const SliverToBoxAdapter(child: SizedBox(height: 36)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        '⭐ Actividad de la comunidad',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        HomeReviews(reviews: _staticReviews),
                        
                        if (_recentReviews.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            child: Divider(color: Colors.white24),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 22),
                            child: Text(
                              'Últimas reseñas de la comunidad',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._recentReviews.map((review) {
                            return Container(
                              margin: const EdgeInsets.only(left: 22, right: 22, bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        review['autor'] ?? 'Usuario',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text('${review['puntuacion']}/5', 
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Reseñó: ${review['titulo']}',
                                    style: const TextStyle(color: AppColors.accentColor, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    review['comentario'] ?? '',
                                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
      bottomNavigationBar: const HomeBottomNav(),
    );
  }
}