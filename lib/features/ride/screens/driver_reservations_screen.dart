import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/reservation_provider.dart';
import 'package:moovapp/core/models/reservation.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/providers/chat_provider.dart';
import 'package:moovapp/features/chat/screens/chat_screen.dart';

class DriverReservationsScreen extends StatefulWidget {
  final RideModel ride;

  const DriverReservationsScreen({super.key, required this.ride});

  @override
  State<DriverReservationsScreen> createState() =>
      _DriverReservationsScreenState();
}

class _DriverReservationsScreenState extends State<DriverReservationsScreen> {
  List<Reservation> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<ReservationProvider>(context, listen: false);
    final results =
        await provider.fetchReservationsForRide(int.parse(widget.ride.rideId));

    if (mounted) {
      setState(() {
        _reservations = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmReservation(Reservation reservation) async {
    final provider = Provider.of<ReservationProvider>(context, listen: false);
    final success = await provider.confirmReservation(reservation.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Réservation confirmée !'),
            backgroundColor: Colors.green),
      );
      _loadReservations(); // Reload to update status
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la confirmation'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _openChat(Reservation reservation) async {
    if (reservation.passengerId == '0') return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Afficher un indicateur de chargement si nécessaire, ou juste attendre
    // Ici on suppose que la création est rapide
    final conversationId = await chatProvider.getOrCreateConversation(
      int.parse(widget.ride.rideId),
      otherUserId: reservation.passengerId,
    );

    if (conversationId != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            otherUserName: reservation.passengerName ?? 'Passager',
            rideInfo: '${widget.ride.startPoint} → ${widget.ride.endPoint}',
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir la conversation')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Passagers'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reservations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 64, color: colors.outline),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune demande pour le moment',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) {
                    final res = _reservations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: res.passengerPhoto != null
                                      ? NetworkImage(res.passengerPhoto!)
                                      : null,
                                  child: res.passengerPhoto == null
                                      ? Text(
                                          res.passengerName?[0].toUpperCase() ??
                                              'P')
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        res.passengerName ?? 'Passager Inconnu',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${res.seatsReserved} places demandées',
                                        style: TextStyle(
                                          color: colors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildStatusChip(res.status),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _openChat(res),
                                  icon: const Icon(Icons.chat_bubble_outline,
                                      size: 18),
                                  label: const Text('Discuter'),
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (res.status.toLowerCase() == 'pending')
                                  FilledButton.icon(
                                    onPressed: () => _confirmReservation(res),
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text('Confirmer'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.green;
        label = 'Confirmé';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'En attente';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Annulé';
        break;
      case 'completed':
        color = Colors.blue;
        label = 'Terminé';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
