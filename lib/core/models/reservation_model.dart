import 'ride_model.dart';

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
      id: json['id'],
      rideId: json['ride_id'].toString(),
      passengerId: json['passenger_id'],
      seatsReserved: json['seats_reserved'],
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      ride: json['ride'] != null ? _mapJsonToRideModel(json['ride']) : null,
      driverFirstName: json['driver_first_name'],
      driverLastName: json['driver_last_name'],
    );
  }

  static RideModel _mapJsonToRideModel(Map<String, dynamic> rideJson) {
    return RideModel(
      rideId: rideJson['id'].toString(),
      driverId: rideJson['driver_id'].toString(),
      driverName: '${rideJson['first_name']} ${rideJson['last_name']}',
      driverRating: rideJson['rating']?.toDouble() ?? 5.0,
      driverIsPremium: false,
      startPoint: rideJson['departure_address'] ?? '',
      endPoint: rideJson['destination_address'] ?? '',
      departureTime: DateTime.parse(rideJson['departure_date']),
      availableSeats: rideJson['available_seats'] ?? 0,
      pricePerSeat: double.parse(rideJson['price_per_seat'].toString()),
      vehicleInfo: rideJson['car_model'] != null && rideJson['car_color'] != null 
          ? '${rideJson['car_model']} - ${rideJson['car_color']}' 
          : null,
      notes: rideJson['description'],
      isRegularRide: false,
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
}