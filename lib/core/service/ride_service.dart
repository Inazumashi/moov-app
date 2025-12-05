// File: lib/core/service/ride_service.dart
import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/models/university_model.dart';
import 'package:intl/intl.dart';

class RideService {
  final ApiService _apiService;

  RideService(this._apiService);

  // 1. RECHERCHER DES TRAJETS
  Future<List<RideModel>> searchRides({
    required String from,
    required String to,
    required DateTime date,
  }) async {
    try {
      final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await _apiService.get(
        'rides/search?departure=$from&arrival=$to&date=$formattedDate',
        isProtected: false,
      );
      
      // Vérifiez la structure de la réponse de votre API
      if (response is Map && response.containsKey('rides')) {
        final List<dynamic> data = response['rides'] ?? [];
        return data.map((json) => RideModel.fromJson(json)).toList();
      } else if (response is List) {
        return response.map((json) => RideModel.fromJson(json)).toList();
      } else {
        throw Exception('Format de réponse inattendu');
      }
    } catch (e) {
      print('Erreur recherche trajets: $e');
      rethrow;
    }
  }

  // 2. PUBLIER UN TRAJET
  Future<void> publishRide(RideModel ride) async {
    try {
      await _apiService.post(
        'rides',
        ride.toJson(),
        isProtected: true,
      );
    } catch (e) {
      print('Erreur publication trajet: $e');
      rethrow;
    }
  }

  // 3. TRAJETS PUBLIÉS PAR L'UTILISATEUR
  Future<List<RideModel>> getMyPublishedRides() async {
    try {
      final response = await _apiService.get(
        'rides/my-rides',
        isProtected: true,
      );
      
      // Vérifiez la structure de la réponse
      if (response is Map && response.containsKey('rides')) {
        final List<dynamic> data = response['rides'] ?? [];
        return data.map((json) => RideModel.fromJson(json)).toList();
      } else if (response is List) {
        return response.map((json) => RideModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur trajets publiés: $e');
      rethrow;
    }
  }

  // 4. SUPPRIMER UN TRAJET
  Future<void> deleteRide(String rideId) async {
    try {
      await _apiService.delete(
        'rides/$rideId',
        isProtected: true,
      );
    } catch (e) {
      print('Erreur suppression trajet: $e');
      rethrow;
    }
  }

  // 5. METTRE À JOUR UN TRAJET
  Future<void> updateRide(RideModel ride) async {
    try {
      await _apiService.put(
        'rides/${ride.rideId}',
        ride.toJson(),
        isProtected: true,
      );
    } catch (e) {
      print('Erreur mise à jour trajet: $e');
      rethrow;
    }
  }

  // 6. TRAJETS FAVORIS
  Future<List<RideModel>> getFavoriteRides() async {
    try {
      final response = await _apiService.get(
        'advanced/favorite-rides',
        isProtected: true,
      );
      
      if (response is Map && response.containsKey('favorite_rides')) {
        final List<dynamic> data = response['favorite_rides'] ?? [];
        return data.map((json) => RideModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur trajets favoris: $e');
      rethrow;
    }
  }

  // 7. AJOUTER AUX FAVORIS
  Future<void> addToFavorites(String rideId) async {
    try {
      await _apiService.post(
        'advanced/favorite-rides',
        {'rideId': rideId},
        isProtected: true,
      );
    } catch (e) {
      print('Erreur ajout favoris: $e');
      rethrow;
    }
  }

  // 8. RETIRER DES FAVORIS
  Future<void> removeFromFavorites(String rideId) async {
    try {
      await _apiService.delete(
        'advanced/favorite-rides/$rideId',
        isProtected: true,
      );
    } catch (e) {
      print('Erreur suppression favoris: $e');
      rethrow;
    }
  }

  // 9. UNIVERSITÉS
  Future<List<UniversityModel>> getUniversities() async {
    try {
      final response = await _apiService.get(
        'auth/universities',
        isProtected: false,
      );
      
      if (response is Map && response.containsKey('universities')) {
        final List<dynamic> data = response['universities'] ?? [];
        return data.map((json) => UniversityModel.fromJson(json)).toList();
      }
      
      // Si l'API ne renvoie pas la bonne structure, retournez une liste vide
      print('Avertissement: Structure de réponse des universités inattendue');
      return [];
    } catch (e) {
      print('Erreur chargement universités: $e');
      return []; // Retournez une liste vide au lieu de lancer une exception
    }
  }

  // 10. RECHERCHE AVANCÉE (optionnel)
  Future<Map<String, dynamic>> searchAdvanced({
    String? departureStationId,
    String? arrivalStationId,
    DateTime? departureDate,
    int? minSeats,
    double? maxPrice,
  }) async {
    try {
      final params = <String, String>{};
      
      if (departureStationId != null) params['departure_station_id'] = departureStationId;
      if (arrivalStationId != null) params['arrival_station_id'] = arrivalStationId;
      if (departureDate != null) params['departure_date'] = DateFormat('yyyy-MM-dd').format(departureDate);
      if (minSeats != null) params['min_seats'] = minSeats.toString();
      if (maxPrice != null) params['max_price'] = maxPrice.toString();
      
      final queryString = Uri(queryParameters: params).query;
      final response = await _apiService.get(
        'rides/search?$queryString',
        isProtected: false,
      );
      
      return response;
    } catch (e) {
      print('Erreur recherche avancée: $e');
      rethrow;
    }
  }
}