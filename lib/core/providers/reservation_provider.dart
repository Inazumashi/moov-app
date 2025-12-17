// lib/core/providers/reservation_provider.dart - VERSION CORRIGÉE
import 'package:flutter/foundation.dart';
import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/reservation.dart';
import 'package:moovapp/core/models/ride_model.dart';

class ReservationProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Reservation> _reservations = [];
  List<Reservation> _allReservations = [];
  bool _isLoading = false;
  String _error = '';
  String _filterStatus = 'all';

  ReservationProvider(this._apiService);

  // Getters
  List<Reservation> get reservations => _reservations;
  List<Reservation> get allReservations => _allReservations;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get filterStatus => _filterStatus;
  List<Reservation> get filteredReservations => _reservations;

  // Charger toutes les réservations AVEC les trajets
  Future<void> loadReservations() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('📦 Chargement des réservations avec trajets...');
      
      final response = await _apiService.get(
        'reservations/my-reservations',
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        final reservationsJson = response['reservations'] as List? ?? [];
        
        print('📊 ${reservationsJson.length} réservations reçues');
        
        // Charger les réservations avec leurs trajets
        final reservations = await _loadReservationsWithRides(reservationsJson);
        
        _allReservations = reservations;
        _applyFilter();
        
        print('✅ ${_allReservations.length} réservations chargées avec succès');
        print('🚗 Réservations avec trajet: ${_allReservations.where((r) => r.ride != null).length}');
        
      } else {
        _error = response['message']?.toString() ?? 'Erreur de chargement';
        print('⚠️ Erreur API: $_error');
        _reservations = [];
        _allReservations = [];
      }
    } catch (e, stackTrace) {
      print('❌ Erreur chargement réservations: $e');
      print('Stack trace: $stackTrace');
      _error = 'Erreur: ${e.toString()}';
      _reservations = [];
      _allReservations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les réservations avec leurs trajets
  Future<List<Reservation>> _loadReservationsWithRides(List<dynamic> reservationsJson) async {
    final reservations = <Reservation>[];
    
    for (var json in reservationsJson) {
      try {
        // Créer la réservation de base
        final reservation = Reservation.fromJson(json);
        
        // Si le JSON contient déjà les infos du trajet
        RideModel? ride;
        if (json['ride'] != null && json['ride'] is Map) {
          try {
            ride = RideModel.fromJson(json['ride'] as Map<String, dynamic>);
            print('✅ Trajet chargé depuis reservation JSON: ${ride.rideId}');
          } catch (e) {
            print('❌ Erreur parsing ride depuis JSON: $e');
          }
        }
        
        // Si le trajet n'est pas dans le JSON, le charger séparément
        if (ride == null && reservation.rideId > 0) {
          try {
            ride = await _loadRideById(reservation.rideId);
            print('✅ Trajet chargé séparément pour rideId: ${reservation.rideId}');
          } catch (e) {
            print('❌ Erreur chargement trajet pour rideId ${reservation.rideId}: $e');
          }
        }
        
        // Créer la réservation avec le trajet
        final reservationWithRide = reservation.copyWith(ride: ride);
        reservations.add(reservationWithRide);
        
      } catch (e) {
        print('❌ Erreur création réservation: $e - JSON: $json');
      }
    }
    
    return reservations;
  }

  // Charger un trajet par ID
  Future<RideModel?> _loadRideById(int rideId) async {
    try {
      print('🔍 Chargement du trajet #$rideId...');
      
      final response = await _apiService.get(
        'rides/$rideId',
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        final rideJson = response['ride'] as Map<String, dynamic>?;
        if (rideJson != null) {
          return RideModel.fromJson(rideJson);
        }
      }
      return null;
    } catch (e) {
      print('❌ Erreur chargement trajet #$rideId: $e');
      return null;
    }
  }

  // Filtrer par statut
  void filterByStatus(String status) {
    _filterStatus = status;
    _applyFilter();
    notifyListeners();
  }

  // setFilter alias de filterByStatus
  void setFilter(String status) {
    filterByStatus(status);
  }

  // Appliquer le filtre
  void _applyFilter() {
    if (_filterStatus == 'all') {
      _reservations = List.from(_allReservations);
    } else {
      _reservations = _allReservations
          .where((r) => r.status.toLowerCase() == _filterStatus.toLowerCase())
          .toList();
    }
    print('🎯 Filtre appliqué: $_filterStatus -> ${_reservations.length} réservations');
  }

  // Statistiques des réservations
  Map<String, int> get reservationStats {
    final stats = <String, int>{
      'all': _allReservations.length,
      'pending': _allReservations.where((r) => r.status.toLowerCase() == 'pending').length,
      'confirmed': _allReservations.where((r) => r.status.toLowerCase() == 'confirmed').length,
      'completed': _allReservations.where((r) => r.status.toLowerCase() == 'completed').length,
      'cancelled': _allReservations.where((r) => r.status.toLowerCase() == 'cancelled').length,
    };

    print('📊 Stats réservations: $stats');
    return stats;
  }

  // Annuler une réservation
  Future<bool> cancelReservation(int reservationId) async {
    try {
      print('🚫 Annulation réservation #$reservationId...');
      
      final response = await _apiService.put(
        'reservations/$reservationId/cancel',
        {},
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        print('✅ Réservation annulée avec succès');
        
        // Recharger les réservations
        await loadReservations();
        return true;
      } else {
        _error = response['message']?.toString() ?? 'Erreur d\'annulation';
        print('⚠️ Erreur annulation: $_error');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Erreur annulation: $e');
      print('Stack trace: $stackTrace');
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
        _error = response['message']?.toString() ?? 'Erreur de création';
        print('⚠️ Erreur création: $_error');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Erreur création réservation: $e');
      print('Stack trace: $stackTrace');
      _error = 'Erreur: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Marquer une réservation comme terminée
  Future<bool> markCompleted(int reservationId) async {
    try {
      print('✅ Marquage réservation #$reservationId comme terminée...');
      
      final response = await _apiService.put(
        'reservations/$reservationId/complete',
        {},
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        print('✅ Réservation marquée comme terminée');
        
        // Recharger les réservations
        await loadReservations();
        return true;
      } else {
        _error = response['message']?.toString() ?? 'Erreur de complétion';
        print('⚠️ Erreur complétion: $_error');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Erreur complétion: $e');
      print('Stack trace: $stackTrace');
      _error = 'Erreur: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Obtenir une réservation par ID
  Future<Reservation?> getReservationById(int reservationId) async {
    try {
      print('🔍 Récupération détails réservation #$reservationId...');
      
      final response = await _apiService.get(
        'reservations/$reservationId',
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        final reservationJson = response['reservation'];
        if (reservationJson != null) {
          // Charger avec le trajet
          final reservation = Reservation.fromJson(reservationJson);
          
          // Charger le trajet si nécessaire
          if (reservation.ride == null && reservation.rideId > 0) {
            final ride = await _loadRideById(reservation.rideId);
            return reservation.copyWith(ride: ride);
          }
          
          return reservation;
        }
      }
      return null;
    } catch (e, stackTrace) {
      print('❌ Erreur détails réservation: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Trouver une réservation par ID dans la liste locale - CORRECTION
  Reservation? findReservationById(int reservationId) {
    try {
      return _allReservations.firstWhere(
        (r) => r.id == reservationId,
      );
    } catch (e) {
      return null;
    }
  }

  // Vérifier les messages non lus
  bool get hasUnreadMessages {
    return _allReservations.any((r) => r.hasUnreadMessages);
  }

  int get unreadMessagesCount {
    return _allReservations
        .where((r) => r.hasUnreadMessages)
        .fold(0, (sum, r) => sum + r.unreadMessagesCount);
  }

  // Effacer les erreurs
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Rafraîchir
  Future<void> refresh() async {
    await loadReservations();
  }

  // Réinitialiser les filtres
  void resetFilters() {
    _filterStatus = 'all';
    _applyFilter();
    notifyListeners();
  }

  // Vérifier si l'utilisateur a des réservations actives
  bool get hasActiveReservations {
    return _allReservations.any((r) => r.isActive);
  }

  // Compter les réservations actives
  int get activeReservationsCount {
    return _allReservations.where((r) => r.isActive).length;
  }

  // Calculer les statistiques écologiques
  Map<String, double> calculateEcoStats() {
    double totalDistance = 0;
    double totalCO2Saved = 0;
    double totalMoneySaved = 0;
    int totalPassengers = 0;
    
    // Seulement les réservations complétées
    final completedReservations = _allReservations.where((r) => r.status == 'completed');
    
    for (var reservation in completedReservations) {
      // Estimation de distance (à adapter selon votre logique)
      final distance = _estimateDistance(reservation);
      totalDistance += distance;
      totalPassengers += reservation.seatsReserved;
      
      // Calcul CO2 économisé (simplifié)
      // 1 voiture = ~150g CO2/km, donc économie = CO2 évité par passager supplémentaire
      final co2PerKm = 150.0; // grammes
      final co2Saved = distance * co2PerKm * (reservation.seatsReserved - 1);
      totalCO2Saved += co2Saved / 1000; // convertir en kg
      
      // Calcul économies (simplifié)
      // Prix essence: ~12 DH/L, consommation: ~6L/100km
      final fuelCostPerKm = (12.0 * 6.0) / 100; // DH/km
      final fuelCost = distance * fuelCostPerKm;
      final revenue = reservation.totalPrice;
      final savings = revenue - fuelCost;
      if (savings > 0) totalMoneySaved += savings;
    }
    
    return {
      'total_distance': totalDistance,
      'co2_saved_kg': totalCO2Saved,
      'money_saved_dh': totalMoneySaved,
      'total_passengers': totalPassengers.toDouble(),
      'trees_equivalent': totalCO2Saved / 21, // 1 arbre absorbe ~21kg CO2/an
    };
  }
  
  // Méthode pour estimer la distance (à adapter)
  double _estimateDistance(Reservation reservation) {
    // Si vous avez des données de distance dans votre modèle
    if (reservation.ride != null) {
      // Ici vous devriez avoir une logique pour estimer la distance
      // basée sur les stations de départ et d'arrivée
      return 50.0; // Valeur par défaut
    }
    return 50.0; // Distance moyenne par défaut
  }
}