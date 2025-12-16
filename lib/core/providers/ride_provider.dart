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
  List<RideModel> _suggestions = [];
  List<UniversityModel> _universities = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';
  Map<String, dynamic> _appliedFilters = {};
  bool _disposed = false;

  RideProvider() {
    final apiService = ApiService();
    _rideService = RideService(apiService);
  }

  // Getters
  List<RideModel> get searchResults => _searchResults;
  List<RideModel> get myPublishedRides => _myPublishedRides;
  List<RideModel> get favoriteRides => _favoriteRides;
  List<RideModel> get suggestions => _suggestions;
  List<UniversityModel> get universities => _universities;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;
  Map<String, dynamic> get appliedFilters => _appliedFilters;

  // Méthode sécurisée pour notifier les listeners
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // 🚀 LOGIQUE MODIFIÉE : Recherche avancée avec filtres
  Future<void> searchRides({
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
    _isLoading = true;
    _error = '';
    
    // Sauvegarder les filtres appliqués
    _appliedFilters = {
      'departureId': departureId,
      'arrivalId': arrivalId,
      'date': date,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minRating': minRating,
      'verifiedOnly': verifiedOnly,
      'departureTimeStart': departureTimeStart,
      'departureTimeEnd': departureTimeEnd,
      'page': page,
      'limit': limit,
    };
    
    _safeNotifyListeners();

    try {
      _searchResults = await _rideService.searchRides(
        departureId: departureId,
        arrivalId: arrivalId,
        date: date,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
        verifiedOnly: verifiedOnly,
        departureTimeStart: departureTimeStart,
        departureTimeEnd: departureTimeEnd,
        page: page,
        limit: limit,
      );
      if (_searchResults.isEmpty) {
        _error = 'Aucun trajet ne correspond à vos critères.';
      }
    } catch (e) {
      _error = 'Erreur lors de la recherche: $e';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // 📌 NOUVEAU : Charger les suggestions
  Future<void> loadSuggestions() async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      _suggestions = await _rideService.getSuggestions();
    } catch (e) {
      _error = 'Erreur chargement suggestions: $e';
      _suggestions = [];
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Publier un trajet
  Future<bool> publishRide(RideModel ride) async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      await _rideService.publishRide(ride);
      await loadMyPublishedRides();
      _isLoading = false;
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la publication: $e';
      _isLoading = false;
      _safeNotifyListeners();
      return false;
    }
  }

  // Charger les trajets publiés par l'utilisateur
  Future<void> loadMyPublishedRides() async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      _myPublishedRides = await _rideService.getMyPublishedRides();
    } catch (e) {
      _error = 'Erreur lors du chargement: $e';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Supprimer un trajet
  Future<bool> deleteRide(String rideId) async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      await _rideService.deleteRide(rideId);
      await loadMyPublishedRides();
      _isLoading = false;
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression: $e';
      _isLoading = false;
      _safeNotifyListeners();
      return false;
    }
  }

  // ✅ CORRECTION : Mettre à jour un trajet avec toApiJson()
  Future<bool> updateRide(RideModel ride) async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      // ✅ CORRECTION : Utilisez toApiJson() au lieu de toJson()
      await _rideService.updateRide(ride);
      await loadMyPublishedRides();
      _isLoading = false;
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour: $e';
      _isLoading = false;
      _safeNotifyListeners();
      return false;
    }
  }

  // Charger les favoris
  Future<void> loadFavoriteRides() async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      _favoriteRides = await _rideService.getFavoriteRides();
    } catch (e) {
      _error = 'Erreur lors du chargement des favoris: $e';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Charger les universités
  Future<void> loadUniversities() async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      _universities = await _rideService.getUniversities();
    } catch (e) {
      _error = 'Erreur lors du chargement des universités: $e';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Ajouter aux favoris
  Future<bool> addToFavorites(String rideId) async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      await _rideService.addToFavorites(rideId);
      await loadFavoriteRides();
      _isLoading = false;
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout aux favoris: $e';
      _isLoading = false;
      _safeNotifyListeners();
      return false;
    }
  }

  // Retirer des favoris
  Future<bool> removeFromFavorites(String rideId) async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      await _rideService.removeFromFavorites(rideId);
      await loadFavoriteRides();
      _isLoading = false;
      _safeNotifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression des favoris: $e';
      _isLoading = false;
      _safeNotifyListeners();
      return false;
    }
  }

  // Mettre à jour la recherche
  void setSearchQuery(String query) {
    _searchQuery = query;
    _safeNotifyListeners();
  }

  // Effacer les erreurs
  void clearError() {
    _error = '';
    _safeNotifyListeners();
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

  // Obtenir un trajet par ID
  RideModel? getRideById(String rideId) {
    // Chercher dans les résultats de recherche
    for (var ride in _searchResults) {
      if (ride.rideId == rideId) return ride;
    }

    // Chercher dans mes trajets publiés
    for (var ride in _myPublishedRides) {
      if (ride.rideId == rideId) return ride;
    }

    // Chercher dans les favoris
    for (var ride in _favoriteRides) {
      if (ride.rideId == rideId) return ride;
    }

    return null;
  }

  // Méthode utilitaire pour recharger toutes les données
  Future<void> refreshAllData() async {
    await Future.wait([
      loadMyPublishedRides(),
      loadFavoriteRides(),
      loadUniversities(),
    ]);
  }

  // ✅ MÉTHODE AJOUTÉE : Pour le bouton "Effacer la recherche"
  void clearSearchResults() {
    _searchResults = [];
    _safeNotifyListeners();
  }
}