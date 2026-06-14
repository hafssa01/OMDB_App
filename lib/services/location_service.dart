import 'package:geolocator/geolocator.dart';

class LocationService {

  /// Demande les permissions si nécessaire, puis retourne la position GPS.
  Future<Position> getCurrentPosition() async {
    // Vérifie si le service de localisation est activé
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Service de localisation désactivé sur l\'appareil.');
    }

    // Vérifie/demande les permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission de localisation refusée.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permission de localisation refusée définitivement. '
            'Veuillez l\'activer dans les paramètres.',
      );
    }

    // Récupère la position (précision haute pour la carte)
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}