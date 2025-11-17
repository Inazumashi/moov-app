import 'package:flutter/material.dart';
// 1. AJOUT DES IMPORTS
import 'package:moovapp/features/profile/screens/faq_screen.dart';
import 'package:moovapp/features/profile/screens/contact_us_screen.dart';
import 'package:moovapp/features/profile/screens/terms_of_service_screen.dart';
import 'package:moovapp/features/profile/screens/privacy_policy_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Aide & Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        // CORRECTION: Ajout de <Widget>
        children: <Widget>[
          // --- Section Aide ---
          _buildSectionTitle('Aide'),
          Container(
            color: Colors.white,
            child: Column(
              // CORRECTION: Ajout de <Widget>
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.quiz_outlined),
                  title: const Text('FAQ (Questions fréquentes)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // 2. MISE À JOUR DE LA NAVIGATION
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const FaqScreen(),
                    ));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Contactez-nous'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // 3. MISE À JOUR DE LA NAVIGATION
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ContactUsScreen(),
                    ));
                  },
                ),
              ],
            ),
          ),

          // --- Section Légal ---
          _buildSectionTitle('Légal'),
          Container(
            color: Colors.white,
            child: Column(
              // CORRECTION: Ajout de <Widget>
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.gavel_outlined),
                  title: const Text("Conditions d'utilisation"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // 4. MISE À JOUR DE LA NAVIGATION
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const TermsOfServiceScreen(),
                    ));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Politique de confidentialité'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // 5. MISE À JOUR DE LA NAVIGATION
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ));
                  },
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
      // CORRECTION: Ajout de const
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