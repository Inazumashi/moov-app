import 'package:flutter/material.dart';
import 'package:moovapp/l10n/app_localizations.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.pageTitleTerms,
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
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dernière mise à jour : 17 Novembre 2025',
                style: TextStyle(
                  color: colors.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '1. Acceptation des conditions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'En utilisant l\'application Moov (le "Service"), vous acceptez d\'être lié par ces Conditions d\'utilisation. Si vous n\'acceptez pas ces conditions, n\'utilisez pas le Service.',
                style: TextStyle(
                  height: 1.5,
                  fontSize: 15,
                  color: colors.onSurface.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '2. Description du Service',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Moov est une plateforme de covoiturage communautaire pour les étudiants et le personnel universitaire. Nous ne sommes pas une entreprise de transport. Les conducteurs ne sont pas nos employés. Nous facilitons uniquement la mise en relation.',
                style: TextStyle(
                  height: 1.5,
                  fontSize: 15,
                  color: colors.onSurface.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '3. Responsabilités de l\'utilisateur',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vous acceptez de fournir des informations exactes lors de votre inscription. Vous êtes responsable de votre propre sécurité lors d\'un trajet. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                style: TextStyle(
                  height: 1.5,
                  fontSize: 15,
                  color: colors.onSurface.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}