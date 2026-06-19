import 'package:dreamers_movies_app_bv/domain/datasources/supabase_datasource.dart';
import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/movie_datasources.dart';
import 'package:dreamers_movies_app_bv/infrastructure/datasources/tmdb_datasource.dart';

import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_header.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_search_bar.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_banner_carousel.dart';
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
  // Instanciamos el datasource de reseñas
  final SupabaseReviewsDatasource _reviewsDatasource = SupabaseReviewsDatasource();

  List<Movie> _nowPlayingMovies = [];
  List<Movie> _popularMoviesApi = [];
  bool _isLoadingMovies = true;

  int _selectedCategoryIndex = 0;
  int _currentNavIndex = 0;

  final List<String> _categories = [
    'Todo',
    'Comedia',
    'Animación',
    'Documentales',
  ];

  @override
  void initState() {
    super.initState();
    _loadAllMovies();
  }

  Future<void> _loadAllMovies() async {
    try {
      final nowPlaying = await _movieDatasource.getNowPlaying();
      final popular = await _movieDatasource.getPopular();

      setState(() {
        _nowPlayingMovies = nowPlaying;
        _popularMoviesApi = popular.take(6).toList();
        _isLoadingMovies = false;
      });
    } catch (e) {
      setState(() => _isLoadingMovies = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar películas de TMDB')),
        );
      }
    }
  }


Future<void> _submitReview(Movie movie, int rating, String comment) async {
    try {
      final supabaseClient = Supabase.instance.client;
      final currentUser = supabaseClient.auth.currentUser;

      if (currentUser == null) {
        throw Exception('No hay una sesión activa. Inicia sesión de nuevo.');
      }

      // 1. Obtener el id_usuario desde el auth_user_id
      final userResp = await supabaseClient
          .from('usuario')
          .select('id_usuario')
          .eq('auth_user_id', currentUser.id)
          .single();

      // 2. Obtener el id_perfil usando el id_usuario
      final perfilResp = await supabaseClient
          .from('perfil')
          .select('id_perfil')
          .eq('id_usuario', userResp['id_usuario'])
          .limit(1)
          .single();

      final int perfilIdActual = perfilResp['id_perfil'];

      // 3. Guardar la reseña usando tu Datasource
      await _reviewsDatasource.saveReview(
        movie: movie,
        idPerfil: perfilIdActual, // ¡Ya usamos el ID real!
        rating: rating,
        comment: comment,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Tu reseña se ha guardado!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReviewModal(BuildContext context, Movie movie) {
    int currentRating = 5;
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reseñar: ${movie.title}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text('Puntuación:', style: TextStyle(color: Colors.white70)),
                  Slider(
                    value: currentRating.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: currentRating.toString(),
                    activeColor: Colors.amber,
                    onChanged: (double value) {
                      setModalState(() {
                        currentRating = value.toInt();
                      });
                    },
                  ),

                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '¿Qué te pareció la película?',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _submitReview(
                          movie,
                          currentRating,
                          commentController.text,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Guardar Reseña',
                        style: TextStyle(
                          color: Colors.black, 
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      extendBody: true,
      body: _isLoadingMovies
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  //header
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  const SliverToBoxAdapter(child: HomeHeader()),

                  //barra de busquedAA
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  const SliverToBoxAdapter(child: HomeSearchBar()),

                  //carrusel
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverToBoxAdapter(
                    child: HomeBannerCarousel(movies: _popularMoviesApi),
                  ),

                  // las categorias
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverToBoxAdapter(
                    child: HomeSectionHeader(title: 'Categorías'),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: HomeCategoryFilter(
                      categories: _categories,
                      selectedIndex: _selectedCategoryIndex,
                      onCategorySelected: (index) {
                        setState(() => _selectedCategoryIndex = index);
                      },
                    ),
                  ),

                  // más popular
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(
                    child: HomeSectionHeader(
                      title: 'Most popular',
                      onSeeAll: () {},
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 230,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        itemCount: _nowPlayingMovies.length,
                        itemBuilder: (context, index) {
                          final movie = _nowPlayingMovies[index];
                          // Envolvemos el MovieCard para detectar el clic
                          return GestureDetector(
                            onTap: () => _showReviewModal(context, movie),
                            child: MovieCard(movie: movie),
                          );
                        },
                      ),
                    ),
                  ),

                  //en cartelera
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  SliverToBoxAdapter(
                    child: HomeSectionHeader(
                      title: 'En Cartelera',
                      onSeeAll: () {},
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 230,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        itemCount: _popularMoviesApi.length,
                        itemBuilder: (context, index) {
                          final movie = _popularMoviesApi[index];
                          // Envolvemos el MovieCard para detectar el clic
                          return GestureDetector(
                            onTap: () => _showReviewModal(context, movie),
                            child: MovieCard(movie: movie),
                          );
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),

      //boton nav
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
      ),
    );
  }
}