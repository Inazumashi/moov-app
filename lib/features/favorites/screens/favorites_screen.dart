import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/favorite_ride_card.dart';
<<<<<<< HEAD
import 'package:moovapp/core/providers/ride_provider.dart';
import 'package:moovapp/core/models/ride_model.dart';
=======
import '../providers/favorite_rides_provider.dart'; 
>>>>>>> cef8c6aabcde6ab6828e1abee46d73d006194ee9

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
<<<<<<< HEAD
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final rideProvider = Provider.of<RideProvider>(context);
=======
    final colors = Theme.of(context).colorScheme;

    // On récupère la liste depuis le provider
    final favoriteRides = Provider.of<FavoriteRidesProvider>(context).rides;
>>>>>>> cef8c6aabcde6ab6828e1abee46d73d006194ee9

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
<<<<<<< HEAD
=======
        backgroundColor: colors.primary,
        toolbarHeight: 90,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Icon(Icons.favorite, color: colors.onPrimary, size: 28),
        ),
        leadingWidth: 44,
>>>>>>> cef8c6aabcde6ab6828e1abee46d73d006194ee9
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mes favoris',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
<<<<<<< HEAD
              '${rideProvider.favoriteRides.length} trajet(s) sauvegardé(s)',
              style: TextStyle(color: Colors.white70, fontSize: 14),
=======
              '${favoriteRides.length} trajet(s) sauvegardé(s)',
              style: TextStyle(
                color: colors.onPrimary.withOpacity(0.7),
                fontSize: 14,
              ),
>>>>>>> cef8c6aabcde6ab6828e1abee46d73d006194ee9
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
<<<<<<< HEAD
      body: _buildBody(rideProvider, primaryColor),
    );
  }

  Widget _buildBody(RideProvider provider, Color primaryColor) {
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
=======
      body: ListView(
>>>>>>> cef8c6aabcde6ab6828e1abee46d73d006194ee9
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Disponibles',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.onBackground.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
<<<<<<< HEAD
          ...provider.favoriteRides.map((ride) => FavoriteRideCard(
                ride: ride,
                onRemove: () => _removeFromFavorites(ride.rideId, provider),
                onView: () => _viewRideDetails(context, ride),
              )),
=======
          if (favoriteRides.isEmpty)
            Center(
              child: Text(
                'Aucun trajet favori pour le moment',
                style: TextStyle(
                  color: colors.onBackground.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ),
          ...favoriteRides.asMap().entries.map(
                (entry) => Stack(
                  children: [
                    FavoriteRideCard(
                      name: entry.value.name,
                      rating: entry.value.rating,
                      isPremium: entry.value.isPremium,
                      departure: entry.value.departure,
                      arrival: entry.value.arrival,
                      date: entry.value.date,
                      time: entry.value.time,
                      seats: entry.value.seats,
                      price: entry.value.price,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Supprimer via le provider
                          Provider.of<FavoriteRidesProvider>(context, listen: false)
                              .removeRide(entry.value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
>>>>>>> cef8c6aabcde6ab6828e1abee46d73d006194ee9
        ],
      ),
    );
  }

  void _removeFromFavorites(String rideId, RideProvider provider) async {
    await provider.removeFromFavorites(rideId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
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
