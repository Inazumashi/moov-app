import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Import nécessaire
import 'package:moovapp/features/home/widgets/my_reservations_widget.dart';
import 'package:moovapp/features/home/widgets/ride_to_rate_card.dart';
import 'package:moovapp/features/premium/screens/premium_screen.dart';

// 1. Changement en StatefulWidget pour pouvoir charger les données
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 2. Variables pour stocker les infos dynamiques (valeurs par défaut vides)
  String firstName = "";
  String university = "";
  String profileType = "";

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 3. On charge les données au lancement
  }

  // Fonction pour récupérer les infos sauvegardées lors de la connexion
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // On récupère les clés sauvegardées (il faudra s'assurer de les sauver au Login !)
      firstName = prefs.getString('first_name') ?? "Utilisateur";
      university = prefs.getString('university_id') ?? "Université"; 
      profileType = prefs.getString('profile_type') ?? "Profil";
      
      // Petit nettoyage si l'université est trop longue pour l'affichage
      if (university.length > 20) {
        university = "${university.substring(0, 15)}...";
      }
    });
  }

  // ------------------------------------------------------------
  // POP-UP NOTATION (INCHANGÉ)
  // ------------------------------------------------------------
  void _showRatingDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cs.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(24.0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.blue,
                  child: Text('F',
                      style: TextStyle(color: Colors.white, fontSize: 30)),
                ),
                const SizedBox(height: 8),
                Text('Fatima Zahra',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: cs.onSurface)),
                Text('Ben Guerir → UM6P Campus',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
                Text('9 Oct 2025',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 16),
                Divider(color: cs.outlineVariant),
                const SizedBox(height: 16),
                Text('Votre note',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: cs.onSurface)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(Icons.star_border,
                        color: cs.outlineVariant, size: 36);
                  }),
                ),
                const SizedBox(height: 24),
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Commentaire (optionnel)\nPartagez votre expérience...',
                    hintStyle: TextStyle(color: cs.onSurfaceVariant),
                    fillColor: cs.surfaceContainerHighest.withOpacity(0.3),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outlineVariant),
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Text('0/300', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: cs.onSurface,
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Envoyer l'avis"),
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

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.primary,
<<<<<<< HEAD
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour 👋',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
=======
        // 4. MODIFICATION ICI : Utilisation des variables dynamiques
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour $firstName 👋', // ✅ Affiche le prénom chargé
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
>>>>>>> 38397c1094c7156cf54cdb86b901a3d5d3bc6b55
            ),
            Text(
              '$university - $profileType', // ✅ Affiche Univ et Profil
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.workspace_premium_outlined,
                color: Colors.orange.shade300, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined,
                color: Colors.white, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        toolbarHeight: 70,
      ),

      // ------------------------------------------------------------
      // BODY 
      // ------------------------------------------------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0.5,
              color: cs.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 36, color: cs.primary),
                    const SizedBox(width: 16),
                    Text(
                      'Carte des trajets disponibles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trajets à noter',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cs.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '1',
                    style: TextStyle(
                        color: cs.onError,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            RideToRateCard(onRatePressed: () => _showRatingDialog(context)),
            const SizedBox(height: 24),

            Row(
              children: [
                _buildStatCard('12', 'Trajets', cs.primary),
                const SizedBox(width: 12),
                _buildStatCard('4.9', 'Note', cs.tertiary),
                const SizedBox(width: 12),
                _buildStatCard('350', 'MAD Économisés', cs.secondary),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'Mes réservations',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface),
            ),
            const SizedBox(height: 12),
            const MyReservationsWidget(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HELPER: STAT CARD
  // ------------------------------------------------------------
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
              Text(value,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}