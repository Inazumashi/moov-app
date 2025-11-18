import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Moyens de paiement',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Cartes enregistrées'),
          
          // Exemple de carte déjà enregistrée (Placeholder)
          _buildPaymentCard(
            context,
            'Carte Bancaire **** 4242',
            'Visa',
            Colors.blue,
          ),
          
          SizedBox(height: 16),
          
          // Bouton pour ajouter une nouvelle carte
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Logique pour ouvrir un formulaire d'ajout de carte
            },
            icon: Icon(Icons.add_circle_outline, color: primaryColor),
            label: Text(
              'Ajouter un nouveau moyen de paiement',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: primaryColor),
            ),
          ),
          
          SizedBox(height: 32),
          
          // Informations
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Vos informations de paiement sont sécurisées et cryptées selon les normes PCI DSS.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper pour les titres de section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
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

  // Helper pour afficher une carte de paiement
  Widget _buildPaymentCard(
      BuildContext context, String title, String type, Color color) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          Icons.credit_card,
          color: color,
          size: 30,
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(type),
        trailing: Icon(Icons.more_vert),
        onTap: () {
          // TODO: Option de modifier/supprimer
        },
      ),
    );
  }
}