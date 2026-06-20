import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; 
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/infrastructure/datasources/tmdb_datasource.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/local_reviews_datasource.dart';

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

  @override
  void initState() {
    super.initState();
    _loadTrailer();
    _checkIfFavorite();
  }

  @override
  void dispose() {
    _youtubeController?.close(); 
    super.dispose();
  }

  Future<void> _checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites_list') ?? [];
    setState(() {
      _isFavorite = favs.any((movieStr) => movieStr.contains('"id":${widget.movie.id}'));
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList('favorites_list') ?? [];
    
    if (_isFavorite) {
      favs.removeWhere((movieStr) => movieStr.contains('"id":${widget.movie.id}'));
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
    }
    
    await prefs.setStringList('favorites_list', favs);
    setState(() => _isFavorite = !_isFavorite);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Agregado a Favoritos ❤️' : 'Eliminado de Favoritos 💔'),
          backgroundColor: AppColors.secondaryColor,
        ),
      );
    }
  }

  Future<void> _loadTrailer() async {
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

      await _reviewsDatasource.saveReview(movie: widget.movie, idPerfil: idPerfil, rating: rating, comment: comment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Tu reseña se ha guardado!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
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
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calificar: ${widget.movie.title}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Text('Puntuación:', style: TextStyle(color: Colors.white70)),
                  Slider(value: currentRating.toDouble(), min: 1, max: 5, divisions: 4, label: currentRating.toString(), activeColor: Colors.amber, onChanged: (double value) => setModalState(() => currentRating = value.toInt())),
                  TextField(controller: commentController, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: '¿Qué te pareció la película?', hintStyle: const TextStyle(color: Colors.white38), filled: true, fillColor: Colors.white.withOpacity(0.1), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(vertical: 15)), onPressed: () { _submitReview(currentRating, commentController.text); Navigator.pop(context); }, child: const Text('Publicar Reseña', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
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
    if (_hasTrailer && _youtubeController != null) return SafeArea(bottom: false, child: YoutubePlayer(controller: _youtubeController!));
    
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(widget.movie.backdropPath.isNotEmpty ? widget.movie.backdropPath : widget.movie.posterPath, fit: BoxFit.cover),
        Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8), Colors.black]))),
        const Center(child: Text('Trailer no disponible', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.black,
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
            // Ya quitamos la propiedad "actions" de aquí arriba para evitar duplicados
            flexibleSpace: FlexibleSpaceBar(background: _buildMediaHeader()),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // --- NUEVO: Fila del Título y el Corazón de Favoritos ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          widget.movie.title, 
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border, 
                          color: Colors.red, 
                          size: 30
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ],
                  ),
                  // --------------------------------------------------------
                  
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(widget.movie.releaseDate.year.toString(), style: const TextStyle(color: Colors.white54)),
                      const SizedBox(width: 12),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)), child: const Text('HD', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 12),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(widget.movie.voteAverage.toStringAsFixed(1), style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _hasTrailer ? () { if (_youtubeController!.value.playerState == PlayerState.playing) { _youtubeController!.pauseVideo(); } else { _youtubeController!.playVideo(); } } : null,
                      icon: const Icon(Icons.play_arrow, color: Colors.black),
                      label: Text(_hasTrailer ? 'Reproducir / Pausar' : 'No disponible', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, disabledBackgroundColor: Colors.grey.shade800, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _showReviewModal, icon: const Icon(Icons.rate_review, color: Colors.white), label: const Text('Dejar una reseña', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))))),
                  const SizedBox(height: 24),
                  const Text('Sinopsis', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.movie.overview.isEmpty ? 'No hay descripción disponible para esta película.' : widget.movie.overview, style: const TextStyle(color: Colors.white70, height: 1.5)),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}