// File: lib/core/models/ride_model.dart
class RideModel {
  final String rideId;
  final String driverId;
  final String driverName;
  final double driverRating;
  final bool driverIsPremium;
  final String startPoint;
  final String endPoint;
  
  // 1. Pour les trajets ponctuels (ex: Demain à 8h)
  final DateTime? departureTime; 
  
  // 2. Pour les trajets habituels (ex: Inscription) - AJOUTEZ CES CHAMPS
  final List<String>? scheduleDays; // ["Lun", "Mar"]
  final String? timeSlot;          // "Matin (6h-12h)"
  
  final int availableSeats;
  final double pricePerSeat;
  final String? vehicleInfo;
  final String? notes;
  final bool isRegularRide; // True si c'est une habitude

  RideModel({
    this.rideId = '',
    required this.driverId,
    this.driverName = '',
    this.driverRating = 0.0,
    this.driverIsPremium = false,
    required this.startPoint,
    required this.endPoint,
    this.departureTime,
    this.scheduleDays,    // AJOUTÉ
    this.timeSlot,        // AJOUTÉ
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
      driverName: json['driver_name'] ?? 'Conducteur',
      driverRating: double.tryParse(json['driver_rating']?.toString() ?? '0.0') ?? 0.0,
      driverIsPremium: json['driver_is_premium'] ?? false,
      
      startPoint: json['departure_address'] ?? '',
      endPoint: json['arrival_address'] ?? '',
      
      // Gestion intelligente de la date
      departureTime: json['departure_time'] != null 
          ? DateTime.parse(json['departure_time']) 
          : null,
          
      // Récupération des jours (si le backend les envoie)
      scheduleDays: json['schedule_days'] != null 
          ? _parseScheduleDays(json['schedule_days'])
          : null,
      timeSlot: json['schedule_time'] ?? json['time_slot'],

      availableSeats: json['available_seats'] ?? 0,
      pricePerSeat: double.tryParse(json['price_per_seat']?.toString() ?? '0.0') ?? 0.0,
      vehicleInfo: json['vehicle_details'] ?? json['vehicle_info'],
      notes: json['notes'],
      isRegularRide: json['is_regular'] ?? false,
    );
  }

  // Helper pour parser les jours de planning
  static List<String>? _parseScheduleDays(dynamic daysData) {
    if (daysData == null) return null;
    
    if (daysData is List) {
      return List<String>.from(daysData.map((day) => day.toString()));
    } else if (daysData is String) {
      // Si c'est une string comme "Lun,Mar,Mer"
      return daysData.split(',').map((day) => day.trim()).toList();
    }
    
    return null;
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
      if (scheduleDays != null) 'schedule_days': scheduleDays!.join(','),
      if (timeSlot != null) 'schedule_time': timeSlot,

      'available_seats': availableSeats,
      'price_per_seat': pricePerSeat,
      'is_regular': isRegularRide,
      'vehicle_details': vehicleInfo,
      'notes': notes,
    };
  }

  // Méthodes utilitaires
  String get formattedDate {
    if (departureTime == null) return 'Trajet régulier';
    return '${departureTime!.day}/${departureTime!.month}/${departureTime!.year}';
  }

  String get formattedTime {
    if (departureTime == null) return timeSlot ?? 'Heure non définie';
    return '${departureTime!.hour}h${departureTime!.minute.toString().padLeft(2, '0')}';
  }

  String get displayRoute {
    return '$startPoint → $endPoint';
  }

  bool get isTrajetPonctuel => departureTime != null;
  bool get isTrajetRegulier => isRegularRide || scheduleDays != null;
}