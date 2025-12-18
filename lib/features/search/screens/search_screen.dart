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
  Map<String, dynamic> _currentFilters = {};

  // Stocke les objets StationModel pour conserver les IDs
  StationModel? _selectedDepartureStation;
  StationModel? _selectedArrivalStation;

  @override
  void initState() {
    super.initState();
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
    // Validation basée sur les objets StationModel
    if (_selectedDepartureStation == null || _selectedArrivalStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une station de départ et d\'arrivée à partir des suggestions.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validation : stations différentes
    if (_selectedDepartureStation!.id == _selectedArrivalStation!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La station de départ et d\'arrivée doivent être différentes.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    
    // Appel du Provider avec les IDs
    rideProvider.searchRides(
      departureId: _selectedDepartureStation!.id,
      arrivalId: _selectedArrivalStation!.id,
      date: _selectedDate,
      minSeats: _currentFilters['minSeats'],
      maxPrice: _currentFilters['maxPrice'],
      minRating: _currentFilters['minRating'],
      verifiedOnly: _currentFilters['onlyPremium'], // Assuming onlyPremium maps to verifiedOnly in provider
      availableOnly: _currentFilters['onlyAvailable'],
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

  Future<StationModel?> _showStationSearch(
    BuildContext context, 
    StationProvider provider,
    bool isDeparture
  ) async {
    final station = await showSearch<StationModel?>(
      context: context,
      delegate: _StationSearchDelegate(provider),
    );
    
    if (station != null) {
      setState(() {
        if (isDeparture) {
          _selectedDepartureStation = station;
          _departureController.text = station.displayName;
        } else {
          _selectedArrivalStation = station;
          _arrivalController.text = station.displayName;
        }
      });
    }
    return station;
  }

  void _selectPopularStation(StationModel station, bool forDeparture) {
    setState(() {
      if (forDeparture) {
        _selectedDepartureStation = station;
        _departureController.text = station.displayName;
      } else {
        _selectedArrivalStation = station;
        _arrivalController.text = station.displayName;
      }
    });
  }

  void _showRideDetails(BuildContext context, RideModel ride) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookRideScreen(
          ride: ride,
          onBookingComplete: () {
            // Callback après réservation réussie
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Réservation confirmée avec succès !'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  // 🚀 MÉTHODE CORRIGÉE : Utilise clearSearchResults() qui est maintenant disponible
  void _clearSearch() {
    setState(() {
      _selectedDepartureStation = null;
      _selectedArrivalStation = null;
      _departureController.clear();
      _arrivalController.clear();
      _selectedDate = DateTime.now();
    });
    
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    rideProvider.clearSearchResults(); // ✅ Maintenant disponible grâce à la correction 1
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
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearSearch,
            tooltip: 'Effacer la recherche',
          ),
        ],
      ),
      body: Column(
        children: [
          // Section de recherche
          _buildSearchSection(context, stationProvider, colors),
          
          // Section de résultats
          Expanded(
            child: _buildResultsSection(context, rideProvider, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, StationProvider provider, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: colors.surfaceVariant.withOpacity(0.1),
      child: Column(
        children: [
          // Champs de recherche
          _buildSearchFields(context, provider, colors),
          const SizedBox(height: 16),
          
          // Contrôles de recherche
          _buildSearchControls(context, colors),
          
          // Stations populaires
          if (provider.popularStations.isNotEmpty) 
            _buildPopularStations(provider, colors),
        ],
      ),
    );
  }

  Widget _buildSearchFields(BuildContext context, StationProvider provider, ColorScheme colors) {
    return Column(
      children: [
        // Champ de départ
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
            suffixIcon: _departureController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedDepartureStation = null;
                        _departureController.clear();
                      });
                    },
                  )
                : null,
          ),
          readOnly: true,
          onTap: () async {
            await _showStationSearch(context, provider, true);
          },
        ),
        const SizedBox(height: 12),

        // Champ d'arrivée
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
            suffixIcon: _arrivalController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedArrivalStation = null;
                        _arrivalController.clear();
                      });
                    },
                  )
                : null,
          ),
          readOnly: true,
          onTap: () async {
            await _showStationSearch(context, provider, false);
          },
        ),
      ],
    );
  }

  Widget _buildSearchControls(BuildContext context, ColorScheme colors) {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);

    return Column(
      children: [
        // Date et bouton de recherche
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
              icon: rideProvider.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search),
              label: Text(rideProvider.isLoading ? 'Recherche...' : 'Rechercher'),
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

        // Bouton filtres
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

        // Section de filtres (expandable)
        if (_showFilters) ...[
          SearchFiltersSheet(
            onFiltersChanged: (filters) {
              setState(() {
                _currentFilters = filters;
              });
              // Si nous avons déjà une recherche en cours (stations sélectionnées), on relance
              if (_selectedDepartureStation != null && _selectedArrivalStation != null) {
                _searchRides();
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPopularStations(StationProvider provider, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
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
              .map((station) => ActionChip(
                    avatar: const Icon(Icons.location_on, size: 16),
                    label: Text(station.displayName),
                    onPressed: () => _selectPopularStation(station, true),
                    backgroundColor: colors.primaryContainer,
                    labelStyle: TextStyle(color: colors.onPrimaryContainer),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildResultsSection(BuildContext context, RideProvider rideProvider, ColorScheme colors) {
    if (rideProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Recherche en cours...'),
          ],
        ),
      );
    }

    if (rideProvider.error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
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
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _searchRides,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (rideProvider.searchResults.isEmpty) {
      return SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, size: 80, color: colors.onSurface.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'Aucun trajet trouvé',
                  style: TextStyle(
                    fontSize: 18,
                    color: colors.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Essayez d\'autres stations ou dates',
                  style: TextStyle(
                    color: colors.onSurface.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Nouvelle recherche'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
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
    );
  }
}

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

    // Déclencher la recherche
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

  // 🚀 MÉTHODE CORRIGÉE DANS _StationSearchDelegate
  Widget _buildPopularStationsList(BuildContext context) {
    // ✅ Utilisation de this.stationProvider et le contexte passé en paramètre
    final popularStations = this.stationProvider.popularStations;
    final colorScheme = Theme.of(context).colorScheme;

    if (popularStations.isEmpty) {
      return const Center(child: Text('Chargement des stations populaires...'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Stations populaires',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        // L'utilisation d'Expanded ici est acceptable si l'écran de recherche 
        // a des contraintes (ce qui est le cas dans le SearchDelegate).
        Expanded(
          child: ListView(
            children: popularStations
                .map((station) => ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(station.displayName),
                      subtitle: Text(station.city),
                      // isPopular est maintenant défini dans StationModel
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