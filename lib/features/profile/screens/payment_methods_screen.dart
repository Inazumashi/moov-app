import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          'Moyens de paiement',
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
          _buildSectionTitle(context, 'Cartes enregistrées'),

          _buildPaymentCard(
            context,
            'Carte Bancaire **** 4242',
            'Visa',
            Colors.blue,
          ),

          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add_circle_outline, color: colors.primary),
            label: Text(
              'Ajouter un nouveau moyen de paiement',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: colors.primary),
            ),
          ),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Vos informations de paiement sont sécurisées et cryptées selon les normes PCI DSS.',
              style: TextStyle(
                color: colors.onBackground.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TITRE DE SECTION
  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: colors.onBackground.withOpacity(0.7),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // CARTE DE PAIEMENT
  Widget _buildPaymentCard(
      BuildContext context, String title, String type, Color color) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 0.5,
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(Icons.credit_card, color: color, size: 30),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.onBackground,
          ),
        ),
        subtitle: Text(
          type,
          style: TextStyle(color: colors.onBackground.withOpacity(0.7)),
        ),
        trailing: Icon(Icons.more_vert, color: colors.onBackground),
        onTap: () {},
      ),
    );
  }
}
