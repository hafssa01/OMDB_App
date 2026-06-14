import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class OmdbService {
  static const String _apiKey  = 'VOTRE_API_KEY';
  static const String _baseUrl = 'https://www.omdbapi.com/';

  /// Recherche des films/séries par titre.
  /// [query]  : le titre à rechercher
  /// [page]   : numéro de page (1 à N, 10 résultats par page)
  /// Retourne une Map avec 'movies' (List<Movie>) et 'totalResults' (int)
  Future<Map<String, dynamic>> searchMovies(
      String query, {int page = 1}) async {
    final uri = Uri.parse(
      '$_baseUrl?apikey=$_apiKey&s=${Uri.encodeComponent(query)}&page=$page',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erreur réseau : ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['Response'] == 'False') {
      // Aucun résultat ou erreur API
      return {'movies': <Movie>[], 'totalResults': 0};
    }

    final List results = data['Search'] as List;
    final int total    = int.tryParse(data['totalResults'] ?? '0') ?? 0;

    return {
      'movies':       results.map((e) => Movie.fromSearchJson(e)).toList(),
      'totalResults': total,
    };
  }

  /// Récupère la fiche complète d'un film par son imdbID.
  Future<Movie> getMovieById(String imdbID) async {
    final uri = Uri.parse('$_baseUrl?apikey=$_apiKey&i=$imdbID&plot=full');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erreur réseau : ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['Response'] == 'False') {
      throw Exception('Film introuvable : ${data['Error']}');
    }

    return Movie.fromDetailJson(data);
  }
}