// File: lib/core/providers/station_provider.dart
import 'package:flutter/material.dart';
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
    _initialize();
  }

  // Initialisation différée pour éviter setState pendant build
  void _initialize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    await loadPopularStations();
    await loadPopularRoutes();
  }

  // Getters
  List<StationModel> get searchResults => List.unmodifiable(_searchResults);
  List<StationModel> get favoriteStations =>
      List.unmodifiable(_favoriteStations);
  List<StationModel> get recentStations => List.unmodifiable(_recentStations);
  List<StationModel> get popularStations => List.unmodifiable(_popularStations);
  List<StationModel> get nearbyStations => List.unmodifiable(_nearbyStations);
  List<Map<String, dynamic>> get popularRoutes =>
      List.unmodifiable(_popularRoutes);
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;

  // Méthode pour notifier les changements de façon sécurisée
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // Auto-complétion
  Future<void> searchStations(String query, {int limit = 10}) async {
    if (query.length < 2) {
      _searchResults = [];
      // ✅ SOLUTION: Utiliser Future.microtask pour éviter setState pendant build
      Future.microtask(() => notifyListeners());
      return;
    }

    _isLoading = true;
    _error = '';
    _searchQuery = query;

    // ✅ SOLUTION: Délai pour éviter setState pendant build
    Future.microtask(() => notifyListeners());

    try {
      final results = await _stationService.autocomplete(query, limit: limit);

      // ✅ CORRECTION: Supprimer les doublons par ID
      final Map<int, StationModel> uniqueStations = {};
      for (final station in results) {
        if (!uniqueStations.containsKey(station.id)) {
          uniqueStations[station.id] = station;
        }
      }

      _searchResults = uniqueStations.values.toList();
    } catch (e) {
      _error = 'Erreur lors de la recherche: $e';
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Stations proches
  Future<void> loadNearbyStations(double lat, double lng,
      {double radius = 10, int limit = 20}) async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      _nearbyStations =
          await _stationService.nearby(lat, lng, radius: radius, limit: limit);
    } catch (e) {
      _error = 'Erreur stations proches: $e';
      _nearbyStations = [];
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Stations favorites
  Future<void> loadFavoriteStations({String? type}) async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      _favoriteStations = await _stationService.getMyFavorites(type: type);
    } catch (e) {
      _error = 'Erreur chargement favoris: $e';
      _favoriteStations = [];
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Stations récentes
  Future<void> loadRecentStations({int limit = 10}) async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      _recentStations = await _stationService.getRecent(limit: limit);
    } catch (e) {
      _error = 'Erreur stations récentes: $e';
      _recentStations = [];
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Stations populaires
  Future<void> loadPopularStations({int limit = 10}) async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      final results = await _stationService.popular(limit: limit);

      // ✅ CORRECTION: Supprimer les doublons par ID
      final Map<int, StationModel> uniqueStations = {};
      for (final station in results) {
        if (!uniqueStations.containsKey(station.id)) {
          uniqueStations[station.id] = station;
        }
      }

      _popularStations = uniqueStations.values.toList();
    } catch (e) {
      _error = 'Erreur stations populaires: $e';
      _popularStations = [];
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Itinéraires populaires
  Future<void> loadPopularRoutes({int limit = 10}) async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      _popularRoutes = await _stationService.getPopularRoutes(limit: limit);
    } catch (e) {
      _error = 'Erreur itinéraires populaires: $e';
      _popularRoutes = [];
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Ajouter aux favoris
  Future<bool> addToFavorites(StationModel station,
      {String type = 'both'}) async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      final success =
          await _stationService.addToFavorites(station.id, type: type);
      if (success) {
        await loadFavoriteStations();
      }
      return success;
    } catch (e) {
      _error = 'Erreur ajout favoris: $e';
      return false;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Retirer des favoris
  Future<bool> removeFromFavorites(StationModel station, {String? type}) async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      final success =
          await _stationService.removeFromFavorites(station.id, type: type);
      if (success) {
        await loadFavoriteStations();
      }
      return success;
    } catch (e) {
      _error = 'Erreur suppression favoris: $e';
      return false;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Basculer favori
  Future<void> toggleFavorite(StationModel station,
      {String type = 'both'}) async {
    final isCurrentlyFavorite =
        _favoriteStations.any((s) => s.id == station.id);

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
    _safeNotifyListeners();

    try {
      final result = await _stationService.quickSearch(
        departure: departure,
        arrival: arrival,
        date: date,
      );
      return result;
    } catch (e) {
      _error = 'Erreur recherche rapide: $e';
      return {
        'rides': [],
        'suggested_departures': [],
        'suggested_arrivals': []
      };
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Effacer les erreurs
  void clearError() {
    _error = '';
    _safeNotifyListeners();
  }

  // Effacer les résultats de recherche
  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    _safeNotifyListeners();
  }

  // Trouver une station par ID
  StationModel? findStationById(int id) {
    // Chercher dans toutes les listes
    final allStations = [
      ..._searchResults,
      ..._favoriteStations,
      ..._recentStations,
      ..._popularStations,
      ..._nearbyStations,
    ];

    return allStations.firstWhere(
      (station) => station.id == id,
      orElse: () => StationModel(
        id: 0,
        name: 'Station inconnue',
        type: 'landmark',
        city: 'Inconnu',
        label: 'Station inconnue',
        address: '',
        latitude: 0,
        longitude: 0,
      ),
    );
  }

  // Recherche améliorée pour l'autocomplétion
  Future<List<StationModel>> enhancedSearch(String query,
      {int limit = 15}) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      // Priorité 1: Recherche exacte par nom
      final exactMatches = _searchResults
          .where((station) =>
              station.name.toLowerCase().contains(query.toLowerCase()) ||
              station.city.toLowerCase().contains(query.toLowerCase()))
          .toList();

      if (exactMatches.isNotEmpty) {
        return exactMatches.take(limit).toList();
      }

      // Priorité 2: Recherche par mots-clés communs
      final keywordMap = {
        'gare': ['gare', 'station', 'train'],
        'aéroport': ['aéroport', 'airport'],
        'université': ['université', 'univ', 'école', 'faculté'],
        'campus': ['campus'],
        'centre': ['centre', 'downtown', 'ville'],
      };

      for (final entry in keywordMap.entries) {
        if (entry.value
            .any((keyword) => query.toLowerCase().contains(keyword))) {
          return _searchResults
              .where((station) =>
                  station.type.contains(entry.key) ||
                  station.name.toLowerCase().contains(entry.key))
              .take(limit)
              .toList();
        }
      }

      return _searchResults.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  // Méthode pour charger toutes les stations d'une ville
  Future<List<StationModel>> getStationsByCity(String city) async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      final stations = await _stationService.getStationsByCity(city);
      return stations;
    } catch (e) {
      _error = 'Erreur chargement stations par ville: $e';
      return [];
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Méthode pour charger toutes les stations d'une université
  Future<List<StationModel>> getStationsByUniversity(int universityId) async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      final stations =
          await _stationService.getStationsByUniversity(universityId);
      return stations;
    } catch (e) {
      _error = 'Erreur chargement stations université: $e';
      return [];
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }
}
