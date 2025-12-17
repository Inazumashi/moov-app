// File: lib/features/reservations/screens/book_ride_screen.dart - VERSION CORRIGÉE COMPLÈTE
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/providers/reservation_provider.dart';

typedef OnBookingComplete = void Function();

class BookRideScreen extends StatefulWidget {
  final RideModel ride;
  final OnBookingComplete? onBookingComplete;

  const BookRideScreen({
    super.key,
    required this.ride,
    this.onBookingComplete,
  });

  @override
  _BookRideScreenState createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> {
  int _selectedSeats = 1;
  bool _isBooking = false; // Protection contre les doubles clics

  Future<void> _bookRide(BuildContext context) async {
    // Protection contre les doubles clics
    if (_isBooking) {
      print('⚠️ Réservation déjà en cours, ignore...');
      return;
    }

    // Validation du nombre de places
    if (_selectedSeats > widget.ride.availableSeats) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nombre de places non disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation de l'ID du trajet
    final rideId = int.tryParse(widget.ride.rideId) ?? 0;
    if (rideId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: ID du trajet invalide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('🚗 Début réservation: rideId=$rideId, seats=$_selectedSeats');

    _isBooking = true;
    final reservationProvider =
        Provider.of<ReservationProvider>(context, listen: false);

    try {
      // ✅ CORRECTION: Utiliser bookRide au lieu de createReservation
      // bookRide envoie UNE SEULE requête avec le bon format
      final success = await reservationProvider.bookRide(rideId, _selectedSeats);

      if (success) {
        print('✅ Réservation réussie!');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Réservation confirmée !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Callback et navigation
        widget.onBookingComplete?.call();
        
        // Petit délai pour que l'utilisateur voie le message
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        print('❌ Échec réservation: ${reservationProvider.error}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${reservationProvider.error}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('❌ Exception dans _bookRide: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Erreur lors de la réservation'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _selectedSeats * widget.ride.pricePerSeat;
    final reservationProvider = Provider.of<ReservationProvider>(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Calcul de l'état de chargement
    final isLoading = reservationProvider.isLoading || _isBooking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver un trajet'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte d'information du trajet
            _buildRideInfoCard(),
            const SizedBox(height: 24),

            // Sélection du nombre de places
            _buildSeatSelection(),
            const SizedBox(height: 24),

            // Résumé du prix
            _buildPriceSummary(totalPrice),
            const SizedBox(height: 32),

            // Bouton de confirmation
            _buildConfirmationButton(isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildRideInfoCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.ride.startPoint,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Divider(height: 20),
            ),
            Row(
              children: [
                const Icon(Icons.place, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.ride.endPoint,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue, size: 18),
                const SizedBox(width: 8),
                Text(widget.ride.driverName.isNotEmpty
                    ? widget.ride.driverName
                    : 'Conducteur'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.event, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Text(_formatDepartureTime(widget.ride)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Text('${widget.ride.pricePerSeat} DH par place'),
              ],
            ),
            if (widget.ride.vehicleInfo != null &&
                widget.ride.vehicleInfo!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.directions_car,
                      color: Colors.purple, size: 18),
                  const SizedBox(width: 8),
                  Text(widget.ride.vehicleInfo!),
                ],
              ),
            ],
            if (widget.ride.scheduleDays != null &&
                widget.ride.scheduleDays!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.repeat, color: Colors.purple, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Jours: ${widget.ride.scheduleDays!.join(", ")}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSeatSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre de places à réserver:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: widget.ride.availableSeats > 1
                  ? Slider(
                      value: _selectedSeats.toDouble(),
                      min: 1,
                      max: widget.ride.availableSeats.toDouble(),
                      divisions: widget.ride.availableSeats - 1,
                      label: _selectedSeats.toString(),
                      onChanged: (double value) {
                        setState(() {
                          _selectedSeats = value.toInt();
                        });
                      },
                    )
                  : Slider(
                      value: 1.0,
                      min: 1,
                      max: 1,
                      divisions: null,
                      label: '1',
                      onChanged: null,
                    ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_selectedSeats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Places disponibles: ${widget.ride.availableSeats}',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(double totalPrice) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total à payer:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$_selectedSeats place(s) × ${widget.ride.pricePerSeat} DH',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Text(
              '$totalPrice DH',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () => _bookRide(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Réservation en cours...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Confirmer la réservation',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  String _formatDepartureTime(RideModel ride) {
    if (ride.departureTime != null) {
      final date = ride.departureTime!;
      return '${date.day}/${date.month}/${date.year} à '
          '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
    } else if (ride.scheduleDays != null && ride.scheduleDays!.isNotEmpty) {
      final days = ride.scheduleDays!.join(", ");
      final timeSlot = ride.timeSlot ?? "Heure non définie";
      return 'Trajet régulier ($days) - $timeSlot';
    } else {
      return 'Date et heure non définies';
    }
  }

  @override
  void dispose() {
    // Nettoyage
    _isBooking = false;
    super.dispose();
  }
}