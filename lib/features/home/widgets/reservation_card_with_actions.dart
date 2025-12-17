// lib/features/home/widgets/reservation_card_with_actions.dart
import 'package:flutter/material.dart';
import 'package:moovapp/core/models/reservation.dart';
import 'package:moovapp/core/models/ride_model.dart';

class ReservationCardWithActions extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onCancel;
  final VoidCallback? onViewDetails;
  final VoidCallback? onOpenChat;

  const ReservationCardWithActions({
    super.key,
    required this.reservation,
    this.onCancel,
    this.onViewDetails,
    this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec numéro et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.confirmation_number, 
                           size: 20, 
                           color: colors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Réservation #${reservation.id}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      // Badge de notification de chat
                      if (reservation.hasUnreadMessages)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(reservation.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(reservation.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Informations du trajet
              if (reservation.ride != null) 
                _buildRideInfo(reservation.ride!, colors),
              
              const Divider(height: 24),
              
              // Détails de la réservation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Places réservées
                  Row(
                    children: [
                      Icon(Icons.people, 
                           size: 18, 
                           color: colors.onSurface.withOpacity(0.6)),
                      const SizedBox(width: 8),
                      Text(
                        '${reservation.seatsReserved} place${reservation.seatsReserved > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: colors.onSurface.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  // Prix total
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${reservation.totalPrice.toStringAsFixed(0)} DH',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Date de réservation
              Row(
                children: [
                  Icon(Icons.access_time, 
                       size: 16, 
                       color: colors.onSurface.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  Text(
                    'Réservé le ${reservation.formattedDate} à ${reservation.formattedTime}',
                    style: TextStyle(
                      color: colors.onSurface.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              
              // Boutons d'action
              const SizedBox(height: 16),
              Row(
                children: [
                  // Bouton Annuler (seulement pour les réservations actives)
                  if (reservation.isActive && onCancel != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Annuler'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  
                  if (reservation.isActive && onCancel != null)
                    const SizedBox(width: 8),
                  
                  // Bouton Chat (disponible pour toutes les réservations non annulées)
                  if (reservation.status != 'cancelled' && onOpenChat != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onOpenChat,
                        icon: const Icon(Icons.chat, size: 18),
                        label: const Text('Chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  
                  // Bouton Détails (toujours visible)
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewDetails,
                      icon: const Icon(Icons.info, size: 18),
                      label: const Text('Détails'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRideInfo(RideModel ride, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Départ
        Row(
          children: [
            Icon(Icons.my_location, size: 18, color: Colors.green[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ride.startPoint,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        
        // Ligne verticale
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 6, bottom: 6),
          child: Container(
            height: 20,
            width: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[600]!, Colors.blue[600]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        
        // Arrivée
        Row(
          children: [
            Icon(Icons.location_on, size: 18, color: Colors.blue[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ride.endPoint,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Date et heure du trajet
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, 
                   size: 16, 
                   color: colors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                ride.departureTime != null
                    ? '${ride.departureTime!.day}/${ride.departureTime!.month}/${ride.departureTime!.year} à ${ride.departureTime!.hour}h${ride.departureTime!.minute.toString().padLeft(2, '0')}'
                    : 'Date non définie',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Informations du conducteur
        if (ride.driverName.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.driverName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (ride.driverRating > 0)
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber[600]),
                            const SizedBox(width: 4),
                            Text(
                              ride.driverRating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'CONFIRMÉE';
      case 'cancelled':
        return 'ANNULÉE';
      case 'completed':
        return 'TERMINÉE';
      case 'pending':
        return 'EN ATTENTE';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}