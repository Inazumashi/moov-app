import 'package:flutter/material.dart';
import 'package:moovapp/core/providers/station_provider.dart';
import 'package:provider/provider.dart';

class PublishRideForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController departureController;
  final TextEditingController arrivalController;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final TextEditingController seatsController;
  final TextEditingController priceController;
  final TextEditingController vehicleController;
  final TextEditingController notesController;
  final bool isRegularRide;
  final ValueChanged<bool> onRegularRideChanged;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;
  final ValueChanged<String>? onDepartureChanged;
  final ValueChanged<String>? onArrivalChanged;

  const PublishRideForm({
    Key? key,
    required this.formKey,
    required this.departureController,
    required this.arrivalController,
    required this.dateController,
    required this.timeController,
    required this.seatsController,
    required this.priceController,
    required this.vehicleController,
    required this.notesController,
    required this.isRegularRide,
    required this.onRegularRideChanged,
    required this.onSelectDate,
    required this.onSelectTime,
    this.onDepartureChanged,
    this.onArrivalChanged,
  }) : super(key: key);

  @override
  _PublishRideFormState createState() => _PublishRideFormState();
}

class _PublishRideFormState extends State<PublishRideForm> {
  late FocusNode _departureFocusNode;
  late FocusNode _arrivalFocusNode;

  @override
  void initState() {
    super.initState();
    _departureFocusNode = FocusNode();
    _arrivalFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _departureFocusNode.dispose();
    _arrivalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stationProvider = Provider.of<StationProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Station de départ
        TextFormField(
          controller: widget.departureController,
          focusNode: _departureFocusNode,
          decoration: InputDecoration(
            labelText: 'Station de départ *',
            hintText: 'Sélectionnez une station...',
            prefixIcon: Icon(Icons.location_on, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () => _showStationSearch(context, true),
            ),
          ),
          readOnly: true,
          onTap: () => _showStationSearch(context, true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner une station de départ';
            }
            return null;
          },
        ),

        SizedBox(height: 16),

        // Station d'arrivée
        TextFormField(
          controller: widget.arrivalController,
          focusNode: _arrivalFocusNode,
          decoration: InputDecoration(
            labelText: 'Station d\'arrivée *',
            hintText: 'Sélectionnez une station...',
            prefixIcon: Icon(Icons.location_on, color: Colors.red),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () => _showStationSearch(context, false),
            ),
          ),
          readOnly: true,
          onTap: () => _showStationSearch(context, false),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner une station d\'arrivée';
            }
            if (widget.departureController.text.isNotEmpty &&
                widget.departureController.text == value) {
              return 'La station d\'arrivée doit être différente de la station de départ';
            }
            return null;
          },
        ),

        SizedBox(height: 16),

        // Date et heure
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.dateController,
                decoration: InputDecoration(
                  labelText: 'Date *',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                readOnly: true,
                onTap: widget.onSelectDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une date';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: widget.timeController,
                decoration: InputDecoration(
                  labelText: 'Heure *',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                readOnly: true,
                onTap: widget.onSelectTime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une heure';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 16),

        // Places disponibles
        TextFormField(
          controller: widget.seatsController,
          decoration: InputDecoration(
            labelText: 'Places disponibles *',
            hintText: '1 à 10',
            prefixIcon: Icon(Icons.people),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer le nombre de places';
            }
            final seats = int.tryParse(value);
            if (seats == null || seats < 1 || seats > 10) {
              return 'Nombre de places invalide (1-10)';
            }
            return null;
          },
        ),

        SizedBox(height: 16),

        // Prix par place
        TextFormField(
          controller: widget.priceController,
          decoration: InputDecoration(
            labelText: 'Prix par place (DH) *',
            hintText: 'Ex: 20',
            prefixIcon: Icon(Icons.attach_money),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer le prix';
            }
            final price = double.tryParse(value);
            if (price == null || price <= 0) {
              return 'Prix invalide';
            }
            return null;
          },
        ),

        SizedBox(height: 16),

        // Trajet régulier
        SwitchListTile(
          title: Text('Trajet régulier'),
          subtitle: Text('Même trajet plusieurs fois par semaine'),
          value: widget.isRegularRide,
          onChanged: widget.onRegularRideChanged,
          secondary: Icon(Icons.repeat),
        ),

        SizedBox(height: 16),

        // Véhicule (optionnel)
        TextFormField(
          controller: widget.vehicleController,
          decoration: InputDecoration(
            labelText: 'Véhicule (optionnel)',
            hintText: 'Ex: Peugeot 208, Renault Clio...',
            prefixIcon: Icon(Icons.directions_car),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        SizedBox(height: 16),

        // Notes (optionnel)
        TextFormField(
          controller: widget.notesController,
          decoration: InputDecoration(
            labelText: 'Notes (optionnel)',
            hintText: 'Bagages, animaux, arrêts possibles...',
            prefixIcon: Icon(Icons.note),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Future<void> _showStationSearch(
      BuildContext context, bool isDeparture) async {
    final stationProvider =
        Provider.of<StationProvider>(context, listen: false);

    final result = await showSearch<String>(
      context: context,
      delegate: StationSearchDelegate(stationProvider),
      query: isDeparture
          ? widget.departureController.text
          : widget.arrivalController.text,
    );

    if (result != null && result.isNotEmpty) {
      if (isDeparture) {
        widget.departureController.text = result;
        if (widget.onDepartureChanged != null) {
          widget.onDepartureChanged!(result);
        }
      } else {
        widget.arrivalController.text = result;
        if (widget.onArrivalChanged != null) {
          widget.onArrivalChanged!(result);
        }
      }
    }
  }
}

class StationSearchDelegate extends SearchDelegate<String> {
  final StationProvider stationProvider;

  StationSearchDelegate(this.stationProvider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildStationList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length > 1) {
      stationProvider.searchStations(query);
    }
    return _buildStationList();
  }

  Widget _buildStationList() {
    if (stationProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (stationProvider.searchResults.isEmpty) {
      return Center(
        child: Text(
          query.length > 1
              ? 'Aucune station trouvée pour "$query"'
              : 'Commencez à taper pour rechercher une station...',
        ),
      );
    }

    return ListView.builder(
      itemCount: stationProvider.searchResults.length,
      itemBuilder: (context, index) {
        final station = stationProvider.searchResults[index];
        return ListTile(
          leading: Icon(
            _getStationIcon(station.type),
            color: _getStationColor(station.type),
          ),
          title: Text(station.displayName),
          subtitle: Text(station.city),
          trailing:
              station.isFavorite ? Icon(Icons.star, color: Colors.amber) : null,
          onTap: () {
            close(context, station.displayName);
          },
        );
      },
    );
  }

  IconData _getStationIcon(String type) {
    switch (type) {
      case 'university':
        return Icons.school;
      case 'train_station':
        return Icons.train;
      case 'bus_station':
        return Icons.directions_bus;
      case 'city':
        return Icons.location_city;
      default:
        return Icons.place;
    }
  }

  Color _getStationColor(String type) {
    switch (type) {
      case 'university':
        return Colors.blue;
      case 'train_station':
        return Colors.green;
      case 'bus_station':
        return Colors.orange;
      case 'city':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
