import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dreamers_movies_app_bv/domain/entities/movie_entities.dart';
import 'package:dreamers_movies_app_bv/domain/datasources/movie_datasources.dart';

class TmdbDatasource implements MovieDatasources {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.themoviedb.org/3',
    queryParameters: {
      'api_key': dotenv.env['THE_MOVIESDB_KEY'],
      'language': 'es-MX',
    },
  ));

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    try {
      final response = await dio.get('/movie/now_playing', queryParameters: {
        'page': page,
      });

      final List<dynamic> data = response.data['results'];
      return data.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar películas en cartelera: $e');
    }
  }

  @override
  Future<List<Movie>> getPopular({int page = 1}) async {
    try {
      final response = await dio.get('/movie/popular', queryParameters: {'page': page});
      final List<dynamic> data = response.data['results'];
      return data.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar películas populares: $e');
    }
}
}