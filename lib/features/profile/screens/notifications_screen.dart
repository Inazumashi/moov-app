import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _newRides = true;
  bool _newMessages = true;
  bool _bookingUpdates = true;
  bool _promotions = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.primary,
        iconTheme: IconThemeData(color: colors.onPrimary),
      ),

      body: ListView(
        children: <Widget>[
          // --- Section Notifications Push ---
          _buildSectionTitle(context, 'Notifications Push'),

          Container(
            color: theme.cardColor,
            child: Column(
              children: <Widget>[
                _buildSwitch(
                  context,
                  icon: Icons.directions_car_outlined,
                  title: 'Nouveaux trajets publiés',
                  subtitle:
                      'Recevoir une alerte pour les nouveaux trajets sur vos routes favorites.',
                  value: _newRides,
                  onChanged: (v) => setState(() => _newRides = v),
                ),
                _buildSwitch(
                  context,
                  icon: Icons.message_outlined,
                  title: 'Nouveaux messages',
                  subtitle:
                      'Recevoir une alerte pour les nouveaux messages de conducteurs/passagers.',
                  value: _newMessages,
                  onChanged: (v) => setState(() => _newMessages = v),
                ),
                _buildSwitch(
                  context,
                  icon: Icons.check_circle_outline,
                  title: 'Mises à jour des réservations',
                  subtitle: 'Réservation confirmée, annulée, etc.',
                  value: _bookingUpdates,
                  onChanged: (v) => setState(() => _bookingUpdates = v),
                ),
              ],
            ),
          ),

          // --- Section Notifications Email ---
          _buildSectionTitle(context, 'Notifications par E-mail'),

          Container(
            color: theme.cardColor,
            child: Column(
              children: <Widget>[
                _buildSwitch(
                  context,
                  icon: Icons.local_offer_outlined,
                  title: 'Promotions et actualités',
                  subtitle:
                      'Recevoir les promotions et les nouvelles de Moov.',
                  value: _promotions,
                  onChanged: (v) => setState(() => _promotions = v),
                ),
              ],
            ),
          ),
        ],
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
          color: colors.onBackground.withOpacity(0.7),
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
      secondary: Icon(icon, color: colors.onBackground),
      title: Text(title, style: TextStyle(color: colors.onBackground)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: colors.onBackground.withOpacity(0.7)),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: colors.primary,
      activeTrackColor: colors.primary.withOpacity(0.4),
    );
  }
}
