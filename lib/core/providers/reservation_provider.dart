// lib/core/providers/reservation_provider.dart - VERSION COMPLÈTE CORRIGÉE
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/reservation.dart';
import 'package:moovapp/core/models/ride_model.dart';

class ReservationProvider with ChangeNotifier {
  final ApiService _apiService;
  String? _token;

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

  // Définir le token
  void setToken(String token) {
    _token = token;
  }

  // Méthode helper pour obtenir l'URL de base
  String _getBaseUrl() {
    if (kIsWeb) {
      return "http://localhost:3000/api";
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:3000/api";
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return "http://localhost:3000/api";
    } else {
      return "http://localhost:3000/api";
    }
  }

  // ✅ Méthode principale pour réserver - VERSION SIMPLIFIÉE
  Future<bool> bookRide(int rideId, int seats) async {
    // Protection contre les doubles appels
    if (_isLoading) {
      print('⚠️ Réservation déjà en cours, ignore...');
      return false;
    }
    
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('📝 Réservation trajet #$rideId avec $seats place(s)...');
      
      // Validation
      if (rideId <= 0) {
        _error = 'ID du trajet invalide';
        print('❌ Erreur: rideId invalide: $rideId');
        return false;
      }
      
      final token = await _apiService.getToken();
      if (token == null || token.isEmpty) {
        _error = 'Session expirée. Veuillez vous reconnecter.';
        print('⚠️ Erreur: Token non disponible');
        return false;
      }
      
      final baseUrl = _getBaseUrl();
      final url = Uri.parse('$baseUrl/reservations');
      
      // ✅ FORMAT UNIQUE (camelCase seulement)
      final requestData = {
        'rideId': rideId,
        'seatsBooked': seats,
      };
      
      print('📤 Envoi avec format camelCase: $requestData');
      print('📤 Données JSON: ${jsonEncode(requestData)}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestData),
      );

      print('📡 Réponse: ${response.statusCode}');
      print('📡 Corps: ${response.body}');
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['success'] == true) {
          print('✅ Réservation créée avec succès');
          print('📊 Données retour: $data');
          
          await loadReservations();
          return true;
        } else {
          _error = data['message']?.toString() ?? 'Erreur lors de la réservation';
          print('⚠️ Erreur création: $_error');
          return false;
        }
      } else {
        _error = data['message']?.toString() ?? 'Erreur lors de la réservation';
        print('⚠️ Erreur API: ${response.statusCode} - $_error');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Erreur création réservation: $e');
      print('Stack trace: $stackTrace');
      _error = 'Erreur réseau: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Créer une réservation - REDIRIGE VERS bookRide
  Future<bool> createReservation({
    required int rideId,
    required int seats,
    String? pickupPoint,
    String? dropoffPoint,
  }) async {
    print('📞 createReservation appelée, redirection vers bookRide');
    return await bookRide(rideId, seats);
  }

  // NOUVELLE MÉTHODE: Tester la connexion
  Future<void> testReservationEndpoint() async {
    print('🧪 TEST ENDPOINT RÉSERVATION');
    print('🌐 Base URL: ${_getBaseUrl()}');
    
    try {
      final token = await _apiService.getToken();
      print('🔑 Token disponible: ${token != null}');
      if (token != null) {
        print('🔑 Token (début): ${token.substring(0, 20)}...');
      }
      
      final response = await _apiService.get(
        'reservations/my-reservations',
        isProtected: true,
      );
      
      print('📡 Réponse test GET: $response');
    } catch (e) {
      print('❌ Erreur test endpoint: $e');
    }
  }

  // Méthode alternative avec contrôle total
  Future<Map<String, dynamic>?> createReservationRaw({
    required int rideId,
    required int seats,
    String? pickupPoint,
    String? dropoffPoint,
  }) async {
    try {
      final token = await _apiService.getToken();
      if (token == null) throw Exception('Token non disponible');
      
      final baseUrl = _getBaseUrl();
      final url = Uri.parse('$baseUrl/reservations');
      
      // Formats possibles
      final formats = [
        // Format principal (camelCase)
        {
          'rideId': rideId,
          'seatsBooked': seats,
          if (pickupPoint != null) 'pickupPoint': pickupPoint,
          if (dropoffPoint != null) 'dropoffPoint': dropoffPoint,
        },
      ];
      
      for (var i = 0; i < formats.length; i++) {
        try {
          print('🔄 Test format ${i + 1}: ${formats[i]}');
          
          final response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(formats[i]),
          );
          
          final data = jsonDecode(response.body);
          print('📡 Format ${i + 1} - Status: ${response.statusCode}');
          print('📡 Format ${i + 1} - Réponse: $data');
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            if (data is Map && data['success'] == true) {
              print('✅ SUCCÈS avec format ${i + 1}');
              return Map<String, dynamic>.from(data);
            }
          }
        } catch (e) {
          print('❌ Format ${i + 1} échoué: $e');
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Erreur createReservationRaw: $e');
      return null;
    }
  }

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
        final reservation = Reservation.fromJson(json);
        
        RideModel? ride;
        if (json['ride'] != null && json['ride'] is Map) {
          try {
            ride = RideModel.fromJson(json['ride'] as Map<String, dynamic>);
          } catch (e) {
            print('❌ Erreur parsing ride depuis JSON: $e');
          }
        }
        
        if (ride == null && reservation.rideId > 0) {
          try {
            ride = await _loadRideById(reservation.rideId);
          } catch (e) {
            print('❌ Erreur chargement trajet pour rideId ${reservation.rideId}: $e');
          }
        }
        
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
          final reservation = Reservation.fromJson(reservationJson);
          
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

  // Trouver une réservation par ID dans la liste locale
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
    int completedTrips = 0;
    
    final completedReservations = _allReservations.where((r) => r.status == 'completed');
    completedTrips = completedReservations.length;
    
    for (var reservation in completedReservations) {
      final distance = 50.0;
      totalDistance += distance;
      totalPassengers += reservation.seatsReserved;
      
      final co2PerKm = 150.0;
      final co2Saved = distance * co2PerKm * (reservation.seatsReserved - 1);
      totalCO2Saved += co2Saved / 1000;
      
      final fuelCostPerKm = (12.0 * 6.0) / 100;
      final fuelCost = distance * fuelCostPerKm;
      final revenue = reservation.totalPrice;
      final savings = revenue - fuelCost;
      if (savings > 0) totalMoneySaved += savings;
    }
    
    if (completedTrips == 0) {
      return {
        'total_trips': 0,
        'total_distance': 0,
        'co2_saved_kg': 0,
        'money_saved_dh': 0,
        'total_passengers': 0,
        'trees_equivalent': 0,
      };
    }
    
    return {
      'total_trips': completedTrips.toDouble(),
      'total_distance': totalDistance,
      'co2_saved_kg': totalCO2Saved,
      'money_saved_dh': totalMoneySaved,
      'total_passengers': totalPassengers.toDouble(),
      'trees_equivalent': totalCO2Saved / 21,
    };
  }

  // Nettoyer le provider
  void disposeProvider() {
    _reservations.clear();
    _allReservations.clear();
    _error = '';
    _filterStatus = 'all';
    notifyListeners();
  }

  // Vérifier si l'utilisateur a déjà réservé un trajet spécifique
  bool hasBookedRide(int rideId) {
    return _allReservations.any((r) => 
      r.rideId == rideId && 
      ['pending', 'confirmed'].contains(r.status.toLowerCase())
    );
  }

  // Obtenir une réservation pour un trajet spécifique
  Reservation? getReservationForRide(int rideId) {
    try {
      return _allReservations.firstWhere((r) => 
        r.rideId == rideId && 
        ['pending', 'confirmed'].contains(r.status.toLowerCase())
      );
    } catch (e) {
      return null;
    }
  }
}