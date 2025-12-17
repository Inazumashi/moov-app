// lib/core/providers/eco_stats_provider.dart
import 'package:flutter/material.dart';
import 'package:moovapp/core/service/eco_calculator_service.dart';
import 'package:moovapp/core/service/stats_service.dart';
import 'package:moovapp/core/api/api_service.dart';

class EcoStatsProvider with ChangeNotifier {
  // Pas besoin d'instance pour EcoCalculatorService car ses méthodes sont statiques
  final StatsService _statsService;
  
  // Données écologiques
  Map<String, double> _ecoStats = {};
  List<Map<String, dynamic>> _completedTrips = [];
  List<Map<String, dynamic>> _monthlyEcoData = [];
  
  // États
  bool _isLoading = false;
  String _error = '';
  DateTimeRange? _selectedDateRange;

  EcoStatsProvider() : _statsService = StatsService(ApiService());

  // Getters
  Map<String, double> get ecoStats => _ecoStats;
  List<Map<String, dynamic>> get completedTrips => _completedTrips;
  List<Map<String, dynamic>> get monthlyEcoData => _monthlyEcoData;
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTimeRange? get selectedDateRange => _selectedDateRange;

  // Charger les trajets complétés
  Future<void> loadCompletedTrips({DateTimeRange? dateRange}) async {
    _isLoading = true;
    _error = '';
    _selectedDateRange = dateRange;
    notifyListeners();

    try {
      // Simuler l'appel API - à remplacer par votre vrai endpoint
      // final response = await _statsService.getCompletedTrips(dateRange);
      // _completedTrips = List<Map<String, dynamic>>.from(response['trips'] ?? []);
      
      // Données de test pour la démo
      await Future.delayed(Duration(seconds: 1));
      
      _completedTrips = [
        {
          'id': 1,
          'date': '2024-03-15',
          'from': 'Casablanca',
          'to': 'Rabat',
          'distance': 86.0,
          'passengers': 2,
          'price_per_seat': 30.0,
          'is_driver': true,
          'vehicle_type': 'gasoline',
        },
        {
          'id': 2,
          'date': '2024-03-10',
          'from': 'Marrakech',
          'to': 'Agadir',
          'distance': 256.0,
          'passengers': 3,
          'price_per_seat': 50.0,
          'is_driver': true,
          'vehicle_type': 'diesel',
        },
        {
          'id': 3,
          'date': '2024-03-05',
          'from': 'Fès',
          'to': 'Meknès',
          'distance': 60.0,
          'passengers': 0,
          'price_per_seat': 15.0,
          'is_driver': false,
          'vehicle_type': 'gasoline',
        },
        {
          'id': 4,
          'date': '2024-02-28',
          'from': 'Tanger',
          'to': 'Tétouan',
          'distance': 40.0,
          'passengers': 1,
          'price_per_seat': 20.0,
          'is_driver': true,
          'vehicle_type': 'gasoline',
        },
        {
          'id': 5,
          'date': '2024-02-20',
          'from': 'Casablanca',
          'to': 'El Jadida',
          'distance': 106.0,
          'passengers': 2,
          'price_per_seat': 25.0,
          'is_driver': false,
          'vehicle_type': 'gasoline',
        },
      ];

      // Filtrer par date si un range est sélectionné
      if (dateRange != null) {
        _completedTrips = _completedTrips.where((trip) {
          final tripDate = DateTime.parse(trip['date']);
          return tripDate.isAfter(dateRange.start) && 
                 tripDate.isBefore(dateRange.end);
        }).toList();
      }

      // CORRECTION : Utiliser la classe directement car la méthode est statique
      _ecoStats = EcoCalculatorService.calculateUserEcoStats(
        completedTrips: _completedTrips,
      );

      // Générer les données mensuelles
      _generateMonthlyData();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des trajets: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Générer des données mensuelles simulées
  void _generateMonthlyData() {
    _monthlyEcoData = [];
    
    // Générer les 6 derniers mois
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final monthName = _getMonthName(month.month);
      
      // Simuler des données basées sur les trajets réels
      final monthlyTrips = _completedTrips.where((trip) {
        final tripDate = DateTime.parse(trip['date']);
        return tripDate.year == month.year && tripDate.month == month.month;
      }).toList();
      
      // CORRECTION : Utiliser la classe directement
      final monthlyStats = EcoCalculatorService.calculateUserEcoStats(
        completedTrips: monthlyTrips,
      );
      
      _monthlyEcoData.add({
        'month': monthName,
        'co2_saved': monthlyStats['co2_saved_kg'] ?? 0,
        'money_saved': monthlyStats['money_saved_dh'] ?? 0,
        'distance': monthlyStats['total_distance'] ?? 0,
        'trips_count': monthlyTrips.length,
      });
    }
  }

  String _getMonthName(int month) {
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return months[month - 1];
  }

  // Changer la période
  Future<void> setDateRange(DateTimeRange? range) async {
    await loadCompletedTrips(dateRange: range);
  }

  // Réinitialiser la période
  Future<void> resetDateRange() async {
    await loadCompletedTrips(dateRange: null);
  }

  // Calculer l'équivalent en arbres
  double get treesEquivalent {
    final co2Saved = _ecoStats['co2_saved_kg'] ?? 0;
    return (co2Saved / 21).roundToDouble(); // 1 arbre absorbe ~21kg CO2/an
  }

  // Calculer l'équivalent en bouteilles plastiques
  int get plasticBottlesEquivalent {
    final co2Saved = _ecoStats['co2_saved_kg'] ?? 0;
    return (co2Saved * 1000 / 42).round(); // 1 bouteille = 42g CO2
  }

  // Calculer l'équivalent en smartphones chargés
  int get smartphoneChargesEquivalent {
    final co2Saved = _ecoStats['co2_saved_kg'] ?? 0;
    return (co2Saved * 1000 / 0.006).round(); // 1 charge = 6g CO2
  }
}