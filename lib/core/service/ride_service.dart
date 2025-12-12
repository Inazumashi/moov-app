// File: lib/core/services/ride_service.dart - CORRECTION COMPLÈTE
import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/models/university_model.dart';
import 'package:intl/intl.dart';

class RideService {
  final ApiService _apiService;

  RideService(this._apiService);

  Map<String, dynamic> _convertMap(Map<dynamic, dynamic> map) {
    return Map<String, dynamic>.from(map);
  }

  List<Map<String, dynamic>> _convertList(List<dynamic> list) {
    return list
        .map((item) => _convertMap(item as Map<dynamic, dynamic>))
        .toList();
  }

  // 1. CORRECTION CRITIQUE : Recherche de trajets
  Future<List<RideModel>> searchRides({
    required String from,
    required String to,
    required DateTime date,
  }) async {
    try {
      final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // D'abord, obtenir les IDs des stations
      final departureId = await _getStationId(from);
      final arrivalId = await _getStationId(to);

      if (departureId == null || arrivalId == null) {
        throw Exception(
            'Stations non trouvées. Veuillez sélectionner dans la liste.');
      }

      // Rechercher avec les IDs
      final response = await _apiService.get(
        'rides/search?departure_station_id=$departureId&arrival_station_id=$arrivalId&departure_date=$formattedDate',
        isProtected: false,
      );

      if (response is Map) {
        final Map<String, dynamic> convertedResponse =
            _convertMap(response as Map<dynamic, dynamic>);

        if (convertedResponse.containsKey('rides')) {
          final List<dynamic> data = convertedResponse['rides'] ?? [];
          return data
              .map((json) => RideModel.fromJson(
                  _convertMap(json as Map<dynamic, dynamic>)))
              .toList();
        } else if (convertedResponse.containsKey('data')) {
          final List<dynamic> data = convertedResponse['data'] ?? [];
          return data
              .map((json) => RideModel.fromJson(
                  _convertMap(json as Map<dynamic, dynamic>)))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Erreur recherche trajets: $e');
      rethrow;
    }
  }

  // Nouvelle méthode : Obtenir l'ID d'une station par son nom
  Future<int?> _getStationId(String stationName) async {
    try {
      final response = await _apiService.get(
        'stations/autocomplete?q=${Uri.encodeComponent(stationName)}&limit=1',
        isProtected: false,
      );

      if (response is Map && response['success'] == true) {
        final suggestions = response['suggestions'] ?? [];
        if (suggestions.isNotEmpty) {
          return suggestions[0]['id'];
        }
      }
      return null;
    } catch (e) {
      print('Erreur récupération ID station: $e');
      return null;
    }
  }

  // 2. CORRECTION CRITIQUE : Publication de trajet
  Future<void> publishRide(RideModel ride) async {
    try {
      // Obtenir les IDs des stations
      final departureId = await _getStationId(ride.startPoint);
      final arrivalId = await _getStationId(ride.endPoint);

      if (departureId == null) {
        throw Exception('Station de départ non trouvée: ${ride.startPoint}');
      }
      if (arrivalId == null) {
        throw Exception('Station d\'arrivée non trouvée: ${ride.endPoint}');
      }

      // Préparer les données au format backend
      final Map<String, dynamic> rideData = {
        'departure_station_id': departureId,
        'arrival_station_id': arrivalId,
        'departure_date': ride.departureTime != null
            ? DateFormat('yyyy-MM-dd').format(ride.departureTime!)
            : DateFormat('yyyy-MM-dd')
                .format(DateTime.now().add(Duration(days: 1))),
        'departure_time': ride.departureTime != null
            ? '${ride.departureTime!.hour.toString().padLeft(2, '0')}:${ride.departureTime!.minute.toString().padLeft(2, '0')}'
            : '08:00',
        'available_seats': ride.availableSeats,
        'price_per_seat': ride.pricePerSeat,
        'notes': ride.notes ?? '',
        'vehicle_details': ride.vehicleInfo ?? '',
      };

      print('📤 Publication avec données: $rideData');

      await _apiService.post(
        'rides',
        rideData,
        isProtected: true,
      );
    } catch (e) {
      print('Erreur publication trajet: $e');
      rethrow;
    }
  }

  // 3. CORRECTION : Charger les favoris
  Future<List<RideModel>> getFavoriteRides() async {
    try {
      final response = await _apiService.get(
        'advanced/favorite-rides',
        isProtected: true,
      );

      if (response is Map) {
        final Map<String, dynamic> convertedResponse =
            _convertMap(response as Map<dynamic, dynamic>);

        if (convertedResponse.containsKey('success') &&
            convertedResponse['success'] == false) {
          return [];
        }

        if (convertedResponse.containsKey('favorite_rides')) {
          final List<dynamic> data = convertedResponse['favorite_rides'] ?? [];
          return data
              .map((json) => RideModel.fromJson(
                  _convertMap(json as Map<dynamic, dynamic>)))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Erreur trajets favoris: $e');
      return [];
    }
  }

  // Les autres méthodes restent inchangées...
  Future<List<RideModel>> getMyPublishedRides() async {
    try {
      final response = await _apiService.get(
        'rides/my-rides',
        isProtected: true,
      );

      if (response is Map) {
        final Map<String, dynamic> convertedResponse =
            _convertMap(response as Map<dynamic, dynamic>);

        if (convertedResponse.containsKey('rides')) {
          final List<dynamic> data = convertedResponse['rides'] ?? [];
          return data
              .map((json) => RideModel.fromJson(
                  _convertMap(json as Map<dynamic, dynamic>)))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Erreur trajets publiés: $e');
      rethrow;
    }
  }

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

  Future<List<UniversityModel>> getUniversities() async {
    try {
      final response = await _apiService.get(
        'auth/universities',
        isProtected: false,
      );

      if (response is Map) {
        final Map<String, dynamic> convertedResponse =
            _convertMap(response as Map<dynamic, dynamic>);

        if (convertedResponse.containsKey('universities')) {
          final List<dynamic> data = convertedResponse['universities'] ?? [];
          return data
              .map((json) => UniversityModel.fromJson(
                  _convertMap(json as Map<dynamic, dynamic>)))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Erreur chargement universités: $e');
      return [];
    }
  }
}
