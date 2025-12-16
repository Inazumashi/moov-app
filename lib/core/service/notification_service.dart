import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:moovapp/core/models/notification.dart';


class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const String _notificationsKey = 'stored_notifications';
  static const String _preferencesKey = 'notification_preferences';

  // Callbacks pour mettre à jour l'UI
  Function(AppNotification)? onNotificationReceived;

  Future<void> initialize() async {
    // Initialize local notifications
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(settings);

    // Setup notification tap
    await _setupNotificationTap();
  }

  Future<String?> getToken() async {
    // Return null since no Firebase
    return null;
  }

  // Gestion des préférences de notifications
  Future<Map<String, bool>> getNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = prefs.getString(_preferencesKey);
    if (preferencesJson != null) {
      final Map<String, dynamic> preferences = jsonDecode(preferencesJson);
      return preferences.map((key, value) => MapEntry(key, value as bool));
    }
    // Valeurs par défaut
    return {
      'newRides': true,
      'newMessages': true,
      'bookingUpdates': true,
      'promotions': false,
    };
  }

  Future<void> updateNotificationPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final preferences = await getNotificationPreferences();
    preferences[key] = value;
    await prefs.setString(_preferencesKey, jsonEncode(preferences));

    // Note: Topic subscription removed since no Firebase
  }

  Future<void> _storeNotification(AppNotification notification) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getStoredNotifications();
    notifications.insert(0, notification); // Ajouter au début

    // Garder seulement les 100 dernières notifications
    if (notifications.length > 100) {
      notifications.removeRange(100, notifications.length);
    }

    final notificationsJson = notifications.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(_notificationsKey, notificationsJson);
  }

  Future<void> storeNotification(AppNotification notification) async {
    await _storeNotification(notification);
  }

  Future<List<AppNotification>> getStoredNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];
    return notificationsJson.map((json) => AppNotification.fromJson(jsonDecode(json))).toList();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getStoredNotifications();

    final updatedNotifications = notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    final notificationsJson = updatedNotifications.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(_notificationsKey, notificationsJson);
  }

  Future<void> deleteNotification(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getStoredNotifications();
    notifications.removeWhere((notification) => notification.id == notificationId);

    final notificationsJson = notifications.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(_notificationsKey, notificationsJson);
  }

  Future<int> getUnreadCount() async {
    final notifications = await getStoredNotifications();
    return notifications.where((notification) => !notification.isRead).length;
  }

  Future<void> _setupNotificationTap() async {
    // Handle notification tap when app is in background
    // Note: Removed Firebase handling
  }

  void _handleNotificationTap() {
    // Handle what happens when user taps on notification
    print('Notification tapped');
    // You can navigate to specific screen based on data
  }
}