import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moovapp/core/models/notification.dart';
import 'package:moovapp/core/service/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<AppNotification> _notifications = [];
  Map<String, bool> _preferences = {};
  bool _isLoading = false;
  int _unreadCount = 0;

  List<AppNotification> get notifications => _notifications;
  Map<String, bool> get preferences => _preferences;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  bool get newRidesEnabled => _preferences['newRides'] ?? true;
  bool get newMessagesEnabled => _preferences['newMessages'] ?? true;
  bool get bookingUpdatesEnabled => _preferences['bookingUpdates'] ?? true;
  bool get promotionsEnabled => _preferences['promotions'] ?? false;

  Future<void> setNewRidesEnabled(bool value) async {
    await updatePreference('newRides', value);
  }

  Future<void> setNewMessagesEnabled(bool value) async {
    await updatePreference('newMessages', value);
  }

  Future<void> setBookingUpdatesEnabled(bool value) async {
    await updatePreference('bookingUpdates', value);
  }

  Future<void> setPromotionsEnabled(bool value) async {
    await updatePreference('promotions', value);
  }

  Future<void> loadNotificationPreferences() async {
    _preferences = await _notificationService.getNotificationPreferences();
    notifyListeners();
  }

  NotificationProvider() {
    _notificationService.onNotificationReceived = _onNotificationReceived;
    loadData();
  }

  Future<void> loadNotifications() async {
    await loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _notificationService.getStoredNotifications();
      _preferences = await _notificationService.getNotificationPreferences();
      _unreadCount = await _notificationService.getUnreadCount();
    } catch (e) {
      print('Error loading notification data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _onNotificationReceived(AppNotification notification) {
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }

  Future<void> updatePreference(String key, bool value) async {
    try {
      await _notificationService.updateNotificationPreference(key, value);
      _preferences[key] = value;
      notifyListeners();
    } catch (e) {
      print('Error updating preference: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);
      final notification = _notifications.firstWhere((n) => n.id == notificationId);
      notification.isRead = true;
      _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      notifyListeners();
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      for (var notification in _notifications.where((n) => !n.isRead)) {
        await _notificationService.markNotificationAsRead(notification.id);
        notification.isRead = true;
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('stored_notifications');
      _notifications.clear();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  // Méthode pour créer des notifications de démonstration
  Future<void> createDemoNotifications() async {
    final demoNotifications = [
      AppNotification(
        id: 'demo_1',
        title: 'Nouveau trajet disponible',
        body: 'Un trajet Ben Guerir → UM6P Campus a été publié pour demain.',
        type: NotificationType.newRide,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        data: {'rideId': '123'},
      ),
      AppNotification(
        id: 'demo_2',
        title: 'Message reçu',
        body: 'Ahmed vous a envoyé un message concernant votre réservation.',
        type: NotificationType.newMessage,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
        data: {'senderId': '456'},
      ),
      AppNotification(
        id: 'demo_3',
        title: 'Réservation confirmée',
        body: 'Votre réservation pour le trajet du 15 Octobre a été confirmée.',
        type: NotificationType.bookingUpdate,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        data: {'bookingId': '789'},
      ),
      AppNotification(
        id: 'demo_4',
        title: 'Promotion spéciale',
        body: 'Profitez de 20% de réduction sur vos 3 prochains trajets !',
        type: NotificationType.promotion,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
        data: {'promoCode': 'MOOV20'},
      ),
      AppNotification(
        id: 'demo_5',
        title: 'Mise à jour système',
        body: 'L\'application Moov a été mise à jour avec de nouvelles fonctionnalités.',
        type: NotificationType.general,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        data: {},
      ),
    ];

    for (final notification in demoNotifications) {
      await _notificationService.storeNotification(notification);
    }

    await loadData(); // Recharger les données
  }
}