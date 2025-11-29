// File: lib/features/ride/screens/my_rides_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/ride_provider.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/features/ride/screens/publish_ride_screen.dart';
class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({Key? key}) : super(key: key);

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
        title: Text('Mes trajets publiés'),
        backgroundColor: Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<RideProvider>(context, listen: false).loadMyPublishedRides();
            },
          ),
        ],
      ),
      body: Consumer<RideProvider>(
        builder: (context, rideProvider, child) {
          if (rideProvider.isLoading && rideProvider.myPublishedRides.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (rideProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Erreur de chargement'),
                  SizedBox(height: 8),
                  Text(rideProvider.error),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => rideProvider.loadMyPublishedRides(),
                    child: Text('Réessayer'),
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
                  SizedBox(height: 16),
                  Text(
                    'Aucun trajet publié',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Publiez votre premier trajet !',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PublishRideScreen(),
                        ),
                      );
                    },
                    child: Text('Publier un trajet'),
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
              padding: EdgeInsets.all(16),
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
              builder: (context) => PublishRideScreen(),
            ),
          );
        },
        backgroundColor: Color(0xFF1E3A8A),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRideCard(BuildContext context, RideModel ride, RideProvider provider) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
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
                          Icon(Icons.location_on, color: Colors.red, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ride.startPoint,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.place, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ride.endPoint,
                              style: TextStyle(fontWeight: FontWeight.bold),
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
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
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
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.event, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Text('${_formatDate(ride.departureTime)}'),
                SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.orange),
                SizedBox(width: 8),
                Text('${_formatTime(ride.departureTime)}'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.purple),
                SizedBox(width: 8),
                Text('${ride.availableSeats} places'),
                SizedBox(width: 16),
                Icon(Icons.attach_money, size: 16, color: Colors.green),
                SizedBox(width: 8),
                Text('${ride.pricePerSeat} DH/place'),
              ],
            ),
            if (ride.vehicleInfo != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.directions_car, size: 16, color: Colors.brown),
                  SizedBox(width: 8),
                  Text(ride.vehicleInfo!),
                ],
              ),
            ],
            SizedBox(height: 8),
            if (ride.isRegularRide) ...[
              Chip(
                label: Text('Trajet régulier'),
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
      SnackBar(content: Text('Édition du trajet - À implémenter')),
    );
  }

  void _deleteRide(BuildContext context, String rideId, RideProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le trajet'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce trajet ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteRide(rideId);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
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
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
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