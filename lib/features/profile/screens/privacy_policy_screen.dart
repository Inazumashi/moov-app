import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          'Politique de confidentialité',
          style: TextStyle(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.primary,
        iconTheme: IconThemeData(color: colors.onPrimary),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dernière mise à jour : 17 Novembre 2025',
                style: TextStyle(
                  color: colors.onBackground.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                '1. Introduction',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colors.onBackground,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                style: TextStyle(
                  height: 1.5,
                  fontSize: 15,
                  color: colors.onBackground.withOpacity(0.9),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                '2. Données collectées',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colors.onBackground,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Nous collectons les informations suivantes :\n'
                '- Informations de profil (Nom, email universitaire, type de profil)\n'
                '- Informations de trajet (Départ, arrivée, horaires)\n'
                '- Données de localisation (si autorisé)\n'
                '- Données de paiement (si applicable)',
                style: TextStyle(
                  height: 1.5,
                  fontSize: 15,
                  color: colors.onBackground.withOpacity(0.9),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                '3. Utilisation de vos données',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colors.onBackground,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                style: TextStyle(
                  height: 1.5,
                  fontSize: 15,
                  color: colors.onBackground.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
