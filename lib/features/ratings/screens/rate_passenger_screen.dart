// File: lib/features/ratings/screens/rate_passenger_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/models/reservation.dart';
import 'package:moovapp/core/providers/rating_provider.dart';

class RatePassengerScreen extends StatefulWidget {
  final Reservation reservation;

  const RatePassengerScreen({
    super.key,
    required this.reservation,
  });

  @override
  State<RatePassengerScreen> createState() => _RatePassengerScreenState();
}

class _RatePassengerScreenState extends State<RatePassengerScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une note'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final ratingProvider = Provider.of<RatingProvider>(context, listen: false);

    // Convertir les IDs
    final rideId = widget.reservation.rideId;
    final passengerId = int.tryParse(widget.reservation.passengerId) ?? 0;

    if (passengerId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur: ID passager invalide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ratingProvider.rateDriver(
      bookingId: widget.reservation.id,
      rideId: rideId,
      driverId: passengerId, // Ici on note le passager
      rating: _rating,
      comment: _commentController.text.isEmpty ? null : _commentController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Note enregistrée avec succès'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${ratingProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return '😞 Très décevant';
      case 2:
        return '😕 Décevant';
      case 3:
        return '😐 Correct';
      case 4:
        return '😊 Bien';
      case 5:
        return '😍 Excellent';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final ratingProvider = Provider.of<RatingProvider>(context);

    final passengerName = widget.reservation.passengerName ?? 'Passager';
    final startPoint = widget.reservation.ride?.startPoint ?? 'Départ';
    final endPoint = widget.reservation.ride?.endPoint ?? 'Arrivée';

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: const Text('Noter le passager'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Illustration
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 80,
                color: colors.onPrimaryContainer,
              ),
            ),

            const SizedBox(height: 24),

            // Nom du passager
            Text(
              passengerName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Itinéraire
            Text(
              '$startPoint → $endPoint',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Question
            Text(
              'Comment s\'est comporté ce passager ?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Étoiles de notation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = starIndex;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      starIndex <= _rating ? Icons.star : Icons.star_border,
                      size: 48,
                      color: starIndex <= _rating
                          ? Colors.amber
                          : Colors.grey[400],
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            // Texte de la note
            if (_rating > 0)
              Text(
                _getRatingText(_rating),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),

            const SizedBox(height: 32),

            // Champ de commentaire
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Commentaire (optionnel)',
                hintText: 'Partagez votre expérience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.comment),
                filled: true,
                fillColor: colors.primaryContainer.withOpacity(0.3),
              ),
              maxLines: 4,
              maxLength: 500,
            ),

            const SizedBox(height: 32),

            // Bouton de soumission
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: ratingProvider.isLoading ? null : _submitRating,
                icon: ratingProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  ratingProvider.isLoading
                      ? 'Envoi en cours...'
                      : 'Envoyer ma note',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Bouton annuler
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Plus tard'),
            ),
          ],
        ),
      ),
    );
  }
}