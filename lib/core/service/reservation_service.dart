// File: lib/core/service/reservation_service.dart - CORRIGÉ
import 'package:moovapp/core/api/api_service.dart';

class ReservationService {
  final ApiService _apiService;

  ReservationService(this._apiService);

  // ✅ CORRECTION : Utiliser les bons noms de champs
  Future<Map<String, dynamic>> createReservation({
    required int rideId,
    required int seatsReserved,
  }) async {
    try {
      print('📤 Création réservation: rideId=$rideId, seats=$seatsReserved');
      
      // ✅ CORRECTION : Envoyer avec les noms attendus par le backend
      final response = await _apiService.post('reservations', {
        'rideId': rideId,           // ✅ Backend attend 'rideId'
        'seatsReserved': seatsReserved,  // ✅ Backend attend 'seatsReserved'
      });

      print('✅ Réservation créée avec succès');

      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      print('❌ Erreur création réservation: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getMyReservations() async {
    try {
      final response = await _apiService.get('reservations/my-reservations');

      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      print('❌ Erreur récupération réservations: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ✅ Annulation de réservation
  Future<Map<String, dynamic>> cancelReservation(int reservationId) async {
    try {
      print('🚫 Annulation réservation ID: $reservationId');
      
      await _apiService.delete('reservations/$reservationId');

      print('✅ Réservation annulée avec succès');

      return {
        'success': true,
      };
    } catch (e) {
      print('❌ Erreur annulation réservation: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ✅ Confirmation de réservation
  Future<Map<String, dynamic>> confirmReservation(int reservationId) async {
    try {
      print('✅ Confirmation réservation ID: $reservationId');
      
      await _apiService.put('reservations/$reservationId/confirm', {});

      print('✅ Réservation confirmée avec succès');

      return {
        'success': true,
      };
    } catch (e) {
      print('❌ Erreur confirmation réservation: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getReservationDetails(int reservationId) async {
    try {
      final response = await _apiService.get('reservations/$reservationId');

      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ✅ NOUVELLE MÉTHODE : Obtenir les statistiques
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiService.get('reservations/stats');

      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ✅ NOUVELLE MÉTHODE : Marquer une réservation comme complétée
  Future<Map<String, dynamic>> markCompleted(int reservationId) async {
    try {
      print('✅ Marquer réservation $reservationId comme complétée');
      await _apiService.put('reservations/$reservationId/complete', {});
      return {
        'success': true,
      };
    } catch (e) {
      print('❌ Erreur markCompleted: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Récupérer les réservations pour un trajet (par rideId)
  Future<Map<String, dynamic>> getReservationsForRide(int rideId) async {
    try {
      final response = await _apiService.get('reservations/for-ride/$rideId');
      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      print('❌ Erreur getReservationsForRide: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}