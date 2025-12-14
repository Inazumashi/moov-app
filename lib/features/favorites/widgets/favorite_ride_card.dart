// lib/features/favorites/widgets/favorite_ride_card.dart - VERSION CORRIGÉE
import 'package:flutter/material.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/ride_provider.dart';

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
    final ColorScheme colors = Theme.of(context).colorScheme;
    
    // ✅ CORRECTION : Vérifier si le trajet est favori
    final rideProvider = Provider.of<RideProvider>(context);
    final isFavorite = rideProvider.isFavorite(ride.rideId);

    return Card(
      elevation: 2,
      shadowColor: Colors.grey.shade100,
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
            // --- En-tête avec conducteur et icône favoris ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Initiale du nom
                CircleAvatar(
                  backgroundColor: primaryColor,
                  radius: 20,
                  child: Text(
                    _getDriverInitial(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Nom et note
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getDriverName(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (ride.driverIsPremium) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Premium',
                                style: TextStyle(
                                  color: Color(0xFF663300),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            ride.driverRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // ✅ CORRECTION : Icône favoris avec état correct
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.pink : Colors.grey,
                    size: 28,
                  ),
                  onPressed: () async {
                    if (isFavorite) {
                      // Supprimer des favoris
                      final success = await rideProvider.removeFromFavorites(ride.rideId);
                      if (!context.mounted) return;
                      
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Retiré des favoris'),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: ${rideProvider.error}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      // Ajouter aux favoris
                      final success = await rideProvider.addToFavorites(ride.rideId);
                      if (!context.mounted) return;
                      
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ajouté aux favoris'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: ${rideProvider.error}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Itinéraire ---
            _buildRideInfo(
              icon: Icons.my_location,
              text: ride.startPoint,
              color: primaryColor,
            ),
            
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

            // Trajets réguliers
            if (ride.scheduleDays != null && ride.scheduleDays!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.repeat, size: 16, color: colors.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ride.scheduleDays!.join(', '),
                        style: TextStyle(
                          color: colors.secondary,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            const Divider(height: 32),

            // --- Bas : Infos et boutons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey[600], size: 14),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(ride.departureTime),
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.grey[600], size: 14),
                          const SizedBox(width: 6),
                          Text(
                            _formatTime(ride.departureTime),
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.people, color: Colors.grey[600], size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${ride.availableSeats} places',
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${ride.pricePerSeat.toInt()} MAD',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Boutons
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: onView,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Réserver'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Retirer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideInfo({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date non définie';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime? date) {
    if (date == null) return 'Heure non définie';
    return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  String _getDriverName() {
    if (ride.driverName.isNotEmpty) return ride.driverName;
    return 'Conducteur';
  }

  String _getDriverInitial() {
    final name = _getDriverName();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}