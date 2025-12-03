import 'package:flutter/material.dart';
import '../core/models/reservation_model.dart';
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(reservation.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reservation.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (reservation.ride != null) ..._buildRideInfo(reservation.ride!),
            const SizedBox(height: 8),
            Text(
                '${reservation.seatsReserved} place(s) - ${reservation.totalPrice} DH'),
            const SizedBox(height: 8),
            Text(
              'Réservé le ${reservation.formattedDate}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (reservation.status == 'confirmed' && onCancel != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
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
      Text('${ride.startPoint} → ${ride.endPoint}'),
      const SizedBox(height: 4),
      Text(
          '${_formatDate(ride.departureTime)} à ${_formatTime(ride.departureTime)}'),
    ];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
