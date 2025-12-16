// lib/features/home/screens/home_screen.dart - VERSION FINALE
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

      body: RefreshIndicator(
        onRefresh: () async {
          final rideProv = Provider.of<RideProvider>(context, listen: false);
          final resProv = Provider.of<ReservationProvider>(context, listen: false);
          await Future.wait([
            rideProv.refreshAllData(),
            resProv.loadReservations(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte des trajets
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
                      Expanded(
                        child: Text('Carte des trajets disponibles',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: cs.primary)),
                      ),
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

              // Suggestions
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

              // Mes réservations avec nouveau widget
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mes réservations',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface)),
                  Consumer<ReservationProvider>(
                    builder: (context, provider, _) {
                      if (provider.reservations.isNotEmpty) {
                        return TextButton.icon(
                          onPressed: () => provider.loadReservations(),
                          icon: provider.isLoading
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cs.primary,
                                  ),
                                )
                              : Icon(Icons.refresh, size: 20),
                          label: Text('Actualiser'),
                          style: TextButton.styleFrom(
                            foregroundColor: cs.primary,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const MyReservationsWidget(),
              const SizedBox(height: 24),

              // Mes trajets publiés
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mes trajets publiés',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface)),
                  if (rideProv.myPublishedRides.isNotEmpty)
                    TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyRidesScreen())),
                      child: const Text('Voir tout'),
                    ),
                ],
              ),
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
                  children: rideProv.myPublishedRides.take(3).map((ride) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text('${ride.startPoint} → ${ride.endPoint}'),
                        subtitle: Text(ride.departureTime != null
                            ? '${ride.formattedDate} • ${ride.formattedTime}'
                            : 'Date non définie'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${ride.availableSeats} places',
                                    style: TextStyle(fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('${ride.pricePerSeat} DH',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) async {
                                final rideProv = Provider.of<RideProvider>(
                                    context,
                                    listen: false);
                                if (value == 'delete') {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Supprimer le trajet'),
                                      content: const Text(
                                          'Êtes-vous sûr de vouloir supprimer ce trajet ?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: const Text('Annuler')),
                                        ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Supprimer')),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    final success =
                                        await rideProv.deleteRide(ride.rideId);
                                    
                                    if (!context.mounted) return;
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(success
                                            ? '✅ Trajet supprimé'
                                            : '❌ Erreur suppression'),
                                        backgroundColor: success 
                                          ? Colors.green 
                                          : Colors.red,
                                      ),
                                    );
                                  }
                                } else if (value == 'edit') {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const MyRidesScreen()));
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete,
                                          color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Text('Supprimer')
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
              
              // Message si plus de 3 trajets
              if (rideProv.myPublishedRides.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyRidesScreen())),
                      child: Text(
                        'Voir ${rideProv.myPublishedRides.length - 3} autres trajets',
                        style: TextStyle(color: cs.primary),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

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