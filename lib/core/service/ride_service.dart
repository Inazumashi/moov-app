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

  // 🚀 LOGIQUE MODIFIÉE : Recherche de trajets par IDs avec filtres avancés
  Future<List<RideModel>> searchRides({
    required int departureId,
    required int arrivalId,
    required DateTime date,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? verifiedOnly,
    String? departureTimeStart,
    String? departureTimeEnd,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Construire URL avec queryParameters
      Map<String, String> queryParams = {
        'departure_station_id': departureId.toString(),
        'arrival_station_id': arrivalId.toString(),
        'departure_date': formattedDate,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (minRating != null) queryParams['min_rating'] = minRating.toString();
      if (verifiedOnly != null)
        queryParams['verified_only'] = verifiedOnly.toString();
      if (departureTimeStart != null)
        queryParams['departure_time_start'] = departureTimeStart;
      if (departureTimeEnd != null)
        queryParams['departure_time_end'] = departureTimeEnd;

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final url = 'rides/search?$queryString';

      print('🔍 Requête API: $url');

      final response = await _apiService.get(
        url,
        isProtected: false,
      );

      if (response is Map) {
        final Map<String, dynamic> convertedResponse =
            _convertMap(response as Map<dynamic, dynamic>);

        if (convertedResponse.containsKey('rides')) {
          final List<dynamic> data = convertedResponse['rides'] ?? [];
          print('✅ ${data.length} trajets trouvés.');
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
      print('❌ Erreur recherche trajets: $e');
      rethrow;
    }
  }

  // 🎯 NOUVEAU : Suggestions personnalisées pour l'utilisateur
  Future<List<RideModel>> getSuggestions() async {
    try {
      print('📌 Chargement suggestions...');

      final response = await _apiService.get(
        'search/rides/suggestions',
        isProtected: true,
      );

      if (response is Map) {
        final Map<String, dynamic> convertedResponse =
            _convertMap(response as Map<dynamic, dynamic>);

        if (convertedResponse.containsKey('suggestions')) {
          final List<dynamic> data = convertedResponse['suggestions'] ?? [];
          print('✅ ${data.length} suggestions chargées.');
          return data
              .map((json) => RideModel.fromJson(
                  _convertMap(json as Map<dynamic, dynamic>)))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('❌ Erreur chargement suggestions: $e');
      return [];
    }
  }

  // 🛑 MÉTHODE À CONSERVER : Utile pour publishRide ou autres besoins
  // Obtenir l'ID d'une station par son nom
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
      print('📤 Début publication du trajet...');
      print(
          '   Départ: ${ride.startPoint} (Station ID: ${ride.departureStationId})');
      print(
          '   Arrivée: ${ride.endPoint} (Station ID: ${ride.arrivalStationId})');

      // ✅ CORRECTION: Les IDs DOIVENT être présents (passés depuis publish_ride_screen)
      final departureId = ride.departureStationId;
      final arrivalId = ride.arrivalStationId;

      if (departureId == null || departureId == 0) {
        throw Exception(
            'ID station de départ manquant pour: ${ride.startPoint}');
      }
      if (arrivalId == null || arrivalId == 0) {
        throw Exception(
            'ID station d\'arrivée manquant pour: ${ride.endPoint}');
      }

      print(
          '✅ IDs utilisés directement: Départ=$departureId, Arrivée=$arrivalId');

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
        isProtected: true, // ✅ IMPORTANT: Route protégée
      );

      print('✅ Trajet publié avec succès!');
    } catch (e) {
      print('❌ Erreur publication trajet: $e');
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

  // 4. Charger les trajets publiés par l'utilisateur
  Future<List<RideModel>> getMyPublishedRides() async {
    try {
      print('🚗 getMyPublishedRides appelé');

      final response =
          await _apiService.get('rides/my-rides', isProtected: true);

      print('📊 Type réponse: ${response.runtimeType}');

      if (response is Map && response.containsKey('rides')) {
        final ridesList = response['rides'] as List;
        print('📊 Nombre de trajets: ${ridesList.length}');

        final parsedRides = <RideModel>[];
        for (var i = 0; i < ridesList.length; i++) {
          try {
            final rideJson = ridesList[i] as Map<String, dynamic>;

            // ✅ DEBUG DÉTAILLÉ
            print('=' * 50);
            print('🔍 Trajet $i - Champs disponibles:');
            rideJson.forEach((key, value) {
              print('   $key: $value (${value.runtimeType})');
            });

            final ride = RideModel.fromJson(rideJson);
            parsedRides.add(ride);

            // ✅ VÉRIFICATION
            print('✅ Trajet parsé:');
            print('   ID: ${ride.rideId}');
            print(
                '   Départ: ${ride.startPoint} (Station ID: ${ride.departureStationId})');
            print(
                '   Arrivée: ${ride.endPoint} (Station ID: ${ride.arrivalStationId})');
            print('   Date: ${ride.departureTime}');
          } catch (e, stack) {
            print('❌ Erreur parsing trajet $i: $e');
            print('❌ Stack: $stack');
          }
        }
        return parsedRides;
      } else {
        print('❌ Format inattendu ou pas de trajets');
        return [];
      }
    } catch (e) {
      print('❌ ERREUR getMyPublishedRides: $e');
      rethrow;
    }
  }

  // 5. Supprimer un trajet
  Future<void> deleteRide(String rideId) async {
    try {
      await _apiService.delete(
        'rides/$rideId',
        isProtected: true,
      );
      print('✅ ride_service.deleteRide: request sent for id $rideId');
    } catch (e) {
      print('Erreur suppression trajet: $e');
      rethrow;
    }
  }

  // 6. Mettre à jour un trajet
  Future<void> updateRide(RideModel ride) async {
    try {
      await _apiService.put(
        'rides/${ride.rideId}',
        ride.toApiJson(),
        isProtected: true,
      );
    } catch (e) {
      print('Erreur mise à jour trajet: $e');
      rethrow;
    }
  }

  // 7. Ajouter aux favoris
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

  // 8. Retirer des favoris
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

  // 9. Charger les universités
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
