import 'package:flutter/material.dart';

// Un widget réutilisable pour afficher une carte de résultat
class RideResultCard extends StatelessWidget {
  final String name;
  final double rating;
  final String departure;
  final String departureDetail;
  final String arrival;
  final String arrivalDetail;
  final String dateTime;
  final String price;
  final int seats;
  final String? tag;
  final bool isFavorited;
  final VoidCallback onFavoriteTap;
  final bool isPremium;
  
  

  const RideResultCard({
    super.key,
    required this.name,
    required this.rating,
    required this.departure,
    required this.departureDetail,
    required this.arrival,
    required this.arrivalDetail,
    required this.dateTime,
    required this.price,
    required this.seats,
    required this.isFavorited,
    required this.onFavoriteTap,
    this.tag,
    this.isPremium = false,
    
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    
    return Card(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Ligne du haut (Nom, Prix) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nom, Premium et Note
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        if (isPremium) _buildPremiumChip(),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber.shade600, size: 16),
                        const SizedBox(width: 4),
                        Text('$rating', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                // Prix et Favori
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const Text('par place', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            // Bouton Favori (positionné)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 28.0), // Ajuster pour aligner sous le prix
                child: IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : Colors.grey,
                  ),
                  onPressed: onFavoriteTap,
                ),
              ),
            ),
            // Bouton Favori dynamique (remplacement)

            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // --- 2. Détails du trajet (Départ, Arrivée) ---
            _buildRouteDetail(
              icon: Icons.location_on_outlined,
              iconColor: primaryColor,
              title: departure,
              subtitle: departureDetail,
            ),
            const SizedBox(height: 12),
            _buildRouteDetail(
              icon: Icons.location_on,
              iconColor: Colors.green.shade600,
              title: arrival,
              subtitle: arrivalDetail,
            ),
            const SizedBox(height: 16),

            // --- 3. Ligne du bas (Date, Places, Tag) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(Icons.calendar_today_outlined, dateTime),
                _buildInfoChip(Icons.person_outline, '$seats places'),
              ],
            ),
            if (tag != null) ...[
              const SizedBox(height: 8),
              _buildTagChip(tag!, primaryColor),
            ],
          ],
        ),
      ),
    );
  }

  // --- Petits widgets pour construire la carte ---

  Widget _buildPremiumChip() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.shade600,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Premium',
        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRouteDetail({required IconData icon, required Color iconColor, required String title, required String subtitle}) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 16),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildTagChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

