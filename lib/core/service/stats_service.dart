import 'package:moovapp/core/api/api_service.dart';

class StatsService {
  final ApiService _apiService;

  StatsService(this._apiService);

  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _apiService.get('stats/dashboard');
    return response['stats'] ?? {};
  }

  Future<Map<String, dynamic>> getMonthlyStats({int? year}) async {
    final yearParam = year ?? DateTime.now().year;
    return await _apiService.get('stats/monthly?year=$yearParam');
  }

  Future<Map<String, dynamic>> getTopRoutes() async {
    return await _apiService.get('stats/top-routes');
  }

  Future<Map<String, dynamic>> getRecentActivity({int limit = 10}) async {
    return await _apiService.get('stats/recent-activity?limit=$limit');
  }
}
