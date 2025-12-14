// lib/features/favorites/screens/favorites_screen.dart - VERSION AMÉLIORÉE
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/favorite_ride_card.dart';
import 'package:moovapp/core/providers/ride_provider.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/features/reservations/screens/book_ride_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _sortBy = 'date'; // date, price, name

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RideProvider>(context, listen: false).loadFavoriteRides();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.primary,
        toolbarHeight: 90,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mes Favoris',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${rideProvider.favoriteRides.length} trajet(s) sauvegardé(s)',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          // ✅ Menu de tri
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: colors.primary),
                    const SizedBox(width: 8),
                    const Text('Par date'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'price',
                child: Row(
                  children: [
                    Icon(Icons.attach_money, size: 18, color: colors.primary),
                    const SizedBox(width: 8),
                    const Text('Par prix'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 18, color: colors.primary),
                    const SizedBox(width: 8),
                    const Text('Par nom'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => rideProvider.loadFavoriteRides(),
          ),
        ],
      ),
      body: _buildBody(rideProvider, colors),
    );
  }

  Widget _buildBody(RideProvider provider, ColorScheme colors) {
    if (provider.isLoading && provider.favoriteRides.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement de vos favoris...'),
          ],
        ),
      );
    }

    if (provider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                provider.error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.loadFavoriteRides(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (provider.favoriteRides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun trajet favori',
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des trajets à vos favoris !',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Retour à l'écran de recherche
                Navigator.pop(context);
              },
              icon: const Icon(Icons.search),
              label: const Text('Rechercher des trajets'),
            ),
          ],
        ),
      );
    }

    // ✅ Trier les favoris
    final sortedRides = _sortRides(provider.favoriteRides);

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadFavoriteRides();
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ✅ Statistiques rapides
          _buildStatsCard(sortedRides, colors),
          const SizedBox(height: 16),

          Text(
            'Trajets favoris',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onBackground.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          
          ...sortedRides.map((ride) => _buildFavoriteRideCard(ride, provider)),
        ],
      ),
    );
  }

  // ✅ NOUVEAU : Carte de statistiques
  Widget _buildStatsCard(List<RideModel> rides, ColorScheme colors) {
    final totalPrice = rides.fold<double>(0, (sum, ride) => sum + ride.pricePerSeat);
    final avgPrice = rides.isEmpty ? 0.0 : totalPrice / rides.length;

    return Card(
      elevation: 2,
      color: colors.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.favorite,
              label: 'Total',
              value: '${rides.length}',
              color: colors.onPrimaryContainer,
            ),
            _buildStatItem(
              icon: Icons.attach_money,
              label: 'Prix moyen',
              value: '${avgPrice.toInt()} DH',
              color: colors.onPrimaryContainer,
            ),
            _buildStatItem(
              icon: Icons.event_seat,
              label: 'Places dispo',
              value: '${rides.fold<int>(0, (sum, ride) => sum + ride.availableSeats)}',
              color: colors.onPrimaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // ✅ NOUVEAU : Tri des favoris
  List<RideModel> _sortRides(List<RideModel> rides) {
    final sorted = List<RideModel>.from(rides);
    
    switch (_sortBy) {
      case 'date':
        sorted.sort((a, b) {
          if (a.departureTime == null) return 1;
          if (b.departureTime == null) return -1;
          return a.departureTime!.compareTo(b.departureTime!);
        });
        break;
      case 'price':
        sorted.sort((a, b) => a.pricePerSeat.compareTo(b.pricePerSeat));
        break;
      case 'name':
        sorted.sort((a, b) => a.startPoint.compareTo(b.startPoint));
        break;
    }
    
    return sorted;
  }

  Widget _buildFavoriteRideCard(RideModel ride, RideProvider provider) {
    return Dismissible(
      key: Key(ride.rideId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 32),
            SizedBox(height: 4),
            Text(
              'Supprimer',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(ride);
      },
      onDismissed: (direction) {
        _removeFromFavorites(ride.rideId, provider);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: FavoriteRideCard(
          ride: ride,
          onRemove: () => _showDeleteDialog(ride, provider),
          onView: () => _viewRideDetails(ride),
        ),
      ),
    );
  }

  // ✅ NOUVEAU : Confirmation de suppression avec animation
  Future<bool> _showDeleteConfirmation(RideModel ride) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirmer la suppression'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Voulez-vous retirer ce trajet de vos favoris ?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ride.startPoint} → ${ride.endPoint}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ride.pricePerSeat.toInt()} DH',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showDeleteDialog(RideModel ride, RideProvider provider) async {
    final confirmed = await _showDeleteConfirmation(ride);
    if (confirmed) {
      _removeFromFavorites(ride.rideId, provider);
    }
  }

  void _removeFromFavorites(String rideId, RideProvider provider) async {
    final success = await provider.removeFromFavorites(rideId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Trajet retiré des favoris'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Annuler',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Réajouter aux favoris
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Erreur: ${provider.error}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _viewRideDetails(RideModel ride) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookRideScreen(
          ride: ride,
          onBookingComplete: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Réservation effectuée !'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }
}