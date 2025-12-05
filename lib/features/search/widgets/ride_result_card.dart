// File: lib/features/search/widgets/ride_result_card.dart
import 'package:flutter/material.dart';
import 'package:moovapp/core/models/ride_model.dart';

class RideResultCard extends StatelessWidget {
  final RideModel ride;
  final bool isFavorited;
  final VoidCallback onFavoriteTap;
  final VoidCallback onViewTap;

  const RideResultCard({
    super.key,
    required this.ride,
    required this.isFavorited,
    required this.onFavoriteTap,
    required this.onViewTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Formater la date
    String formatDate(DateTime? date) {
      if (date == null) return 'Trajet régulier';
      return '${date.day}/${date.month}/${date.year}';
    }

    // Formater l'heure
    String formatTime(DateTime? date) {
      if (date == null) return '';
      return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête : Conducteur et favori
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primary,
                  radius: 20,
                  child: Text(
                    ride.driverName.isNotEmpty ? ride.driverName[0] : 'C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.driverName.isNotEmpty ? ride.driverName : 'Conducteur',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            ride.driverRating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? Colors.red : colors.onSurface,
                  ),
                  onPressed: onFavoriteTap,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Itinéraire
            Row(
              children: [
                Icon(Icons.my_location, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ride.startPoint,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 11, top: 4, bottom: 4),
              child: Container(
                height: 15,
                width: 2,
                color: colors.outline,
              ),
            ),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ride.endPoint,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Infos complémentaires
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: colors.onSurface.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(
                  ride.departureTime != null
                      ? '${formatDate(ride.departureTime)} ${formatTime(ride.departureTime)}'
                      : 'Trajet régulier',
                  style: TextStyle(color: colors.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(width: 16),
                Icon(Icons.people, size: 16, color: colors.onSurface.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(
                  '${ride.availableSeats} places',
                  style: TextStyle(color: colors.onSurface.withOpacity(0.7)),
                ),
              ],
            ),

            // Pour les trajets réguliers, afficher les jours
            if (ride.scheduleDays != null && ride.scheduleDays!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.repeat, size: 16, color: colors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    ride.scheduleDays!.join(', '),
                    style: TextStyle(color: colors.secondary),
                  ),
                ],
              ),
            ],

            const Divider(height: 20),

            // Pied de carte : Prix et bouton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${ride.pricePerSeat.toStringAsFixed(0)} DH',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                ElevatedButton(
                  onPressed: onViewTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Voir détails'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}