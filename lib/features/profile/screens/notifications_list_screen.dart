import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:moovapp/core/providers/notification_provider.dart';
import 'package:moovapp/core/models/notification.dart';

class NotificationsListScreen extends StatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  State<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends State<NotificationsListScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les notifications au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Mes Notifications',
          style: TextStyle(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.primary,
        iconTheme: IconThemeData(color: colors.onPrimary),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: notificationProvider.notifications.isNotEmpty
                    ? () => _showClearAllDialog(context, notificationProvider)
                    : null,
                tooltip: 'Tout marquer comme lu',
              );
            },
          ),
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _createDemoNotifications(context, notificationProvider),
                tooltip: 'Créer des notifications de démonstration',
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notificationProvider.notifications.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];
              return _buildNotificationTile(context, notification, notificationProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: colors.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous n\'avez pas encore reçu de notifications.',
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    AppNotification notification,
    NotificationProvider provider,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colors.error,
        child: Icon(
          Icons.delete,
          color: colors.onError,
        ),
      ),
      onDismissed: (direction) {
        provider.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification supprimée'),
            action: SnackBarAction(
              label: 'Annuler',
              onPressed: () {
                // Note: Dans une vraie app, on restaurerait la notification
              },
            ),
          ),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type, colors),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: colors.onPrimary,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.body,
              style: TextStyle(
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(notification.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          if (!notification.isRead) {
            provider.markAsRead(notification.id);
          }
          // Ici on pourrait naviguer vers l'écran approprié selon le type de notification
          _handleNotificationTap(context, notification);
        },
        tileColor: notification.isRead ? null : colors.primary.withValues(alpha: 0.05),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type, ColorScheme colors) {
    switch (type) {
      case NotificationType.newRide:
        return colors.primary;
      case NotificationType.newMessage:
        return colors.secondary;
      case NotificationType.bookingUpdate:
        return Colors.orange;
      case NotificationType.promotion:
        return Colors.green;
      case NotificationType.general:
        return colors.error;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newRide:
        return Icons.directions_car;
      case NotificationType.newMessage:
        return Icons.message;
      case NotificationType.bookingUpdate:
        return Icons.check_circle;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.general:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Hier ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} jours';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  void _showClearAllDialog(BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marquer tout comme lu'),
        content: const Text('Voulez-vous marquer toutes les notifications comme lues ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              provider.markAllAsRead();
              Navigator.of(context).pop();
            },
            child: const Text('Marquer comme lu'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, AppNotification notification) {
    // Ici on pourrait implémenter la navigation selon le type de notification
    // Par exemple, aller vers les détails d'un trajet, d'une réservation, etc.
    switch (notification.type) {
      case NotificationType.newRide:
        // Navigator.pushNamed(context, '/ride-details', arguments: notification.data);
        break;
      case NotificationType.newMessage:
        // Navigator.pushNamed(context, '/messages');
        break;
      case NotificationType.bookingUpdate:
        // Navigator.pushNamed(context, '/reservations');
        break;
      case NotificationType.promotion:
        // Navigator.pushNamed(context, '/promotions');
        break;
      case NotificationType.general:
        // Peut-être afficher un dialog avec plus d'infos
        break;
    }
  }

  void _createDemoNotifications(BuildContext context, NotificationProvider provider) async {
    await provider.createDemoNotifications();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifications de démonstration créées'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}