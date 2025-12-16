import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/providers/reservation_provider.dart';
import 'package:moovapp/core/providers/auth_provider.dart';

class ReservationFlowModal extends StatefulWidget {
  final RideModel ride;

  const ReservationFlowModal({super.key, required this.ride});

  @override
  State<ReservationFlowModal> createState() => _ReservationFlowModalState();
}

class _ReservationFlowModalState extends State<ReservationFlowModal> {
  int selectedSeats = 1;
  String selectedPaymentMethod = 'card';
  bool acceptTerms = false;
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final totalPrice = widget.ride.pricePerSeat * selectedSeats;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Réserver un trajet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.outline),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trajet info
                      _buildRideInfo(colors),
                      const SizedBox(height: 24),

                      // Nombre de places
                      _buildSeatsSelector(colors),
                      const SizedBox(height: 24),

                      // Récapitulatif prix
                      _buildPriceSummary(colors, totalPrice),
                      const SizedBox(height: 24),

                      // Paiement
                      _buildPaymentMethod(colors),
                      const SizedBox(height: 24),

                      // Conditions
                      _buildTermsCheckbox(colors),
                      const SizedBox(height: 24),

                      // Infos passager
                      _buildPassengerInfo(colors),
                    ],
                  ),
                ),
              ),

              // Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: acceptTerms && !isProcessing
                            ? () => _processReservation(context, totalPrice)
                            : null,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Confirmer la réservation'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: isProcessing ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRideInfo(ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.ride.startPoint} → ${widget.ride.endPoint}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${widget.ride.departureTime?.day}/${widget.ride.departureTime?.month}',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: colors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  widget.ride.driverName,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatsSelector(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre de places',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: colors.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: selectedSeats > 1
                    ? () => setState(() => selectedSeats--)
                    : null,
              ),
              Text(
                '$selectedSeats',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: selectedSeats < widget.ride.availableSeats
                    ? () => setState(() => selectedSeats++)
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.ride.availableSeats} places disponibles',
          style: TextStyle(
            fontSize: 12,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(ColorScheme colors, double totalPrice) {
    return Container(
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
              Text(
                'Prix unitaire:',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              Text(
                '${widget.ride.pricePerSeat}€',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nombre de places:',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              Text(
                '$selectedSeats',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
          Divider(height: 16, color: colors.outline),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '$totalPrice€',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Moyen de paiement',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          colors,
          'card',
          'Carte bancaire',
          Icons.credit_card,
        ),
        const SizedBox(height: 8),
        _buildPaymentOption(
          colors,
          'wallet',
          'Portefeuille numérique',
          Icons.account_balance_wallet,
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    ColorScheme colors,
    String value,
    String label,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => setState(() => selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedPaymentMethod == value
                ? colors.primary
                : colors.outline,
            width: selectedPaymentMethod == value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(width: 12),
            Text(label),
            const Spacer(),
            if (selectedPaymentMethod == value)
              Icon(Icons.check_circle, color: colors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox(ColorScheme colors) {
    return Row(
      children: [
        Checkbox(
          value: acceptTerms,
          onChanged: (value) => setState(() => acceptTerms = value ?? false),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => acceptTerms = !acceptTerms),
            child: Text.rich(
              TextSpan(
                text: 'J\'accepte les ',
                children: [
                  TextSpan(
                    text: 'conditions d\'utilisation',
                    style: TextStyle(
                      color: colors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' et '),
                  TextSpan(
                    text: 'la politique de confidentialité',
                    style: TextStyle(
                      color: colors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerInfo(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations passager',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final user = authProvider.currentUser;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nom: ${user?.fullName ?? 'Non spécifié'}',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: ${user?.email ?? 'Non spécifié'}',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Téléphone: ${user?.phoneNumber ?? 'Non spécifié'}',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _processReservation(BuildContext context, double totalPrice) async {
    setState(() => isProcessing = true);

    try {
      final reservationProvider =
          Provider.of<ReservationProvider>(context, listen: false);

      // Créer la réservation
      await reservationProvider.createReservation(
        rideId: int.parse(widget.ride.rideId),
        seats: selectedSeats,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Réservation confirmée!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }
}
