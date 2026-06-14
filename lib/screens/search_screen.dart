import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';
import 'details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  // ScrollController to detect when user reaches bottom of list
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Listen for scroll to trigger pagination
    _scrollController.addListener(_onScroll);
  }

  // Loads next page when user scrolls near the bottom
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MovieProvider>().loadNextPage();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎬 CineApp'),
        centerTitle: true,
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [

          // Search bar
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search for a movie...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) {
                      context.read<MovieProvider>().searchMovies(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  onPressed: () {
                    context
                        .read<MovieProvider>()
                        .searchMovies(_searchController.text);
                  },
                  child: const Text('Search'),
                ),
              ],
            ),
          ),

          // Results
          Expanded(child: _buildBody(provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/favorites'),
        backgroundColor: Colors.amber,
        icon: const Icon(Icons.favorite, color: Colors.black),
        label: const Text('Favorites',
            style: TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget _buildBody(MovieProvider provider) {
    // Error state
    if (provider.errorMessage != null) {
      return Center(child: Text(provider.errorMessage!));
    }

    // Initial empty state
    if (provider.searchResults.isEmpty && provider.query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Search for your favorite movies',
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    // No results
    if (provider.searchResults.isEmpty && !provider.isLoading) {
      return Center(
        child: Text('No results for "${provider.query}"',
            style: TextStyle(color: Colors.grey.shade500)),
      );
    }

    // Results list with pagination
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      // +1 for loading spinner at bottom
      itemCount: provider.searchResults.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Show spinner at the bottom while loading next page
        if (index == provider.searchResults.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Colors.amber),
            ),
          );
        }
        final movie = provider.searchResults[index];
        return _MovieCard(movie: movie);
      },
    );
  }
}

class _MovieCard extends StatefulWidget {
  final Movie movie;
  const _MovieCard({required this.movie});

  @override
  State<_MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<_MovieCard> {
  // Local favorite state — checked from SQLite
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final fav = await context.read<MovieProvider>().isFavorite(widget.movie.imdbID);
    if (mounted) setState(() => _isFav = fav);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(movie: widget.movie),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [

              // Movie poster
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.movie.poster.isNotEmpty
                    ? Image.network(
                        widget.movie.poster,
                        width: 70,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _posterPlaceholder(),
                      )
                    : _posterPlaceholder(),
              ),

              const SizedBox(width: 12),

              // Movie info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.movie.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(widget.movie.year,
                          style: TextStyle(color: Colors.grey.shade600)),
                    ]),
                  ],
                ),
              ),

              // Favorite button
              IconButton(
                icon: Icon(
                  _isFav ? Icons.favorite : Icons.favorite_border,
                  color: _isFav ? Colors.red : Colors.grey,
                ),
                onPressed: () async {
                  await context
                      .read<MovieProvider>()
                      .toggleFavorite(widget.movie);
                  if (mounted) setState(() => _isFav = !_isFav);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _posterPlaceholder() {
    return Container(
      width: 70,
      height: 100,
      color: Colors.grey.shade300,
      child: const Icon(Icons.movie),
    );
  }
}