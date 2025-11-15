import 'package:flutter/material.dart';

class FavoriteRideCard extends StatelessWidget {
  final String name;
  final double rating;
  final bool isPremium;
  final String departure;
  final String arrival;
  final String date;
  final String time;
  final int seats;
  final double price;

  const FavoriteRideCard({
    super.key,
    required this.name,
    required this.rating,
    required this.isPremium,
    required this.departure,
    required this.arrival,
    required this.date,
    required this.time,
    required this.seats,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 1,
      shadowColor: Colors.grey.shade50,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Partie supérieure : Profil & Icône ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Initiale du nom
                CircleAvatar(
                  backgroundColor: primaryColor,
                  radius: 20,
                  child: Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                // Nom, note, etc.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          if (isPremium) ...[
                            const SizedBox(width: 8),
                            Chip(
                              label: const Text(
                                'Premium',
                                style: TextStyle(
                                    color: Color(0xFF663300), fontSize: 10),
                              ),
                              backgroundColor: const Color(0xFFFFD700),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.star,
                              color: Colors.amber[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Icône poubelle
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    // TODO: Gérer la suppression du favori
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Trajet : Départ & Arrivée ---
            _buildRideInfo(
              icon: Icons.my_location,
              text: departure,
              color: primaryColor,
            ),
            // Ligne verticale
            Padding(
              padding: const EdgeInsets.only(left: 11, top: 4, bottom: 4),
              child: Container(
                height: 15,
                width: 2,
                color: Colors.grey[200],
              ),
            ),
            _buildRideInfo(
              icon: Icons.location_on,
              text: arrival,
              color: Colors.green[600]!,
            ),
            const Divider(height: 32),

            // --- Bas : Infos & Bouton ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Infos
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: Colors.grey[600], size: 14),
                        const SizedBox(width: 6),
                        Text('$date  ·  $time'),
                        const SizedBox(width: 12),
                        Icon(Icons.people, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 6),
                        Text('$seats'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${price.toInt()} MAD',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                // Bouton
                ElevatedButton(
                  onPressed: () {
                    // TODO: Naviguer vers les détails du trajet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Voir le trajet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Petit helper pour afficher une ligne d'info (départ/arrivée)
  Widget _buildRideInfo(
      {required IconData icon, required String text, required Color color}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
