// File: lib/features/ride/screens/publish_ride_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/ride_provider.dart';
import 'package:moovapp/core/models/ride_model.dart';

class PublishRideScreen extends StatefulWidget {
  const PublishRideScreen({Key? key}) : super(key: key);

  @override
  _PublishRideScreenState createState() => _PublishRideScreenState();
}

class _PublishRideScreenState extends State<PublishRideScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _startPoint = '';
  String _endPoint = '';
  DateTime _departureTime = DateTime.now();
  TimeOfDay _departureTimeOfDay = TimeOfDay.now();
  int _availableSeats = 1;
  double _pricePerSeat = 0.0;
  String? _vehicleInfo;
  String? _notes;
  bool _isRegularRide = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _departureTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _departureTime) {
      setState(() {
        _departureTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _departureTimeOfDay.hour,
          _departureTimeOfDay.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _departureTimeOfDay,
    );
    if (picked != null && picked != _departureTimeOfDay) {
      setState(() {
        _departureTimeOfDay = picked;
        _departureTime = DateTime(
          _departureTime.year,
          _departureTime.month,
          _departureTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _publishRide(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final ride = RideModel(
        rideId: '', // Généré par le backend
        driverId: 'current_user_id', // À remplacer par l'ID réel de l'utilisateur
        driverName: 'Nom Conducteur', // À remplacer par le nom réel
        driverRating: 5.0,
        driverIsPremium: false,
        startPoint: _startPoint,
        endPoint: _endPoint,
        departureTime: _departureTime,
        availableSeats: _availableSeats,
        pricePerSeat: _pricePerSeat,
        vehicleInfo: _vehicleInfo,
        notes: _notes,
        isRegularRide: _isRegularRide,
      );

      final rideProvider = Provider.of<RideProvider>(context, listen: false);
      final success = await rideProvider.publishRide(ride);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trajet publié avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${rideProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Publier un trajet'),
        backgroundColor: Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nouveau trajet',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Point de départ
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Point de départ',
                  prefixIcon: Icon(Icons.location_on, color: Colors.red),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un point de départ';
                  }
                  return null;
                },
                onSaved: (value) => _startPoint = value!,
              ),
              SizedBox(height: 16),

              // Point d'arrivée
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Point d\'arrivée',
                  prefixIcon: Icon(Icons.place, color: Colors.green),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un point d\'arrivée';
                  }
                  return null;
                },
                onSaved: (value) => _endPoint = value!,
              ),
              SizedBox(height: 16),

              // Date et heure de départ
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Date de départ',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      controller: TextEditingController(
                        text: '${_departureTime.day}/${_departureTime.month}/${_departureTime.year}',
                      ),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Heure de départ',
                        prefixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      controller: TextEditingController(
                        text: _departureTimeOfDay.format(context),
                      ),
                      onTap: () => _selectTime(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Nombre de places
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre de places disponibles',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: _availableSeats.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir le nombre de places';
                  }
                  final seats = int.tryParse(value);
                  if (seats == null || seats < 1 || seats > 8) {
                    return 'Nombre de places invalide (1-8)';
                  }
                  return null;
                },
                onSaved: (value) => _availableSeats = int.parse(value!),
              ),
              SizedBox(height: 16),

              // Prix par place
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Prix par place (DH)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un prix';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Prix invalide';
                  }
                  return null;
                },
                onSaved: (value) => _pricePerSeat = double.parse(value!),
              ),
              SizedBox(height: 16),

              // Véhicule
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Véhicule (optionnel)',
                  prefixIcon: Icon(Icons.directions_car),
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _vehicleInfo = value,
              ),
              SizedBox(height: 16),

              // Notes
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Notes (optionnel)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) => _notes = value,
              ),
              SizedBox(height: 16),

              // Trajet régulier
              SwitchListTile(
                title: Text('Trajet régulier'),
                subtitle: Text('Ce trajet est effectué régulièrement'),
                value: _isRegularRide,
                onChanged: (value) {
                  setState(() {
                    _isRegularRide = value;
                  });
                },
              ),
              SizedBox(height: 24),

              // Bouton de publication
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: rideProvider.isLoading ? null : () => _publishRide(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: rideProvider.isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Publication en cours...'),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.publish),
                            SizedBox(width: 8),
                            Text(
                              'Publier le trajet',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}