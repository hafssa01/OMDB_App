import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie.dart';

class DatabaseService {
  // Singleton
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  /// Ouvre (ou crée) la base de données.
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, 'omdb_favorites.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites (
            imdbID     TEXT PRIMARY KEY,
            title      TEXT NOT NULL,
            year       TEXT,
            poster     TEXT,
            plot       TEXT,
            genre      TEXT,
            director   TEXT,
            imdbRating TEXT,
            runtime    TEXT
          )
        ''');
      },
    );
  }

  /// Ajoute un film aux favoris (ignore si déjà présent).
  Future<void> addFavorite(Movie movie) async {
    final db = await database;
    await db.insert(
      'favorites',
      movie.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Supprime un film des favoris par imdbID.
  Future<void> removeFavorite(String imdbID) async {
    final db = await database;
    await db.delete('favorites', where: 'imdbID = ?', whereArgs: [imdbID]);
  }

  /// Retourne tous les films favoris.
  Future<List<Movie>> getFavorites() async {
    final db   = await database;
    final rows = await db.query('favorites');
    return rows.map((row) => Movie.fromMap(row)).toList();
  }

  /// Vérifie si un film est déjà en favori.
  Future<bool> isFavorite(String imdbID) async {
    final db  = await database;
    final res = await db.query(
      'favorites',
      where:     'imdbID = ?',
      whereArgs: [imdbID],
    );
    return res.isNotEmpty;
  }
}