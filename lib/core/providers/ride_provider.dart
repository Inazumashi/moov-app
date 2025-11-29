// File: lib/core/providers/ride_provider.dart
import 'package:flutter/foundation.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/models/university_model.dart';
import 'package:moovapp/core/service/ride_service.dart';
import 'package:moovapp/core/api/api_service.dart';

class RideProvider with ChangeNotifier {
  late final RideService _rideService;
  
  List<RideModel> _searchResults = [];
  List<RideModel> _myPublishedRides = [];
  List<RideModel> _favoriteRides = [];
  List<UniversityModel> _universities = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';

  RideProvider() {
    final apiService = ApiService();
    _rideService = RideService(apiService);
  }

  // Getters
  List<RideModel> get searchResults => _searchResults;
  List<RideModel> get myPublishedRides => _myPublishedRides;
  List<RideModel> get favoriteRides => _favoriteRides;
  List<UniversityModel> get universities => _universities;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;

  // Recherche de trajets
  Future<void> searchRides({
    required String from,
    required String to,
    required DateTime date,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _searchResults = await _rideService.searchRides(
        from: from,
        to: to,
        date: date,
      );
    } catch (e) {
      _error = 'Erreur lors de la recherche: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Publier un trajet
  Future<bool> publishRide(RideModel ride) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _rideService.publishRide(ride);
      // Recharger les trajets publiés après publication
      await loadMyPublishedRides();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la publication: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Charger les trajets publiés par l'utilisateur
  Future<void> loadMyPublishedRides() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _myPublishedRides = await _rideService.getMyPublishedRides();
    } catch (e) {
      _error = 'Erreur lors du chargement: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Supprimer un trajet
  Future<bool> deleteRide(String rideId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _rideService.deleteRide(rideId);
      // Recharger la liste après suppression
      await loadMyPublishedRides();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Mettre à jour un trajet
  Future<bool> updateRide(RideModel ride) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _rideService.updateRide(ride);
      await loadMyPublishedRides();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Charger les favoris
  Future<void> loadFavoriteRides() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _favoriteRides = await _rideService.getFavoriteRides();
    } catch (e) {
      _error = 'Erreur lors du chargement des favoris: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les universités
  Future<void> loadUniversities() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _universities = await _rideService.getUniversities();
    } catch (e) {
      _error = 'Erreur lors du chargement des universités: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ajouter aux favoris
  Future<void> addToFavorites(String rideId) async {
    try {
      await _rideService.addToFavorites(rideId);
      await loadFavoriteRides(); // Recharger la liste
    } catch (e) {
      _error = 'Erreur lors de l\'ajout aux favoris: $e';
      notifyListeners();
    }
  }

  // Retirer des favoris
  Future<void> removeFromFavorites(String rideId) async {
    try {
      await _rideService.removeFromFavorites(rideId);
      await loadFavoriteRides(); // Recharger la liste
    } catch (e) {
      _error = 'Erreur lors de la suppression des favoris: $e';
      notifyListeners();
    }
  }

  // Mettre à jour la recherche
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Effacer les erreurs
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Vérifier si un trajet est dans les favoris
  bool isFavorite(String rideId) {
    return _favoriteRides.any((ride) => ride.rideId == rideId);
  }

  // Basculer les favoris
  Future<void> toggleFavorite(String rideId) async {
    if (isFavorite(rideId)) {
      await removeFromFavorites(rideId);
    } else {
      await addToFavorites(rideId);
    }
  }

  // Obtenir un trajet par ID (depuis les résultats de recherche)
  RideModel? getRideById(String rideId) {
    return _searchResults.firstWhere(
      (ride) => ride.rideId == rideId,
      orElse: () => _myPublishedRides.firstWhere(
        (ride) => ride.rideId == rideId,
        orElse: () => _favoriteRides.firstWhere(
          (ride) => ride.rideId == rideId,
          orElse: () => RideModel(
            rideId: '',
            driverId: '',
            driverName: '',
            driverRating: 0,
            startPoint: '',
            endPoint: '',
            departureTime: DateTime.now(),
            availableSeats: 0,
            pricePerSeat: 0,
          ),
        ),
      ),
    );
  }
}