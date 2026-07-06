import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';

abstract class MovieDatasources {
  Future<List<Movie>> getNowPlaying({int page = 1});
  Future<List<Movie>> getPopular({int page = 1});
  Future<List<Movie>> getTopRated({int page = 1});
  Future<List<Movie>> getUpcoming({int page = 1}); 
  Future<String?> getMovieTrailer(int movieId);
  Future<List<Movie>> searchMovies(String query);
}