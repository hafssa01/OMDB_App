import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../services/omdb_service.dart';

class SearchProvider extends ChangeNotifier {
  final OmdbService _service = OmdbService();

  List<Movie> movies       = [];
  String      currentQuery = '';
  int         currentPage  = 1;
  int         totalResults = 0;
  bool        isLoading    = false;
  String?     errorMessage;

  bool get hasMore => movies.length < totalResults;

  /// Lance une nouvelle recherche (reset de la pagination).
  Future<void> search(String query) async {
    if (query.isEmpty) return;

    // Reset
    currentQuery = query;
    currentPage  = 1;
    movies       = [];
    totalResults = 0;
    errorMessage = null;
    isLoading    = true;
    notifyListeners();

    try {
      final result = await _service.searchMovies(query, page: 1);
      movies       = result['movies'] as List<Movie>;
      totalResults = result['totalResults'] as int;
    } catch (e) {
      errorMessage = 'Erreur de chargement : $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Charge la page suivante (pagination au scroll).
  Future<void> loadNextPage() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    notifyListeners();

    try {
      currentPage++;
      final result   = await _service.searchMovies(currentQuery, page: currentPage);
      final newMovies = result['movies'] as List<Movie>;
      movies.addAll(newMovies);
    } catch (e) {
      currentPage--; // rollback si erreur
      errorMessage = 'Erreur page suivante : $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}