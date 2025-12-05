// File: lib/features/ride/screens/my_rides_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/ride_provider.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/features/ride/screens/publish_ride_screen.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  _MyRidesScreenState createState() => _MyRidesScreenState();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes trajets publiés'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<RideProvider>(context, listen: false)
                  .loadMyPublishedRides();
            },
          ),
        ],
      ),
      body: Consumer<RideProvider>(
        builder: (context, rideProvider, child) {
          if (rideProvider.isLoading && rideProvider.myPublishedRides.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (rideProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Erreur de chargement'),
                  const SizedBox(height: 8),
                  Text(rideProvider.error),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => rideProvider.loadMyPublishedRides(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (rideProvider.myPublishedRides.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun trajet publié',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Publiez votre premier trajet !',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PublishRideScreen(),
                        ),
                      );
                    },
                    child: const Text('Publier un trajet'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await rideProvider.loadMyPublishedRides();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rideProvider.myPublishedRides.length,
              itemBuilder: (context, index) {
                final ride = rideProvider.myPublishedRides[index];
                return _buildRideCard(context, ride, rideProvider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PublishRideScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editRide(context, ride);
                    } else if (value == 'delete') {
                      _deleteRide(context, ride.rideId, provider);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
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
            
            // AFFICHAGE DE LA DATE ET HEURE (GÉRÉ NULL)
            Row(
              children: [
                const Icon(Icons.event, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                if (ride.departureTime != null)
                  Text(_formatDate(ride.departureTime!)),
                if (ride.departureTime != null) const SizedBox(width: 16),
                if (ride.departureTime != null) ...[
                  const Icon(Icons.access_time, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(_formatTime(ride.departureTime!)),
                ],
                if (ride.departureTime == null)
                  Text(
                    'Trajet régulier',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            
            // AFFICHAGE DES JOURS SI C'EST UN TRAJET RÉGULIER
            if (ride.scheduleDays != null && ride.scheduleDays!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.repeat, size: 16, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text(
                    'Jours: ${ride.scheduleDays!.join(', ')}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: Colors.purple),
                const SizedBox(width: 8),
                Text('${ride.availableSeats} places'),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text('${ride.pricePerSeat.toStringAsFixed(2)} DH/place'),
              ],
            ),
            if (ride.vehicleInfo != null && ride.vehicleInfo!.isNotEmpty) ...[
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
          ],
        ),
      ),
    );
  }

  void _editRide(BuildContext context, RideModel ride) {
    // TODO: Implémenter l'écran d'édition
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Édition du trajet: ${ride.startPoint} → ${ride.endPoint}'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
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

  // Fonctions auxiliaires qui gèrent le null
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}