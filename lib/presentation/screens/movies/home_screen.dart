import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';

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
                          return MovieCard(movie: _nowPlayingMovies[index]);
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
                          return MovieCard(movie: _popularMoviesApi[index]);
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
