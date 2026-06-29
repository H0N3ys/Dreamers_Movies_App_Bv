import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';

import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/movie_datasources.dart';
import 'package:dreamers_movies_app_bv/infrastructure/datasources/tmdb_datasource.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/local_reviews_datasource.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/database_helper.dart';

import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_header.dart';
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
  List<Movie> _upcomingMovies = []; 

  List<Movie> _allMoviesPool = []; 
  List<Movie> _filteredMovies = []; 
  
  List<Map<String, dynamic>> _recentReviews = [];

  bool _isLoadingMovies = true;
  int _selectedCategoryIndex = 0;
  int _currentNavIndex = 0;

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
        height: 300.0,
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
        bool isHovered = false; 
        
        return StatefulBuilder(
          builder: (context, setState) {
            return MouseRegion(
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: GestureDetector(
                onTapDown: (_) => setState(() => isHovered = true),
                onTapUp: (_) {
                  setState(() => isHovered = false);
                  context.pushNamed('movie-details', extra: movie);
                },
                onTapCancel: () => setState(() => isHovered = false),
                child: AnimatedScale(
                  scale: isHovered ? 1.05 : 1.0, // Flota y crece un 5% (bien notable)
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack, // Mini rebote elegante al crecer
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isHovered ? Colors.white.withAlpha(150) : Colors.white.withAlpha(30),
                        width: isHovered ? 2.0 : 1.0,
                      ),
                      boxShadow: isHovered
                          ? [
                              // Sombra profunda proyectada hacia abajo al flotar
                              BoxShadow(
                                color: Colors.black.withAlpha(200), 
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 12), 
                              ),
                              // Un brillo sutil alrededor para que resalte del fondo oscuro
                              BoxShadow(
                                color: Colors.white.withAlpha(40),
                                blurRadius: 15,
                                spreadRadius: 1,
                              )
                            ]
                          : [
                              // Sombra normal pegada al fondo
                              BoxShadow(
                                color: Colors.black.withAlpha(120),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                      image: DecorationImage(
                        image: NetworkImage('https://image.tmdb.org/t/p/w500${movie.backdropPath}'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withAlpha(77), BlendMode.darken),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          movie.title,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black, blurRadius: 4)]
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  // --- LÓGICA CORREGIDA PARA LAS FILAS INFINITAS ---
  Widget _buildMovieRow(List<Movie> movies, {int? activeGenreId}) {
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
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent, 
              Colors.white, 
              Colors.black, 
              Colors.transparent
            ],
            stops: [0.02, 0.10, 0.90, 1.0], 
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
            // Se quitó el GestureDetector externo para evitar conflicto
            // y se pasó todo directamente a MovieCard
            return MovieCard(
              movie: movie,
              activeGenreId: activeGenreId,
              onTap: () => context.pushNamed('movie-details', extra: movie),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categoryNames = _categories.map((c) => c['name'] as String).toList();
    // Obtener el ID activo de la categoría para mandarlo a las tarjetas filtradas
    final int? currentGenreId = _selectedCategoryIndex == 0 ? null : _categories[_selectedCategoryIndex]['id'] as int;

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
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  SliverToBoxAdapter(child: _buildAnimatedCarousel(_nowPlayingMovies.take(6).toList())),

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

                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(
                    child: HomeSectionHeader(
                      title: _selectedCategoryIndex == 0 ? 'Tendencias actuales' : 'Resultados de tu filtro',
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  // --- SE MANDA EL ID AL FILTRO DE RESULTADOS ---
                  SliverToBoxAdapter(child: _buildMovieRow(_filteredMovies, activeGenreId: currentGenreId)),

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