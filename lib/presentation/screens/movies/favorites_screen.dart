import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/movie_card.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_bottom_nav.dart';
import 'package:like_button/like_button.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/database_helper.dart';
import 'package:dreamers_movies_app_bv/domain/repositories/user_repositories.dart';

class FavoritesScreen extends StatefulWidget {
  static const name = 'favorites-screen';
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final UserRepository _userRepository = UserRepository();
  
  List<Movie> _favoriteMovies = [];
  bool _isLoading = true;
  int? _currentProfileId;

  @override
  void initState() {
    super.initState();
    _loadFavoritesFromDB();
  }

  Future<void> _loadFavoritesFromDB() async {
    try {
      // 1. Obtenemos el usuario actual
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        final db = await _dbHelper.database;
        final profileResult = await db.query(
          'perfil',
          where: 'id_usuario = ?',
          whereArgs: [user.id],
          limit: 1,
        );

        if (profileResult.isNotEmpty) {
          _currentProfileId = profileResult.first['id_perfil'] as int;
          
          // 2. Traemos SOLO los favoritos de este perfil
          final favsData = await _dbHelper.getFavoriteMoviesByUser(_currentProfileId!);
          
          final List<Movie> loadedMovies = favsData.map((data) {
            return Movie(
              id: data['id_pelicula'] as int,
              title: data['titulo'] as String,
              posterPath: data['caratula_url'] as String,
              backdropPath: '',
              voteAverage: 5.0, // Valor por defecto si no lo guardaste en BD
              releaseDate: DateTime.now(),
              adult: false,
              genreIds: [],
              originalLanguage: '',
              originalTitle: '',
              overview: data['descripcion'] ?? '',
              popularity: 0.0,
              video: false,
              voteCount: 0,
            );
          }).toList();

          if (mounted) {
            setState(() {
              _favoriteMovies = loadedMovies;
              _isLoading = false;
            });
          }
          return;
        }
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      print('Error cargando favoritos de la BD: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavoriteFast(int movieId) async {
    if (_currentProfileId == null) return;
    
    // Lo borramos de la base de datos de este usuario específico
    await _dbHelper.removeFavoriteLocal(_currentProfileId!, movieId);

    setState(() {
      _favoriteMovies.removeWhere((m) => m.id == movieId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mis Favoritos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : _favoriteMovies.isEmpty
          ? const Center(
              child: Text(
                'Aún no tienes películas favoritas 💔',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _favoriteMovies.length,
              itemBuilder: (context, index) {
                final movie = _favoriteMovies[index];
                return GestureDetector(
                  onTap: () => context
                      .pushNamed('movie-details', extra: movie)
                      .then((_) => _loadFavoritesFromDB()),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MovieCard(movie: movie),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: LikeButton(
                            size: 24,
                            isLiked: true,
                            circleColor: const CircleColor(
                              start: Colors.pinkAccent,
                              end: Colors.red,
                            ),
                            bubblesColor: const BubblesColor(
                              dotPrimaryColor: Colors.red,
                              dotSecondaryColor: Colors.white,
                            ),
                            likeBuilder: (bool isLiked) {
                              return Icon(
                                isLiked ? Icons.favorite : Icons.heart_broken,
                                color: isLiked ? Colors.red : Colors.white54,
                                size: 22,
                              );
                            },
                            onTap: (bool isLiked) async {
                              Future.delayed(
                                const Duration(milliseconds: 450),
                                () {
                                  if (mounted) {
                                    _removeFavoriteFast(movie.id);
                                  }
                                },
                              );
                              return !isLiked;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: const HomeBottomNav(), 
    );
  }
}