import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';
import '../services/location_service.dart';
import 'details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        centerTitle: true,
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: provider.favorites.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.favorites.length,
                    itemBuilder: (context, index) {
                      return _FavoriteCard(
                          movie: provider.favorites[index]);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  color: Colors.black87,
                  width: double.infinity,
                  child: const Row(
                    children: [
                      Icon(Icons.local_movies,
                          color: Colors.amber, size: 18),
                      SizedBox(width: 8),
                      Text('Cinemas Near You',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(flex: 1, child: _CinemaMap()),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No favorites yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text('Tap the heart icon on any movie to save it',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Movie movie;
  const _FavoriteCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(movie.imdbID),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) async {
        await context.read<MovieProvider>().toggleFavorite(movie);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('"${movie.title}" removed from favorites')),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: movie.poster.isNotEmpty
                ? Image.network(movie.poster,
                    width: 50,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                        width: 50,
                        height: 70,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.movie)))
                : Container(
                    width: 50,
                    height: 70,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.movie)),
          ),
          title: Text(movie.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          subtitle: Text(movie.year),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailsScreen(movie: movie)),
          ),
        ),
      ),
    );
  }
}

// Map widget that uses real GPS from LocationService
class _CinemaMap extends StatefulWidget {
  const _CinemaMap();

  @override
  State<_CinemaMap> createState() => _CinemaMapState();
}

class _CinemaMapState extends State<_CinemaMap> {
  final LocationService _locationService = LocationService();

  // Default to Casablanca until GPS loads
  LatLng _center = const LatLng(33.5892, -7.6036);
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  // Gets real GPS position from ta collègue's LocationService
  Future<void> _loadLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (mounted) {
        setState(() {
          _center = LatLng(position.latitude, position.longitude);
          _locationLoaded = true;
        });
      }
    } catch (e) {
      // GPS failed — keep Casablanca as default
      print('❌ GPS error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: _center,
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.cine_app',
            ),
            MarkerLayer(
              markers: [
                // User location marker
                Marker(
                  point: _center,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Show loading indicator while GPS is being fetched
        if (!_locationLoaded)
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.amber),
                    ),
                    SizedBox(width: 8),
                    Text('Getting your location...',
                        style: TextStyle(
                            color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}