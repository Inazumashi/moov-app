import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/favorite_ride_card.dart';
import 'package:moovapp/core/providers/ride_provider.dart';
import 'package:moovapp/core/models/ride_model.dart';

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
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final rideProvider = Provider.of<RideProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mes favoris',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              '${rideProvider.favoriteRides.length} trajet(s) sauvegardé(s)',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        toolbarHeight: 90,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Icon(Icons.favorite, color: Colors.white, size: 28),
        ),
        leadingWidth: 44,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => rideProvider.loadFavoriteRides(),
          ),
        ],
      ),
      body: _buildBody(rideProvider, primaryColor),
    );
  }

  Widget _buildBody(RideProvider provider, Color primaryColor) {
    if (provider.isLoading && provider.favoriteRides.isEmpty) {
      return Center(
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
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                provider.error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadFavoriteRides(),
              child: Text('Réessayer'),
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
            SizedBox(height: 16),
            Text(
              'Aucun trajet favori',
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
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
            'Disponibles',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          ...provider.favoriteRides.map((ride) => FavoriteRideCard(
                ride: ride,
                onRemove: () => _removeFromFavorites(ride.rideId, provider),
                onView: () => _viewRideDetails(context, ride),
              )),
        ],
      ),
    );
  }

  void _removeFromFavorites(String rideId, RideProvider provider) async {
    await provider.removeFromFavorites(rideId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trajet retiré des favoris'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _viewRideDetails(BuildContext context, RideModel ride) {
    // TODO: Naviguer vers l'écran de détails du trajet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigation vers détails de ${ride.startPoint} → ${ride.endPoint}'),
      ),
    );
  }
}