import 'package:flutter/material.dart';

import 'package:moovapp/features/home/widgets/my_reservations_widget.dart';

import 'package:moovapp/features/home/widgets/ride_to_rate_card.dart';

import 'package:moovapp/features/premium/screens/premium_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Fonction pour afficher la pop-up de notation (moov7.jpg)
  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(24.0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bouton Fermer
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                // Infos utilisateur
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.blue, // Couleur exemple
                  child: Text('F', style: TextStyle(color: Colors.white, fontSize: 30)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fatima Zahra',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Text(
                  'Ben Guerir → UM6P Campus',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const Text(
                  '9 Oct 2025',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                
                // Notation
                const Text('Votre note', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star_border,
                      color: Colors.grey[400],
                      size: 36,
                    );
                    // TODO: Ajouter la logique pour changer les étoiles pleines/vides
                  }),
                ),
                const SizedBox(height: 24),
                
                // Commentaire
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Commentaire (optionnel)\nPartagez votre expérience...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Text('0/300', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                const SizedBox(height: 24),
                
                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Logique d'envoi de l'avis
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.7), // Couleur 'Envoyer l'avis'
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Envoyer l\'avis'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        // 'Bonjour'
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour 👋', // J'ai ajouté l'emoji
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
            ),
            // TODO: Rendre ce texte dynamique
            Text(
              'uir - Étudiant',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        actions: [
          // Bouton Premium (Couronne)
          IconButton(
            icon: Icon(Icons.workspace_premium_outlined, color: Colors.orange.shade300, size: 28),
            onPressed: () {
              // --- NOUVELLE LOGIQUE ---
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
              // --- FIN NOUVELLE LOGIQUE ---
            },
          ),
          // Bouton Notifications (Cloche)
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 28),
            onPressed: () {
              // TODO: Logique pour les notifications
            },
          ),
          const SizedBox(width: 8),
        ],
        toolbarHeight: 70, // Augmente la hauteur de l'AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte des trajets disponibles
            Card(
              elevation: 0.5,
              color: const Color(0xFFe6f7ff), // Fond bleu très clair
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 36, color: primaryColor),
                    const SizedBox(width: 16),
                    Text(
                      'Carte des trajets disponibles',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // --- SECTION "Trajets à noter" ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trajets à noter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Bulle de notification rouge
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '1',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // --- UTILISATION DU NOUVEAU WIDGET ---
            RideToRateCard(
              onRatePressed: () {
                _showRatingDialog(context); // Ouvre la pop-up
              },
            ),
            // --- FIN NOUVEAU WIDGET ---
            
            const SizedBox(height: 24),

            // --- SECTION "Mes statistiques" (Les 3 petites cartes) ---
            Row(
              children: [
                _buildStatCard('12', 'Trajets', Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard('4.9', 'Note', Colors.green),
                const SizedBox(width: 12),
                _buildStatCard('350', 'MAD Économisés', Colors.purple),
              ],
            ),
            const SizedBox(height: 24),
            
            // --- SECTION "Mes réservations" ---
            const Text(
              'Mes réservations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // --- UTILISATION DU NOUVEAU WIDGET ---
            const MyReservationsWidget(),
            // --- FIN NOUVEAU WIDGET ---
          ],
        ),
      ),
    );
  }

  // Helper widget pour les petites cartes de statistiques
  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Card(
        elevation: 0.5,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
