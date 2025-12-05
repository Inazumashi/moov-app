// File: lib/core/providers/reservation_provider.dart
import 'package:flutter/foundation.dart';
import 'package:moovapp/core/models/reservation.dart';
import 'package:moovapp/core/service/reservation_service.dart';
import 'package:moovapp/core/api/api_service.dart';

class ReservationProvider with ChangeNotifier {
  late final ReservationService _reservationService;
  List<Reservation> _reservations = [];
  bool _isLoading = false;
  String _error = '';
  String _filterStatus = 'all';

  ReservationProvider() {
    final apiService = ApiService();
    _reservationService = ReservationService(apiService);
  }

  // Getters
  List<Reservation> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get filterStatus => _filterStatus;

  List<Reservation> get filteredReservations {
    if (_filterStatus == 'all') return _reservations;
    
    return _reservations.where((reservation) {
      return reservation.status == _filterStatus;
    }).toList();
  }

  Future<void> loadReservations() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    final result = await _reservationService.getMyReservations();

    _isLoading = false;

    if (result['success'] == true) {
      final data = result['data'];
      if (data != null && data['reservations'] != null) {
        List<dynamic> reservationsJson = data['reservations'];
        _reservations = reservationsJson.map((json) => Reservation.fromJson(json)).toList();
        _reservations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _reservations = [];
      }
    } else {
      _error = result['error'] ?? 'Erreur inconnue';
    }

    notifyListeners();
  }

  Future<bool> createReservation({
    required int rideId,
    required int seats,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _reservationService.createReservation(
      rideId: rideId,
      seatsReserved: seats,
    );

    _isLoading = false;

    if (result['success'] == true) {
      await loadReservations();
      notifyListeners();
      return true;
    } else {
      _error = result['error'] ?? 'Erreur lors de la réservation';
      notifyListeners();
      return false;
    }
  }

  // ✅ CORRIGÉ - Annulation réelle avec API
  Future<bool> cancelReservation(int reservationId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    final result = await _reservationService.cancelReservation(reservationId);

    _isLoading = false;

    if (result['success'] == true) {
      await loadReservations();
      notifyListeners();
      return true;
    } else {
      _error = result['error'] ?? 'Erreur lors de l\'annulation';
      notifyListeners();
      return false;
    }
  }

  // ✅ NOUVELLE MÉTHODE - Confirmation de réservation
  Future<bool> confirmReservation(int reservationId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    final result = await _reservationService.confirmReservation(reservationId);

    _isLoading = false;

    if (result['success'] == true) {
      await loadReservations();
      notifyListeners();
      return true;
    } else {
      _error = result['error'] ?? 'Erreur lors de la confirmation';
      notifyListeners();
      return false;
    }
  }

  void setFilter(String status) {
    if (_filterStatus != status) {
      _filterStatus = status;
      notifyListeners();
    }
  }

  Map<String, int> get reservationStats {
    return {
      'total': _reservations.length,
      'confirmed': _reservations.where((r) => r.status == 'confirmed').length,
      'cancelled': _reservations.where((r) => r.status == 'cancelled').length,
      'completed': _reservations.where((r) => r.status == 'completed').length,
    };
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}