// File: lib/core/service/ride_service.dart
import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/models/university_model.dart';

class RideService {
  final ApiService _apiService;

  RideService(this._apiService);

  // Recherche de trajets
  Future<List<RideModel>> searchRides({
    required String from,
    required String to,
    required DateTime date,
  }) async {
    try {
      final response = await _apiService.get(
        'rides/search?from=$from&to=$to&date=${date.toIso8601String()}',
      );
      
      return (response['rides'] as List)
          .map((json) => RideModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Erreur recherche trajets: $e');
      rethrow;
    }
  }

  // Publier un trajet
  Future<void> publishRide(RideModel ride) async {
    try {
      await _apiService.post('rides', ride.toJson());
    } catch (e) {
      print('Erreur publication trajet: $e');
      rethrow;
    }
  }

  // Récupérer les trajets publiés par l'utilisateur
  Future<List<RideModel>> getMyPublishedRides() async {
    try {
      final response = await _apiService.get('rides/my-published');
      
      return (response['rides'] as List)
          .map((json) => RideModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Erreur récupération trajets publiés: $e');
      rethrow;
    }
  }

  // Supprimer un trajet publié
  Future<void> deleteRide(String rideId) async {
    try {
      await _apiService.delete('rides/$rideId');
    } catch (e) {
      print('Erreur suppression trajet: $e');
      rethrow;
    }
  }

  // Mettre à jour un trajet
  Future<void> updateRide(RideModel ride) async {
    try {
      await _apiService.put('rides/${ride.rideId}', ride.toJson());
    } catch (e) {
      print('Erreur mise à jour trajet: $e');
      rethrow;
    }
  }

  // Récupérer un trajet par ID
  Future<RideModel> getRideById(String rideId) async {
    try {
      final response = await _apiService.get('rides/$rideId');
      return RideModel.fromJson(response['ride']);
    } catch (e) {
      print('Erreur récupération trajet: $e');
      rethrow;
    }
  }

  // Récupérer les trajets favoris
  Future<List<RideModel>> getFavoriteRides() async {
    try {
      final response = await _apiService.get('rides/favorites');
      
      return (response['favorites'] as List)
          .map((json) => RideModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Erreur récupération favoris: $e');
      rethrow;
    }
  }

  // Récupérer la liste des universités
  Future<List<UniversityModel>> getUniversities() async {
    try {
      final response = await _apiService.get('universities');
      
      return (response['universities'] as List)
          .map((json) => UniversityModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Erreur récupération universités: $e');
      rethrow;
    }
  }

  // Ajouter aux favoris
  Future<void> addToFavorites(String rideId) async {
    try {
      await _apiService.post('rides/$rideId/favorite', {});
    } catch (e) {
      print('Erreur ajout aux favoris: $e');
      rethrow;
    }
  }

  // Retirer des favoris
  Future<void> removeFromFavorites(String rideId) async {
    try {
      await _apiService.delete('rides/$rideId/favorite');
    } catch (e) {
      print('Erreur suppression des favoris: $e');
      rethrow;
    }
  }

  // Vérifier si un trajet est dans les favoris
  Future<bool> isFavorite(String rideId) async {
    try {
      final response = await _apiService.get('rides/$rideId/favorite-status');
      return response['isFavorite'] ?? false;
    } catch (e) {
      print('Erreur vérification favori: $e');
      return false;
    }
  }
}