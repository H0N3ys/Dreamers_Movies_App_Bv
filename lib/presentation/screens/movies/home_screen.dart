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
  List<Movie> _upcomingMovies = []; // Nueva lista
  

  List<Movie> _allMoviesPool = []; 
  List<Movie> _filteredMovies = []; 
  
  List<Map<String, dynamic>> _recentReviews = [];

  bool _isLoadingMovies = true;
  int _selectedCategoryIndex = 0;
  int _currentNavIndex = 0;

  // Categorías con sus IDs oficiales de TMDB
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Todo', 'id': 0},
    {'name': 'Acción', 'id': 28},
    {'name': 'Comedia', 'id': 35},
    {'name': 'Ciencia Ficción', 'id': 878},
    {'name': 'Animación', 'id': 16},
    {'name': 'Terror', 'id': 27},
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
        _movieDatasource.getUpcoming(), // Cargamos la nueva sección
        _loadRecentReviews(),
      ]);

      setState(() {
        _nowPlayingMovies = results[0] as List<Movie>;
        _popularMoviesApi = results[1] as List<Movie>;
        _topRatedMovies = results[2] as List<Movie>;
        _upcomingMovies = results[3] as List<Movie>;
        
       
        _allMoviesPool = [
          ..._nowPlayingMovies, 
          ..._popularMoviesApi, 
          ..._topRatedMovies, 
          ..._upcomingMovies
        ];
        
        // Elimina duplicados por ID para que no salgan repetidas en el filtro
        final Map<int, Movie> uniqueMovies = {for (var m in _allMoviesPool) m.id: m};
        _allMoviesPool = uniqueMovies.values.toList();
        
        // Al inicio, la sección filtrada muestra las populares
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
      print('Error cargando reseñas: $e');
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
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage('https://image.tmdb.org/t/p/w500${movie.backdropPath}'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  movie.title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper para crear filas horizontales estilo Netflix
  Widget _buildMovieRow(List<Movie> movies) {
    if (movies.isEmpty) {
      return const SizedBox(
        height: 230, 
        child: Center(child: Text('No hay películas', style: TextStyle(color: Colors.white54)))
      );
    }
    return SizedBox(
      height: 230,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extraemos solo los nombres de la lista de mapas para el widget HomeCategoryFilter
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

                  // Carrusel Destacado (En Cartelera)
                  SliverToBoxAdapter(child: _buildAnimatedCarousel(_nowPlayingMovies.take(6).toList())),

                  // Filtro por Categorías
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverToBoxAdapter(child: HomeSectionHeader(title: 'Explorar')),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: HomeCategoryFilter(
                      categories: categoryNames,
                      selectedIndex: _selectedCategoryIndex,
                      onCategorySelected: _filterByCategory,
                    ),
                  ),

                  // Fila 1: Resultados del Filtro o Populares
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(
                    child: HomeSectionHeader(
                      title: _selectedCategoryIndex == 0 ? 'Tendencias actuales' : 'Resultados de tu filtro',
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(child: _buildMovieRow(_filteredMovies)),

                  // Fila 2: Próximos Estrenos
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(child: HomeSectionHeader(title: 'Próximos Estrenos')),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(child: _buildMovieRow(_upcomingMovies)),

                  // Fila 3: Aclamadas por la crítica
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(child: HomeSectionHeader(title: 'Aclamadas por la crítica')),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(child: _buildMovieRow(_topRatedMovies)),

                  // Sección: Reseñas de la Comunidad
                  const SliverToBoxAdapter(child: SizedBox(height: 36)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        'Actividad de la comunidad',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  
                  if (_recentReviews.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 22),
                        child: Text('Aún no hay reseñas. ¡Sé el primero!', style: TextStyle(color: Colors.white54)),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final review = _recentReviews[index];
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
                                        Text('${review['puntuacion']}/5', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                        },
                        childCount: _recentReviews.length,
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