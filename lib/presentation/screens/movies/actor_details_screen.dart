import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/resources/colors/colors.dart';

class ActorDetailsScreen extends StatefulWidget {
  static const name = 'actor-details-screen';

  final Map<String, dynamic> actor;

  const ActorDetailsScreen({super.key, required this.actor});

  @override
  State<ActorDetailsScreen> createState() => _ActorDetailsScreenState();
}

class _ActorDetailsScreenState extends State<ActorDetailsScreen> {
  final Dio _dio = Dio();

  bool _isLoading = true;
  Map<String, dynamic> _actorDetails = {};
  List<Map<String, dynamic>> _filmography = [];

  @override
  void initState() {
    super.initState();
    _loadActorData();
  }

  Future<void> _loadActorData() async {
    final actorId = widget.actor['id']?.toString();
    if (actorId == null || actorId.isEmpty) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    const String apiKey = 'f0af9b11b8c5d768dbccadfc7867b396';

    try {
      final detailsResponse = await _dio.get(
        'https://api.themoviedb.org/3/person/$actorId?api_key=$apiKey&language=es-MX',
      );
      final creditsResponse = await _dio.get(
        'https://api.themoviedb.org/3/person/$actorId/combined_credits?api_key=$apiKey&language=es-MX',
      );

      final castList = (creditsResponse.data['cast'] as List<dynamic>? ?? []);

      // Ordenamos por popularidad para mostrar las 10 mejores obras del actor
      castList.sort((a, b) {
        final popA = (a['popularity'] as num?)?.toDouble() ?? 0.0;
        final popB = (b['popularity'] as num?)?.toDouble() ?? 0.0;
        return popB.compareTo(popA);
      });

      final filmography = castList
          .where((entry) => entry['title'] != null || entry['name'] != null)
          .map<Map<String, dynamic>>((entry) {
            final isMovie = entry['media_type'] == 'movie' || entry['title'] != null;
            return {
              'raw': Map<String, dynamic>.from(entry as Map),
              'id': entry['id'],
              'title': entry['title'] ?? entry['name'] ?? 'Sin título',
              'character': entry['character'] ?? '',
              'releaseDate': entry['release_date'] ?? entry['first_air_date'] ?? '',
              'posterPath': entry['poster_path'] ?? '',
              'mediaType': isMovie ? 'Película' : 'Serie',
            };
          })
          .take(10)
          .toList();

      if (!mounted) return;
      setState(() {
        _actorDetails = detailsResponse.data as Map<String, dynamic>;
        _filmography = filmography;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar actor: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _getProfilePath() {
    final profilePath = _actorDetails['profile_path']?.toString() ?? '';
    return profilePath.isEmpty ? '' : 'https://image.tmdb.org/t/p/w500$profilePath';
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return 'No disponible';
    return value;
  }

  String _getCharacterLabel() {
    final character = widget.actor['character']?.toString() ?? '';
    return character.isEmpty ? 'Participación especial' : 'Como $character';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _actorDetails['name']?.toString() ?? widget.actor['name']?.toString() ?? 'Actor',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            width: 130,
                            height: 180,
                            child: _getProfilePath().isEmpty
                                ? const Center(
                                    child: Icon(Icons.person_outline, size: 56, color: Colors.white54),
                                  )
                                : Image.network(
                                    _getProfilePath(),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Center(
                                      child: Icon(Icons.person_outline, size: 56, color: Colors.white54),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _actorDetails['name']?.toString() ?? 'Sin nombre',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _getCharacterLabel(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Nació el ${_formatDate(_actorDetails['birthday']?.toString())}',
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Lugar: ${_actorDetails['place_of_birth']?.toString() ?? 'No disponible'}',
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Conocido por: ${_actorDetails['known_for_department']?.toString() ?? 'No disponible'}',
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Biografía',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    (_actorDetails['biography']?.toString() ?? 'No hay biografía disponible para este actor.').trim().isEmpty
                        ? 'No hay biografía disponible para este actor.'
                        : _actorDetails['biography'].toString(),
                    style: const TextStyle(color: Colors.white70, height: 1.6),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Filmografía',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_filmography.isEmpty)
                    const Text(
                      'No hay filmografía disponible en este momento.',
                      style: TextStyle(color: Colors.white54),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filmography.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white12),
                      itemBuilder: (context, index) {
                        final item = _filmography[index];
                        final posterPath = item['posterPath']?.toString() ?? '';
                        final rawData = item['raw'] as Map<String, dynamic>? ?? {};

                        return InkWell(
                          onTap: () {
                            final movie = Movie.fromJson(rawData);
                            context.pushNamed('movie-details', extra: movie);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 52,
                                    height: 72,
                                    child: posterPath.isEmpty
                                        ? const Center(
                                            child: Icon(Icons.movie_outlined, color: Colors.white54),
                                          )
                                        : Image.network(
                                            'https://image.tmdb.org/t/p/w200$posterPath',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Center(
                                              child: Icon(Icons.movie_outlined, color: Colors.white54),
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'].toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['mediaType'].toString(),
                                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                      if ((item['character']?.toString() ?? '').isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Como: ${item['character']}',
                                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
