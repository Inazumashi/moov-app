import 'package:flutter/material.dart';
import 'package:moovapp/core/service/stats_service.dart';
import 'package:moovapp/core/api/api_service.dart';

class StatsProvider with ChangeNotifier {
  final StatsService _statsService;

  Map<String, dynamic>? _dashboardStats;
  List<Map<String, dynamic>> _monthlyData = [];
  List<Map<String, dynamic>> _topRoutes = [];
  List<Map<String, dynamic>> _recentActivity = [];
  bool _isLoading = false;
  String _error = '';

  StatsProvider() : _statsService = StatsService(ApiService());

  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  List<Map<String, dynamic>> get monthlyData => _monthlyData;
  List<Map<String, dynamic>> get topRoutes => _topRoutes;
  List<Map<String, dynamic>> get recentActivity => _recentActivity;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Charger le dashboard
  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _dashboardStats = await _statsService.getDashboardStats();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les données mensuelles
  Future<void> loadMonthlyData({int? year}) async {
    try {
      final data = await _statsService.getMonthlyStats(year: year);
      _monthlyData = List<Map<String, dynamic>>.from(data['data'] ?? []);
      notifyListeners();
    } catch (e) {
      print('Erreur chargement données mensuelles: $e');
    }
  }

  // Charger les top trajets
  Future<void> loadTopRoutes() async {
    try {
      final data = await _statsService.getTopRoutes();
      _topRoutes = List<Map<String, dynamic>>.from(data['top_routes'] ?? []);
      notifyListeners();
    } catch (e) {
      print('Erreur chargement top trajets: $e');
    }
  }

  // Charger l'activité récente
  Future<void> loadRecentActivity({int limit = 10}) async {
    try {
      final data = await _statsService.getRecentActivity(limit: limit);
      _recentActivity = List<Map<String, dynamic>>.from(data['activities'] ?? []);
      notifyListeners();
    } catch (e) {
      print('Erreur chargement activité: $e');
    }
  }

  // Recharger toutes les stats
  Future<void> refreshAll() async {
    await Future.wait([
      loadDashboard(),
      loadMonthlyData(),
      loadTopRoutes(),
      loadRecentActivity(),
    ]);
  }
}
