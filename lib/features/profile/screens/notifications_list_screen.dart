import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:moovapp/core/providers/notification_provider.dart';
import 'package:moovapp/core/models/notification_model.dart';
import 'package:moovapp/l10n/app_localizations.dart';

class NotificationsListScreen extends StatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  State<NotificationsListScreen> createState() =>
      _NotificationsListScreenState();
}

class _NotificationsListScreenState extends State<NotificationsListScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les notifications au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
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
          AppLocalizations.of(context)?.myNotifications ?? 'Mes notifications',
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
                icon: const Icon(Icons.done_all),
                onPressed: notificationProvider.notifications.isNotEmpty
                    ? () =>
                        _showMarkAllReadDialog(context, notificationProvider)
                    : null,
                tooltip: AppLocalizations.of(context)?.markAllAsRead ??
                    'Tout marquer comme lu',
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

          return RefreshIndicator(
            onRefresh: () => notificationProvider.loadNotifications(),
            child: ListView.builder(
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                return _buildNotificationTile(
                    context, notification, notificationProvider);
              },
            ),
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
            color: colors.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)?.noNotifications ??
                'Aucune notification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.noNotificationsDesc ??
                'Vous n\'avez pas encore reçu de notifications.',
            style: TextStyle(
              color: colors.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    NotificationModel notification,
    NotificationProvider provider,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Dismissible(
      key: Key(notification.id.toString()),
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
        // Note: deleteNotification à implémenter dans le provider si besoin
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.notificationDeleted ??
                'Notification supprimée'),
          ),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.type, colors),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: TextStyle(
                color: colors.onSurface.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(notification.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface.withOpacity(0.5),
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
        },
        tileColor:
            notification.isRead ? null : colors.primary.withOpacity(0.05),
      ),
    );
  }

  Color _getNotificationColor(String type, ColorScheme colors) {
    switch (type) {
      case 'reservation':
        return colors.primary;
      case 'message':
        return colors.secondary;
      case 'confirmation':
        return Colors.green;
      case 'cancellation':
        return Colors.red;
      case 'reminder':
        return Colors.orange;
      default:
        return colors.primary;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'reservation':
        return Icons.directions_car;
      case 'message':
        return Icons.message;
      case 'confirmation':
        return Icons.check_circle;
      case 'cancellation':
        return Icons.cancel;
      case 'reminder':
        return Icons.alarm;
      default:
        return Icons.notifications;
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
      return 'Il y a ${difference.inDays} jours';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  void _showMarkAllReadDialog(
      BuildContext context, NotificationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.markAllAsRead ??
            'Tout marquer comme lu'),
        content: Text(AppLocalizations.of(context)?.markAllAsReadQuestion ??
            'Voulez-vous marquer toutes les notifications comme lues ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Annuler'),
          ),
          TextButton(
            onPressed: () {
              provider.markAllAsRead();
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)?.confirm ?? 'Confirmer'),
          ),
        ],
      ),
    );
  }
}
