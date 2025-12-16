import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:moovapp/features/home/widgets/my_reservations_widget.dart';
import 'package:moovapp/features/home/widgets/suggestions_section.dart';
import 'package:moovapp/features/premium/screens/premium_screen.dart';
import 'package:moovapp/features/ride/screens/my_rides_screen.dart';
import 'package:moovapp/core/providers/auth_provider.dart';
import 'package:moovapp/core/providers/ride_provider.dart';
import 'package:moovapp/core/providers/reservation_provider.dart';
import 'package:moovapp/features/profile/screens/notifications_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rideProv = Provider.of<RideProvider>(context, listen: false);
      final resProv = Provider.of<ReservationProvider>(context, listen: false);
      rideProv.refreshAllData();
      resProv.loadReservations();
    });
  }

  // ------------------------------------------------------------
  // POP-UP NOTATION
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
    final auth = Provider.of<AuthProvider>(context);
    final rideProv = Provider.of<RideProvider>(context);

    final user = auth.currentUser;

    final ridesCount = user?.ridesCompleted ?? 0;
    final rating = (user?.averageRating ?? 0.0).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.fullName != null && user!.fullName.isNotEmpty
                  ? 'Bonjour, ${user.fullName.split(' ').first} 👋'
                  : 'Bonjour 👋',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
            Text(
              user?.universityId ?? 'Étudiant',
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
                  MaterialPageRoute(
                      builder: (context) => const PremiumScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined,
                color: Colors.white, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                   builder: (_) => const NotificationsListScreen(),
                ),
              );
            },
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
            // Carte (garder)
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
                    Text('Carte des trajets disponibles',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cs.primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistiques de l'utilisateur
            Row(
              children: [
                _buildStatCard(ridesCount.toString(), 'Trajets', cs.primary),
                const SizedBox(width: 12),
                _buildStatCard(rating, 'Note', cs.tertiary),
                const SizedBox(width: 12),
                _buildStatCard('0', 'MAD Économisés', cs.secondary),
              ],
            ),
            const SizedBox(height: 24),

            // 🎯 Suggestions
            SuggestionsSection(
              onViewDetails: (rideId) {
                // TODO: Naviguer vers RideDetailsScreen
                print('Voir détails: $rideId');
              },
              onRideSelected: (ride) {
                // TODO: Ouvrir ReservationFlowModal
                print('Réserver: ${ride.rideId}');
              },
            ),
            const SizedBox(height: 24),

            // Mes réservations réelles
            Text('Mes réservations',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface)),
            const SizedBox(height: 12),
            const MyReservationsWidget(),
            const SizedBox(height: 24),

            // Mes trajets publiés
            Text('Mes trajets publiés',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface)),
            const SizedBox(height: 12),
            if (rideProv.myPublishedRides.isEmpty)
              Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text('Aucun trajet publié pour le moment.'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MyRidesScreen())),
                        child: const Text('Publier'),
                      )
                    ],
                  ),
                ),
              )
            else
              Column(
                children: rideProv.myPublishedRides.map((ride) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text('${ride.startPoint} → ${ride.endPoint}'),
                      subtitle: Text(ride.departureTime != null
                          ? '${ride.formattedDate} • ${ride.formattedTime}'
                          : 'Date non définie'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${ride.availableSeats} places'),
                          const SizedBox(height: 4),
                          Text('${ride.pricePerSeat} DH',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyRidesScreen())),
                    ),
                  );
                }).toList(),
              ),
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