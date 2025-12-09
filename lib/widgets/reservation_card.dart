import 'package:flutter/material.dart';
import '../core/models/reservation.dart';
import '../../../core/models/ride_model.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onCancel;

  const ReservationCard({
    super.key,
    required this.reservation,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Réservation #${reservation.id}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(reservation.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reservation.statusText.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (reservation.ride != null) ..._buildRideInfo(reservation.ride!),
            
            const SizedBox(height: 12),
            
            // Places et prix
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: colors.onSurface.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    Text(
                      '${reservation.seatsReserved} place${reservation.seatsReserved > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${reservation.totalPrice.toStringAsFixed(0)} DH',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Date de réservation
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: colors.onSurface.withOpacity(0.5)),
                const SizedBox(width: 6),
                Text(
                  'Réservé le ${reservation.formattedDate} à ${reservation.formattedTime}',
                  style: TextStyle(
                    color: colors.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            // Bouton d'annulation pour les réservations confirmées
            if (reservation.status == 'confirmed' && onCancel != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Annuler la réservation'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRideInfo(RideModel ride) {
    return [
      // Départ - Arrivée
      Row(
        children: [
          Icon(Icons.my_location, size: 16, color: Colors.green[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ride.startPoint,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      
      // Ligne verticale
      Padding(
        padding: const EdgeInsets.only(left: 7, top: 4, bottom: 4),
        child: Container(
          height: 20,
          width: 2,
          color: Colors.grey[300],
        ),
      ),
      
      // Arrivée
      Row(
        children: [
          Icon(Icons.location_on, size: 16, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ride.endPoint,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      
      const SizedBox(height: 8),
      
      // Date et heure (gestion du nullable)
      Row(
        children: [
          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            ride.departureTime != null 
              ? _formatDateTime(ride.departureTime!)
              : 'Date non définie',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
      
      // Informations du conducteur
      if (ride.driverName.isNotEmpty) ...[
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.person, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'Conducteur: ${ride.driverName}',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            if (ride.driverRating > 0) ...[
              const SizedBox(width: 12),
              Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                ride.driverRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ],
    ];
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}