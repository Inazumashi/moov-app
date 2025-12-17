import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/notification_provider.dart';
import 'package:moovapp/l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les préférences au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotificationPreferences();
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
          AppLocalizations.of(context)!.pageTitleNotifications,
          style: TextStyle(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.primary,
        iconTheme: IconThemeData(color: colors.onPrimary),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          return ListView(
            children: <Widget>[
              // --- Section Notifications Push ---
              _buildSectionTitle(context, AppLocalizations.of(context)!.pushNotifications),

              Container(
                color: theme.cardColor,
                child: Column(
                  children: <Widget>[
                    _buildSwitch(
                      context,
                      icon: Icons.directions_car_outlined,
                      title: AppLocalizations.of(context)!.newRidesPublished,
                      subtitle: AppLocalizations.of(context)!.newRidesDesc,
                      value: notificationProvider.newRidesEnabled,
                      onChanged: (v) => notificationProvider.setNewRidesEnabled(v),
                    ),
                    _buildSwitch(
                      context,
                      icon: Icons.message_outlined,
                      title: AppLocalizations.of(context)!.newMessages,
                      subtitle: AppLocalizations.of(context)!.newMessagesDesc,
                      value: notificationProvider.newMessagesEnabled,
                      onChanged: (v) => notificationProvider.setNewMessagesEnabled(v),
                    ),
                    _buildSwitch(
                      context,
                      icon: Icons.check_circle_outline,
                      title: AppLocalizations.of(context)!.bookingUpdates,
                      subtitle: AppLocalizations.of(context)!.bookingUpdatesDesc,
                      value: notificationProvider.bookingUpdatesEnabled,
                      onChanged: (v) => notificationProvider.setBookingUpdatesEnabled(v),
                    ),
                  ],
                ),
              ),

              // --- Section Notifications Email ---
              _buildSectionTitle(context, AppLocalizations.of(context)!.emailNotifications),

              Container(
                color: theme.cardColor,
                child: Column(
                  children: <Widget>[
                    _buildSwitch(
                      context,
                      icon: Icons.local_offer_outlined,
                      title: AppLocalizations.of(context)!.promotions,
                      subtitle: AppLocalizations.of(context)!.promotionsDesc,
                      value: notificationProvider.promotionsEnabled,
                      onChanged: (v) => notificationProvider.setPromotionsEnabled(v),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // TITRE DE SECTION
  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: colors.onSurface.withValues(alpha: 0.7),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // SWITCH LIST TILE
  Widget _buildSwitch(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SwitchListTile(
      secondary: Icon(icon, color: colors.onSurface),
      title: Text(title, style: TextStyle(color: colors.onSurface)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: colors.onSurface.withValues(alpha: 0.7)),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: colors.primary,
      activeTrackColor: colors.primary.withValues(alpha: 0.4),
    );
  }
}
