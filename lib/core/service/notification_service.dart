import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:moovapp/core/models/notification.dart';


class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const String _notificationsKey = 'stored_notifications';
  static const String _preferencesKey = 'notification_preferences';

  // Callbacks pour mettre à jour l'UI
  Function(AppNotification)? onNotificationReceived;

  Future<void> initialize() async {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(settings);

    // Request permissions
    await _requestPermissions();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps
    await _setupNotificationTap();
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
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

    // S'abonner/désabonner au topic selon la préférence
    final topic = _getTopicForPreference(key);
    if (topic != null) {
      if (value) {
        await subscribeToTopic(topic);
      } else {
        await unsubscribeFromTopic(topic);
      }
    }
  }

  String? _getTopicForPreference(String preference) {
    switch (preference) {
      case 'newRides':
        return 'new_rides';
      case 'newMessages':
        return 'new_messages';
      case 'bookingUpdates':
        return 'booking_updates';
      case 'promotions':
        return 'promotions';
      default:
        return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      // Créer une notification locale
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );

      // Stocker la notification dans l'app
      final appNotification = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        type: _getNotificationTypeFromData(message.data),
        timestamp: DateTime.now(),
        data: message.data,
      );

      _storeNotification(appNotification);

      // Notifier l'UI
      onNotificationReceived?.call(appNotification);
    }
  }

  NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    final type = data['type'];
    switch (type) {
      case 'new_ride':
        return NotificationType.newRide;
      case 'new_message':
        return NotificationType.newMessage;
      case 'booking_update':
        return NotificationType.bookingUpdate;
      case 'promotion':
        return NotificationType.promotion;
      default:
        return NotificationType.general;
    }
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
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Handle what happens when user taps on notification
    print('Notification tapped: ${message.data}');
    // You can navigate to specific screen based on message data
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}