import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';
import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/infrastructure/datasources/tmdb_datasource.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/local_reviews_datasource.dart';
// 🔥 IMPORTS DE LOS NUEVOS WIDGETS
import 'package:dreamers_movies_app_bv/presentation/widgets/shared/save_animation_widget.dart';
import 'package:dreamers_movies_app_bv/presentation/widgets/shared/save_confirmation_overlay.dart';
import 'package:like_button/like_button.dart';

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
  bool _isBreaking = false;
  @override
  void initState() {
    super.initState();
    _loadTrailer();
    _checkIfFavorite();
    _checkIfSaved();
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
      _isFavorite = favs.any(
        (movieStr) => movieStr.contains('"id":${widget.movie.id}'),
      );
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList('favorites_list') ?? [];

    if (_isFavorite) {
      favs.removeWhere(
        (movieStr) => movieStr.contains('"id":${widget.movie.id}'),
      );
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
          content: Text(
            _isFavorite
                ? 'Agregado a Favoritos ❤️'
                : 'Eliminado de Favoritos 💔',
          ),
          backgroundColor: AppColors.secondaryColor,
        ),
      );
    }
  }

  Future<void> _checkIfSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedJson = prefs.getStringList('saved_list') ?? [];

    final bool exists = savedJson.any((str) {
      final data = jsonDecode(str);
      return data['id'] == widget.movie.id;
    });

    setState(() {
      _isSaved = exists;
    });
  }

  Future<void> _toggleSave() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedJson = prefs.getStringList('saved_list') ?? [];

    if (_isSaved) {
      // Eliminar de guardados
      savedJson.removeWhere((str) {
        final data = jsonDecode(str);
        return data['id'] == widget.movie.id;
      });

      await prefs.setStringList('saved_list', savedJson);
      setState(() => _isSaved = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eliminado de guardados'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else {
      // Guardar película
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

      // Mostrar overlay de confirmación
      if (mounted) {
        _showConfirmationOverlay();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Guardado en tu lista! 📚'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _showConfirmationOverlay() {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => SaveConfirmationOverlay(
        onComplete: () {
          overlayEntry?.remove();
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  Future<void> _loadTrailer() async {
    bool isDesktop = false;
    if (!kIsWeb) {
      try {
        isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
      } catch (e) {}
    }

    if (isDesktop) {
      if (mounted) {
        setState(() {
          _hasTrailer = false;
          _isLoadingTrailer = false;
        });
      }
      return;
    }

    final key = await _tmdbDatasource.getMovieTrailer(widget.movie.id);
    if (mounted) {
      if (key != null) {
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: key,
          autoPlay: false,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            mute: false,
          ),
        );
        setState(() {
          _hasTrailer = true;
          _isLoadingTrailer = false;
        });
      } else {
        setState(() {
          _hasTrailer = false;
          _isLoadingTrailer = false;
        });
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Tu reseña se ha guardado!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
    }
  }

  String _getGenreName() {
    if (widget.movie.genreIds.isEmpty) return 'Sin género';

    final genres = {
      28: "Acción",
      12: "Aventura",
      16: "Animación",
      35: "Comedia",
      80: "Crimen",
      99: "Documental",
      18: "Drama",
      10751: "Familia",
      14: "Fantasía",
      36: "Historia",
      27: "Terror",
      10402: "Música",
      9648: "Misterio",
      10749: "Romance",
      878: "Ciencia Ficción",
      10770: "Película de TV",
      53: "Suspense",
      10752: "Bélica",
      37: "Western",
    };

    final names = widget.movie.genreIds
        .map((id) => genres[id])
        .where((name) => name != null)
        .cast<String>();

    return names.isEmpty ? 'Desconocido' : names.join(', ');
  }

  void _showReviewModal() {
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
                    'Calificar: ${widget.movie.title}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Puntuación:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Slider(
                    value: currentRating.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: currentRating.toString(),
                    activeColor: Colors.amber,
                    onChanged: (double value) =>
                        setModalState(() => currentRating = value.toInt()),
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
                      ),
                      onPressed: () {
                        _submitReview(currentRating, commentController.text);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Publicar Reseña',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
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

  Widget _buildMediaHeader() {
    if (_isLoadingTrailer)
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );

    if (_hasTrailer && _youtubeController != null) {
      return YoutubePlayer(controller: _youtubeController!);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          widget.movie.backdropPath.isNotEmpty
              ? widget.movie.backdropPath
              : widget.movie.posterPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.movie_outlined, color: Colors.white24, size: 50),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.8),
                Colors.black,
              ],
            ),
          ),
        ),
        const Center(
          child: Text(
            'Trailer no disponible',
            style: TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              actions: [
                // 🔥 USANDO EL WIDGET DE ANIMACIÓN DESDE shared/
                SaveAnimationWidget(
                  isSaved: _isSaved,
                  onTap: _toggleSave,
                  size: 28,
                  activeColor: Colors.amber,
                  inactiveColor: Colors.white,
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 230,
                    width: double.infinity,
                    child: _buildMediaHeader(),
                  ),

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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // 🔥 USANDO EL WIDGET DE ANIMACIÓN DESDE shared/
                            SaveAnimationWidget(
                              isSaved: _isSaved,
                              onTap: _toggleSave,
                              size: 28,
                              activeColor: Colors.amber,
                              inactiveColor: Colors.white54,
                            ),
                            LikeButton(
                              size: 32,
                              isLiked: _isFavorite,
                              circleColor: const CircleColor(
                                start: Colors.pinkAccent,
                                end: Colors.red,
                              ),
                              bubblesColor: const BubblesColor(
                                dotPrimaryColor: Colors.red,
                                dotSecondaryColor: Colors.white,
                              ),
                              likeBuilder: (bool isLiked) {
                                if (_isBreaking) {
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 1.3, end: 1.0),
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.bounceOut,
                                    builder: (context, scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: const Icon(
                                          Icons.heart_broken,
                                          color: Colors.white54,
                                          size: 32,
                                        ),
                                      );
                                    },
                                  );
                                }

                                return Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isLiked ? Colors.red : Colors.white54,
                                  size: 32,
                                );
                              },
                              onTap: (bool isLiked) async {
                                if (isLiked) {
                                  setState(() => _isBreaking = true);

                                  Future.delayed(
                                    const Duration(milliseconds: 500),
                                    () {
                                      if (mounted) {
                                        setState(() => _isBreaking = false);
                                      }
                                    },
                                  );
                                }

                                await _toggleFavorite();
                                return !isLiked;
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Text(
                              widget.movie.releaseDate.year.toString(),
                              style: const TextStyle(color: Colors.white54),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getGenreName(),
                                style: const TextStyle(color: Colors.white54),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'HD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _hasTrailer
                                ? () {
                                    if (_youtubeController!.value.playerState ==
                                        PlayerState.playing) {
                                      _youtubeController!.pauseVideo();
                                    } else {
                                      _youtubeController!.playVideo();
                                    }
                                  }
                                : null,
                            icon: const Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                            ),
                            label: Text(
                              _hasTrailer
                                  ? 'Reproducir / Pausar'
                                  : 'No disponible',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade800,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showReviewModal,
                            icon: const Icon(
                              Icons.rate_review,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Dejar una reseña',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white24,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Sinopsis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.movie.overview.isEmpty
                              ? 'No hay descripción disponible para esta película.'
                              : widget.movie.overview,
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),

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
