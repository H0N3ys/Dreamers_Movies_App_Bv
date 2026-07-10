import 'package:flutter/material.dart';

class MovieReviewsCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;

  const MovieReviewsCarousel({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'Nadie ha comentado esta película aún. ¡Sé el primero!',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return SizedBox(
      height: 140, // Altura de la tarjeta
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Efecto "ruleta"
        physics: const BouncingScrollPhysics(),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          final String autor = review['autor'] ?? 'Usuario';
          final int puntuacion = (review['puntuacion'] as num?)?.toInt() ?? 5;

          return Container(
            width: 280, // Ancho de cada comentario
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(150), // Color oscuro que combina
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${autor.replaceAll(' ', '')}'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        autor,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Estrellitas en la reseña
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < puntuacion ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 14,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    review['comentario'] ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}