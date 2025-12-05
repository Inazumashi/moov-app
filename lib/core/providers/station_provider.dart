// File: lib/core/providers/station_provider.dart
import 'package:flutter/foundation.dart';
import 'package:moovapp/core/models/station_model.dart';
import 'package:moovapp/core/service/station_service.dart';
import 'package:moovapp/core/api/api_service.dart';

class StationProvider with ChangeNotifier {
  late final StationService _stationService;
  
  List<StationModel> _searchResults = [];
  List<StationModel> _favoriteStations = [];
  List<StationModel> _recentStations = [];
  List<StationModel> _popularStations = [];
  List<StationModel> _nearbyStations = [];
  List<Map<String, dynamic>> _popularRoutes = [];
  
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';

  StationProvider() {
    final apiService = ApiService();
    _stationService = StationService(apiService);
  }

  // Getters
  List<StationModel> get searchResults => _searchResults;
  List<StationModel> get favoriteStations => _favoriteStations;
  List<StationModel> get recentStations => _recentStations;
  List<StationModel> get popularStations => _popularStations;
  List<StationModel> get nearbyStations => _nearbyStations;
  List<Map<String, dynamic>> get popularRoutes => _popularRoutes;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;

  // Auto-complétion
  Future<void> searchStations(String query, {int limit = 10}) async {
    if (query.length < 2) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    _searchQuery = query;
    notifyListeners();

    try {
      _searchResults = await _stationService.autocomplete(query, limit: limit);
    } catch (e) {
      _error = 'Erreur lors de la recherche: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Stations proches
  Future<void> loadNearbyStations(double lat, double lng, {double radius = 10, int limit = 20}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _nearbyStations = await _stationService.nearby(lat, lng, radius: radius, limit: limit);
    } catch (e) {
      _error = 'Erreur stations proches: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Stations favorites
  Future<void> loadFavoriteStations({String? type}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _favoriteStations = await _stationService.getMyFavorites(type: type);
    } catch (e) {
      _error = 'Erreur chargement favoris: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Stations récentes
  Future<void> loadRecentStations({int limit = 10}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _recentStations = await _stationService.getRecent(limit: limit);
    } catch (e) {
      _error = 'Erreur stations récentes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Stations populaires
  Future<void> loadPopularStations({int limit = 10}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _popularStations = await _stationService.popular(limit: limit);
    } catch (e) {
      _error = 'Erreur stations populaires: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Itinéraires populaires
  Future<void> loadPopularRoutes({int limit = 10}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _popularRoutes = await _stationService.getPopularRoutes(limit: limit);
    } catch (e) {
      _error = 'Erreur itinéraires populaires: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ajouter aux favoris
  Future<bool> addToFavorites(StationModel station, {String type = 'both'}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final success = await _stationService.addToFavorites(station.id, type: type);
      if (success) {
        await loadFavoriteStations();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Erreur ajout favoris: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Retirer des favoris
  Future<bool> removeFromFavorites(StationModel station, {String? type}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final success = await _stationService.removeFromFavorites(station.id, type: type);
      if (success) {
        await loadFavoriteStations();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Erreur suppression favoris: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Basculer favori
  Future<void> toggleFavorite(StationModel station, {String type = 'both'}) async {
    final isCurrentlyFavorite = _favoriteStations.any((s) => s.id == station.id);
    
    if (isCurrentlyFavorite) {
      await removeFromFavorites(station, type: type);
    } else {
      await addToFavorites(station, type: type);
    }
  }

  // Vérifier si une station est en favoris
  bool isFavorite(int stationId) {
    return _favoriteStations.any((station) => station.id == stationId);
  }

  // Recherche rapide de trajets
  Future<Map<String, dynamic>> quickSearchRides({
    required String departure,
    required String arrival,
    String? date,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _stationService.quickSearch(
        departure: departure,
        arrival: arrival,
        date: date,
      );
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = 'Erreur recherche rapide: $e';
      _isLoading = false;
      notifyListeners();
      return {'rides': [], 'suggested_departures': [], 'suggested_arrivals': []};
    }
  }

  // Effacer les erreurs
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Effacer les résultats de recherche
  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    notifyListeners();
  }

  // Trouver une station par ID
  StationModel? findStationById(int id) {
    return _searchResults
        .firstWhere((station) => station.id == id, orElse: () => _favoriteStations
        .firstWhere((station) => station.id == id, orElse: () => _recentStations
        .firstWhere((station) => station.id == id, orElse: () => _popularStations
        .firstWhere((station) => station.id == id, orElse: () => _nearbyStations
        .firstWhere((station) => station.id == id, orElse: () => StationModel(
          id: 0,
          name: 'Inconnue',
          type: 'landmark',
          city: '',
          label: 'Station inconnue',
        ))))));
  }
}