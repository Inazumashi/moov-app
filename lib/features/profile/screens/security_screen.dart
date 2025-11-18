import 'package:flutter/material.dart';
// 1. AJOUT DE L'IMPORT
import 'package:moovapp/features/profile/screens/change_password_screen.dart';

// On utilise un StatefulWidget pour gérer l'état du Switch
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  // Valeur d'exemple pour le Switch 2FA
  bool _twoFactorAuth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Sécurité',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          // --- Section Mot de passe ---
          _buildSectionTitle('Gestion du mot de passe'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Changer le mot de passe'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // 2. MISE À JOUR DE LA NAVIGATION
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen(),
                    ));
                  },
                ),
              ],
            ),
          ),

          // --- Section Authentification ---
          _buildSectionTitle('Authentification à deux facteurs'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.shield_outlined),
                  title: const Text('Authentification à deux facteurs'),
                  subtitle:
                      const Text('Utilisez un code SMS pour plus de sécurité.'),
                  value: _twoFactorAuth,
                  onChanged: (bool value) {
                    setState(() {
                      _twoFactorAuth = value;
                    });
                    // TODO: Logique pour activer/désactiver le 2FA
                  },
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),

          // --- 3. SECTION VÉRIFICATION (SUPPRIMÉE) ---
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