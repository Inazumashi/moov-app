import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/features/driver/driver_messages_screen.dart'; // Pour DriverMessages (ancien)
import 'package:moovapp/features/ride/screens/driver_reservations_screen.dart'; // Pour DriverReservations (nouveau)
import 'package:moovapp/core/providers/auth_provider.dart';
import 'package:moovapp/core/providers/ride_provider.dart';

class RideDetailsScreen extends StatefulWidget {
  final String rideId;

  const RideDetailsScreen({super.key, required this.rideId});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  late RideModel ride;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadRideDetails();
  }

  void _loadRideDetails() {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final foundRide = rideProvider.getRideById(widget.rideId);
    
    if (foundRide != null) {
      setState(() {
        ride = foundRide;
        isFavorite = rideProvider.isFavorite(widget.rideId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: const Text('Détails du trajet'),
        actions: [
          Consumer<RideProvider>(
            builder: (context, rideProvider, _) {
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : colors.onPrimary,
                ),
                onPressed: rideProvider != null ? () {
                  rideProvider.toggleFavorite(widget.rideId);
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                } : null,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route Card
            _buildRouteCard(colors),
            const SizedBox(height: 24),

            // Conducteur Card
            _buildDriverCard(colors),
            const SizedBox(height: 24),

            // Détails trajet
            _buildDetailsSection(colors),
            const SizedBox(height: 24),

            // Notes et avis
            _buildRatingsSection(colors),
            const SizedBox(height: 24),

            // Description
            if (ride.notes != null && ride.notes!.isNotEmpty)
              _buildDescriptionSection(colors),

            const SizedBox(height: 32),
            
            // Action buttons
            _buildActionButtons(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Départ',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ride.startPoint,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ride.departureTime?.hour.toString().padLeft(2, '0')}:${ride.departureTime?.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: colors.primary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, color: colors.primary, size: 28),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Arrivée',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ride.endPoint,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ride.departureTime?.hour.toString().padLeft(2, '0')}:${(ride.departureTime!.minute + 90).toString().padLeft(2, '0')}',
                        style: TextStyle(color: colors.primary),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip('${ride.pricePerSeat}€', 'Prix', colors),
                _buildInfoChip('${ride.availableSeats}', 'Places', colors),
                _buildInfoChip('150 km', 'Distance', colors),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard(ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: colors.primary.withOpacity(0.2),
              child: Icon(Icons.person, color: colors.primary, size: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ride.driverName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${ride.driverRating.toStringAsFixed(1)}/5 ⭐',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        const Text(
                          'Vérifié',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détails du trajet',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildDetailRow('Véhicule', ride.vehicleInfo ?? 'Non spécifié', colors),
        _buildDetailRow('Type de musique', 'À définir', colors),
        _buildDetailRow('Climatisation', 'Oui', colors),
        _buildDetailRow('Fumeurs', 'Non', colors),
      ],
    );
  }

  Widget _buildRatingsSection(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avis',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Note moyenne:', style: TextStyle(color: colors.onSurfaceVariant)),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${ride.driverRating.toStringAsFixed(1)}/5',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Statut:', style: TextStyle(color: colors.onSurfaceVariant)),
                  Text(
                    'Conducteur vérifié',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes du conducteur',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(ride.notes ?? ''),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String value, String label, ColorScheme colors) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }



  Widget _buildActionButtons(ColorScheme colors) {
    // 1. Récupérer l'utilisateur courant
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final isDriver = currentUser != null && currentUser.uid == ride.driverId;
    final isCompleted = ride.status == 'completed';

    // 2. Si c'est le conducteur
    if (isDriver) {
      return Column(
        children: [
          // Bouton Gérer les passagers
          FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DriverReservationsScreen(ride: ride),
                ),
              );
            },
            icon: const Icon(Icons.people),
            label: const Text('Gérer les passagers'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 12),
          
          if (!isCompleted)
            FilledButton.icon(
              onPressed: () => _completeRide(context),
              icon: const Icon(Icons.check_circle),
              label: const Text('Terminer le trajet'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          if (!isCompleted) const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _deleteRide(context),
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text(
              'Supprimer le trajet',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ],
      );
    }

    // 3. Si c'est un passager
    return Column(
      children: [
        if (isCompleted)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.check_circle, color: Colors.green),
                 SizedBox(width: 8),
                 const Text(
                  'Ce trajet est terminé',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                 ),
               ]
            )
          )
        else ...[
          FilledButton.icon(
            onPressed: () => _openReservationFlow(context),
            icon: const Icon(Icons.event_seat),
            label: const Text('Réserver ce trajet'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _openChat(context),
            icon: const Icon(Icons.message),
            label: const Text('Contacter le conducteur'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ]
      ],
    );
  }

  void _completeRide(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terminer le trajet ?'),
        content: const Text(
            'Cela marquera le trajet comme complété et confirmera toutes les réservations.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await Provider.of<RideProvider>(context, listen: false)
          .completeRide(ride.rideId);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Trajet terminé avec succès'),
              backgroundColor: Colors.green));
          _loadRideDetails();
        } else {
          final error = Provider.of<RideProvider>(context, listen: false).error;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Erreur: $error'), backgroundColor: Colors.red));
        }
      }
    }
  }

  void _deleteRide(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le trajet'),
        content: const Text(
            'Êtes-vous sûr de vouloir supprimer ce trajet ? Cette action est irréversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer')),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = Provider.of<RideProvider>(context, listen: false);
      final success = await provider.deleteRide(ride.rideId);

      if (context.mounted) {
        if (success) {
          Navigator.pop(context); // Quitter l'écran
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('✅ Trajet supprimé'),
            backgroundColor: Colors.green,
          ));
        } else {
          // Afficher le message d'erreur précis (ex: réservations actives)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(provider.error.isNotEmpty
                ? provider.error
                : '❌ Impossible de supprimer le trajet'),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  void _openReservationFlow(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Réservation en cours...')),
    );
    // TODO: Open reservation modal/screen
  }

  void _openChat(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ouverture du chat...')),
    );
    // TODO: Navigate to chat screen
  }
}