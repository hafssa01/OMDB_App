import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/omdb_service.dart';
import '../services/database_service.dart';

// Global state manager — bridges backend services with UI screens.
// Uses real OmdbService and DatabaseService from backend.
class MovieProvider extends ChangeNotifier {

  final OmdbService _omdbService = OmdbService();
  final DatabaseService _dbService = DatabaseService();

  // Search results from OMDb API
  List<Movie> _searchResults = [];
  List<Movie> get searchResults => _searchResults;

  // User's favorite movies from SQLite
  List<Movie> _favorites = [];
  List<Movie> get favorites => _favorites;

  // Loading state for spinner
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Currently selected movie for DetailsScreen
  Movie? _selectedMovie;
  Movie? get selectedMovie => _selectedMovie;

  // Pagination
  String _currentQuery = '';
  int _currentPage = 1;
  int _totalResults = 0;
  bool get hasMore => _searchResults.length < _totalResults;
  String get query => _currentQuery;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Loads favorites from SQLite on app startup
  Future<void> loadFavorites() async {
    _favorites = await _dbService.getFavorites();
    notifyListeners();
  }

  // Searches movies via OMDb API — resets pagination
  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) return;

    _currentQuery = query;
    _currentPage = 1;
    _searchResults = [];
    _totalResults = 0;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _omdbService.searchMovies(query, page: 1);
      _searchResults = result['movies'] as List<Movie>;
      _totalResults = result['totalResults'] as int;
    } catch (e) {
      _errorMessage = 'Erreur de chargement : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Loads next page when user scrolls to bottom
  Future<void> loadNextPage() async {
    if (_isLoading || !hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentPage++;
      final result = await _omdbService.searchMovies(
        _currentQuery,
        page: _currentPage,
      );
      _searchResults.addAll(result['movies'] as List<Movie>);
    } catch (e) {
      _currentPage--;
      _errorMessage = 'Erreur page suivante : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Loads full movie details by IMDB ID
  Future<Movie> getMovieDetails(String imdbID) async {
    return await _omdbService.getMovieById(imdbID);
  }

  // Toggles a movie in/out of SQLite favorites
  Future<void> toggleFavorite(Movie movie) async {
    final alreadyFav = await _dbService.isFavorite(movie.imdbID);

    if (alreadyFav) {
      await _dbService.removeFavorite(movie.imdbID);
      _favorites.removeWhere((m) => m.imdbID == movie.imdbID);
    } else {
      await _dbService.addFavorite(movie);
      _favorites.add(movie);
    }
    notifyListeners();
  }

  // Checks if a movie is currently in favorites
  Future<bool> isFavorite(String imdbID) async {
    return await _dbService.isFavorite(imdbID);
  }

  // Sets the selected movie when user taps a result
  void selectMovie(Movie movie) {
    _selectedMovie = movie;
    notifyListeners();
  }

  // Clears search results
  void clearSearch() {
    _searchResults = [];
    _currentQuery = '';
    notifyListeners();
  }
}