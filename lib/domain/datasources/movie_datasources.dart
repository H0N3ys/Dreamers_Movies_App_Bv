import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';

abstract class MovieDatasources {
  Future<List<Movie>> getNowPlaying({int page = 1});
  Future<List<Movie>> getPopular({int page = 1});
}