import 'package:flutter/material.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/resources/styles/styles.dart';

import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/movie_datasources.dart';
import 'package:dreamers_movies_app_bv/infrastructure/datasources/tmdb_datasource.dart';

// Widgets reutlizados
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_category_filter.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_section_header.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/movie_card.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/home/home_bottom_nav.dart';


import 'package:dreamers_movies_app_bv/presentation/widgets/home/search_movie_result_card.dart';

class SearchScreen extends StatefulWidget {
  static const name = 'search-screen';
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MovieDatasources _movieDatasource = TmdbDatasource();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Movie> _allMovies = [];
  List<Movie> _searchResults = [];
  List<Movie> _recommendedMovies = [];
  Movie? _featuredMovie;

  bool _isLoading = true;
  bool _isSearching = false;
  int _selectedCategoryIndex = 0;
  int _currentNavIndex = 1;

  final List<String> _categories = [
    'Todo',
    'Comedia',
    'Animación',
    'Documentales',
  ];

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    try {
      final nowPlaying = await _movieDatasource.getNowPlaying();
      final popular = await _movieDatasource.getPopular();

      setState(() {
        _allMovies = [...nowPlaying, ...popular];
        _featuredMovie = nowPlaying.isNotEmpty ? nowPlaying.first : null;
        _recommendedMovies = popular.take(6).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    final results = _allMovies
        .where((m) => m.title.toLowerCase().contains(query))
        .toList();

    setState(() {
      _isSearching = true;
      _searchResults = results;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _focusNode.unfocus();
    setState(() {
      _isSearching = false;
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : Column(
                children: [
                  const SizedBox(height: 16),

                  // barra de busqueda
                  _buildSearchBar(),

                  const SizedBox(height: 16),

                  // contenido
                  Expanded(
                    child: _isSearching
                        ? _buildSearchResults()
                        : _buildEmptyState(),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
      ),
    );
  }

  
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search_rounded,
                      color: Colors.white54, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      autofocus: true,
                      style: TextStyle(
                        fontFamily: AppTheme.secondaryFont,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar por categoría, nombre etc',
                        hintStyle: TextStyle(
                          fontFamily: AppTheme.secondaryFont,
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_isSearching)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.close_rounded,
                            color: Colors.white38, size: 18),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // "Cancelar" solo cuando está buscando
          if (_isSearching) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _clearSearch,
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: AppTheme.secondaryFont,
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  //categorias + featured + recomendadows
  Widget _buildEmptyState() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Categorías
        SliverToBoxAdapter(
          child: HomeCategoryFilter(
            categories: _categories,
            selectedIndex: _selectedCategoryIndex,
            onCategorySelected: (i) =>
                setState(() => _selectedCategoryIndex = i),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Today — featured card horizontal grande
        if (_featuredMovie != null) ...[
          SliverToBoxAdapter(
            child: HomeSectionHeader(title: 'Today'),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchMovieResultCard(
                movie: _featuredMovie!,
                badge: MovieBadgeType.premium,
              ),
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Recommend for you
        SliverToBoxAdapter(
          child: HomeSectionHeader(
            title: 'Recommend for you',
            onSeeAll: () {},
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 14)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _recommendedMovies.length,
              itemBuilder: (context, index) =>
                  MovieCard(movie: _recommendedMovies[index]),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // ── Results State: lista vertical ──────────────────────────────────────
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                color: Colors.white24, size: 56),
            const SizedBox(height: 16),
            Text(
              'Sin resultados para\n"${_searchController.text}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.secondaryFont,
                color: Colors.white38,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final movie = _searchResults[index];
        // Alternamos badge Premium / Free para variedad visual
        final badge =
            index % 3 == 1 ? MovieBadgeType.free : MovieBadgeType.premium;
        return SearchMovieResultCard(movie: movie, badge: badge);
      },
    );
  }
}
