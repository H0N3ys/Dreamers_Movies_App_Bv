import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
//El repositorio que va a llamar el Datasource (Proposito: Llamar el datasource a traves del repositorio [intermediario])
//Sirve para cuando queremos cambiar nuestro origen de datos
abstract class MovieRepositories 
{
  Future<List<Movie>> getNowPlaying ({int page = 1});
}
