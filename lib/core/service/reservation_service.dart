// File: lib/core/service/reservation_service.dart
import 'package:moovapp/core/api/api_service.dart';

class ReservationService {
  final ApiService _apiService;

  ReservationService(this._apiService);

  Future<Map<String, dynamic>> createReservation({
    required int rideId,
    required int seatsReserved,
  }) async {
    try {
      final response = await _apiService.post('reservations', {
        'ride_id': rideId,
        'seats_reserved': seatsReserved,
      });

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

  Future<Map<String, dynamic>> getMyReservations() async {
    try {
      final response = await _apiService.get('reservations/my');
      
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

  // ✅ NOUVELLE MÉTHODE - Annulation réelle
  Future<Map<String, dynamic>> cancelReservation(int reservationId) async {
    try {
      await _apiService.delete('reservations/$reservationId');
      
      return {
        'success': true,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ✅ NOUVELLE MÉTHODE - Confirmation de réservation
  Future<Map<String, dynamic>> confirmReservation(int reservationId) async {
    try {
      await _apiService.put('reservations/$reservationId/confirm', {});
      
      return {
        'success': true,
      };
    } catch (e) {
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
}