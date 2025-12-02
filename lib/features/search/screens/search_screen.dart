import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/features/search/widgets/ride_result_card.dart';
import 'package:moovapp/core/providers/ride_provider.dart';
import 'package:moovapp/core/models/ride_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _showAd = true;

  @override
  void initState() {
    super.initState();
    // Charger les universités au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RideProvider>(context, listen: false).loadUniversities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final rideProvider = Provider.of<RideProvider>(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: colorScheme.surface,
            pinned: true,
            expandedHeight: 360.0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              background: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 90, 16, 16),
                    child: _buildSearchForm(primaryColor, rideProvider),
                  ),
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (_showAd) _buildAdCard(),

                      _buildResultsHeader(primaryColor, rideProvider),
                      const SizedBox(height: 12),

                      if (rideProvider.isLoading) ...[
                        Center(child: CircularProgressIndicator()),
                        SizedBox(height: 20),
                      ],

                      if (rideProvider.error.isNotEmpty) ...[
                        _buildErrorState(rideProvider),
                        SizedBox(height: 20),
                      ],

                      if (rideProvider.searchResults.isEmpty && !rideProvider.isLoading) ...[
                        _buildEmptyState(),
                        SizedBox(height: 20),
                      ],

                      // RÉSULTATS DYNAMIQUES
                      ...rideProvider.searchResults.map((ride) => 
                        Column(
                          children: [
                            RideResultCard(
                              ride: ride,
                              isFavorite: rideProvider.isFavorite(ride.rideId),
                              onFavoriteToggle: () => _toggleFavorite(ride.rideId, rideProvider),
                              onTap: () => _viewRideDetails(context, ride),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch(RideProvider provider) async {
    if (_departureController.text.isEmpty || _arrivalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir les champs de départ et d\'arrivée'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await provider.searchRides(
      from: _departureController.text,
      to: _arrivalController.text,
      date: _selectedDate,
    );
  }

  void _toggleFavorite(String rideId, RideProvider provider) async {
    await provider.toggleFavorite(rideId);
    
    if (provider.isFavorite(rideId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trajet ajouté aux favoris'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _viewRideDetails(BuildContext context, RideModel ride) {
    // TODO: Naviguer vers l'écran de réservation ou détails
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voir détails: ${ride.startPoint} → ${ride.endPoint}'),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // ----------------------------
  // FORMULAIRE SEARCH
  // ----------------------------
  Widget _buildSearchForm(Color primaryColor, RideProvider provider) {
    return Column(
      children: [
        TextField(
          controller: _departureController,
          decoration: InputDecoration(
            hintText: 'Départ',
            prefixIcon: Icon(Icons.location_on_outlined, color: primaryColor),
            filled: true,
            fillColor: colorScheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _arrivalController,
          decoration: InputDecoration(
            hintText: 'Arrivée',
            prefixIcon: Icon(Icons.location_on, color: Colors.green[600]),
            filled: true,
            fillColor: colorScheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'jj/mm/aaaa',
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: colorScheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(width: 8),

            IconButton(
              onPressed: () {
                // TODO: Implémenter l'écran de filtres avancés
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Filtres avancés - À implémenter')),
                );
              },
              icon: const Icon(Icons.filter_list),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.all(14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: provider.isLoading ? null : () => _performSearch(provider),
            icon: const Icon(Icons.search, color: Colors.white),
            label: provider.isLoading 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text('Rechercher'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------
  // CARTE PUBLICITÉ
  // ----------------------------
  Widget _buildAdCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.secondary.withOpacity(0.4)),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'AD',
                style: TextStyle(
                  color: colorScheme.onSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Passez à Premium pour une expérience sans pub',
                style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 18, color: colorScheme.onSurfaceVariant),
              onPressed: () {
                setState(() {
                  _showAd = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------
  // HEADER RÉSULTATS
  // ----------------------------
  Widget _buildResultsHeader(Color primaryColor, RideProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Résultats (${provider.searchResults.length})',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {
            // TODO: Implémenter le tri
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tri par prix - À implémenter')),
            );
          },
          child: Text(
            'Trier par prix',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(RideProvider provider) {
    return Column(
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.red),
        SizedBox(height: 16),
        Text(
          'Erreur de recherche',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(provider.error),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _performSearch(provider),
          child: Text('Réessayer'),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
        SizedBox(height: 16),
        Text(
          'Aucun trajet trouvé',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
        SizedBox(height: 8),
        Text(
          'Essayez de modifier vos critères de recherche',
          style: TextStyle(color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}