import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/database_helper.dart';

class LocalReviewsDatasource {
  final DatabaseHelper _db = DatabaseHelper();

  Future<void> saveReview({
    required Movie movie,
    required int idPerfil,
    required int rating,
    required String comment,
  }) async {
    // Llamamos directamente a la base local
    await _db.saveReviewLocal(
      idPerfil: idPerfil,
      idPelicula: movie.id,
      titulo: movie.title,
      descripcion: movie.overview,
      caratulaUrl: movie.posterPath,
      rating: rating,
      comentario: comment,
    );
  }
}