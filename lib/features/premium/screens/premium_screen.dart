import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/payment_provider.dart';
import 'package:moovapp/core/providers/premium_provider.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isProcessingPayment = false;

  Future<void> _handlePremiumPurchase() async {
    final paymentProvider = context.read<PaymentProvider>();
    
    // NOTE: Si tu veux forcer l'utilisateur à avoir ajouté une méthode avant de payer, garde ceci.
    // Sinon, tu peux retirer ce bloc si flutter_paypal_payment gère tout.
    final defaultMethod = await paymentProvider.getDefaultPaymentMethod();

    if (defaultMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez ajouter un moyen de paiement dans les paramètres'),
          action: SnackBarAction(
            label: 'Aller aux paramètres',
            onPressed: () {
              Navigator.of(context).pushNamed('/payment-methods');
            },
          ),
        ),
      );
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      await paymentProvider.initiatePayPalPayment(
        context: context,
        amount: 49.0,
        currency: 'MAD',
        description: 'Abonnement Premium Moov - 1 mois',
        onSuccess: (paymentId) async {
          print("Paiement PayPal réussi (ID: $paymentId). Vérification serveur...");
          
          try {
            // -----------------------------------------------------------
            // 1. APPEL AU BACKEND : On vérifie et on active coté serveur
            // -----------------------------------------------------------
            await context.read<PaymentProvider>().verifyAndActivatePremium(paymentId, 49.0);

            // -----------------------------------------------------------
            // 2. MISE À JOUR LOCALE : Si le serveur dit OK, on débloque l'UI
            // -----------------------------------------------------------
            if (mounted) {
              await context.read<PremiumProvider>().activatePremium();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Paiement validé par le serveur ! Bienvenue dans Premium !'),
                  backgroundColor: Colors.green,
                ),
              );
              
              // Retourner à l'écran précédent
              Navigator.of(context).pop();
            }
          } catch (serverError) {
            // Si le serveur refuse (fraude, erreur réseau...)
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur de validation serveur: ${serverError.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur de paiement: $error')),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PremiumProvider>().loadPremiumStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final premiumProvider = context.watch<PremiumProvider>();
    final isAlreadyPremium = premiumProvider.isPremium;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.orange[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAlreadyPremium ? 'Premium Actif' : 'Premium',
              style:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              isAlreadyPremium
                  ? 'Votre abonnement expire dans ${premiumProvider.getRemainingTime()}'
                  : 'Profitez d\'une expérience complète sans interruption',
              style:
                  TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
            ),
          ],
        ),
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPremiumCard(context),
            const SizedBox(height: 24),
            _buildFreeCard(context),
            const SizedBox(height: 24),
            Text(
              'Pourquoi Premium ?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildWhyPremiumRow(context, Icons.block,
                'Expérience sans publicité', 'Naviguez sans interruption'),
            const SizedBox(height: 12),
            _buildWhyPremiumRow(context, Icons.bar_chart,
                'Statistiques détaillées', 'Analysez vos habitudes de trajets'),
            const SizedBox(height: 12),
            _buildWhyPremiumRow(context, Icons.verified_user,
                'Badge Premium visible', 'Montrez votre engagement'),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------
  // PREMIUM CARD
  // ------------------------------------------------------
  Widget _buildPremiumCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // On récupère l'état pour savoir si le bouton doit être désactivé
    final isPremium = context.watch<PremiumProvider>().isPremium;

    return Container(
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[400],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Le plus populaire',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
              Icon(Icons.workspace_premium,
                  color: Colors.orange[400], size: 32),
            ],
          ),

          const SizedBox(height: 16),

          RichText(
            text: TextSpan(
              text: '49 MAD ',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: '/ par mois',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          Text('Annulez à tout moment',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 13)),
          const SizedBox(height: 24),

          // Avantages premium
          _buildFeatureRow('Recherche de trajets', true),
          _buildFeatureRow('Publication de trajets', true),
          _buildFeatureRow('Messagerie illimitée', true),
          _buildFeatureRow('Sans publicité', true, isHighlighted: true),
          _buildFeatureRow('Statistiques avancées', true),
          _buildFeatureRow('Sous-communautés multiples', true),
          _buildFeatureRow('Analyses détaillées', true),
          _buildFeatureRow('Badge Premium', true),
          _buildFeatureRow('Support prioritaire', true),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // Si déjà premium ou en chargement, on désactive le bouton
              onPressed: _isProcessingPayment || isPremium ? null : _handlePremiumPurchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[400],
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isProcessingPayment
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                      ),
                    )
                  : Text(
                      isPremium ? 'Premium Actif' : 'Commencer Premium',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------
  // FREE CARD (Code inchangé)
  // ------------------------------------------------------
  Widget _buildFreeCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Plan actuel',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              text: '0 MAD ',
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: '/ toujours',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildFeatureRow('Recherche de trajets', true, isFree: true),
          _buildFeatureRow('Publication de trajets', true, isFree: true),
          _buildFeatureRow('Messagerie basique', true, isFree: true),
          _buildFeatureRow('Publicités', false,
              isFree: true, isHighlighted: true),
          _buildFeatureRow('Statistiques basiques', true, isFree: true),
          _buildFeatureRow('Sous-communautés', true, isFree: true),
          _buildFeatureRow('Stats avancées', false, isFree: true),
          _buildFeatureRow('Badge Premium', false, isFree: true),
          _buildFeatureRow('Support prioritaire', false, isFree: true),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
    String text,
    bool included, {
    bool isFree = false,
    bool isHighlighted = false,
  }) {
    Color iconColor;
    Color textColor;

    if (included) {
      iconColor = isHighlighted
          ? Colors.orange
          : (isFree ? Colors.green : Colors.white);
      textColor = isFree ? Colors.black87 : Colors.white;
    } else {
      iconColor = isFree ? Colors.grey : Colors.white70;
      textColor = isFree ? Colors.grey : Colors.white70;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              decoration:
                  included ? TextDecoration.none : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyPremiumRow(
      BuildContext context, IconData icon, String title, String subtitle) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: cs.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: cs.onSurface)),
              Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}