// lib/features/home/widgets/my_reservations_widget.dart - VERSION FINALE CORRIGÉE
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/reservation_provider.dart';
import 'package:moovapp/features/home/widgets/reservation_card_with_actions.dart';

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
    final colors = Theme.of(context).colorScheme;

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
        if (provider.reservations.isEmpty) {
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
                      // Naviguer vers la recherche (via MainNavigationShell index 1)
                      // TODO: Implémenter navigation vers recherche
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

        // Liste des réservations avec filtres
        return Column(
          children: [
            // Filtres rapides
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  _buildFilterChip(
                    context,
                    'Toutes',
                    provider.filterStatus == 'all',
                    () => provider.filterByStatus('all'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    'En attente',
                    provider.filterStatus == 'pending',
                    () => provider.filterByStatus('pending'),
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    'Confirmées',
                    provider.filterStatus == 'confirmed',
                    () => provider.filterByStatus('confirmed'),
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    'Terminées',
                    provider.filterStatus == 'completed',
                    () => provider.filterByStatus('completed'),
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    'Annulées',
                    provider.filterStatus == 'cancelled',
                    () => provider.filterByStatus('cancelled'),
                    color: Colors.red,
                  ),
                ],
              ),
            ),

            // Liste des réservations
            ...provider.reservations.map((reservation) {
              return ReservationCardWithActions(
                reservation: reservation,
              );
            }).toList(),

            // Message si résultats filtrés vides
            if (provider.reservations.isEmpty && provider.filterStatus != null)
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
  }) {
    final colors = Theme.of(context).colorScheme;
    final chipColor = color ?? colors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : chipColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  String _getFilterLabel(String? status) {
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
}