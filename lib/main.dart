import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/movie_provider.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      // Load favorites from SQLite on startup
      create: (context) => MovieProvider()..loadFavorites(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OmdbApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.amber,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SearchScreen(),
        '/favorites': (context) => const FavoritesScreen(),
      },
    );
  }
}
