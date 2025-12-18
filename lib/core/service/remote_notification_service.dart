import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/notification_model.dart'; // My new model

class RemoteNotificationService {
  final ApiService _apiService;

  RemoteNotificationService(this._apiService);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiService.get('notifications');
      if (response['success'] == true) {
        final List<dynamic> list = response['data'] ?? [];
        return list.map((e) => NotificationModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.put('notifications/$notificationId/read', {});
      return response['success'] == true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
  
  Future<bool> markAllAsRead() async {
     try {
      final response = await _apiService.put('notifications/read-all', {});
      return response['success'] == true;
    } catch (e) {
      print('Error marking all as read: $e');
      return false;
    }
  }
}
