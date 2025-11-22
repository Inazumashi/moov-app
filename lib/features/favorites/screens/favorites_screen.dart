import 'package:flutter/material.dart';
import '../widgets/favorite_ride_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
              '1 trajet sauvegardé',
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

          const FavoriteRideCard(
            name: 'Fatima Zahra',
            rating: 4.8,
            isPremium: true,
            departure: 'Ben Guerir Centre',
            arrival: 'UM6P Campus',
            date: '10 Oct',
            time: '06:00',
            seats: 3,
            price: 15,
          ),
        ],
      ),
    );
  }
}
