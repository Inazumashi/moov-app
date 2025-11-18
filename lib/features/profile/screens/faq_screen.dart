import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'FAQ (Questions fréquentes)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // J'ajoute quelques questions/réponses d'exemple
          _buildFaqItem(
            'Comment publier un trajet ?',
            'Allez dans l\'onglet "Publier" (l\'icône + au milieu). Remplissez les détails de votre trajet, y compris le départ, l\'arrivée, la date, l\'heure, et le prix. Appuyez ensuite sur "Publier le trajet".',
          ),
          _buildFaqItem(
            'Comment réserver une place ?',
            'Allez dans l\'onglet "Rechercher". Entrez votre point de départ, d\'arrivée et la date. Parcourez les résultats et cliquez sur le trajet qui vous convient pour voir les détails et le réserver.',
          ),
          _buildFaqItem(
            'La vérification est-elle obligatoire ?',
            'La vérification de votre email universitaire est obligatoire pour rejoindre votre communauté. La vérification de l\'identité et du téléphone est optionnelle mais fortement recommandée pour augmenter la confiance et la sécurité.',
          ),
          _buildFaqItem(
            'Comment contacter un conducteur ?',
            'Une fois votre réservation confirmée, vous aurez accès à une messagerie privée pour discuter des détails (lieu de rendez-vous exact, etc.) avec le conducteur.',
          ),
        ],
      ),
    );
  }

  // Helper widget pour un seul item de la FAQ (un titre cliquable qui s'ouvre)
  Widget _buildFaqItem(String question, String answer) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // Ce qui s'affiche quand on clique
        childrenPadding: const EdgeInsets.all(16.0),
        children: [
          Text(
            answer,
            style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 15),
          )
        ],
      ),
    );
  }
}
