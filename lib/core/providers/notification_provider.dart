import 'package:flutter/material.dart';
import 'package:moovapp/core/models/notification_model.dart';
import 'package:moovapp/core/service/remote_notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final RemoteNotificationService _service;
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  NotificationProvider(this._service);

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    _notifications = await _service.getNotifications();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      if (_notifications[index].isRead) return; // Already read
      
      // Optimistic update
      // We can't easily modify a final field, so we need to copy or replace
     // Assuming NotificationModel fields are final, we can't set isRead.
     // But wait, in NotificationModel I made fields final? Yes.
     // Ideally I'd use copyWith but checking my model I didn't add copyWith.
     // I'll just reload or hack it if I didn't implement copyWith.
     // Actually I should add copyWith or make it mutable. 
     // For now I'll just trigger the API call and reload or assume success.
     
     await _service.markAsRead(id);
     await loadNotifications(); // Refresh to be sure
    }
  }

  Future<void> markAllAsRead() async {
    await _service.markAllAsRead();
    await loadNotifications();
  }
  // --- PRÉFÉRENCES (Local) ---
  bool _newRidesEnabled = true;
  bool _newMessagesEnabled = true;
  bool _bookingUpdatesEnabled = true;
  bool _promotionsEnabled = false;

  bool get newRidesEnabled => _newRidesEnabled;
  bool get newMessagesEnabled => _newMessagesEnabled;
  bool get bookingUpdatesEnabled => _bookingUpdatesEnabled;
  bool get promotionsEnabled => _promotionsEnabled;

  // Charger les préférences (simulé ou via SharedPreferences si besoin)
  Future<void> loadNotificationPreferences() async {
    // TODO: Implémenter SharedPreferences si persistante nécessaire
    notifyListeners();
  }

  void setNewRidesEnabled(bool value) {
    _newRidesEnabled = value;
    notifyListeners();
  }

  void setNewMessagesEnabled(bool value) {
    _newMessagesEnabled = value;
    notifyListeners();
  }

  void setBookingUpdatesEnabled(bool value) {
    _bookingUpdatesEnabled = value;
    notifyListeners();
  }

  void setPromotionsEnabled(bool value) {
    _promotionsEnabled = value;
    notifyListeners();
  }
}