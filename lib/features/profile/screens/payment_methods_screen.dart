import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/payment_provider.dart';
import 'package:moovapp/core/models/payment_method.dart';
import 'package:moovapp/features/profile/screens/add_credit_card_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadPaymentMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final paymentProvider = context.watch<PaymentProvider>();

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
      body: paymentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionTitle(context, 'Cartes enregistrées'),
                ...paymentProvider.paymentMethods
                    .where((method) => method.type == PaymentMethodType.creditCard)
                    .map((method) => _buildPaymentCard(context, method)),
                const SizedBox(height: 16),
                _buildSectionTitle(context, 'Comptes PayPal'),
                ...paymentProvider.paymentMethods
                    .where((method) => method.type == PaymentMethodType.paypal)
                    .map((method) => _buildPaymentCard(context, method)),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _showAddPaymentMethodDialog(context),
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
                      color: colors.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
                if (paymentProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      paymentProvider.error!,
                      style: TextStyle(color: colors.error),
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
          color: colors.onSurface.withOpacity(0.7),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // CARTE DE PAIEMENT
  Widget _buildPaymentCard(BuildContext context, PaymentMethod method) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    IconData icon;
    Color iconColor;
    String subtitle;

    switch (method.type) {
      case PaymentMethodType.paypal:
        icon = Icons.account_balance_wallet;
        iconColor = Colors.blue;
        subtitle = method.email ?? 'PayPal';
        break;
      case PaymentMethodType.creditCard:
        icon = Icons.credit_card;
        iconColor = Colors.blue;
        subtitle = method.lastFourDigits != null ? '**** ${method.lastFourDigits}' : 'Carte';
        break;
    }

    return Card(
      elevation: 0.5,
      color: theme.cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 30),
        title: Text(
          method.displayName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: colors.onSurface.withOpacity(0.7)),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'default':
                context.read<PaymentProvider>().setDefaultPaymentMethod(method.id);
                break;
              case 'delete':
                _showDeleteConfirmation(context, method);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!method.isDefault)
              const PopupMenuItem(
                value: 'default',
                child: Text('Définir par défaut'),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Supprimer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un moyen de paiement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: Colors.blue),
              title: const Text('PayPal'),
              onTap: () {
                Navigator.of(context).pop();
                _addPayPalAccount(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.blue),
              title: const Text('Carte bancaire'),
              onTap: () {
                Navigator.of(context).pop();
                _addCreditCard(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addPayPalAccount(BuildContext context) {
    // Pour simplifier, on simule l'ajout d'un compte PayPal
    // En production, ceci devrait ouvrir une connexion PayPal
    final paymentProvider = context.read<PaymentProvider>();
    final method = PaymentMethod(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: PaymentMethodType.paypal,
      displayName: 'PayPal',
      email: 'user@example.com', // À remplacer par l'email réel
    );
    paymentProvider.addPaymentMethod(method);
  }

  void _addCreditCard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddCreditCardScreen()),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le moyen de paiement'),
        content: Text('Voulez-vous vraiment supprimer ${method.displayName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<PaymentProvider>().removePaymentMethod(method.id);
              Navigator.of(context).pop();
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
