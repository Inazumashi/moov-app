// File: lib/core/models/reservation.dart
import 'package:moovapp/core/models/ride_model.dart';

class Reservation {
  final int id;
  final String rideId;
  final int passengerId;
  final int seatsReserved;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final RideModel? ride;
  final String? driverFirstName;
  final String? driverLastName;

  Reservation({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.seatsReserved,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.ride,
    this.driverFirstName,
    this.driverLastName,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? 0,
      rideId: json['ride_id']?.toString() ?? '',
      passengerId: json['passenger_id'] ?? 0,
      seatsReserved: json['seats_reserved'] ?? json['seats_booked'] ?? 1,
      totalPrice: (json['total_price'] is int) 
          ? (json['total_price'] as int).toDouble() 
          : (json['total_price'] as double?) ?? 0.0,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      ride: json['ride'] != null ? RideModel.fromJson(json['ride']) : null,
      driverFirstName: json['driver_first_name'],
      driverLastName: json['driver_last_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ride_id': rideId,
      'seats_reserved': seatsReserved,
    };
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedTime {
    return '${createdAt.hour}h${createdAt.minute.toString().padLeft(2, '0')}';
  }

  // Statut traduit en français
  String get statusText {
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
  
  // Couleur selon le statut
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return '#38A169'; // Vert
      case 'cancelled':
        return '#E53E3E'; // Rouge
      case 'completed':
        return '#3182CE'; // Bleu
      case 'pending':
        return '#D69E2E'; // Orange
      default:
        return '#718096'; // Gris
    }
  }
}