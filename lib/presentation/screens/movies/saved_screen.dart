import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_bottom_nav.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/database_helper.dart';
import 'package:dreamers_movies_app_bv/domain/repositories/user_repositories.dart';

import 'package:dreamers_movies_app_bv/presentation/widgets/shared/app_refresh_indicator.dart';

class SavedScreen extends StatefulWidget {
  static const name = 'saved-screen';
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final UserRepository _userRepository = UserRepository();

  List<Movie> _savedMovies = [];
  bool _isLoading = true;
  int? _currentProfileId;

  @override
  void initState() {
    super.initState();
    _loadSavedFromDB();
  }

  Future<void> _loadSavedFromDB() async {
    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final activeProfileId = prefs.getInt('active_profile_id');
        if (activeProfileId != null) {
          _currentProfileId = activeProfileId;
          final savedData = await _dbHelper.getSavedMoviesByUser(_currentProfileId!);
          
          final List<Movie> loadedMovies = savedData.map((data) {
            return Movie(
              id: data['id_pelicula'] as int,
              title: data['titulo'] as String,
              posterPath: data['caratula_url'] as String,
              backdropPath: '',
              voteAverage: 5.0,
              releaseDate: DateTime.now(),
              adult: false, genreIds: [], originalLanguage: '', originalTitle: '', overview: '', popularity: 0.0, video: false, voteCount: 0,
            );
          }).toList();

          if (mounted) {
            setState(() {
              _savedMovies = loadedMovies;
              _isLoading = false;
            });
          }
          return;
        }
      }
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeSavedMovie(Movie movie) async {
    if (_currentProfileId == null) return;
    await _dbHelper.removeSavedLocal(_currentProfileId!, movie.id);
    
    setState(() {
      _savedMovies.removeWhere((m) => m.id == movie.id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Eliminado de guardados'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mis Guardados', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _loadSavedFromDB,
          ),
        ],
      ),
      body: AppRefreshIndicator(
        onRefresh: _loadSavedFromDB,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.amber))
            : _savedMovies.isEmpty
                ? CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.bookmark_border_rounded, color: Colors.white38, size: 80),
                              SizedBox(height: 16),
                              Text('Aún no tienes películas guardadas', style: TextStyle(color: Colors.white54, fontSize: 16)),
                              SizedBox(height: 8),
                              Text('Guarda tus películas para verlas después', style: TextStyle(color: Colors.white38, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.6, crossAxisSpacing: 12, mainAxisSpacing: 16,
                    ),
                    itemCount: _savedMovies.length,
                    itemBuilder: (context, index) {
                      final movie = _savedMovies[index];
                      return _SavedMovieCard(
                        movie: movie,
                        onTap: () => context.pushNamed('movie-details', extra: movie).then((_) => _loadSavedFromDB()),
                        onRemove: () => _removeSavedMovie(movie),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: const HomeBottomNav(),
    );
  }
}

class _SavedMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SavedMovieCard({required this.movie, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[850],
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.movie_outlined, color: Colors.white24, size: 50),
                      ),
                    ),
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8, left: 8, right: 8,
                      child: Text(
                        movie.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Positioned(
                      top: 8, left: 8,
                      child: GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                          child: const Icon(Icons.bookmark_rounded, color: Colors.amber, size: 18),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 12),
                            const SizedBox(width: 3),
                            Text(movie.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}