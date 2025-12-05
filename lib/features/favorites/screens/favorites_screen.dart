import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/favorite_ride_card.dart';
import 'package:moovapp/core/providers/ride_provider.dart'; // Changé depuis favorite_rides_provider
import 'package:moovapp/core/models/ride_model.dart'; // Ajout pour RideModel

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
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
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
        ),
        leadingWidth: 44,
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => rideProvider.loadFavoriteRides(),
            color: Colors.white,
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
            ElevatedButton(
              onPressed: () => provider.loadFavoriteRides(),
              child: const Text('Réessayer'),
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
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadFavoriteRides();
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Trajets favoris',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onBackground.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          ...provider.favoriteRides.map((ride) => _buildFavoriteRideCard(ride, provider)),
        ],
      ),
    );
  }

  Widget _buildFavoriteRideCard(RideModel ride, RideProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: FavoriteRideCard(
        ride: ride,
        onRemove: () => _removeFromFavorites(ride.rideId, provider),
        onView: () => _viewRideDetails(ride),
      ),
    );
  }

  void _removeFromFavorites(String rideId, RideProvider provider) async {
    final success = await provider.removeFromFavorites(rideId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trajet retiré des favoris'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${provider.error}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _viewRideDetails(RideModel ride) {
    // TODO: Naviguer vers l'écran de détails du trajet
    // Pour l'instant, affichons un snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Détails: ${ride.startPoint} → ${ride.endPoint}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}