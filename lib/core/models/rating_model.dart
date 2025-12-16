// File: lib/core/models/rating_model.dart
class RatingModel {
  final int id;
  final int bookingId;
  final int rideId;
  final int passengerId;
  final int driverId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? passengerName;
  final String? passengerLastName;
  final String? driverName;
  final String? driverLastName;

  RatingModel({
    required this.id,
    required this.bookingId,
    required this.rideId,
    required this.passengerId,
    required this.driverId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.passengerName,
    this.passengerLastName,
    this.driverName,
    this.driverLastName,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? json['bookingId'] ?? 0,
      rideId: json['ride_id'] ?? json['rideId'] ?? 0,
      passengerId: json['passenger_id'] ?? json['passengerId'] ?? 0,
      driverId: json['driver_id'] ?? json['driverId'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      passengerName: json['passenger_name'],
      passengerLastName: json['passenger_last_name'],
      driverName: json['driver_name'],
      driverLastName: json['driver_last_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'ride_id': rideId,
      'passenger_id': passengerId,
      'driver_id': driverId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'passenger_name': passengerName,
      'passenger_last_name': passengerLastName,
      'driver_name': driverName,
      'driver_last_name': driverLastName,
    };
  }

  // Helper pour obtenir le nom complet du conducteur
  String get driverFullName {
    final name = (driverName ?? '').trim();
    final lastName = (driverLastName ?? '').trim();
    return '$name $lastName'.trim();
  }

  // Helper pour obtenir le nom complet du passager
  String get passengerFullName {
    final name = (passengerName ?? '').trim();
    final lastName = (passengerLastName ?? '').trim();
    return '$name $lastName'.trim();
  }
}
