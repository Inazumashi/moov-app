// File: lib/core/models/ride_model.dart
class RideModel {
  final String rideId;
  final String driverId;
  final String driverName;
  final double driverRating;
  final bool driverIsPremium;
  final String startPoint;
  final String endPoint;
  final DateTime departureTime;
  final int availableSeats;
  final double pricePerSeat;
  final String? vehicleInfo;
  final String? notes;
  final bool isRegularRide;

  RideModel({
    required this.rideId,
    required this.driverId,
    required this.driverName,
    required this.driverRating,
    this.driverIsPremium = false,
    required this.startPoint,
    required this.endPoint,
    required this.departureTime,
    required this.availableSeats,
    required this.pricePerSeat,
    this.vehicleInfo,
    this.notes,
    this.isRegularRide = false,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      rideId: json['rideId'] ?? json['id']?.toString() ?? '',
      driverId: json['driverId']?.toString() ?? '',
      driverName: json['driverName'] ?? '${json['driverFirstName']} ${json['driverLastName']}',
      driverRating: double.tryParse(json['driverRating']?.toString() ?? '0') ?? 0.0,
      driverIsPremium: json['driverIsPremium'] ?? false,
      startPoint: json['startPoint'] ?? json['departureAddress'] ?? '',
      endPoint: json['endPoint'] ?? json['destinationAddress'] ?? '',
      departureTime: DateTime.parse(json['departureTime'] ?? json['departureDate']),
      availableSeats: json['availableSeats'] ?? 0,
      pricePerSeat: double.tryParse(json['pricePerSeat']?.toString() ?? '0') ?? 0.0,
      vehicleInfo: json['vehicleInfo'] ?? json['carModel'],
      notes: json['notes'] ?? json['description'],
      isRegularRide: json['isRegularRide'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'driverId': driverId,
      'driverName': driverName,
      'driverRating': driverRating,
      'driverIsPremium': driverIsPremium,
      'startPoint': startPoint,
      'endPoint': endPoint,
      'departureTime': departureTime.toIso8601String(),
      'availableSeats': availableSeats,
      'pricePerSeat': pricePerSeat,
      'vehicleInfo': vehicleInfo,
      'notes': notes,
      'isRegularRide': isRegularRide,
    };
  }
}