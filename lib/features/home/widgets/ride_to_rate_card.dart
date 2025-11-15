import 'package:flutter/material.dart';

class RideToRateCard extends StatelessWidget {
  // On demande une fonction 'onPressed' pour que
  // le 'home_screen' puisse décider quoi faire (ouvrir le dialogue)
  final VoidCallback onRatePressed;

  const RideToRateCard({
    super.key,
    required this.onRatePressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Avatar 'F'
            const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue, // Couleur exemple
              child: Text(
                'F',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            // Détails (Nom, Trajet, Date)
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fatima Zahra',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Ben Guerir → UM6P Campus',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  Text(
                    '9 Oct 2025',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Bouton Noter
            ElevatedButton(
              onPressed: onRatePressed, // On utilise la fonction passée en paramètre
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Noter'),
            ),
          ],
        ),
      ),
    );
  }
}

