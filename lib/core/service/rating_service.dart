// File: lib/core/service/rating_service.dart
import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/rating_model.dart';

class RatingService {
  final ApiService _apiService;

  RatingService(this._apiService);

  // Noter un conducteur
  Future<Map<String, dynamic>> rateDriver({
    required int bookingId,
    required int rideId,
    required int driverId,
    required int rating,
    String? comment,
  }) async {
    try {
      final payload = {
        'bookingId': bookingId,
        'rideId': rideId,
        'driverId': driverId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      };

      final response = await _apiService.post(
        'ratings',
        payload,
        isProtected: true,
      );

      return response is Map ? response as Map<String, dynamic> : {};
    } catch (e) {
      throw Exception('Erreur lors de l\'enregistrement de la note: $e');
    }
  }

  // Obtenir les notes d'un conducteur
  Future<Map<String, dynamic>> getDriverRatings(
    int driverId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        'ratings/driver/$driverId?page=$page&limit=$limit',
        isProtected: false,
      );

      if (response is Map) {
        return response as Map<String, dynamic>;
      }
      return {'success': false, 'ratings': [], 'average_rating': 0.0};
    } catch (e) {
      throw Exception('Erreur lors de la récupération des notes: $e');
    }
  }

  // Obtenir mes notes données (en tant que passager)
  Future<Map<String, dynamic>> getMyRatings() async {
    try {
      final response = await _apiService.get(
        'ratings/my-ratings',
        isProtected: true,
      );

      if (response is Map) {
        return response as Map<String, dynamic>;
      }
      return {'success': false, 'ratings': []};
    } catch (e) {
      throw Exception('Erreur lors de la récupération de vos notes: $e');
    }
  }

  // Vérifier si peut noter une réservation
  Future<Map<String, dynamic>> canRate(int bookingId) async {
    try {
      final response = await _apiService.get(
        'ratings/can-rate/$bookingId',
        isProtected: true,
      );

      if (response is Map) {
        return response as Map<String, dynamic>;
      }
      return {'success': false, 'can_rate': false};
    } catch (e) {
      throw Exception('Erreur lors de la vérification: $e');
    }
  }

  // Convertir la réponse JSON en modèles RatingModel
  List<RatingModel> _parseRatings(dynamic data) {
    if (data is! List) return [];
    return data
        .map((json) => RatingModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Helper pour extraire les ratings de la réponse API
  List<RatingModel> extractRatingsFromResponse(Map<String, dynamic> response) {
    if (response['ratings'] is List) {
      return _parseRatings(response['ratings']);
    }
    return [];
  }
}
