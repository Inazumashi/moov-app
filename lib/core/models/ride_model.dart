// File: lib/core/models/ride_model.dart - CORRECTION
class RideModel {
  final String rideId;
  final String driverId;
  final String driverName;
  final double driverRating;
  final bool driverIsPremium;
  final String startPoint;
  final String endPoint;

  final DateTime? departureTime;
  final List<String>? scheduleDays;
  final String? timeSlot;

  final int availableSeats;
  final double pricePerSeat;
  final String? vehicleInfo;
  final String? notes;
  final bool isRegularRide;

  // NOUVEAU : IDs des stations
  final int? departureStationId;
  final int? arrivalStationId;

  RideModel({
    this.rideId = '',
    required this.driverId,
    this.driverName = '',
    this.driverRating = 0.0,
    this.driverIsPremium = false,
    required this.startPoint,
    required this.endPoint,
    this.departureTime,
    this.scheduleDays,
    this.timeSlot,
    required this.availableSeats,
    required this.pricePerSeat,
    this.vehicleInfo,
    this.notes,
    this.isRegularRide = false,
    this.departureStationId,
    this.arrivalStationId,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      rideId: json['ride_id']?.toString() ?? '',
      driverId: json['driver_id']?.toString() ?? '',
      driverName: json['driver_name'] ?? 'Conducteur',
      driverRating:
          double.tryParse(json['driver_rating']?.toString() ?? '0.0') ?? 0.0,
      driverIsPremium: json['driver_is_premium'] ?? false,

      startPoint:
          json['departure_address'] ?? json['departure_station_name'] ?? '',
      endPoint: json['arrival_address'] ?? json['arrival_station_name'] ?? '',

      departureTime: json['departure_time'] != null
          ? DateTime.parse(json['departure_time'])
          : null,

      scheduleDays: json['schedule_days'] != null
          ? _parseScheduleDays(json['schedule_days'])
          : null,
      timeSlot: json['schedule_time'] ?? json['time_slot'],

      availableSeats: json['available_seats'] ?? 0,
      pricePerSeat:
          double.tryParse(json['price_per_seat']?.toString() ?? '0.0') ?? 0.0,
      vehicleInfo: json['vehicle_details'] ?? json['vehicle_info'],
      notes: json['notes'],
      isRegularRide: json['is_regular'] ?? false,

      // NOUVEAU : IDs des stations
      departureStationId: json['departure_station_id'] != null
          ? int.tryParse(json['departure_station_id'].toString())
          : null,
      arrivalStationId: json['arrival_station_id'] != null
          ? int.tryParse(json['arrival_station_id'].toString())
          : null,
    );
  }

  static List<String>? _parseScheduleDays(dynamic daysData) {
    if (daysData == null) return null;

    if (daysData is List) {
      return List<String>.from(daysData.map((day) => day.toString()));
    } else if (daysData is String) {
      return daysData.split(',').map((day) => day.trim()).toList();
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'ride_id': rideId,
      'driver_id': driverId,

      // ENVOYER LES NOMS POUR L'AFFICHAGE
      'departure_address': startPoint,
      'arrival_address': endPoint,

      // ENVOYER LES IDs POUR LE BACKEND
      if (departureStationId != null)
        'departure_station_id': departureStationId,
      if (arrivalStationId != null) 'arrival_station_id': arrivalStationId,

      if (departureTime != null)
        'departure_time': departureTime!.toIso8601String(),
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
