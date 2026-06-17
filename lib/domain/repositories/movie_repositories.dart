import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';

abstract class MovieRepositories 
{
  Future<List<Movie>> getNowPlaying ({int page = 1});
}