import 'package:flutter/material.dart';
import 'package:moovapp/l10n/app_localizations.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.pageTitleFaq,
          style: TextStyle(
            color: colors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.primary,
        iconTheme: IconThemeData(color: colors.onPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildFaqItem(
            context,
            'Comment publier un trajet ?',
            'Allez dans l\'onglet "Publier" (l\'icône + au milieu). Remplissez les détails de votre trajet, y compris le départ, l\'arrivée, la date, l\'heure, et le prix. Appuyez ensuite sur "Publier le trajet".',
          ),
          _buildFaqItem(
            context,
            'Comment réserver une place ?',
            'Allez dans l\'onglet "Rechercher". Entrez votre point de départ, d\'arrivée et la date. Parcourez les résultats et cliquez sur le trajet qui vous convient pour voir les détails et le réserver.',
          ),
          _buildFaqItem(
            context,
            'La vérification est-elle obligatoire ?',
            'La vérification de votre email universitaire est obligatoire pour rejoindre votre communauté. La vérification de l\'identité et du téléphone est optionnelle mais fortement recommandée pour augmenter la confiance et la sécurité.',
          ),
          _buildFaqItem(
            context,
            'Comment contacter un conducteur ?',
            'Une fois votre réservation confirmée, vous aurez accès à une messagerie privée pour discuter des détails (lieu de rendez-vous exact, etc.) avec le conducteur.',
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context,
    String question,
    String answer,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        iconColor: colors.primary,
        collapsedIconColor: colors.primary,
        childrenPadding: const EdgeInsets.all(16.0),
        children: [
          Text(
            answer,
            style: TextStyle(
              color: colors.onSurface.withOpacity(0.8),
              height: 1.5,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
