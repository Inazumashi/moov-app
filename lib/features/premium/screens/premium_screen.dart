import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // L'AppBar orange
      appBar: AppBar(
        backgroundColor: Colors.orange[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Premium',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              'Profitez d\'une expérience complète sans interruption',
              style: TextStyle(color: Colors.white70, fontSize: 13),
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
            // --- Carte Premium ---
            _buildPremiumCard(context),
            const SizedBox(height: 24),
            
            // --- Carte Gratuit ---
            _buildFreeCard(context),
            const SizedBox(height: 24),

            // --- Section "Pourquoi Premium ?" ---
            const Text(
              'Pourquoi Premium ?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildWhyPremiumRow(
              context,
              Icons.block,
              'Expérience sans publicité',
              'Naviguez sans interruption',
            ),
            const SizedBox(height: 12),
            _buildWhyPremiumRow(
              context,
              Icons.bar_chart,
              'Statistiques détaillées',
              'Analysez vos habitudes de trajets',
            ),
            const SizedBox(height: 12),
            _buildWhyPremiumRow(
              context,
              Icons.verified_user,
              'Badge Premium visible',
              'Montrez votre engagement',
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour la carte bleue "Premium"
  Widget _buildPremiumCard(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[400],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Le plus populaire',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              Icon(Icons.workspace_premium, color: Colors.orange[400], size: 32),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: const TextSpan(
              text: '49 MAD ',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: '/ par mois',
                  style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          const Text('Annulez à tout moment', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 24),
          
          // Liste des avantages
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
          
          // Bouton Commencer Premium
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Logique d'abonnement
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[400],
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // Widget pour la carte blanche "Gratuit"
  Widget _buildFreeCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Plan actuel',
              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: const TextSpan(
              text: '0 MAD ',
              style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: '/ toujours',
                  style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Liste des avantages/limitations
          _buildFeatureRow('Recherche de trajets', true, isFree: true),
          _buildFeatureRow('Publication de trajets', true, isFree: true),
          _buildFeatureRow('Messagerie basique', true, isFree: true),
          _buildFeatureRow('Publicités', false, isFree: true, isHighlighted: true),
          _buildFeatureRow('Statistiques basiques', true, isFree: true),
          _buildFeatureRow('Sous-communautés', true, isFree: true),
          _buildFeatureRow('Stats avancées', false, isFree: true),
          _buildFeatureRow('Badge Premium', false, isFree: true),
          _buildFeatureRow('Support prioritaire', false, isFree: true),
        ],
      ),
    );
  }
  
  // Helper pour les lignes d'avantages (Premium et Gratuit)
  Widget _buildFeatureRow(String text, bool included, {bool isFree = false, bool isHighlighted = false}) {
    IconData icon;
    Color iconColor;
    Color textColor = isFree ? Colors.black87 : Colors.white;

    if (included) {
      icon = Icons.check_circle;
      iconColor = isHighlighted ? (isFree ? Colors.orange.shade400 : Colors.orange.shade400) : (isFree ? Colors.green.shade400 : Colors.white);
    } else {
      icon = Icons.cancel;
      iconColor = isFree ? Colors.grey.shade400 : Colors.white60;
      textColor = isFree ? Colors.grey.shade600 : Colors.white60;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              decoration: included ? TextDecoration.none : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }

  // Helper pour les lignes "Pourquoi Premium ?"
  Widget _buildWhyPremiumRow(BuildContext context, IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }
}
