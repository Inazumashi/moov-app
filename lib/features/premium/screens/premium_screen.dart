import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
            const Text(
              'Premium',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'Profitez d\'une expérience complète sans interruption',
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[400],
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Commencer Premium',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------
  // FREE CARD
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

  // ------------------------------------------------------
  // FEATURE ROW (Premium + Free Cards)
  // ------------------------------------------------------
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

  // ------------------------------------------------------
  // WHY PREMIUM ROW
  // ------------------------------------------------------
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
