// File: lib/features/reservations/screens/book_ride_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/providers/reservation_provider.dart';

class BookRideScreen extends StatefulWidget {
  final RideModel ride;
  final VoidCallback? onReservationSuccess;

  const BookRideScreen({
    super.key,
    required this.ride,
    this.onReservationSuccess,
  });

  @override
  _BookRideScreenState createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> {
  int _selectedSeats = 1;

  void _bookRide(BuildContext context) async {
    if (_selectedSeats > widget.ride.availableSeats) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nombre de places non disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final reservationProvider =
        Provider.of<ReservationProvider>(context, listen: false);

    final success = await reservationProvider.createReservation(
      rideId: int.tryParse(widget.ride.rideId) ?? 0,
      seats: _selectedSeats,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Réservation confirmée !'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      if (widget.onReservationSuccess != null) {
        widget.onReservationSuccess!();
      }

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${reservationProvider.error}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _selectedSeats * widget.ride.pricePerSeat;
    final reservationProvider = Provider.of<ReservationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver un trajet'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte d'information du trajet
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.red, size: 20),
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
                        Text(
                          widget.ride.departureTime != null
                            ? '${_formatDate(widget.ride.departureTime!)} à ${_formatTime(widget.ride.departureTime!)}'
                            : 'Trajet régulier',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.attach_money,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Text('${widget.ride.pricePerSeat.toStringAsFixed(2)} DH par place'),
                      ],
                    ),
                    if (widget.ride.vehicleInfo != null && widget.ride.vehicleInfo!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.directions_car,
                              color: Colors.purple, size: 18),
                          const SizedBox(width: 8),
                          Text('${widget.ride.vehicleInfo}'),
                        ],
                      ),
                    ],
                    
                    // Si c'est un trajet régulier, afficher les jours
                    if (widget.ride.scheduleDays != null && widget.ride.scheduleDays!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.repeat, color: Colors.deepPurple, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Jours: ${widget.ride.scheduleDays!.join(', ')}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sélection du nombre de places
            const Text(
              'Nombre de places à réserver:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _selectedSeats.toDouble(),
                    min: 1,
                    max: widget.ride.availableSeats.toDouble(),
                    divisions: widget.ride.availableSeats > 1 ? widget.ride.availableSeats - 1 : 0,
                    label: _selectedSeats.toString(),
                    onChanged: (double value) {
                      setState(() {
                        _selectedSeats = value.toInt();
                      });
                    },
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

            const SizedBox(height: 24),

            // Résumé du prix
            Card(
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
                          '$_selectedSeats place(s) × ${widget.ride.pricePerSeat.toStringAsFixed(2)} DH',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${totalPrice.toStringAsFixed(2)} DH',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Bouton de confirmation
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: reservationProvider.isLoading
                    ? null
                    : () => _bookRide(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: reservationProvider.isLoading
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
                          Text('Réservation en cours...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline),
                          SizedBox(width: 8),
                          Text(
                            'Confirmer la réservation',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}