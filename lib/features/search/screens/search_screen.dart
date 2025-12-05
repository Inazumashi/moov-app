// File: lib/features/search/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/ride_provider.dart';
import 'package:moovapp/core/providers/station_provider.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/models/station_model.dart';
import 'package:moovapp/features/search/widgets/ride_result_card.dart';
import 'package:moovapp/features/search/widgets/search_filters_sheet.dart';
import 'package:moovapp/features/reservations/screens/book_ride_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // Charger les stations populaires au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StationProvider>(context, listen: false).loadPopularStations();
    });
  }

  @override
  void dispose() {
    _departureController.dispose();
    _arrivalController.dispose();
    super.dispose();
  }

  void _searchRides() {
    if (_departureController.text.isEmpty || _arrivalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir une station de départ et d\'arrivée'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    rideProvider.searchRides(
      from: _departureController.text,
      to: _arrivalController.text,
      date: _selectedDate,
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final stationProvider = Provider.of<StationProvider>(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher un trajet'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Départ
                TextField(
                  controller: _departureController,
                  decoration: InputDecoration(
                    hintText: 'Départ (ville, station, campus...)',
                    prefixIcon: const Icon(Icons.my_location),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onTap: () async {
                    final station = await _showStationSearch(
                      context,
                      stationProvider,
                    );
                    if (station != null) {
                      _departureController.text = station.name;
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Arrivée
                TextField(
                  controller: _arrivalController,
                  decoration: InputDecoration(
                    hintText: 'Arrivée (ville, station, campus...)',
                    prefixIcon: const Icon(Icons.location_on),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onTap: () async {
                    final station = await _showStationSearch(
                      context,
                      stationProvider,
                    );
                    if (station != null) {
                      _arrivalController.text = station.name;
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Date et bouton recherche
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showDatePicker,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: rideProvider.isLoading ? null : _searchRides,
                      icon: const Icon(Icons.search),
                      label: rideProvider.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Rechercher'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),

                // Filtres
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                      icon: Icon(
                        _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                        size: 16,
                      ),
                      label: Text(
                        _showFilters ? 'Masquer les filtres' : 'Filtres',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Section de filtres (expandable)
          if (_showFilters) ...[
            SearchFiltersSheet(
              onFiltersChanged: (filters) {
                // TODO: Appliquer les filtres
                print('Filtres appliqués: $filters');
              },
            ),
          ],

          // Stations populaires (avant recherche)
          if (rideProvider.searchResults.isEmpty && !rideProvider.isLoading) ...[
            _buildPopularStations(stationProvider, colors),
          ],

          // Résultats ou état de chargement
          Expanded(
            child: rideProvider.isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Recherche en cours...'),
                      ],
                    ),
                  )
                : rideProvider.error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                rideProvider.error,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _searchRides,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : rideProvider.searchResults.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search, size: 80, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Aucun trajet trouvé',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Essayez d\'autres stations ou dates',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: rideProvider.searchResults.length,
                            itemBuilder: (context, index) {
                              final ride = rideProvider.searchResults[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: RideResultCard(
                                  ride: ride,
                                  isFavorited: rideProvider.isFavorite(ride.rideId),
                                  onFavoriteTap: () {
                                    rideProvider.toggleFavorite(ride.rideId);
                                  },
                                  onViewTap: () {
                                    _showRideDetails(context, ride);
                                  },
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularStations(StationProvider provider, ColorScheme colors) {
    if (provider.popularStations.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stations populaires',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.popularStations
                .take(6)
                .map((station) => Chip(
                      label: Text(station.displayName),
                      onDeleted: () {
                        // Quick search avec cette station comme départ
                        _departureController.text = station.name;
                        _searchRides();
                      },
                      deleteIcon: const Icon(Icons.arrow_forward, size: 16),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  void _showRideDetails(BuildContext context, RideModel ride) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    
    // Format de date et heure
    String formatDate(DateTime? date) {
      if (date == null) return 'N/A';
      return '${date.day}/${date.month}/${date.year}';
    }

    String formatTime(DateTime? date) {
      if (date == null) return '';
      return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
    }

    // Utilisez `scheduleDays` pour les trajets réguliers
    String getScheduleText() {
      if (ride.scheduleDays != null && ride.scheduleDays!.isNotEmpty) {
        return 'Jours: ${ride.scheduleDays!.join(', ')}';
      }
      return '';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Détails du trajet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Conducteur'),
                subtitle: Text(ride.driverName.isNotEmpty ? ride.driverName : 'Conducteur'),
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Itinéraire'),
                // Utilisation des propriétés correctes de RideModel
                subtitle: Text('${ride.startPoint} → ${ride.endPoint}'),
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Départ'),
                subtitle: Text(
                  ride.departureTime != null
                      ? '${formatDate(ride.departureTime)} ${formatTime(ride.departureTime)}'
                      : 'Trajet régulier',
                ),
              ),
              // Si c'est un trajet régulier, afficher les jours
              if (ride.scheduleDays != null && ride.scheduleDays!.isNotEmpty) ...[
                ListTile(
                  leading: const Icon(Icons.repeat),
                  title: const Text('Jours'),
                  subtitle: Text(getScheduleText()),
                ),
              ],
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Places disponibles'),
                subtitle: Text('${ride.availableSeats}'),
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Prix'),
                subtitle: Text('${ride.pricePerSeat.toStringAsFixed(2)} DH par place'),
              ),
              if (ride.vehicleInfo != null && ride.vehicleInfo!.isNotEmpty) ...[
                ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: const Text('Véhicule'),
                  subtitle: Text(ride.vehicleInfo!),
                ),
              ],
              if (ride.notes != null && ride.notes!.isNotEmpty) ...[
                ListTile(
                  leading: const Icon(Icons.note),
                  title: const Text('Notes'),
                  subtitle: Text(ride.notes!),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Naviguer vers l'écran de réservation
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookRideScreen(ride: ride),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Réserver ce trajet'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<StationModel?> _showStationSearch(BuildContext context, StationProvider provider) async {
    final station = await showSearch<StationModel?>(
      context: context,
      delegate: _StationSearchDelegate(provider),
    );
    return station;
  }
}

class _StationSearchDelegate extends SearchDelegate<StationModel?> {
  final StationProvider stationProvider;

  _StationSearchDelegate(this.stationProvider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
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
      return ListView(
        children: stationProvider.popularStations
            .map((station) => ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(station.displayName),
                  subtitle: Text(station.city),
                  onTap: () {
                    close(context, station);
                  },
                ))
            .toList(),
      );
    }

    // Déclencher la recherche
    stationProvider.searchStations(query);

    return Consumer<StationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: provider.searchResults
              .map((station) => ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(station.displayName),
                    subtitle: Text(station.city),
                    onTap: () {
                      close(context, station);
                    },
                  ))
              .toList(),
        );
      },
    );
  }

  @override
  String get searchFieldLabel => 'Rechercher une station...';
}