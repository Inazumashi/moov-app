import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/favorite_ride_card.dart';
import '../providers/favorite_rides_provider.dart'; 

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // On récupère la liste depuis le provider
    final favoriteRides = Provider.of<FavoriteRidesProvider>(context).rides;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.primary,
        toolbarHeight: 90,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Icon(Icons.favorite, color: colors.onPrimary, size: 28),
        ),
        leadingWidth: 44,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mes favoris',
              style: TextStyle(
                color: colors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${favoriteRides.length} trajet(s) sauvegardé(s)',
              style: TextStyle(
                color: colors.onPrimary.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
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
        ],
      ),
    );
  }
}
