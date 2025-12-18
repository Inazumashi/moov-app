// File: lib/features/driver/screens/ride_reservations_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/models/reservation.dart';
import 'package:moovapp/core/providers/reservation_provider.dart';
import 'package:moovapp/core/providers/rating_provider.dart';
import 'package:moovapp/widgets/driver_reservation_card.dart';
import 'package:moovapp/features/ratings/screens/rate_passenger_screen.dart';

class RideReservationsScreen extends StatefulWidget {
  final RideModel ride;

  const RideReservationsScreen({
    super.key,
    required this.ride,
  });

  @override
  State<RideReservationsScreen> createState() => _RideReservationsScreenState();
}

class _RideReservationsScreenState extends State<RideReservationsScreen> {
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final provider = Provider.of<ReservationProvider>(context, listen: false);
    final rideId = int.tryParse(widget.ride.rideId) ?? 0;

    if (rideId > 0) {
      await provider.fetchReservationsForRide(rideId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: const Text('Réservations du trajet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReservations,
          ),
        ],
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final allReservations = provider.allReservations
              .where((r) => r.rideId.toString() == widget.ride.rideId)
              .toList();

          // Filtrer selon le statut
          List<Reservation> filteredReservations;
          if (_filterStatus == 'all') {
            filteredReservations = allReservations;
          } else {
            filteredReservations = allReservations
                .where((r) => r.status.toLowerCase() == _filterStatus)
                .toList();
          }

          return Column(
            children: [
              // Informations du trajet
              _buildRideInfo(colors, theme),

              // Statistiques
              _buildStats(allReservations, colors),

              // Filtres
              _buildFilters(allReservations, colors),

              const Divider(height: 1),

              // Liste des réservations
              Expanded(
                child: filteredReservations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadReservations,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: filteredReservations.length,
                          itemBuilder: (context, index) {
                            final reservation = filteredReservations[index];
                            return DriverReservationCard(
                              reservation: reservation,
                              onComplete: () =>
                                  _handleComplete(reservation, provider),
                              onCancel: () =>
                                  _handleCancel(reservation, provider),
                              onContact: () => _handleContact(reservation),
                              onRate: () => _handleRate(reservation),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRideInfo(ColorScheme colors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trip_origin, size: 20, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.ride.startPoint,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.ride.endPoint,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.event_seat, size: 18),
              const SizedBox(width: 8),
              Text(
                '${widget.ride.availableSeats} places disponibles',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(List<Reservation> reservations, ColorScheme colors) {
    final pending = reservations.where((r) => r.status == 'pending').length;
    final confirmed =
        reservations.where((r) => r.status == 'confirmed').length;
    final completed =
        reservations.where((r) => r.status == 'completed').length;
    final totalSeats = reservations
        .where((r) => r.status != 'cancelled')
        .fold(0, (sum, r) => sum + r.seatsReserved);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('En attente', pending, Colors.orange),
          _buildStatItem('Confirmées', confirmed, Colors.blue),
          _buildStatItem('Terminées', completed, Colors.green),
          _buildStatItem('Places', totalSeats, colors.primary),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(List<Reservation> reservations, ColorScheme colors) {
    final filters = [
      {'key': 'all', 'label': 'Toutes', 'count': reservations.length},
      {
        'key': 'pending',
        'label': 'En attente',
        'count': reservations.where((r) => r.status == 'pending').length
      },
      {
        'key': 'confirmed',
        'label': 'Confirmées',
        'count': reservations.where((r) => r.status == 'confirmed').length
      },
      {
        'key': 'completed',
        'label': 'Terminées',
        'count': reservations.where((r) => r.status == 'completed').length
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _filterStatus == filter['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('${filter['label']} (${filter['count']})'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filterStatus = filter['key'] as String;
                });
              },
              backgroundColor: isSelected ? colors.primary : Colors.white,
              selectedColor: colors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
              checkmarkColor: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune réservation',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            _filterStatus == 'all'
                ? 'Aucune réservation pour ce trajet'
                : 'Aucune réservation avec ce statut',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // ✅ Terminer une réservation
  Future<void> _handleComplete(
      Reservation reservation, ReservationProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminer la réservation'),
        content: Text(
          'Confirmer que le trajet avec ${reservation.passengerName} est terminé ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await provider.markCompleted(reservation.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Réservation marquée comme terminée'),
              backgroundColor: Colors.green,
            ),
          );
          _loadReservations();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erreur: ${provider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ✅ Annuler une réservation
  Future<void> _handleCancel(
      Reservation reservation, ReservationProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: Text(
          'Voulez-vous vraiment annuler la réservation de ${reservation.passengerName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await provider.cancelReservation(reservation.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Réservation annulée'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadReservations();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erreur: ${provider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ✅ Contacter le passager
  Future<void> _handleContact(Reservation reservation) async {
    // Afficher les options de contact
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contacter ${reservation.passengerName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Appeler'),
              onTap: () {
                Navigator.pop(context);
                // Implémenter l'appel téléphonique
                // launchUrl(Uri.parse('tel:${reservation.passengerPhone}'));
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.blue),
              title: const Text('Envoyer un SMS'),
              onTap: () {
                Navigator.pop(context);
                // Implémenter l'envoi de SMS
                // launchUrl(Uri.parse('sms:${reservation.passengerPhone}'));
              },
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Noter le passager
  Future<void> _handleRate(Reservation reservation) async {
    // Navigation vers l'écran de notation
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RatePassengerScreen(
          reservation: reservation,
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Note enregistrée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      _loadReservations();
    }
  }
}