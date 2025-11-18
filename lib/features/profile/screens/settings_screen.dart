import 'package:flutter/material.dart';
// --- CORRIGEZ CES IMPORTS ---
import 'package:moovapp/features/profile/screens/edit_profile_screen.dart';
import 'package:moovapp/features/profile/screens/payment_methods_screen.dart';
import 'package:moovapp/features/profile/screens/language_selection_screen.dart';
// 2. IMPORT DU PROVIDER DE THÈME
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/theme_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    // Le provider nous permet de lire et modifier l'état du thème
    final themeProvider = Provider.of<ThemeProvider>(context);

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
                    // CONNECTÉ: Navigue vers EditProfileScreen
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payment_outlined),
                  title: const Text('Moyens de paiement'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // CONNECTÉ: Navigue vers PaymentMethodsScreen
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PaymentMethodsScreen(),
                    ));
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
                    // TODO: Appeler le backend pour enregistrer la préférence
                  },
                  activeThumbColor: Theme.of(context).colorScheme.primary,
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
                    // TODO: Appeler le backend pour enregistrer la préférence
                  },
                  activeThumbColor: Theme.of(context).colorScheme.primary,
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
                        'Français', // TODO: Rendre dynamique via i18n
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () {
                    // CONNECTÉ: Navigue vers l'écran de sélection de langue
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const LanguageSelectionScreen(),
                    ));
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Mode sombre'),
                  value: themeProvider.isDarkMode, // Lit l'état du provider
                  onChanged: (bool value) {
                    // Appelle le provider pour changer l'état (met à jour toute l'app)
                    themeProvider.toggleTheme(value);
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
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}