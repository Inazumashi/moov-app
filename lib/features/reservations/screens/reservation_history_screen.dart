// File: lib/features/reservations/screens/reservation_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/models/reservation_model.dart';
import 'package:moovapp/core/providers/reservation_provider.dart';
import 'package:moovapp/features/reservations/widgets/reservation_list.dart';
import 'package:moovapp/features/reservations/widgets/reservation_filter.dart';

class ReservationHistoryScreen extends StatefulWidget {
  const ReservationHistoryScreen({Key? key}) : super(key: key);

  @override
  _ReservationHistoryScreenState createState() => _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState extends State<ReservationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReservationProvider>(context, listen: false).loadReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des Réservations'),
        backgroundColor: Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ReservationProvider>(context, listen: false).loadReservations();
            },
          ),
        ],
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, reservationProvider, child) {
          if (reservationProvider.isLoading && reservationProvider.reservations.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (reservationProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Erreur de chargement'),
                  SizedBox(height: 8),
                  Text(reservationProvider.error),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      reservationProvider.loadReservations();
                    },
                    child: Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filtres
              ReservationFilter(
                currentFilter: reservationProvider.filterStatus,
                onFilterChanged: (status) {
                  reservationProvider.setFilter(status);
                },
                stats: reservationProvider.reservationStats,
              ),

              // Liste des réservations
              Expanded(
                child: ReservationList(
                  reservations: reservationProvider.filteredReservations,
                  onCancelReservation: (reservationId) {
                    _showCancelDialog(context, reservationId, reservationProvider);
                  },
                  onTapReservation: (reservation) {
                    _showReservationDetails(context, reservation);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCancelDialog(BuildContext context, int reservationId, ReservationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Annuler la réservation'),
        content: Text('Êtes-vous sûr de vouloir annuler cette réservation ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Non', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.cancelReservation(reservationId);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Réservation annulée avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de l\'annulation: ${provider.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Oui, annuler', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showReservationDetails(BuildContext context, Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de la réservation'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Trajet: ${reservation.ride?.startPoint} → ${reservation.ride?.endPoint}'),
              SizedBox(height: 8),
              Text('Date: ${reservation.formattedDate}'),
              SizedBox(height: 8),
              Text('Heure: ${reservation.formattedTime}'),
              SizedBox(height: 8),
              Text('Places: ${reservation.seatsReserved}'),
              SizedBox(height: 8),
              Text('Prix total: ${reservation.totalPrice} DH'),
              SizedBox(height: 8),
              Text('Statut: ${reservation.status}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }
}