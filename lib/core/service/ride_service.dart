// File: lib/core/services/ride_service.dart
import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/models/university_model.dart';
import 'package:intl/intl.dart';

class RideService {
  final ApiService _apiService;

  RideService(this._apiService);

  // Helper pour convertir Map<dynamic, dynamic> en Map<String, dynamic>
  Map<String, dynamic> _convertMap(Map<dynamic, dynamic> map) {
    return Map<String, dynamic>.from(map);
  }

  // Helper pour convertir une liste
  List<Map<String, dynamic>> _convertList(List<dynamic> list) {
    return list.map((item) => _convertMap(item as Map<dynamic, dynamic>)).toList();
  }

  // 1. RECHERCHER DES TRAJETS
  Future<List<RideModel>> searchRides({
    required String from,
    required String to,
    required DateTime date,
  }) async {
    try {
      final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await _apiService.get(
        'rides/search?from=$from&to=$to&date=$formattedDate',
        isProtected: false,
      );
      
      // Gestion des différentes structures de réponse
      if (response is Map) {
        final Map<String, dynamic> convertedResponse = _convertMap(response as Map<dynamic, dynamic>);
        
        if (convertedResponse.containsKey('rides')) {
          final List<dynamic> data = convertedResponse['rides'] ?? [];
          return data.map((json) => RideModel.fromJson(_convertMap(json as Map<dynamic, dynamic>))).toList();
        } else if (convertedResponse.containsKey('data')) {
          final List<dynamic> data = convertedResponse['data'] ?? [];
          return data.map((json) => RideModel.fromJson(_convertMap(json as Map<dynamic, dynamic>))).toList();
        }
      } else if (response is List) {
        return response.map((json) => RideModel.fromJson(_convertMap(json as Map<dynamic, dynamic>))).toList();
      }
      return [];
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
      
      // Gestion des différentes structures de réponse
      if (response is Map) {
        final Map<String, dynamic> convertedResponse = _convertMap(response as Map<dynamic, dynamic>);
        
        if (convertedResponse.containsKey('rides')) {
          final List<dynamic> data = convertedResponse['rides'] ?? [];
          return data.map((json) => RideModel.fromJson(_convertMap(json as Map<dynamic, dynamic>))).toList();
        } else if (convertedResponse.containsKey('data')) {
          final List<dynamic> data = convertedResponse['data'] ?? [];
          return data.map((json) => RideModel.fromJson(_convertMap(json as Map<dynamic, dynamic>))).toList();
        }
      } else if (response is List) {
        return response.map((json) => RideModel.fromJson(_convertMap(json as Map<dynamic, dynamic>))).toList();
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
      
      // Gestion des différentes structures de réponse
      if (response is Map) {
        final Map<String, dynamic> convertedResponse = _convertMap(response as Map<dynamic, dynamic>);
        
        if (convertedResponse.containsKey('favorite_rides')) {
          final List<dynamic> data = convertedResponse['favorite_rides'] ?? [];
          return data.map((json) => RideModel.fromJson(_convertMap(json as Map<dynamic, dynamic>))).toList();
        } else if (convertedResponse.containsKey('data')) {
          final List<dynamic> data = convertedResponse['data'] ?? [];
          return data.map((json) => RideModel.fromJson(_convertMap(json as Map<dynamic, dynamic>))).toList();
        }
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
      
      if (response is Map) {
        final Map<String, dynamic> convertedResponse = _convertMap(response as Map<dynamic, dynamic>);
        
        if (convertedResponse.containsKey('universities')) {
          final List<dynamic> data = convertedResponse['universities'] ?? [];
          return data.map((json) => UniversityModel.fromJson(_convertMap(json as Map<dynamic, dynamic>))).toList();
        }
      }
      
      // Si l'API ne renvoie pas la bonne structure, retournez une liste vide
      print('Avertissement: Structure de réponse des universités inattendue');
      return [];
    } catch (e) {
      print('Erreur chargement universités: $e');
      return [];
    }
  }

  // 10. RECHERCHE AVANCÉE
  Future<Map<String, dynamic>> searchAdvanced({
    String? departureStationId,
    String? arrivalStationId,
    DateTime? departureDate,
    int? minSeats,
    double? maxPrice,
    String sortBy = 'departure_date',
    String sortOrder = 'ASC',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, String>{};
      
      if (departureStationId != null) params['departure_station_id'] = departureStationId;
      if (arrivalStationId != null) params['arrival_station_id'] = arrivalStationId;
      if (departureDate != null) params['departure_date'] = DateFormat('yyyy-MM-dd').format(departureDate);
      if (minSeats != null) params['min_seats'] = minSeats.toString();
      if (maxPrice != null) params['max_price'] = maxPrice.toString();
      params['sort_by'] = sortBy;
      params['sort_order'] = sortOrder;
      params['page'] = page.toString();
      params['limit'] = limit.toString();
      
      final queryString = Uri(queryParameters: params).query;
      final response = await _apiService.get(
        'rides/search?$queryString',
        isProtected: false,
      );
      
      return _convertMap(response as Map<dynamic, dynamic>);
    } catch (e) {
      print('Erreur recherche avancée: $e');
      rethrow;
    }
  }

  // 11. DÉTAILS D'UN TRAJET
  Future<RideModel> getRideDetails(String rideId) async {
    try {
      final response = await _apiService.get(
        'rides/$rideId',
        isProtected: false,
      );
      
      if (response is Map) {
        return RideModel.fromJson(_convertMap(response as Map<dynamic, dynamic>));
      } else {
        throw Exception('Format de réponse inattendu pour les détails du trajet');
      }
    } catch (e) {
      print('Erreur détails trajet: $e');
      rethrow;
    }
  }

  // 12. RECHERCHE RAPIDE
  Future<List<RideModel>> quickSearch({
    required String departure,
    required String arrival,
    String? date,
  }) async {
    try {
      String endpoint = 'rides/quick-search?departure=$departure&arrival=$arrival';
      if (date != null) {
        endpoint += '&date=$date';
      }

      final response = await _apiService.get(
        endpoint,
        isProtected: false,
      );

      if (response is Map) {
        final Map<String, dynamic> convertedResponse = _convertMap(response as Map<dynamic, dynamic>);
        
        if (convertedResponse.containsKey('rides')) {
          final List<dynamic> data = convertedResponse['rides'] ?? [];
          return data.map((json) => RideModel.fromJson(_convertMap(json as Map<dynamic, dynamic>))).toList();
        }
      }
      return [];
    } catch (e) {
      print('Erreur recherche rapide: $e');
      rethrow;
    }
  }

  // 13. TRAJETS DISPONIBLES AUJOURD'HUI
  Future<List<RideModel>> getTodayRides() async {
    try {
      final response = await _apiService.get(
        'rides/today',
        isProtected: false,
      );

      if (response is Map) {
        final Map<String, dynamic> convertedResponse = _convertMap(response as Map<dynamic, dynamic>);
        
        if (convertedResponse.containsKey('rides')) {
          final List<dynamic> data = convertedResponse['rides'] ?? [];
          return data.map((json) => RideModel.fromJson(_convertMap(json as Map<dynamic, dynamic>))).toList();
        }
      }
      return [];
    } catch (e) {
      print('Erreur trajets aujourd\'hui: $e');
      rethrow;
    }
  }

  // 14. CONFIRMER UN TRAJET (pour conducteur)
  Future<void> confirmRide(String rideId) async {
    try {
      await _apiService.put(
        'rides/$rideId/confirm',
        {},
        isProtected: true,
      );
    } catch (e) {
      print('Erreur confirmation trajet: $e');
      rethrow;
    }
  }

  // 15. ANNULER UN TRAJET
  Future<void> cancelRide(String rideId) async {
    try {
      await _apiService.delete(
        'rides/$rideId',
        isProtected: true,
      );
    } catch (e) {
      print('Erreur annulation trajet: $e');
      rethrow;
    }
  }

  // 16. MARQUER UN TRAJET COMME COMPLÉTÉ
  Future<void> completeRide(String rideId) async {
    try {
      await _apiService.put(
        'rides/$rideId/complete',
        {},
        isProtected: true,
      );
    } catch (e) {
      print('Erreur complétion trajet: $e');
      rethrow;
    }
  }

  // 17. OBTENIR LES TRAJETS SIMILAIRES
  Future<List<RideModel>> getSimilarRides(String rideId) async {
    try {
      final response = await _apiService.get(
        'rides/$rideId/similar',
        isProtected: false,
      );

      if (response is Map) {
        final Map<String, dynamic> convertedResponse = _convertMap(response as Map<dynamic, dynamic>);
        
        if (convertedResponse.containsKey('similar_rides')) {
          final List<dynamic> data = convertedResponse['similar_rides'] ?? [];
          return data.map((json) => RideModel.fromJson(_convertMap(json as Map<dynamic, dynamic>))).toList();
        }
      }
      return [];
    } catch (e) {
      print('Erreur trajets similaires: $e');
      rethrow;
    }
  }
}