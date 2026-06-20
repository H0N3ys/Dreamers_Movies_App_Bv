import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/movie_card.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_bottom_nav.dart';

class FavoritesScreen extends StatefulWidget {
  static const name = 'favorites-screen';
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Movie> _favoriteMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favsJson = prefs.getStringList('favorites_list') ?? [];
    
    final List<Movie> loadedMovies = favsJson.map((str) {
      final data = jsonDecode(str);
      // Reconstruimos el objeto para poder usarlo en tu MovieCard
      return Movie(
        id: data['id'],
        title: data['title'],
        posterPath: data['posterPath'],
        backdropPath: data['backdropPath'] ?? '',
        voteAverage: data['voteAverage'] ?? 0.0,
        releaseDate: DateTime.tryParse(data['releaseDate'] ?? '') ?? DateTime.now(),
        // Datos de relleno genéricos porque solo necesitamos la portada y el título
        adult: false, genreIds: [], originalLanguage: '', originalTitle: '', 
        overview: '', popularity: 0.0, video: false, voteCount: 0,
      );
    }).toList();

    setState(() {
      _favoriteMovies = loadedMovies;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mis Favoritos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
        : _favoriteMovies.isEmpty
          ? const Center(
              child: Text(
                'Aún no tienes películas favoritas 💔', 
                style: TextStyle(color: Colors.white54, fontSize: 16)
              )
            )
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Dos columnas
                childAspectRatio: 0.65, // Proporción vertical para el póster
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _favoriteMovies.length,
              itemBuilder: (context, index) {
                final movie = _favoriteMovies[index];
                return GestureDetector(
                  onTap: () => context.pushNamed('movie-details', extra: movie).then((_) => _loadFavorites()), // Recarga al volver por si lo quitaste
                  child: MovieCard(movie: movie), 
                );
              },
            ),
      bottomNavigationBar: const HomeBottomNav(), // La misma barra inteligente
    );
  }
}