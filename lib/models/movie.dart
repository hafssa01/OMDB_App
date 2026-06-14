class Movie {
  final String imdbID;
  final String title;
  final String year;
  final String poster;
  // Champs détaillés (chargés via requête par ID)
  final String? plot;
  final String? genre;
  final String? director;
  final String? imdbRating;
  final String? runtime;

  Movie({
    required this.imdbID,
    required this.title,
    required this.year,
    required this.poster,
    this.plot,
    this.genre,
    this.director,
    this.imdbRating,
    this.runtime,
  });

  // Crée un Movie depuis la réponse JSON de recherche (?s=...)
  factory Movie.fromSearchJson(Map<String, dynamic> json) {
    return Movie(
      imdbID: json['imdbID'] ?? '',
      title:  json['Title']  ?? 'Titre inconnu',
      year:   json['Year']   ?? '',
      poster: json['Poster'] != 'N/A' ? json['Poster'] : '',
    );
  }

  // Crée un Movie depuis la réponse JSON de détail (?i=...)
  factory Movie.fromDetailJson(Map<String, dynamic> json) {
    return Movie(
      imdbID:     json['imdbID']     ?? '',
      title:      json['Title']      ?? '',
      year:       json['Year']       ?? '',
      poster:     json['Poster'] != 'N/A' ? json['Poster'] : '',
      plot:       json['Plot'],
      genre:      json['Genre'],
      director:   json['Director'],
      imdbRating: json['imdbRating'],
      runtime:    json['Runtime'],
    );
  }

  // Convertit en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'imdbID':     imdbID,
      'title':      title,
      'year':       year,
      'poster':     poster,
      'plot':       plot,
      'genre':      genre,
      'director':   director,
      'imdbRating': imdbRating,
      'runtime':    runtime,
    };
  }

  // Crée un Movie depuis une ligne SQLite
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      imdbID:     map['imdbID'],
      title:      map['title'],
      year:       map['year'],
      poster:     map['poster'] ?? '',
      plot:       map['plot'],
      genre:      map['genre'],
      director:   map['director'],
      imdbRating: map['imdbRating'],
      runtime:    map['runtime'],
    );
  }
}