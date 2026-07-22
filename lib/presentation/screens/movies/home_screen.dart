import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:dreamers_movies_app_bv/domain/datasources/database_helper.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/local_reviews_datasource.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/movie_datasources.dart';
import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/infrastructure/datasources/tmdb_datasource.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_bottom_nav.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_category_filter.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_header.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_reviews.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_search_bar.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_section_header.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/movie_card.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';

class HomeScreen extends StatefulWidget {
  static const name = 'home-screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MovieDatasources _movieDatasource = TmdbDatasource();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Movie> _nowPlayingMovies = [];
  List<Movie> _popularMoviesApi = [];
  List<Movie> _topRatedMovies = [];
  List<Movie> _upcomingMovies = [];
  List<Movie> _mostViewedMovies = [];
  List<Movie> _topMexicoMovies = [];
  List<Movie> _allMoviesPool = [];
  List<Movie> _filteredMovies = [];
  List<Map<String, dynamic>> _dbReviews = [];
  List<ReviewData> _recentReviews = [];

  bool _isLoadingMovies = true;
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Todo', 'id': 0},
    {'name': 'Acción', 'id': 28},
    {'name': 'Aventura', 'id': 12},
    {'name': 'Comedia', 'id': 35},
    {'name': 'Ciencia Ficción', 'id': 878},
    {'name': 'Animación', 'id': 16},
    {'name': 'Terror', 'id': 27},
    {'name': 'Drama', 'id': 18},
    {'name': 'Fantasía', 'id': 14},
    {'name': 'Romance', 'id': 10749},
    {'name': 'Misterio', 'id': 9648},
    {'name': 'Familia', 'id': 10751},
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
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDBReviews();
  }

  Future<void> _loadInitialData() async {
    try {
      final movieResults = await Future.wait([
        _movieDatasource.getNowPlaying(),
        _movieDatasource.getPopular(),
        _movieDatasource.getTopRated(),
        _movieDatasource.getUpcoming(),
      ]);

      final mostViewedMovies = await _loadMostViewedMovies();
      final topMexicoMovies = await _loadTopMexicoMovies();

      unawaited(_loadStaticReviews());

      if (!mounted) return;

      setState(() {
        _nowPlayingMovies = movieResults[0];
        _popularMoviesApi = movieResults[1];
        _topRatedMovies = movieResults[2];
        _upcomingMovies = movieResults[3];
        _mostViewedMovies = mostViewedMovies;
        _topMexicoMovies = topMexicoMovies;

        _allMoviesPool = [
          ..._nowPlayingMovies,
          ..._popularMoviesApi,
          ..._topRatedMovies,
          ..._upcomingMovies,
        ];

        final Map<int, Movie> uniqueMovies = {for (var movie in _allMoviesPool) movie.id: movie};
        _allMoviesPool = uniqueMovies.values.toList();
        _filteredMovies = _popularMoviesApi;
        _isLoadingMovies = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMovies = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  Future<List<Movie>> _loadMostViewedMovies() async {
    try {
      final popular = await _movieDatasource.getPopular(page: 2);
      return popular.take(10).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Movie>> _loadTopMexicoMovies() async {
    try {
      final nowPlaying = await _movieDatasource.getNowPlaying(page: 2);
      return nowPlaying.take(10).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _loadStaticReviews() async {
    if (!mounted) return;
    setState(() {
      _recentReviews = _staticReviews;
    });
  }

  Future<void> _loadDBReviews() async {
    try {
      final db = await _dbHelper.database;
      final reviews = await db.rawQuery('''
        SELECT r.puntuacion, r.comentario, r.fecha_creacion, p.titulo, p.caratula_url, u.nombres as autor
        FROM resena r
        JOIN pelicula p ON r.id_pelicula = p.id_pelicula
        JOIN perfil pr ON r.id_perfil = pr.id_perfil
        JOIN usuario u ON pr.id_usuario = u.id_usuario
        ORDER BY r.fecha_creacion DESC
        LIMIT 10
      ''');
      if (!mounted) return;
      setState(() {
        _dbReviews = reviews;
      });
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
        final int targetGenreId = _categories[index]['id'] as int;
        _filteredMovies = _allMoviesPool.where((movie) {
          return movie.genreIds.contains(targetGenreId);
        }).toList();
      }
    });
  }

  Widget _buildHeroCarousel(List<Movie> movies) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return CarouselSlider.builder(
      itemCount: movies.length,
      options: CarouselOptions(
        height: 220,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        viewportFraction: 0.9,
        enlargeCenterPage: true,
        enableInfiniteScroll: true,
      ),
      itemBuilder: (context, index, realIndex) {
        final movie = movies[index];
        return GestureDetector(
          onTap: () => context.pushNamed('movie-details', extra: movie),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  movie.backdropPath.isNotEmpty ? movie.backdropPath : movie.posterPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
        child: Center(
          child: Text('No hay películas', style: TextStyle(color: Colors.white54)),
        ),
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
            return MovieCard(
              movie: movie,
              onTap: () => context.pushNamed('movie-details', extra: movie),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    final reviews = _dbReviews.isNotEmpty
        ? _dbReviews.map((review) {
            return ReviewData(
              userName: review['autor']?.toString() ?? 'Usuario',
              userAvatar: '',
              rating: (review['puntuacion'] as num?)?.toDouble() ?? 0,
              reviewText: review['comentario']?.toString() ?? '',
              movieTitle: review['titulo']?.toString() ?? 'Película',
              reviewDate: review['fecha_creacion']?.toString(),
            );
          }).toList()
        : _recentReviews;

    return HomeReviews(reviews: reviews);
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
                  SliverToBoxAdapter(child: _buildHeroCarousel(_nowPlayingMovies.take(6).toList())),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverToBoxAdapter(
                    child: HomeSectionHeader(title: 'Explorar', onSeeAll: () => context.go('/search')),
                  ),
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
                  SliverToBoxAdapter(child: HomeSectionHeader(title: '🔥 Lo más visto')),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(child: _buildMovieRow(_mostViewedMovies)),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(child: HomeSectionHeader(title: '🇲🇽 Top en México')),
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
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(child: HomeSectionHeader(title: 'Reseñas recientes')),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(child: _buildReviewsSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
      bottomNavigationBar: const HomeBottomNav(),
    );
  }
}