// lib/features/home/widgets/reservation_card_with_actions.dart - VERSION COMPLÈTE
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/reservation_provider.dart';
import 'package:moovapp/core/providers/chat_provider.dart';
import 'package:moovapp/core/providers/rating_provider.dart';
import 'package:moovapp/features/chat/screens/chat_screen.dart';
import 'package:moovapp/features/ratings/screens/rate_driver_screen.dart';
import 'package:moovapp/core/models/reservation.dart';

class ReservationCardWithActions extends StatelessWidget {
  final Reservation reservation;

  const ReservationCardWithActions({
    Key? key,
    required this.reservation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // ✅ Extrait des données de l'objet Reservation
    final reservationId = reservation.id;
    if (reservationId == 0) {
      return const SizedBox.shrink(); 
    }
    final status = reservation.status;
    
    // Si reservation.ride existe, utilise ses données
    String departureStation;
    String arrivalStation;
    String departureDate;
    String departureTime;
    String driverName;
    String driverRating;
    int? driverId;
    String rideId;
    
    if (reservation.ride != null) {
      final ride = reservation.ride!;
      departureStation = ride.startPoint;
      arrivalStation = ride.endPoint;
      departureDate = ride.formattedDate;
      departureTime = ride.formattedTime;
      driverName = ride.driverName;
      driverRating = ride.driverRating.toStringAsFixed(1);
      driverId = ride.driverId != null ? int.tryParse(ride.driverId) : null;
      rideId = ride.rideId;
    } else {
      // Fallback si ride n'existe pas (utilise les données raw du Map)
      // Mais pour utiliser l'opérateur point, il faut que ces champs existent dans Reservation
      departureStation = 'Départ';
      arrivalStation = 'Arrivée';
      departureDate = '';
      departureTime = '';
      driverName = reservation.driverFirstName != null && reservation.driverLastName != null
          ? '${reservation.driverFirstName} ${reservation.driverLastName}'
          : 'Conducteur';
      driverRating = '5.0';
      driverId = reservation.driverId;
      rideId = reservation.rideId.toString();
    }
    
    final seats = reservation.seatsReserved.toString();
    final totalPrice = reservation.totalPrice.toStringAsFixed(0);

    // ... le reste du code build() reste inchangé ...
    // Couleur selon le statut
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'confirmed':
        statusColor = Colors.green;
        statusText = 'Confirmée';
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'En attente';
        statusIcon = Icons.pending;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Annulée';
        statusIcon = Icons.cancel;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusText = 'Terminée';
        statusIcon = Icons.done_all;
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // En-tête avec statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  'Réservation #$reservationId',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trajet
                Row(
                  children: [
                    Icon(Icons.location_on, color: colors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        departureStation,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Column(
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: 2,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: colors.outlineVariant,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.location_on, color: colors.secondary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        arrivalStation,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Infos trajet
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        context,
                        Icons.calendar_today,
                        departureDate,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        context,
                        Icons.access_time,
                        departureTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        context,
                        Icons.airline_seat_recline_normal,
                        '$seats place${int.parse(seats) > 1 ? 's' : ''}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoChip(
                        context,
                        Icons.payments,
                        '$totalPrice DH',
                        color: colors.tertiary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Infos conducteur
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colors.primaryContainer,
                      child: Text(
                        driverName.isNotEmpty ? driverName[0].toUpperCase() : 'C',
                        style: TextStyle(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driverName.isNotEmpty ? driverName : 'Conducteur',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                driverRating,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ✅ CORRECTION: Passe les données avec l'opérateur point
                _buildActionButtons(
                  context,
                  status,
                  reservation.id, // ✅ .id
                  int.tryParse(rideId) ?? 0, // ✅ conversion en int
                  driverId,
                  driverName,
                  departureStation,
                  arrivalStation,
                  colors,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ CORRECTION des méthodes pour utiliser l'objet Reservation
  Widget _buildActionButtons(
    BuildContext context,
    String status,
    int reservationId, // ✅ int au lieu de String
    int rideId, // ✅ int
    int? driverId,
    String driverName,
    String departureStation,
    String arrivalStation,
    ColorScheme colors,
  ) {
    if (status.toLowerCase() == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Cette réservation a été annulée',
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    if (status.toLowerCase() == 'completed') {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Trajet complété avec succès',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _rateDriver(context, reservation),
              icon: const Icon(Icons.star_border),
              label: const Text('Noter le trajet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _openChat(
              context,
              rideId,
              driverName,
              departureStation,
              arrivalStation,
            ),
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text('Contacter'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primary,
              side: BorderSide(color: colors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showCancelDialog(context, reservationId),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Annuler'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label, {Color? color}) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? colors.primaryContainer).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color ?? colors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color ?? colors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openChat(
    BuildContext context,
    int rideId,
    String driverName,
    String departure,
    String arrival,
  ) async {
    if (rideId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de contacter le conducteur')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final conversationId = await chatProvider.getOrCreateConversation(rideId);

      if (!context.mounted) return;
      Navigator.pop(context);

      if (conversationId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conversationId,
              otherUserName: driverName,
              rideInfo: '$departure → $arrival',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de créer la conversation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCancelDialog(BuildContext context, int reservationId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Annuler la réservation'),
          content: const Text(
            'Êtes-vous sûr de vouloir annuler cette réservation ?\n\n'
            'Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Non, garder'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _cancelReservation(context, reservationId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Oui, annuler'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelReservation(BuildContext context, int reservationId) async {
    final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await reservationProvider.cancelReservation(reservationId);
      
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Réservation annulée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ CORRECTION: Prend un objet Reservation en paramètre
  Future<void> _rateDriver(BuildContext context, Reservation reservation) async {
    if (reservation.driverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conducteur introuvable')),
      );
      return;
    }

    try {
      final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
      final canRate = await ratingProvider.canRate(reservation.id);
      
      if (!context.mounted) return;
      
      if (canRate) {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => RateDriverScreen(
              reservation: reservation, // ✅ Passe l'objet Reservation
            ),
          ),
        );
        
        if (result == true && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Merci pour votre avis !'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous avez déjà noté ce trajet'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}