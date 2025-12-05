// File: lib/features/reservations/screens/reservations_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/models/reservation.dart';
import 'package:moovapp/core/providers/reservation_provider.dart';
import 'package:moovapp/features/reservations/widgets/reservation_list.dart';
import 'package:moovapp/features/reservations/widgets/reservation_filter.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReservationProvider>(context, listen: false)
          .loadReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ReservationProvider>(context, listen: false)
                  .loadReservations();
            },
          ),
        ],
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, reservationProvider, child) {
          return _buildBody(reservationProvider);
        },
      ),
    );
  }

  Widget _buildBody(ReservationProvider provider) {
    if (provider.isLoading && provider.reservations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement de vos réservations...'),
          ],
        ),
      );
    }

    if (provider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                provider.error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadReservations(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (provider.reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucune réservation',
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Réservez votre premier trajet !',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filtres
        ReservationFilter(
          currentFilter: provider.filterStatus,
          onFilterChanged: (status) {
            provider.setFilter(status);
          },
          stats: provider.reservationStats,
        ),

        // Liste des réservations
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await provider.loadReservations();
            },
            child: ReservationList(
              reservations: provider.filteredReservations,
              onCancelReservation: (reservationId) {
                _showCancelDialog(context, reservationId, provider);
              },
              onTapReservation: (reservation) {
                _showReservationDetails(context, reservation);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(
      BuildContext context, int reservationId, ReservationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content:
            const Text('Êtes-vous sûr de vouloir annuler cette réservation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.cancelReservation(reservationId);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Réservation annulée avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: ${provider.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  void _showReservationDetails(BuildContext context, Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la réservation'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Trajet: ${reservation.ride?.startPoint} → ${reservation.ride?.endPoint}'),
              const SizedBox(height: 8),
              Text('Date: ${reservation.formattedDate}'),
              const SizedBox(height: 8),
              Text('Heure: ${reservation.formattedTime}'),
              const SizedBox(height: 8),
              Text('Places: ${reservation.seatsReserved}'),
              const SizedBox(height: 8),
              Text('Prix total: ${reservation.totalPrice} DH'),
              const SizedBox(height: 8),
              Text('Statut: ${reservation.status}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
