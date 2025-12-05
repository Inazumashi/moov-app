// File: lib/features/reservations/widgets/reservation_list.dart
import 'package:flutter/material.dart';
import 'package:moovapp/core/models/reservation.dart';
import 'package:moovapp/core/utils/reservation_utils.dart';
import 'package:moovapp/widgets/reservation_card.dart';

class ReservationList extends StatelessWidget {
  final List<Reservation> reservations;
  final Function(int) onCancelReservation;
  final Function(Reservation) onTapReservation;

  const ReservationList({
    super.key,
    required this.reservations,
    required this.onCancelReservation,
    required this.onTapReservation,
  });

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucune réservation',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Les réservations correspondant au filtre\napparaîtront ici',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return GestureDetector(
          onTap: () => onTapReservation(reservation),
          child: ReservationCard(
            reservation: reservation,
            onCancel: ReservationUtils.canCancel(reservation)
                ? () => onCancelReservation(reservation.id)
                : null,
          ),
        );
      },
    );
  }
}
