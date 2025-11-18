import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Politique de confidentialité',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dernière mise à jour : 17 Novembre 2025',
                style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Introduction',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                style: TextStyle(height: 1.5, fontSize: 15),
              ),
              const SizedBox(height: 24),
              const Text(
                '2. Données collectées',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nous collectons les informations suivantes :\n- Informations de profil (Nom, email universitaire, type de profil)\n- Informations de trajet (Départ, arrivée, horaires)\n- Données de localisation (si autorisé)\n- Données de paiement (si applicable)',
                style: TextStyle(height: 1.5, fontSize: 15),
              ),
              const SizedBox(height: 24),
              const Text(
                '3. Utilisation de vos données',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                style: TextStyle(height: 1.5, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}