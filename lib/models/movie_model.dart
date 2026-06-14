// Data model representing a single movie object.
class Movie {
  final String imdbID;
  final String title;
  final String year;
  final String poster;
  final String? plot;
  final String? director;
  final String? actors;
  final String? genre;
  final String? imdbRating;
  final bool isFavorite;

  Movie({
    required this.imdbID,
    required this.title,
    required this.year,
    required this.poster,
    this.plot,
    this.director,
    this.actors,
    this.genre,
    this.imdbRating,
    this.isFavorite = false,
  });

  // Constructs a Movie from OMDb API JSON response
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      imdbID: json['imdbID'] ?? '',
      title: json['Title'] ?? '',
      year: json['Year'] ?? '',
      poster: json['Poster'] ?? '',
      plot: json['Plot'],
      director: json['Director'],
      actors: json['Actors'],
      genre: json['Genre'],
      imdbRating: json['imdbRating'],
    );
  }

  // Creates a copy of this movie with modified fields
  // Used to toggle isFavorite without mutating the original object
  Movie copyWith({bool? isFavorite}) {
    return Movie(
      imdbID: imdbID,
      title: title,
      year: year,
      poster: poster,
      plot: plot,
      director: director,
      actors: actors,
      genre: genre,
      imdbRating: imdbRating,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}