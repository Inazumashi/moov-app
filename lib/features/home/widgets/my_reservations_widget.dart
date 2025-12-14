import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/reservation_provider.dart';
import 'package:moovapp/widgets/reservation_card.dart';

class MyReservationsWidget extends StatefulWidget {
  const MyReservationsWidget({super.key});

  @override
  State<MyReservationsWidget> createState() => _MyReservationsWidgetState();
}

class _MyReservationsWidgetState extends State<MyReservationsWidget> {
  @override
  void initState() {
    super.initState();
    // Charger les réservations de l'utilisateur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ReservationProvider>(context, listen: false);
      provider.loadReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReservationProvider>(context);

    if (provider.isLoading) {
      return Card(
        elevation: 0.5,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (provider.error.isNotEmpty) {
      return Card(
        elevation: 0.5,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child:
              Text(provider.error, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final reservations = provider.filteredReservations;

    if (reservations.isEmpty) {
      return Card(
        elevation: 0.5,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Column(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Aucune réservation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Recherchez un trajet pour commencer votre voyage',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: reservations.map((r) {
        return ReservationCard(
          reservation: r,
          onCancel: r.status == 'confirmed'
              ? () async {
                  final prov =
                      Provider.of<ReservationProvider>(context, listen: false);
                  await prov.cancelReservation(r.id);
                }
              : null,
        );
      }).toList(),
    );
  }
}
