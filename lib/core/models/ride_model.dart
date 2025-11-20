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
      rideId: json['ride_id']?.toString() ?? '',
      driverId: json['driver_id']?.toString() ?? '',
      driverName: json['driver_name'] ?? 'Conducteur inconnu', 
      driverRating: double.tryParse(json['driver_rating']?.toString() ?? '0.0') ?? 0.0,
      driverIsPremium: json['driver_is_premium'] ?? false,
      startPoint: json['departure_address'] ?? '',
      endPoint: json['arrival_address'] ?? '',
      departureTime: json['departure_time'] != null 
          ? DateTime.parse(json['departure_time']) 
          : DateTime.now(),
      availableSeats: json['available_seats'] ?? 0,
      pricePerSeat: double.tryParse(json['price_per_seat']?.toString() ?? '0.0') ?? 0.0,
      vehicleInfo: json['vehicle_details'],
      notes: json['notes'],
      isRegularRide: json['is_regular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ride_id': rideId,
      'driver_id': driverId,
      'departure_address': startPoint,
      'arrival_address': endPoint,
      'departure_time': departureTime.toIso8601String(),
      'available_seats': availableSeats,
      'price_per_seat': pricePerSeat,
      'is_regular': isRegularRide,
      'vehicle_details': vehicleInfo,
      'notes': notes,
    };
  }
}