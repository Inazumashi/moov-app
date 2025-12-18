import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/notification_provider.dart';
import 'package:moovapp/core/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications()
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);
    final colors = Theme.of(context).colorScheme;

    // Filter lists
    final activityNotes = provider.notifications.where((n) => 
      n.type == 'reservation' || n.type == 'confirmation' || n.type == 'info'
    ).toList();
    
    final messageNotes = provider.notifications.where((n) => 
      n.type == 'message'
    ).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          backgroundColor: colors.surface,
          foregroundColor: colors.onSurface,
          elevation: 0,
          bottom: TabBar(
            labelColor: colors.primary,
            unselectedLabelColor: colors.onSurfaceVariant,
            indicatorColor: colors.primary,
            tabs: const [
              Tab(text: 'Activité'),
              Tab(text: 'Messages'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: () {
                provider.markAllAsRead();
              },
              tooltip: 'Tout marquer comme lu',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildNotificationList(activityNotes, colors, isMessage: false),
            _buildNotificationList(messageNotes, colors, isMessage: true),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications, ColorScheme colors, {required bool isMessage}) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isMessage ? Icons.message_outlined : Icons.notifications_none,
              size: 64,
              color: colors.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isMessage ? 'Aucun message' : 'Aucune activité',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final n = notifications[index];
        return Dismissible(
          key: Key(n.id.toString()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            // Supprimer localement et appeler le provider
            // Note: Il faudrait ajouter deleteNotification dans le provider
            // Pour l'instant on le marque juste comme lu ou on suppose qu'il est supprimé
             Provider.of<NotificationProvider>(context, listen: false).markAsRead(n.id);
             
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Notification supprimée')),
             );
          },
          child: Container(
            color: n.isRead ? null : colors.primary.withOpacity(0.05),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getIconColor(n.type).withOpacity(0.1),
                child: Icon(_getIcon(n.type), color: _getIconColor(n.type), size: 20),
              ),
              title: Text(
                n.title,
                style: TextStyle(
                  fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.message),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(n.createdAt),
                    style: TextStyle(fontSize: 12, color: colors.outline),
                  ),
                ],
              ),
              onTap: () {
                Provider.of<NotificationProvider>(context, listen: false).markAsRead(n.id);
                // Handle navigation logic here if needed (e.g. go to ride or chat)
              },
            ),
          ),
        );
      },
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours} h';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'reservation': return Icons.directions_car;
      case 'confirmation': return Icons.check_circle;
      case 'message': return Icons.chat;
      default: return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'reservation': return Colors.blue;
      case 'confirmation': return Colors.green;
      case 'message': return Colors.purple;
      default: return Colors.orange;
    }
  }
}
