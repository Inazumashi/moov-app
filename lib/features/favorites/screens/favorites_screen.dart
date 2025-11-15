import 'package:flutter/material.dart';
// Cet import devrait maintenant fonctionner !
import '../widgets/favorite_ride_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mes favoris',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              '1 trajet sauvegardé', // TODO: Rendre ce chiffre dynamique
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        toolbarHeight: 90,
        // L'icône coeur est déjà dans le titre de l'AppBar
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Icon(Icons.favorite, color: Colors.white, size: 28),
        ),
        leadingWidth: 44,
      ),
      body: ListView(
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

          // --- On appelle le widget pour la carte de favori ---
          // TODO: Remplacer par des données réelles
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

          // Vous pouvez ajouter d'autres cartes ici
          // const FavoriteRideCard(...),
        ],
      ),
    );
  }
}


