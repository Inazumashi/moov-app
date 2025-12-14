// File: lib/features/ride/screens/publish_ride_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/ride_provider.dart';
import 'package:moovapp/core/providers/auth_provider.dart';
import 'package:moovapp/core/providers/station_provider.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/models/station_model.dart';

class PublishRideScreen extends StatefulWidget {
  const PublishRideScreen({super.key});

  @override
  _PublishRideScreenState createState() => _PublishRideScreenState();
}

class _PublishRideScreenState extends State<PublishRideScreen> {
  final _formKey = GlobalKey<FormState>();

  // ✅ CORRECTION : Stocker les objets StationModel complets
  StationModel? _departureStation;
  StationModel? _arrivalStation;
  
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();

  DateTime _departureTime = DateTime.now();
  TimeOfDay _departureTimeOfDay = TimeOfDay.now();
  int _availableSeats = 1;
  double _pricePerSeat = 0.0;
  String? _vehicleInfo;
  String? _notes;
  bool _isRegularRide = false;

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    super.dispose();
  }

  // ✅ Méthode pour afficher la recherche de station
  Future<void> _showStationSearch(BuildContext context, bool isDeparture) async {
    final stationProvider = Provider.of<StationProvider>(context, listen: false);
    
    final station = await showSearch<StationModel?>(
      context: context,
      delegate: _StationSearchDelegate(stationProvider),
    );
    
    if (station != null) {
      setState(() {
        if (isDeparture) {
          _departureStation = station;
          _departureController.text = station.displayName;
          print('🔍 Station départ sélectionnée: ${station.name} (ID: ${station.id})');
        } else {
          _arrivalStation = station;
          _arrivalController.text = station.displayName;
          print('🔍 Station arrivée sélectionnée: ${station.name} (ID: ${station.id})');
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _departureTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    // ✅ VALIDATION : Vérifier que les stations sont sélectionnées
    if (_departureStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une station de départ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_arrivalStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une station d\'arrivée'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validation des stations différentes
    if (_departureStation!.id == _arrivalStation!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les stations de départ et d\'arrivée doivent être différentes'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous devez être connecté pour publier un trajet'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('📤 Début publication du trajet...');
      print('   Départ: ${_departureStation!.displayName}');
      print('   Arrivée: ${_arrivalStation!.displayName}');

      // ✅ CORRECTION : Utiliser les IDs des stations
      final ride = RideModel(
        rideId: '',
        driverId: currentUser.uid,
        driverName: currentUser.fullName,
        driverRating: currentUser.averageRating,
        driverIsPremium: currentUser.isPremium,
        startPoint: _departureStation!.name,  // Pour l'affichage
        endPoint: _arrivalStation!.name,      // Pour l'affichage
        departureStationId: _departureStation!.id,  // ✅ ID pour l'API
        arrivalStationId: _arrivalStation!.id,      // ✅ ID pour l'API
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
          const SnackBar(
            content: Text('🎉 Trajet publié avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: ${rideProvider.error}'),
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
        title: const Text('Publier un trajet'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nouveau trajet',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // ✅ CORRECTION : Point de départ avec recherche
              TextField(
                controller: _departureController,
                decoration: InputDecoration(
                  labelText: 'Point de départ',
                  prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                  border: const OutlineInputBorder(),
                  hintText: 'Rechercher une station...',
                  suffixIcon: _departureStation != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _departureStation = null;
                              _departureController.clear();
                            });
                          },
                        )
                      : null,
                ),
                readOnly: true,
                onTap: () => _showStationSearch(context, true),
              ),
              const SizedBox(height: 16),

              // ✅ CORRECTION : Point d'arrivée avec recherche
              TextField(
                controller: _arrivalController,
                decoration: InputDecoration(
                  labelText: 'Point d\'arrivée',
                  prefixIcon: const Icon(Icons.place, color: Colors.green),
                  border: const OutlineInputBorder(),
                  hintText: 'Rechercher une station...',
                  suffixIcon: _arrivalStation != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _arrivalStation = null;
                              _arrivalController.clear();
                            });
                          },
                        )
                      : null,
                ),
                readOnly: true,
                onTap: () => _showStationSearch(context, false),
              ),
              const SizedBox(height: 16),

              // Date et heure de départ
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Date de départ',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      controller: TextEditingController(
                        text:
                            '${_departureTime.day}/${_departureTime.month}/${_departureTime.year}',
                      ),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
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
              const SizedBox(height: 16),

              // Nombre de places
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nombre de places disponibles',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                  hintText: '1-8',
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
              const SizedBox(height: 16),

              // Prix par place
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Prix par place (DH)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  hintText: 'Ex: 45',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
              const SizedBox(height: 16),

              // Véhicule
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Véhicule (optionnel)',
                  prefixIcon: Icon(Icons.directions_car),
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Renault Clio - Blanc',
                ),
                onSaved: (value) => _vehicleInfo = value,
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Bagages légers uniquement',
                ),
                maxLines: 3,
                onSaved: (value) => _notes = value,
              ),
              const SizedBox(height: 16),

              // Trajet régulier
              SwitchListTile(
                title: const Text('Trajet régulier'),
                subtitle: const Text('Ce trajet est effectué régulièrement'),
                value: _isRegularRide,
                onChanged: (value) {
                  setState(() {
                    _isRegularRide = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Bouton de publication
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: rideProvider.isLoading
                      ? null
                      : () => _publishRide(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: rideProvider.isLoading
                      ? const Row(
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
                      : const Row(
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

// ✅ SearchDelegate pour la recherche de stations
class _StationSearchDelegate extends SearchDelegate<StationModel?> {
  final StationProvider stationProvider;

  _StationSearchDelegate(this.stationProvider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSuggestionsWidget(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSuggestionsWidget(context);
  }

  Widget _buildSuggestionsWidget(BuildContext context) {
    if (query.isEmpty) {
      return _buildPopularStationsList(context);
    }

    stationProvider.searchStations(query);

    return Consumer<StationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.searchResults.isEmpty) {
          return const Center(
            child: Text('Aucune station trouvée'),
          );
        }

        return ListView(
          children: provider.searchResults
              .map((station) => ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(station.displayName),
                    subtitle: Text(station.city),
                    trailing: station.isPopular
                        ? const Icon(Icons.star, color: Colors.amber, size: 16)
                        : null,
                    onTap: () {
                      close(context, station);
                    },
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildPopularStationsList(BuildContext context) {
    final popularStations = stationProvider.popularStations;

    if (popularStations.isEmpty) {
      return const Center(child: Text('Chargement des stations populaires...'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Stations populaires',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView(
            children: popularStations
                .map((station) => ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(station.displayName),
                      subtitle: Text(station.city),
                      trailing: station.isPopular
                          ? const Icon(Icons.star, color: Colors.amber, size: 16)
                          : null,
                      onTap: () {
                        close(context, station);
                      },
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  @override
  String get searchFieldLabel => 'Rechercher une station...';
}