import 'package:flutter/material.dart';

// On utilise un StatefulWidget pour gérer l'état des Switchs
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Valeurs d'exemple pour les Switchs
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Paramètres',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          // --- Section Compte ---
          _buildSectionTitle('Compte'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Modifier le profil'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Naviguer vers un futur écran EditProfileScreen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payment_outlined),
                  title: const Text('Moyens de paiement'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Naviguer vers un futur écran PaymentMethodsScreen
                  },
                ),
              ],
            ),
          ),

          // --- Section Notifications ---
          _buildSectionTitle('Notifications'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Notifications Push'),
                  value: _pushNotifications,
                  onChanged: (bool value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.email_outlined),
                  title: const Text('Notifications par e-mail'),
                  subtitle: const Text('Promotions, actualités, etc.'),
                  value: _emailNotifications,
                  onChanged: (bool value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),

          // --- Section Apparence ---
          _buildSectionTitle('Apparence'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: const Text('Langue'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Français',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () {
                    // TODO: Logique pour changer la langue
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Mode sombre'),
                  value: _darkMode,
                  onChanged: (bool value) {
                    setState(() {
                      _darkMode = value;
                    });
                    // TODO: Logique pour changer le thème de l'application
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
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
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}