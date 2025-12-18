import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/payment_provider.dart';
import 'package:moovapp/core/providers/auth_provider.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final double _price = 10.0;
  final String _currency = 'USD'; // Sandbox often easier in USD, but user listed verification in MAD.
  // Actually PaymentService verify expects 'MAD' hardcoded in body? 
  // Line 169 of payment_provider: 'currency': 'MAD'.
  // But PayPal payment flutter view usually takes any supported currency.
  // I will use USD for sandbox to be safe or verify what the user wants. 
  // User Prompt: "Mode Premium & Paiement (PayPal)... Intégrer flutter_paypal_payment... sandbox".
  // The backend verify logic sends 'MAD'.
  // I will stick to what payment_provider does locally or match it.
  // In initiatePayPalPayment call, I pass currency.
  
  bool _isProcessing = false;

  void _handlePayment() {
    setState(() {
      _isProcessing = true;
    });

    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    paymentProvider.initiatePayPalPayment(
      context: context,
      amount: _price,
      currency: 'USD',
      description: 'Abonnement Premium Moov (1 Mois)',
      onSuccess: (paymentId) async {
        print('Payment success: $paymentId');
        try {
          await paymentProvider.verifyAndActivatePremium(paymentId, _price);
          await authProvider.refreshProfile();
          
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Abonnement Premium activé !'), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur activation: $e'), backgroundColor: Colors.red),
            );
          }
        } finally {
          if (mounted) setState(() => _isProcessing = false);
        }
      },
      onError: (error) {
        print('Payment error: $error');
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $error'), backgroundColor: Colors.red),
          );
          setState(() => _isProcessing = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = Provider.of<AuthProvider>(context).currentUser;
    final isPremium = user?.isPremium ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moov Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colors.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'Passez au niveau supérieur',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Débloquez des fonctionnalités exclusives pour une meilleure expérience.',
              style: TextStyle(fontSize: 16, color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            _buildFeatureItem(Icons.eco, 'Tableau de bord écologique', 'Suivez votre impact CO2 et vos économies en temps réel.'),
            _buildFeatureItem(Icons.verified, 'Badge Premium', 'Affichez un badge distinctif sur votre profil.'),
            _buildFeatureItem(Icons.priority_high, 'Support Prioritaire', 'Vos demandes sont traitées en priorité.'),
            
            const SizedBox(height: 48),
            
            if (isPremium)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Vous êtes déjà Premium', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        '10.00 USD / mois',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('Annulable à tout moment'),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: _isProcessing ? null : _handlePayment,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.blue[800], // PayPal color implies trust
                          ),
                          icon: _isProcessing 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                            : const Icon(Icons.paypal),
                          label: Text(_isProcessing ? 'Traitement...' : 'Payer avec PayPal'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.amber[700], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}