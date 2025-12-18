// File: lib/features/ride/screens/my_rides_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/ride_provider.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/service/reservation_service.dart';
import 'package:moovapp/core/models/reservation.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RideProvider>(context, listen: false).loadMyPublishedRides();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);

    if (rideProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (rideProvider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Erreur: ${rideProvider.error}'),
            ElevatedButton(
              onPressed: () => rideProvider.loadMyPublishedRides(),
              child: Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes trajets publiés'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => rideProvider.loadMyPublishedRides(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/publish').then((_) {
            rideProvider.loadMyPublishedRides();
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Publier'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: rideProvider.myPublishedRides.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucun trajet publié'),
                  Text('Publiez votre premier trajet !',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/publish').then((_) {
                        rideProvider.loadMyPublishedRides();
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Publier un trajet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => rideProvider.loadMyPublishedRides(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: rideProvider.myPublishedRides.length,
                itemBuilder: (context, index) {
                  final ride = rideProvider.myPublishedRides[index];
                  return _buildRideCard(context, ride, rideProvider);
                },
              ),
            ),
    );
  }

  Future<void> _openReservationsModal(
      BuildContext context, RideModel ride) async {
    final api = ApiService();
    final service = ReservationService(api);

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>>(
          future:
              service.getReservationsForRide(int.tryParse(ride.rideId) ?? 0),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const AlertDialog(
                  content: SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator())));
            }

            if (!snapshot.hasData || snapshot.data!['success'] != true) {
              final error = snapshot.data?['error'] ?? 'Erreur chargement';
              return AlertDialog(
                title: const Text('Réservations'),
                content: Text('Erreur: $error'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer'))
                ],
              );
            }

            final data = snapshot.data!['data'];
            final List<dynamic> items = data['reservations'] ?? [];
            final reservations =
                items.map((j) => Reservation.fromJson(j)).toList();

            return AlertDialog(
              title: Text('Réservations (${reservations.length})'),
              content: SizedBox(
                width: double.maxFinite,
                child: reservations.isEmpty
                    ? const Text('Aucune réservation')
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: reservations.length,
                        itemBuilder: (context, index) {
                          final r = reservations[index];
                          return ListTile(
                            title: Text(
                                'Réservation #${r.id} - ${r.seatsReserved} place(s)'),
                            subtitle:
                                Text('${r.formattedDate} • ${r.formattedTime}'),
                            trailing: r.status.toLowerCase() == 'completed'
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : ElevatedButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      final res =
                                          await service.markCompleted(r.id);
                                      if (res['success'] == true) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Marqué comme terminé'),
                                                backgroundColor: Colors.green));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Erreur: ${res['error']}')));
                                      }
                                      // reopen to refresh
                                      _openReservationsModal(context, ride);
                                    },
                                    child: const Text('Terminer'),
                                  ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'))
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRideCard(
      BuildContext context, RideModel ride, RideProvider provider) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ride.startPoint,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.place,
                              color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ride.endPoint,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteRide(context, ride.rideId, provider);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Supprimer'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Affichage des informations de date/heure avec gestion du null
            Row(
              children: [
                const Icon(Icons.event, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  ride.departureTime != null
                      ? _formatDate(ride.departureTime!)
                      : 'Date non définie',
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  ride.departureTime != null
                      ? _formatTime(ride.departureTime!)
                      : 'Heure non définie',
                ),
              ],
            ),

            // Affichage pour les trajets réguliers (scheduleDays)
            if (ride.isRegularRide &&
                ride.scheduleDays != null &&
                ride.scheduleDays!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.repeat, size: 16, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text(
                      ride.scheduleDays!.join(', '),
                      style: const TextStyle(color: Colors.purple),
                    ),
                  ],
                ),
              ),

            // Si timeSlot est disponible pour les trajets réguliers
            if (ride.isRegularRide && ride.timeSlot != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(ride.timeSlot!),
                  ],
                ),
              ),

            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: Colors.purple),
                const SizedBox(width: 8),
                Text('${ride.availableSeats} places'),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text('${ride.pricePerSeat} DH/place'),
              ],
            ),
            if (ride.vehicleInfo != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.directions_car,
                      size: 16, color: Colors.brown),
                  const SizedBox(width: 8),
                  Text(ride.vehicleInfo!),
                ],
              ),
            ],
            const SizedBox(height: 8),
            if (ride.isRegularRide) ...[
              Chip(
                label: const Text('Trajet régulier'),
                backgroundColor: Colors.blue[50],
                labelStyle: TextStyle(color: Colors.blue[800]),
              ),
            ],
            const SizedBox(height: 12),
            // Bouton Voir réservations
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.list),
                label: const Text('Voir les réservations'),
                onPressed: () => _openReservationsModal(context, ride),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E3A8A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editRide(BuildContext context, RideModel ride) {
    // TODO: Implémenter l'écran d'édition
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Édition du trajet - À implémenter')),
    );
  }

  void _deleteRide(BuildContext context, String rideId, RideProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le trajet'),
        content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce trajet ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteRide(rideId);
              if (success) {
                // Update UI immediately
                provider.removeLocalRide(rideId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Trajet supprimé avec succès'),
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
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}
