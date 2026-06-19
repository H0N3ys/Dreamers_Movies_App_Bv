import 'package:supabase_flutter/supabase_flutter.dart';
// Asegúrate de importar tu entidad Movie
import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart'; 

final supabase = Supabase.instance.client;

class SupabaseHelper {
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message.toLowerCase()) {
        case 'invalid login credentials':
          return 'Correo o contraseña incorrectos';
        case 'user already registered':
          return 'Este correo ya está registrado';
        case 'password should be at least 6 characters':
          return 'La contraseña debe tener al menos 6 caracteres';
        case 'email not confirmed':
          return 'Por favor verifica tu correo electrónico';
        default:
          return error.message;
      }
    }
    return 'Error de conexión: $error';
  }
}

// Nueva clase para manejar las reseñas y películas
class SupabaseReviewsDatasource {
  Future<void> saveReview({
    required Movie movie,
    required int idPerfil,
    required int rating,
    required String comment,
  }) async {
    try {
      // 1. Guardar la película en la tabla local si no existe
      await supabase.from('pelicula').upsert({
        'id_pelicula': movie.id, // ID directo de TMDB
        'titulo': movie.title,
        'descripcion': movie.overview,
        // Mandamos un placeholder porque este campo es NOT NULL en tu BD
        'url_archivo': 'N/A', 
        'caratula_url': movie.posterPath,
      });

      // 2. Insertar la reseña vinculada al perfil y a la película
      await supabase.from('resena').insert({
        'id_perfil': idPerfil,
        'id_pelicula': movie.id, // El mismo ID de TMDB
        'puntuacion': rating,
        'comentario': comment,
      });
      
    } catch (e) {
      // Podemos aprovechar tu SupabaseHelper para formatear el error
      throw Exception(SupabaseHelper.getErrorMessage(e));
    }
  }
}