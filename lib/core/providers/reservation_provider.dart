// reservation_provider.dart - VERSION CORRIGÉE
import 'package:flutter/foundation.dart';
import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/reservation.dart'; // AJOUTE CET IMPORT

class ReservationProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Reservation> _reservations = []; // ✅ Change en List<Reservation>
  List<Reservation> _allReservations = []; // ✅ Change en List<Reservation>
  bool _isLoading = false;
  String _error = '';
  String _filterStatus = 'all'; // ✅ Change de String? à String avec valeur par défaut

  ReservationProvider(this._apiService);

  // Getters
  List<Reservation> get reservations => _reservations; // ✅ Retourne List<Reservation>
  List<Reservation> get allReservations => _allReservations;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get filterStatus => _filterStatus; // ✅ Retourne String

  // Alias pour compatibilité
  List<Reservation> get filteredReservations => _reservations; // ✅ List<Reservation>

  // Charger toutes les réservations
  Future<void> loadReservations() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('📦 Chargement des réservations...');
      
      final response = await _apiService.get(
        'reservations/my-reservations',
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        // ✅ Convertir les données JSON en objets Reservation
        final reservationsJson = response['reservations'] as List? ?? [];
        _allReservations = reservationsJson
            .map((json) => Reservation.fromJson(json))
            .toList();
        
        _applyFilter(); // Appliquer le filtre actuel
        
        print('✅ ${_allReservations.length} réservations chargées');
      } else {
        _error = response['message'] ?? 'Erreur de chargement';
        _reservations = [];
        _allReservations = [];
      }
    } catch (e) {
      print('❌ Erreur chargement réservations: $e');
      _error = 'Erreur: ${e.toString()}';
      _reservations = [];
      _allReservations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ CORRECTION : Filtrer par statut
  void filterByStatus(String status) {
    _filterStatus = status;
    _applyFilter();
    notifyListeners();
  }

  // ✅ CORRECTION : setFilter doit accepter String, pas String?
  void setFilter(String status) {
    if (_filterStatus != status) {
      _filterStatus = status;
      _applyFilter(); // ✅ AJOUT: Appliquer le filtre
      notifyListeners();
    }
  }

  void _applyFilter() {
    if (_filterStatus == 'all') {
      _reservations = List.from(_allReservations);
    } else {
      _reservations = _allReservations
          .where((r) => r.status.toLowerCase() == _filterStatus.toLowerCase())
          .toList();
    }
  }

  // Statistiques des réservations
  Map<String, int> get reservationStats {
    final stats = <String, int>{
      'all': _allReservations.length,
      'pending': _allReservations.where((r) => r.status == 'pending').length,
      'confirmed': _allReservations.where((r) => r.status == 'confirmed').length,
      'completed': _allReservations.where((r) => r.status == 'completed').length,
      'cancelled': _allReservations.where((r) => r.status == 'cancelled').length,
    };

    return stats;
  }
  // ✅ CORRECTION : Annuler une réservation avec PUT
  Future<bool> cancelReservation(int reservationId) async {
    try {
      print('🚫 Annulation réservation #$reservationId...');
      
      // ✅ CHANGE patch par put
      final response = await _apiService.put(
        'reservations/$reservationId/cancel',
        {}, // Données vides si ton backend accepte
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        print('✅ Réservation annulée avec succès');
        
        // Recharger les réservations
        await loadReservations();
        return true;
      } else {
        _error = response['message'] ?? 'Erreur d\'annulation';
        return false;
      }
    } catch (e) {
      print('❌ Erreur annulation: $e');
      _error = 'Erreur: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Créer une réservation
  Future<bool> createReservation({
    required int rideId,
    required int seats,
    String? pickupPoint,
    String? dropoffPoint,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('📝 Création réservation pour trajet #$rideId...');
      
      final response = await _apiService.post(
        'reservations',
        {
          'ride_id': rideId,
          'seats': seats,
          if (pickupPoint != null) 'pickup_point': pickupPoint,
          if (dropoffPoint != null) 'dropoff_point': dropoffPoint,
        },
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        print('✅ Réservation créée avec succès');
        
        // Recharger les réservations
        await loadReservations();
        return true;
      } else {
        _error = response['message'] ?? 'Erreur de création';
        return false;
      }
    } catch (e) {
      print('❌ Erreur création réservation: $e');
      _error = 'Erreur: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ CORRECTION : Marquer une réservation comme terminée avec PUT
  Future<bool> markCompleted(int reservationId) async {
    try {
      print('✅ Marquage réservation #$reservationId comme terminée...');
      
      // ✅ CHANGE patch par put
      final response = await _apiService.put(
        'reservations/$reservationId/complete',
        {}, // Données vides
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        print('✅ Réservation marquée comme terminée');
        
        // Recharger les réservations
        await loadReservations();
        return true;
      } else {
        _error = response['message'] ?? 'Erreur de complétion';
        return false;
      }
    } catch (e) {
      print('❌ Erreur complétion: $e');
      _error = 'Erreur: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Obtenir une réservation par ID
  Future<Map<String, dynamic>?> getReservationDetails(int reservationId) async {
    try {
      print('🔍 Récupération détails réservation #$reservationId...');
      
      final response = await _apiService.get(
        'reservations/$reservationId',
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        return response['reservation'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('❌ Erreur détails réservation: $e');
      return null;
    }
  }
  // Effacer les erreurs
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Rafraîchir (pull-to-refresh)
  Future<void> refresh() async {
    await loadReservations();
  }

  // Réinitialiser les filtres
  void resetFilters() {
    _filterStatus = 'all';
    _applyFilter();
    notifyListeners();
  }
}