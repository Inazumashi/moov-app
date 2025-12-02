import 'package:flutter/material.dart';
import 'package:moovapp/core/models/ride_model.dart';

class FavoriteRideCard extends StatelessWidget {
  final RideModel ride;
  final VoidCallback onRemove;
  final VoidCallback onView;

  const FavoriteRideCard({
    super.key,
    required this.ride,
    required this.onRemove,
    required this.onView,
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
                    ride.driverName.isNotEmpty ? ride.driverName[0] : '?',
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
                            ride.driverName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          if (ride.driverIsPremium) ...[
                            const SizedBox(width: 8),
                            const Chip(
                              label: Text(
                                'Premium',
                                style: TextStyle(
                                    color: Color(0xFF663300), fontSize: 10),
                              ),
                              backgroundColor: Color(0xFFFFD700),
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
                            ride.driverRating.toStringAsFixed(1),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
<<<<<<< HEAD
                // Icône poubelle
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onRemove,
                ),
=======
>>>>>>> cef8c6aabcde6ab6828e1abee46d73d006194ee9
              ],
            ),
            const SizedBox(height: 16),

            // --- Trajet : Départ & Arrivée ---
            _buildRideInfo(
              icon: Icons.my_location,
              text: ride.startPoint,
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
              text: ride.endPoint,
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
                        Text('${_formatDate(ride.departureTime)}  ·  ${_formatTime(ride.departureTime)}'),
                        const SizedBox(width: 12),
                        Icon(Icons.people, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 6),
                        Text('${ride.availableSeats}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${ride.pricePerSeat.toInt()} MAD',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                // Bouton
                ElevatedButton(
                  onPressed: onView,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}