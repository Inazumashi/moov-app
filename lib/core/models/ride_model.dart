// File: lib/core/models/ride_model.dart
class RideModel {
  final String rideId;
  final String driverId;
  final String driverName;
  final double driverRating;
  final bool driverIsPremium;
  final String startPoint;
  final String endPoint;
<<<<<<< HEAD
  final DateTime departureTime;
=======
  
  // 1. Pour les trajets ponctuels (ex: Demain à 8h)
  final DateTime? departureTime; 

  // 2. Pour les trajets habituels (ex: Inscription)
  final List<String>? scheduleDays; // ["Lun", "Mar"]
  final String? timeSlot;          // "Matin (6h-12h)"

>>>>>>> 38397c1094c7156cf54cdb86b901a3d5d3bc6b55
  final int availableSeats;
  final double pricePerSeat;
  final String? vehicleInfo;
  final String? notes;
  final bool isRegularRide; // True si c'est une habitude

  RideModel({
    this.rideId = '', // Rendons-le optionnel pour la création
    required this.driverId,
    this.driverName = '', // Optionnel car à l'inscription on ne le sait pas encore
    this.driverRating = 0.0,
    this.driverIsPremium = false,
    required this.startPoint,
    required this.endPoint,
    this.departureTime,   // Devenu nullable
    this.scheduleDays,    // Nouveau
    this.timeSlot,        // Nouveau
    required this.availableSeats,
    required this.pricePerSeat,
    this.vehicleInfo,
    this.notes,
    this.isRegularRide = false,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
<<<<<<< HEAD
      rideId: json['rideId'] ?? json['id']?.toString() ?? '',
      driverId: json['driverId']?.toString() ?? '',
      driverName: json['driverName'] ??
          '${json['driverFirstName']} ${json['driverLastName']}',
      driverRating:
          double.tryParse(json['driverRating']?.toString() ?? '0') ?? 0.0,
      driverIsPremium: json['driverIsPremium'] ?? false,
      startPoint: json['startPoint'] ?? json['departureAddress'] ?? '',
      endPoint: json['endPoint'] ?? json['destinationAddress'] ?? '',
      departureTime:
          DateTime.parse(json['departureTime'] ?? json['departureDate']),
      availableSeats: json['availableSeats'] ?? 0,
      pricePerSeat:
          double.tryParse(json['pricePerSeat']?.toString() ?? '0') ?? 0.0,
      vehicleInfo: json['vehicleInfo'] ?? json['carModel'],
      notes: json['notes'] ?? json['description'],
      isRegularRide: json['isRegularRide'] ?? false,
=======
      rideId: json['ride_id']?.toString() ?? '',
      driverId: json['driver_id']?.toString() ?? '',
      driverName: json['driver_name'] ?? 'Conducteur',
      driverRating: double.tryParse(json['driver_rating']?.toString() ?? '0.0') ?? 0.0,
      driverIsPremium: json['driver_is_premium'] ?? false,
      
      startPoint: json['departure_address'] ?? '',
      endPoint: json['arrival_address'] ?? '',
      
      // Gestion intelligente de la date
      departureTime: json['departure_time'] != null 
          ? DateTime.parse(json['departure_time']) 
          : null,
          
      // Récupération des jours (si le backend les envoie comme string "Lun,Mar")
      scheduleDays: json['schedule_days'] != null 
          ? (json['schedule_days'] as String).split(',') 
          : [],
      timeSlot: json['schedule_time'],

      availableSeats: json['available_seats'] ?? 0,
      pricePerSeat: double.tryParse(json['price_per_seat']?.toString() ?? '0.0') ?? 0.0,
      vehicleInfo: json['vehicle_details'],
      notes: json['notes'],
      isRegularRide: json['is_regular'] ?? false,
>>>>>>> 38397c1094c7156cf54cdb86b901a3d5d3bc6b55
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ride_id': rideId,
      'driver_id': driverId,
      'departure_address': startPoint,
      'arrival_address': endPoint,
      
      // On envoie la date SI elle existe
      if (departureTime != null) 'departure_time': departureTime!.toIso8601String(),
      
      // On envoie les jours SI c'est une habitude
      if (scheduleDays != null) 'schedule_days': scheduleDays!.join(','), // Envoie "Lun,Mar"
      if (timeSlot != null) 'schedule_time': timeSlot,

      'available_seats': availableSeats,
      'price_per_seat': pricePerSeat,
      'is_regular': isRegularRide,
      'vehicle_details': vehicleInfo,
      'notes': notes,
    };
  }
}
