import 'package:flutter/material.dart';

// On utilise un StatefulWidget pour gérer l'état des Switchs
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Valeurs d'exemple pour les Switchs
  bool _newRides = true;
  bool _newMessages = true;
  bool _bookingUpdates = true;
  bool _promotions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: <Widget>[
          // --- Section Notifications Push ---
          _buildSectionTitle('Notifications Push'),
          Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  secondary: const Icon(Icons.directions_car_outlined),
                  title: const Text('Nouveaux trajets publiés'),
                  subtitle: const Text(
                      'Recevoir une alerte pour les nouveaux trajets sur vos routes favorites.'),
                  value: _newRides,
                  onChanged: (bool value) {
                    setState(() {
                      _newRides = value;
                    });
                  },
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.message_outlined),
                  title: const Text('Nouveaux messages'),
                  subtitle: const Text(
                      'Recevoir une alerte pour les nouveaux messages de conducteurs/passagers.'),
                  value: _newMessages,
                  onChanged: (bool value) {
                    setState(() {
                      _newMessages = value;
                    });
                  },
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.check_circle_outline),
                  title: const Text('Mises à jour des réservations'),
                  subtitle: const Text('Réservation confirmée, annulée, etc.'),
                  value: _bookingUpdates,
                  onChanged: (bool value) {
                    setState(() {
                      _bookingUpdates = value;
                    });
                  },
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),

          // --- Section Notifications Email ---
          _buildSectionTitle('Notifications par E-mail'),
          Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  secondary: const Icon(Icons.local_offer_outlined),
                  title: const Text('Promotions et actualités'),
                  subtitle:
                      const Text('Recevoir les promotions et les nouvelles de Moov.'),
                  value: _promotions,
                  onChanged: (bool value) {
                    setState(() {
                      _promotions = value;
                    });
                  },
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper pour les titres de section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        // CORRECTION: Ajout de const ici
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}