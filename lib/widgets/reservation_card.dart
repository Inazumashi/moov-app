// lib/features/reservations/widgets/reservation_card.dart - VERSION COMPLÈTE
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/models/reservation.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/providers/rating_provider.dart';
import 'package:moovapp/core/providers/auth_provider.dart';
import 'package:moovapp/core/providers/reservation_provider.dart';
import 'package:moovapp/features/ratings/screens/rate_driver_screen.dart';
import 'package:moovapp/widgets/star_rating.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onCancel;
  final VoidCallback? onViewDetails;

  const ReservationCard({
    super.key,
    required this.reservation,
    this.onCancel,
    this.onViewDetails,
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
              // ✅ En-tête avec numéro et statut
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
              
              // ✅ Informations du trajet
              if (reservation.ride != null) 
                ..._buildRideInfo(reservation.ride!, colors),
              
              const Divider(height: 24),
              
              // ✅ Détails de la réservation
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
              
              // ✅ Date de réservation
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
              
              // ✅ Avertissement pour annulation
              if (reservation.status == 'confirmed' && onCancel != null) ...[
                const SizedBox(height: 16),
                _buildCancellationWarning(reservation, colors),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showCancellationDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.cancel, size: 20),
                    label: const Text(
                      'Annuler la réservation',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
              
              // ✅ BOUTON CONDUCTEUR : Marquer comme terminé (visible seulement au conducteur)
              Builder(builder: (context) {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final reservationProv = Provider.of<ReservationProvider>(context, listen: false);
                final isDriver = auth.currentUser != null && reservation.ride?.driverId == auth.currentUser!.uid;

                if (reservation.status.toLowerCase() != 'completed' && isDriver) {
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmMarkCompleted(context, reservation, reservationProv),
                          icon: const Icon(Icons.check_circle, size: 20),
                          label: const Text('Marquer comme terminé'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              }),

              // ✅ Message pour réservations annulées
              if (reservation.status == 'cancelled') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cette réservation a été annulée',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // ✅ Message pour réservations complétées
              if (reservation.status == 'completed') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, 
                           color: Colors.green[700], 
                           size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Trajet complété avec succès',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // ✅ NOUVEAU : Bouton pour noter le conducteur
                _buildRatingButton(context, reservation, colors),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRideInfo(RideModel ride, ColorScheme colors) {
    return [
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
              overflow: TextOverflow.ellipsis,
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
              overflow: TextOverflow.ellipsis,
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
                  ? _formatDateTime(ride.departureTime!)
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
        const SizedBox(height: 10),
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: colors.primaryContainer,
              child: Icon(
                Icons.person,
                size: 16,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              ride.driverName,
              style: TextStyle(
                color: colors.onSurface.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (ride.driverRating > 0) ...[
              const SizedBox(width: 12),
              Icon(Icons.star, size: 16, color: Colors.amber[600]),
              const SizedBox(width: 4),
              Text(
                ride.driverRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ],
    ];
  }

  // ✅ NOUVEAU : Bouton pour noter le conducteur
  Widget _buildRatingButton(BuildContext context, Reservation reservation, ColorScheme colors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final ratingProvider = Provider.of<RatingProvider>(context, listen: false);
          
          // Vérifier si peut noter
          final canRate = await ratingProvider.canRate(reservation.id);
          
          if (!context.mounted) return;
          
          if (canRate) {
            // Naviguer vers l'écran de notation
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => RateDriverScreen(
                  reservation: reservation,
                ),
              ),
            );
            
            // Optionnel : Actualiser les données après notation
            if (result == true && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Merci pour votre avis !'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
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
        },
        icon: const Icon(Icons.star_rate, size: 20),
        label: const Text('Noter le conducteur'),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ✅ NOUVEAU : Avertissement sur les conditions d'annulation
  Widget _buildCancellationWarning(Reservation reservation, ColorScheme colors) {
    // Calculer le temps restant avant le départ
    final departureTime = reservation.ride?.departureTime;
    String warningText = 'L\'annulation est possible jusqu\'à 24h avant le départ.';
    Color warningColor = Colors.orange[700]!;
    IconData warningIcon = Icons.info_outline;
    
    if (departureTime != null) {
      final hoursUntilDeparture = departureTime.difference(DateTime.now()).inHours;
      
      if (hoursUntilDeparture < 24) {
        warningText = '⚠️ Moins de 24h avant le départ. Des frais peuvent s\'appliquer.';
        warningColor = Colors.red[700]!;
        warningIcon = Icons.warning_amber_rounded;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: warningColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(warningIcon, color: warningColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              warningText,
              style: TextStyle(
                color: warningColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancellationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Annuler la réservation ?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Êtes-vous sûr de vouloir annuler cette réservation ?',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ Attention :',
                    style: TextStyle(
                      color: Colors.red[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Cette action est irréversible\n'
                    '• Le conducteur sera notifié\n'
                    '• Des frais peuvent s\'appliquer selon le délai',
                    style: TextStyle(
                      color: Colors.red[800],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Non, garder'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onCancel != null) onCancel!();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  void _confirmMarkCompleted(BuildContext context, Reservation reservation, ReservationProvider reservationProv) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.blue, size: 28),
            SizedBox(width: 12),
            Text('Marquer comme terminé ?'),
          ],
        ),
        content: const Text('Confirmez-vous que le trajet est bien terminé ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final scaffold = ScaffoldMessenger.of(context);
              try {
                final success = await reservationProv.markCompleted(reservation.id);
                if (success) {
                  scaffold.showSnackBar(const SnackBar(
                    content: Text('Trajet marqué comme terminé'),
                    backgroundColor: Colors.green,
                  ));
                } else {
                  scaffold.showSnackBar(const SnackBar(
                    content: Text('Impossible de marquer le trajet'),
                    backgroundColor: Colors.red,
                  ));
                }
              } catch (e) {
                scaffold.showSnackBar(SnackBar(
                  content: Text('Erreur: $e'),
                ));
              }
            },
            child: const Text('Oui, terminer'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
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