import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:dio/dio.dart'; 
import 'package:dreamers_movies_app_bv/domain/datasources/database_helper.dart';

import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/infrastructure/datasources/tmdb_datasource.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/local_reviews_datasource.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/shared/save_animation_widget.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/shared/save_confirmation_overlay.dart';
import 'package:like_button/like_button.dart';

// Importamos los widgets creados (Asegúrate de que las rutas sean correctas)
import 'package:dreamers_movies_app_bv/presentation/widgets/movie_details/movie_cast_widget.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/movie_details/movie_reviews_carousel.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/shared/favorite_confirmation_overlay.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;
  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final TmdbDatasource _tmdbDatasource = TmdbDatasource();
  final LocalReviewsDatasource _reviewsDatasource = LocalReviewsDatasource();

  YoutubePlayerController? _youtubeController;
  bool _isLoadingTrailer = true;
  bool _hasTrailer = false;
  bool _isFavorite = false;
  bool _isSaved = false;

  int? _runtime;
  String _director = 'Desconocido';
  List<Map<String, dynamic>> _cast = [];
  List<Map<String, dynamic>> _movieReviews = [];
  final Dio _dio = Dio(); 

  @override
  void initState() {
    super.initState();
    _loadTrailer();
    _checkIfFavorite();
    _checkIfSaved();
    _loadExtraData();
  }

  @override
  void dispose() {
    _youtubeController?.close();
    super.dispose();
  }

  Future<void> _loadExtraData() async {
    await Future.wait([
      _fetchTmdbExtraDetails(),
      _loadReviewsByMovie(),
    ]);
  }

  Future<void> _fetchTmdbExtraDetails() async {
    const String apiKey = 'f0af9b11b8c5d768dbccadfc7867b396'; // Tu API KEY real
    try {
      final detailResponse = await _dio.get('https://api.themoviedb.org/3/movie/${widget.movie.id}?api_key=$apiKey&language=es-MX');
      final creditsResponse = await _dio.get('https://api.themoviedb.org/3/movie/${widget.movie.id}/credits?api_key=$apiKey&language=es-MX');
      
      if (mounted) {
        setState(() {
          _runtime = detailResponse.data['runtime'];
          
          final castList = creditsResponse.data['cast'] as List<dynamic>? ?? [];
          _cast = castList.take(12).map((actor) => {
            'name': actor['name'] ?? 'Desconocido',
            'character': actor['character'] ?? '',
            'profilePath': actor['profile_path'],
          }).toList();

          final crewList = creditsResponse.data['crew'] as List<dynamic>? ?? [];
          final directorData = crewList.firstWhere(
            (element) => element['job'] == 'Director',
            orElse: () => null,
          );
          if (directorData != null) _director = directorData['name'];
        });
      }
    } catch (e) {
      debugPrint('Error TMDB extra: $e');
    }
  }

  Future<void> _loadReviewsByMovie() async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      final reviews = await db.rawQuery('''
        SELECT r.puntuacion, r.comentario, r.fecha_creacion, u.nombres as autor
        FROM resena r
        JOIN perfil pr ON r.id_perfil = pr.id_perfil
        JOIN usuario u ON pr.id_usuario = u.id_usuario
        WHERE r.id_pelicula = ?
        ORDER BY r.fecha_creacion DESC
      ''', [widget.movie.id]);
      
      if (mounted) setState(() => _movieReviews = reviews);
    } catch (e) {
      debugPrint('Error cargando reseñas BD: $e');
    }
  }

  Future<void> _checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites_list') ?? [];
    setState(() {
      _isFavorite = favs.any((movieStr) => movieStr.contains('"id":${widget.movie.id}'));
    });
  }

  // --- NUEVA LÓGICA DE FAVORITOS (OVERLAY) ---
  void _showFavoriteOverlay({required bool isBreaking}) {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => FavoriteConfirmationOverlay(
        isBreaking: isBreaking,
        onComplete: () => overlayEntry?.remove(),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList('favorites_list') ?? [];

    if (_isFavorite) {
      favs.removeWhere((movieStr) => movieStr.contains('"id":${widget.movie.id}'));
      if (mounted) _showFavoriteOverlay(isBreaking: true); // Muestra corazón roto
    } else {
      final movieData = {
        "id": widget.movie.id,
        "title": widget.movie.title,
        "posterPath": widget.movie.posterPath,
        "backdropPath": widget.movie.backdropPath,
        "voteAverage": widget.movie.voteAverage,
        "releaseDate": widget.movie.releaseDate.toIso8601String(),
      };
      favs.add(jsonEncode(movieData));
      if (mounted) _showFavoriteOverlay(isBreaking: false); // Muestra corazón rojo
    }

    await prefs.setStringList('favorites_list', favs);
    setState(() => _isFavorite = !_isFavorite);
  }
  // ------------------------------------------

  Future<void> _checkIfSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedJson = prefs.getStringList('saved_list') ?? [];
    setState(() {
      _isSaved = savedJson.any((str) => jsonDecode(str)['id'] == widget.movie.id);
    });
  }

  Future<void> _toggleSave() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedJson = prefs.getStringList('saved_list') ?? [];

    if (_isSaved) {
      savedJson.removeWhere((str) => jsonDecode(str)['id'] == widget.movie.id);
      await prefs.setStringList('saved_list', savedJson);
      setState(() => _isSaved = false);
    } else {
      final movieData = {
        "id": widget.movie.id,
        "title": widget.movie.title,
        "posterPath": widget.movie.posterPath,
        "backdropPath": widget.movie.backdropPath,
        "voteAverage": widget.movie.voteAverage,
        "releaseDate": widget.movie.releaseDate.toIso8601String(),
      };
      savedJson.add(jsonEncode(movieData));
      await prefs.setStringList('saved_list', savedJson);
      setState(() => _isSaved = true);

      if (mounted) _showSaveConfirmationOverlay();
    }
  }

  void _showSaveConfirmationOverlay() {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => SaveConfirmationOverlay(onComplete: () => overlayEntry?.remove()),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  Future<void> _loadTrailer() async {
    bool isDesktop = false;
    if (!kIsWeb) {
      try { isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS; } catch (e) {}
    }

    if (isDesktop) {
      if (mounted) setState(() { _hasTrailer = false; _isLoadingTrailer = false; });
      return;
    }

    final key = await _tmdbDatasource.getMovieTrailer(widget.movie.id);
    if (mounted) {
      if (key != null) {
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: key,
          autoPlay: false,
          params: const YoutubePlayerParams(showControls: true, showFullscreenButton: true, mute: false),
        );
        setState(() { _hasTrailer = true; _isLoadingTrailer = false; });
      } else {
        setState(() { _hasTrailer = false; _isLoadingTrailer = false; });
      }
    }
  }

  Future<void> _submitReview(int rating, String comment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdString = prefs.getString('user_id');
      if (userIdString == null) throw Exception('No hay sesión activa.');

      final int idPerfil = int.tryParse(userIdString) ?? 1;

      await _reviewsDatasource.saveReview(
        movie: widget.movie,
        idPerfil: idPerfil,
        rating: rating,
        comment: comment,
      );

      await _loadReviewsByMovie();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Tu reseña se ha guardado!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  String _getGenreName() {
    if (widget.movie.genreIds.isEmpty) return 'Sin género';
    final genres = {
      28: "Acción", 12: "Aventura", 16: "Animación", 35: "Comedia", 80: "Crimen",
      99: "Documental", 18: "Drama", 10751: "Familia", 14: "Fantasía", 36: "Historia",
      27: "Terror", 10402: "Música", 9648: "Misterio", 10749: "Romance", 878: "Ciencia Ficción",
      10770: "Película de TV", 53: "Suspense", 10752: "Bélica", 37: "Western",
    };
    final names = widget.movie.genreIds.map((id) => genres[id]).where((name) => name != null).cast<String>();
    return names.isEmpty ? 'Desconocido' : names.join(', ');
  }

  void _showReviewModal() {
    int currentRating = 5;
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondaryColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calificar: ${widget.movie.title}',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setModalState(() => currentRating = index + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(
                            index < currentRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '¿Qué te pareció la película?',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(vertical: 15)),
                      onPressed: () {
                        _submitReview(currentRating, commentController.text);
                        Navigator.pop(context);
                      },
                      child: const Text('Publicar Reseña', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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

  Widget _buildMediaHeader() {
    if (_isLoadingTrailer) return const Center(child: CircularProgressIndicator(color: Colors.white));
    if (_hasTrailer && _youtubeController != null) return YoutubePlayer(controller: _youtubeController!);
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          widget.movie.backdropPath.isNotEmpty ? widget.movie.backdropPath : widget.movie.posterPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.movie_outlined, color: Colors.white24, size: 50)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8), Colors.black],
            ),
          ),
        ),
        const Center(child: Text('Trailer no disponible', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.black,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    if (context.canPop()) context.pop();
                    else context.go('/');
                  },
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                ),
              ),
              actions: [
                // 🔥 FAVORITOS EN EL APPBAR 🔥
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: LikeButton(
                    size: 28,
                    isLiked: _isFavorite,
                    circleColor: const CircleColor(start: Colors.redAccent, end: Colors.red),
                    bubblesColor: const BubblesColor(dotPrimaryColor: Colors.red, dotSecondaryColor: Colors.white),
                    likeBuilder: (bool isLiked) {
                      return Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white54,
                        size: 28,
                      );
                    },
                    onTap: (bool isLiked) async {
                      await _toggleFavorite();
                      return !isLiked;
                    },
                  ),
                ),
                // 🔥 GUARDADOS EN EL APPBAR 🔥
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: SaveAnimationWidget(
                    isSaved: _isSaved,
                    onTap: _toggleSave,
                    size: 28,
                    activeColor: Colors.amber,
                    inactiveColor: Colors.white54,
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 230, width: double.infinity, child: _buildMediaHeader()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                widget.movie.title,
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                            // 🔥 GUARDADOS BAJO EL TÍTULO (opcional, ya está en AppBar) 🔥
                            // Si quieres mantenerlo aquí también, descomenta:
                            // SaveAnimationWidget(
                            //   isSaved: _isSaved, 
                            //   onTap: _toggleSave, 
                            //   size: 32, 
                            //   activeColor: Colors.amber, 
                            //   inactiveColor: Colors.white54
                            // ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(widget.movie.releaseDate.year.toString(), style: const TextStyle(color: Colors.white54)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(_getGenreName(), style: const TextStyle(color: Colors.white54), overflow: TextOverflow.ellipsis)),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                              child: const Text('HD', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(widget.movie.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.white54, size: 16),
                            const SizedBox(width: 4),
                            Text(_runtime != null ? '$_runtime min' : 'N/A', style: const TextStyle(color: Colors.white54)),
                            const SizedBox(width: 16),
                            const Icon(Icons.movie_creation_outlined, color: Colors.white54, size: 16),
                            const SizedBox(width: 4),
                            Expanded(child: Text('Dir: $_director', style: const TextStyle(color: Colors.white54), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showReviewModal,
                            icon: const Icon(Icons.rate_review, color: Colors.white),
                            label: const Text('Dejar una reseña', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('Sinopsis', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(widget.movie.overview.isEmpty ? 'No hay descripción disponible para esta película.' : widget.movie.overview, style: const TextStyle(color: Colors.white70, height: 1.5)),
                        
                        const SizedBox(height: 24),
                        const Text('Reparto Principal', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        MovieCastWidget(cast: _cast),

                        const SizedBox(height: 24),
                        Text('Reseñas de la película (${_movieReviews.length})', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        MovieReviewsCarousel(reviews: _movieReviews),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}