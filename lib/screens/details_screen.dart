import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';

class DetailsScreen extends StatefulWidget {
  final Movie movie;
  const DetailsScreen({super.key, required this.movie});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  // Full movie details loaded from API
  Movie? _fullMovie;
  bool _isLoading = true;
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  // Loads full details via getMovieById (ta collègue)
  Future<void> _loadDetails() async {
    try {
      final full = await context
          .read<MovieProvider>()
          .getMovieDetails(widget.movie.imdbID);
      final fav = await context
          .read<MovieProvider>()
          .isFavorite(widget.movie.imdbID);
      if (mounted) {
        setState(() {
          _fullMovie = full;
          _isFav = fav;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openImdb() async {
    final uri = Uri.parse(
        'https://www.imdb.com/title/${widget.movie.imdbID}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open IMDB')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use full details if loaded, otherwise use basic info from search
    final movie = _fullMovie ?? widget.movie;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : CustomScrollView(
              slivers: [

                SliverAppBar(
                  expandedHeight: 350,
                  pinned: true,
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  actions: [
                    IconButton(
                      icon: Icon(
                        _isFav ? Icons.favorite : Icons.favorite_border,
                        color: _isFav ? Colors.red : Colors.white,
                      ),
                      onPressed: () async {
                        await context
                            .read<MovieProvider>()
                            .toggleFavorite(movie);
                        if (mounted) setState(() => _isFav = !_isFav);
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: movie.poster.isNotEmpty
                        ? Image.network(movie.poster,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.movie,
                                    size: 80, color: Colors.white)))
                        : Container(
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.movie,
                                size: 80, color: Colors.white)),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(movie.title,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),

                        // Metadata chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _chip(Icons.calendar_today, movie.year, Colors.blue),
                            if (movie.genre != null)
                              _chip(Icons.category, movie.genre!, Colors.orange),
                            if (movie.imdbRating != null)
                              _chip(Icons.star,
                                  '${movie.imdbRating}/10', Colors.amber),
                            if (movie.runtime != null)
                              _chip(Icons.timer, movie.runtime!, Colors.purple),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // IMDB button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5C518),
                              foregroundColor: Colors.black,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text('View on IMDB',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            onPressed: _openImdb,
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),

                        if (movie.plot != null)
                          _section('Synopsis', movie.plot!),
                        if (movie.director != null)
                          _section('Director', movie.director!),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(content,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5)),
        ],
      ),
    );
  }
}