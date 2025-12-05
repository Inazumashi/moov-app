import 'package:moovapp/core/models/reservation.dart';

class ReservationUtils {
  // Convertir le statut en texte lisible
  static String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmée';
      case 'cancelled':
        return 'Annulée';
      case 'completed':
        return 'Terminée';
      case 'pending':
        return 'En attente';
      default:
        return status;
    }
  }

  // Obtenir la couleur du statut
  static int getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 0xFF4CAF50; // Vert
      case 'cancelled':
        return 0xFFF44336; // Rouge
      case 'completed':
        return 0xFF2196F3; // Bleu
      case 'pending':
        return 0xFFFF9800; // Orange
      default:
        return 0xFF9E9E9E; // Gris
    }
  }

  // Vérifier si une réservation peut être annulée
  static bool canCancel(Reservation reservation) {
    return reservation.status == 'confirmed';
  }

  // Formater le prix
  static String formatPrice(double price) {
    return '${price.toStringAsFixed(2)} DH';
  }

  // Calculer le temps restant avant le trajet
  static String getTimeRemaining(DateTime? departureTime) {
    if (departureTime == null) return 'Date inconnue';
    
    final now = DateTime.now();
    final difference = departureTime.difference(now);

    if (difference.isNegative) {
      return 'Terminé';
    }

    if (difference.inDays > 0) {
      return 'Dans ${difference.inDays} jour(s)';
    } else if (difference.inHours > 0) {
      return 'Dans ${difference.inHours} heure(s)';
    } else if (difference.inMinutes > 0) {
      return 'Dans ${difference.inMinutes} minute(s)';
    } else {
      return 'Maintenant';
    }
  }
}