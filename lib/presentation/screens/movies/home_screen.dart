import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/movie_datasources.dart';
import 'package:dreamers_movies_app_bv/infrastructure/datasources/tmdb_datasource.dart';

class HomeScreen extends StatefulWidget {
  static const name = 'home-screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MovieDatasources _movieDatasource = TmdbDatasource();
  
  // Ahora tenemos dos listas vivas
  List<Movie> _nowPlayingMovies = [];
  List<Movie> _popularMoviesApi = [];
  bool _isLoadingMovies = true;

  int _currentBannerIndex = 0;
  int _selectedCategoryIndex = 0;
  int _currentNavIndex = 0;

  final List<String> _categories = ['Todo', 'Comedia', 'Animación', 'Documentales'];

  @override
  void initState() {
    super.initState();
    _loadAllMovies();
  }

  Future<void> _loadAllMovies() async {
    try {
      // Pedimos ambas listas al mismo tiempo
      final nowPlaying = await _movieDatasource.getNowPlaying();
      final popular = await _movieDatasource.getPopular();
      
      setState(() {
        _nowPlayingMovies = nowPlaying;
        // Tomamos solo las primeras 6 para que el carrusel superior no sea eterno
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: _isLoadingMovies 
            ? const Center(child: CircularProgressIndicator(color: AppColors.secondaryColor))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // 1. HEADER
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white54,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hola, Pablo',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontFamily: AppTheme.primaryFont,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Veamos tu película favorita',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white70,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white70),
                            onPressed: () async {
                              await Supabase.instance.client.auth.signOut();
                              if (context.mounted) {
                                context.goNamed('login-screen');
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. BUSCADOR
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(Icons.search, color: Colors.white70),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Busca una película',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 3. CARRUSEL HERO (CONECTADO A LA API)
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: PageController(viewportFraction: 0.85),
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() {
                            _currentBannerIndex = index;
                          });
                        },
                        itemCount: _popularMoviesApi.length,
                        itemBuilder: (context, index) {
                          final movie = _popularMoviesApi[index];
                          // Usamos backdropPath porque es una imagen horizontal, ideal para banners
                          final imageUrl = movie.backdropPath.isNotEmpty ? movie.backdropPath : movie.posterPath;
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                  stops: const [0.4, 1.0],
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                movie.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 4. INDICADOR DE PUNTOS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _popularMoviesApi.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentBannerIndex == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentBannerIndex == index ? Colors.white : Colors.white38,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 5. CATEGORÍAS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Categorías',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedCategoryIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryIndex = index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected ? Border.all(color: AppColors.secondaryColor.withOpacity(0.5)) : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _categories[index],
                                style: TextStyle(
                                  color: isSelected ? AppColors.secondaryColor : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 6. EN CARTELERA (CONECTADO A LA API)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'En Cartelera',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _nowPlayingMovies.length,
                        itemBuilder: (context, index) {
                          final movie = _nowPlayingMovies[index];
                          return Container(
                            width: 140,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C2434),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                        child: Image.network(
                                          movie.posterPath,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => 
                                              const Icon(Icons.error, color: Colors.white),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star, color: Colors.orange, size: 14),
                                              const SizedBox(width: 4),
                                              Text(
                                                movie.voteAverage.toStringAsFixed(1),
                                                style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
      
      // 7. BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(color: Color(0xFF12192B)),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home_filled, label: 'Inicio', index: 0),
              _buildNavItem(icon: Icons.search, label: '', index: 1),
              _buildNavItem(icon: Icons.download_rounded, label: '', index: 2),
              _buildNavItem(icon: Icons.person_outline, label: '', index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.secondaryColor : Colors.white54,
            ),
            if (isSelected && label.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}