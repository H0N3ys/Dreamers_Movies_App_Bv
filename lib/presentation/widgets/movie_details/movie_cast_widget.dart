import 'package:flutter/material.dart';

class MovieCastWidget extends StatelessWidget {
  final List<Map<String, dynamic>> cast;
  final int visibleCount;
  final void Function(Map<String, dynamic> actor)? onActorTap;

  const MovieCastWidget({
    super.key,
    required this.cast,
    this.visibleCount = 12,
    this.onActorTap,
  });

  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) {
      return const Center(
        child: Text('Cargando reparto...', style: TextStyle(color: Colors.white54)),
      );
    }

    final displayCast = visibleCount > 0 ? cast.take(visibleCount).toList() : cast;

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: displayCast.length,
        itemBuilder: (context, index) {
          final actor = displayCast[index];
          final profileUrl = actor['profilePath'];

          return GestureDetector(
            onTap: () => onActorTap?.call(actor),
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withAlpha(25),
                    backgroundImage: profileUrl != null
                        ? NetworkImage('https://image.tmdb.org/t/p/w200$profileUrl')
                        : null,
                    child: profileUrl == null ? const Icon(Icons.person, color: Colors.white54) : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    actor['name']?.toString() ?? 'Actor',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    actor['character']?.toString() ?? '',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}