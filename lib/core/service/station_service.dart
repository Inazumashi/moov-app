// File: lib/core/services/station_service.dart
import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/station_model.dart';

class StationService {
  final ApiService _apiService;

  StationService(this._apiService);

  // Auto-complétion des stations
  Future<List<StationModel>> autocomplete(String query, {int limit = 10}) async {
    try {
      final response = await _apiService.get(
        'stations/autocomplete?q=$query&limit=$limit',
        isProtected: false,
      );

      if (response['success'] == true) {
        final List<dynamic> suggestions = response['suggestions'] ?? [];
        return suggestions.map((json) => StationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur auto-complétion stations: $e');
      rethrow;
    }
  }

  // Stations proches (géolocalisation)
  Future<List<StationModel>> nearby(double lat, double lng, {double radius = 10, int limit = 20}) async {
    try {
      final response = await _apiService.get(
        'stations/nearby?lat=$lat&lng=$lng&radius=$radius&limit=$limit',
        isProtected: false,
      );

      if (response['success'] == true) {
        final List<dynamic> stations = response['stations'] ?? [];
        return stations.map((json) => StationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur stations proches: $e');
      rethrow;
    }
  }

  // Stations populaires
  Future<List<StationModel>> popular({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        'stations/popular?limit=$limit',
        isProtected: false,
      );

      if (response['success'] == true) {
        final List<dynamic> stations = response['stations'] ?? [];
        return stations.map((json) => StationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur stations populaires: $e');
      rethrow;
    }
  }



  // Dans station_service.dart
Future<List<StationModel>> getStationsByCity(String city) async {
  try {
    final response = await _apiService.get('stations/city/$city');
    final List<dynamic> data = response['stations'] ?? [];
    return data.map((json) => StationModel.fromJson(json)).toList();
  } catch (e) {
    print('❌ Erreur getStationsByCity: $e');
    return [];
  }
}

Future<List<StationModel>> getStationsByUniversity(int universityId) async {
  try {
    final response = await _apiService.get('stations/university/$universityId');
    final List<dynamic> data = response['stations'] ?? [];
    return data.map((json) => StationModel.fromJson(json)).toList();
  } catch (e) {
    print('❌ Erreur getStationsByUniversity: $e');
    return [];
  }
}
  // Ajouter une station aux favoris
  Future<bool> addToFavorites(int stationId, {String type = 'both'}) async {
    try {
      final response = await _apiService.post(
        'stations/favorites',
        {
          'stationId': stationId,  // CORRECTION: 'stationId' avec 's' minuscule
          'type': type,
        },
        isProtected: true,
      );

      return response['success'] == true;
    } catch (e) {
      print('Erreur ajout favoris: $e');
      rethrow;
    }
  }

  // Retirer une station des favoris - CORRECTION MÉTHODE
  Future<bool> removeFromFavorites(int stationId, {String? type}) async {
    try {
      // CORRECTION: Utilisation correcte de la méthode delete avec paramètre data
      final response = await _apiService.delete(
        'stations/favorites',
        data: {
          'stationId': stationId,  // CORRECTION: 'stationId' avec 's' minuscule
          if (type != null) 'type': type,
        },
      );

      return response['success'] == true;
    } catch (e) {
      print('Erreur suppression favoris: $e');
      rethrow;
    }
  }

  // Mes stations favorites
  Future<List<StationModel>> getMyFavorites({String? type}) async {
    try {
      String endpoint = 'stations/favorites';
      if (type != null) {
        endpoint += '?type=$type';
      }

      final response = await _apiService.get(
        endpoint,
        isProtected: true,
      );

      if (response['success'] == true) {
        final List<dynamic> favorites = response['favorites'] ?? [];
        return favorites.map((json) => StationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur récupération favoris: $e');
      rethrow;
    }
  }

  // Stations récentes (historique)
  Future<List<StationModel>> getRecent({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        'stations/recent?limit=$limit',
        isProtected: true,
      );

      if (response['success'] == true) {
        final List<dynamic> stations = response['stations'] ?? [];
        return stations.map((json) => StationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Erreur stations récentes: $e');
      rethrow;
    }
  }

  // Itinéraires populaires
  Future<List<Map<String, dynamic>>> getPopularRoutes({int limit = 10}) async {
    try {
      final response = await _apiService.get(
        'stations/popular-routes?limit=$limit',
        isProtected: false,
      );

      if (response['success'] == true) {
        return List<Map<String, dynamic>>.from(response['routes'] ?? []);
      }
      return [];
    } catch (e) {
      print('Erreur itinéraires populaires: $e');
      rethrow;
    }
  }

  // Recherche rapide (départ/arrivée) - CORRECTION DE L'ENDPOINT
  Future<Map<String, dynamic>> quickSearch({
    required String departure,
    required String arrival,
    String? date,
  }) async {
    try {
      // CORRECTION: L'endpoint correct est 'rides/quick-search' selon votre backend
      String endpoint = 'rides/quick-search?departure=$departure&arrival=$arrival';
      if (date != null) {
        endpoint += '&date=$date';
      }

      final response = await _apiService.get(
        endpoint,
        isProtected: false,
      );

      if (response['success'] == true) {
        return {
          'rides': (response['rides'] as List)
              .map((json) => json)
              .toList(),
          'suggested_departures': (response['suggested_departures'] as List)
              .map((json) => StationModel.fromJson(json))
              .toList(),
          'suggested_arrivals': (response['suggested_arrivals'] as List)
              .map((json) => StationModel.fromJson(json))
              .toList(),
        };
      }
      return {'rides': [], 'suggested_departures': [], 'suggested_arrivals': []};
    } catch (e) {
      print('Erreur recherche rapide: $e');
      rethrow;
    }
  }
}