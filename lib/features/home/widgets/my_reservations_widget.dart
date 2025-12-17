// lib/features/home/widgets/my_reservations_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/reservation_provider.dart';
import 'package:moovapp/core/providers/chat_provider.dart';
import 'package:moovapp/features/home/widgets/reservation_card_with_actions.dart';
import 'package:moovapp/features/chat/screens/chat_screen.dart';
import 'package:moovapp/core/models/reservation.dart';
import 'package:moovapp/core/providers/auth_provider.dart'; // Si vous avez AuthProvider

class MyReservationsWidget extends StatefulWidget {
  const MyReservationsWidget({Key? key}) : super(key: key);

  @override
  State<MyReservationsWidget> createState() => _MyReservationsWidgetState();
}

class _MyReservationsWidgetState extends State<MyReservationsWidget> {
  @override
  void initState() {
    super.initState();
    // Charger les réservations au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ReservationProvider>(context, listen: false);
      provider.loadReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReservationProvider>(
      builder: (context, provider, child) {
        // État de chargement
        if (provider.isLoading && provider.reservations.isEmpty) {
          return Card(
            elevation: 0.5,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Erreur
        if (provider.error.isNotEmpty && provider.reservations.isEmpty) {
          return Card(
            elevation: 0.5,
            color: Colors.red.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Erreur de chargement',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => provider.loadReservations(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Aucune réservation
        if (provider.reservations.isEmpty && provider.filterStatus == 'all') {
          return Card(
            elevation: 0.5,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Column(
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune réservation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vos réservations de trajets apparaîtront ici',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Allez dans l\'onglet Recherche pour trouver un trajet'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Rechercher un trajet'),
                  ),
                ],
              ),
            ),
          );
        }

        // Récupérer les statistiques
        final stats = provider.reservationStats;
        
        // Liste des réservations avec filtres
        return Column(
          children: [
            // FILTRES ET STATISTIQUES
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Filtres avec compteurs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          context,
                          'Toutes',
                          provider.filterStatus == 'all',
                          () => provider.filterByStatus('all'),
                          count: stats['all'] ?? 0,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          'En attente',
                          provider.filterStatus == 'pending',
                          () => provider.filterByStatus('pending'),
                          color: Colors.orange,
                          count: stats['pending'] ?? 0,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          'Confirmées',
                          provider.filterStatus == 'confirmed',
                          () => provider.filterByStatus('confirmed'),
                          color: Colors.green,
                          count: stats['confirmed'] ?? 0,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          'Terminées',
                          provider.filterStatus == 'completed',
                          () => provider.filterByStatus('completed'),
                          color: Colors.blue,
                          count: stats['completed'] ?? 0,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          context,
                          'Annulées',
                          provider.filterStatus == 'cancelled',
                          () => provider.filterByStatus('cancelled'),
                          color: Colors.red,
                          count: stats['cancelled'] ?? 0,
                        ),
                      ],
                    ),
                  ),
                  
                  // Statistiques résumées
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem('Total', '${stats['all'] ?? 0}', Colors.blue),
                        _buildStatItem('Actives', '${(stats['pending'] ?? 0) + (stats['confirmed'] ?? 0)}', Colors.green),
                        _buildStatItem('Terminées', '${stats['completed'] ?? 0}', Colors.blue[700]!),
                        _buildStatItem('Annulées', '${stats['cancelled'] ?? 0}', Colors.red),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Liste des réservations
            ...provider.reservations.map((reservation) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ReservationCardWithActions(
                  reservation: reservation,
                  onCancel: () => _showCancelDialog(context, reservation.id, provider),
                  onViewDetails: () => _showReservationDetails(context, reservation),
                  onOpenChat: () => _openChatWithDriver(context, reservation),
                ),
              );
            }).toList(),

            // Message si résultats filtrés vides (mais il y a d'autres réservations)
            if (provider.reservations.isEmpty && provider.filterStatus != 'all')
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.filter_list_off,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune réservation ${_getFilterLabel(provider.filterStatus)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => provider.filterByStatus('all'),
                      child: const Text('Voir toutes les réservations'),
                    ),
                  ],
                ),
              ),

            // Indicateur de rechargement
            if (provider.isLoading && provider.reservations.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap, {
    Color? color,
    required int count,
  }) {
    final colors = Theme.of(context).colorScheme;
    final chipColor = color ?? colors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
            ? chipColor 
            : chipColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: chipColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : chipColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : chipColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? chipColor : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _getFilterLabel(String status) {
    switch (status) {
      case 'pending':
        return 'en attente';
      case 'confirmed':
        return 'confirmée';
      case 'completed':
        return 'terminée';
      case 'cancelled':
        return 'annulée';
      default:
        return '';
    }
  }

  void _showCancelDialog(BuildContext context, int reservationId, ReservationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette réservation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.cancelReservation(reservationId);
              
              if (!context.mounted) return;
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Réservation annulée avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: ${provider.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  void _showReservationDetails(BuildContext context, Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la réservation'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Réservation #${reservation.id}'),
              const SizedBox(height: 8),
              Text('Statut: ${reservation.status}'),
              const SizedBox(height: 8),
              Text('Places réservées: ${reservation.seatsReserved}'),
              const SizedBox(height: 8),
              Text('Prix total: ${reservation.totalPrice.toStringAsFixed(2)} DH'),
              const SizedBox(height: 8),
              Text('Date de création: ${reservation.formattedDate}'),
              const SizedBox(height: 8),
              if (reservation.ride != null) ...[
                const SizedBox(height: 8),
                const Text('Informations du trajet:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Départ: ${reservation.ride!.startPoint}'),
                Text('Arrivée: ${reservation.ride!.endPoint}'),
                if (reservation.ride!.departureTime != null)
                  Text('Date: ${reservation.ride!.departureTime!.toLocal()}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Dans my_reservations_widget.dart - Modifiez cette méthode
Future<void> _openChatWithDriver(BuildContext context, Reservation reservation) async {
  // DEBUG: Vérifiez les données
  print('💬 Tentative d\'ouverture du chat pour réservation #${reservation.id}');
  print('   - Ride ID: ${reservation.rideId}');
  print('   - Ride object: ${reservation.ride}');
  print('   - Ride object non null? ${reservation.ride != null}');
  
  if (reservation.ride != null) {
    print('   - Ride details:');
    print('     * Ride ID: ${reservation.ride!.rideId}');
    print('     * Driver ID: ${reservation.ride!.driverId}');
    print('     * Driver Name: ${reservation.ride!.driverName}');
    print('     * Route: ${reservation.ride!.startPoint} → ${reservation.ride!.endPoint}');
  }

  final chatProvider = Provider.of<ChatProvider>(context, listen: false);
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  // Assurez-vous que l'utilisateur est connecté
  final currentUserId = authProvider.currentUser?.uid;
  if (currentUserId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vous devez être connecté pour utiliser le chat')),
    );
    return;
  }
  
  // Définir l'ID utilisateur courant dans le chat provider
  chatProvider.setCurrentUserId(currentUserId);
  
  // Vérifiez si la réservation a un trajet
  if (reservation.ride == null) {
    print('❌ Ride est null pour la réservation #${reservation.id}');
    print('   - rideId dans reservation: ${reservation.rideId}');
    
    // Essayer de charger le trajet
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement des informations du trajet...'),
          ],
        ),
      ),
    );
    
    try {
      final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
      final updatedReservation = await reservationProvider.getReservationById(reservation.id);
      
      if (!context.mounted) return;
      Navigator.pop(context); // Fermer le loading
      
      if (updatedReservation?.ride != null) {
        print('✅ Trajet chargé avec succès');
        // Réessayer avec la réservation mise à jour
        await _openChatWithDriver(context, updatedReservation!);
        return;
      } else {
        print('❌ Impossible de charger le trajet après tentative');
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Fermer le loading
      print('❌ Erreur chargement trajet: $e');
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Impossible d\'ouvrir le chat: informations de trajet manquantes')),
    );
    return;
  }
  
  // Vérifier que rideId est valide
  final rideIdString = reservation.ride!.rideId;
  if (rideIdString.isEmpty || rideIdString == '0') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID du trajet invalide')),
    );
    return;
  }
  
  final rideId = int.tryParse(rideIdString);
  if (rideId == null || rideId == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ID du trajet invalide')),
    );
    return;
  }
  
  print('🚗 Tentative de création de conversation pour rideId: $rideId');
  
  // Afficher un indicateur de chargement
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );
  
  try {
    // Obtenir ou créer la conversation
    final conversationId = await chatProvider.getOrCreateConversation(rideId);
    
    if (!context.mounted) return;
    
    Navigator.pop(context); // Fermer l'indicateur de chargement
    
    if (conversationId == null) {
      print('❌ conversationId est null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'ouverture du chat')),
      );
      return;
    }
    
    print('✅ Conversation créée avec ID: $conversationId');
    print('   - Driver Name: ${reservation.ride!.driverName}');
    print('   - Route: ${reservation.ride!.startPoint} → ${reservation.ride!.endPoint}');
    
    // Naviguer vers l'écran de chat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversationId: conversationId,
          otherUserName: reservation.ride!.driverName.isNotEmpty 
              ? reservation.ride!.driverName 
              : 'Conducteur',
          rideInfo: '${reservation.ride!.startPoint} → ${reservation.ride!.endPoint}',
        ),
      ),
    ).then((_) {
      // Recharger les réservations après retour du chat
      Provider.of<ReservationProvider>(context, listen: false).loadReservations();
    });
    
  } catch (e) {
    if (!context.mounted) return;
    
    Navigator.pop(context); // Fermer l'indicateur de chargement
    
    print('❌ Erreur détaillée lors de l\'ouverture du chat: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}}