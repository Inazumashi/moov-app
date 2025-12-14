// File: lib/core/models/ride_model.dart - VERSION COMPLÈTE CORRIGÉE
import 'dart:convert';

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

  // ✅ IDs des stations
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
    // ✅ PARSING SPÉCIFIQUE POUR TON BACKEND
    DateTime? parsedDepartureTime;
    
    try {
      // Ton backend envoie "2025-12-17 19:00" dans departure_date
      if (json['departure_date'] != null && json['departure_date'].toString().isNotEmpty) {
        final dateStr = json['departure_date'].toString();
        parsedDepartureTime = DateTime.parse(dateStr);
      }
    } catch (e) {
      print('⚠️ Erreur parsing departure_date: ${json['departure_date']} - $e');
      parsedDepartureTime = null;
    }

    // ✅ IMPORTANT : Ton backend utilise 'departure_station' et 'arrival_station'
    final startPoint = json['departure_station'] ?? 
                      json['departure_station_name'] ?? 
                      json['departure_address'] ?? 
                      'Départ';
    
    final endPoint = json['arrival_station'] ?? 
                    json['arrival_station_name'] ?? 
                    json['arrival_address'] ?? 
                    'Arrivée';

    return RideModel(
      rideId: json['id']?.toString() ?? json['ride_id']?.toString() ?? '0',
      driverId: json['driver_id']?.toString() ?? '0',
      
      // ✅ Utiliser departure_station et arrival_station
      startPoint: startPoint,
      endPoint: endPoint,
      
      driverName: json['driver_name'] ?? 
                 '${json['driver_first_name'] ?? ''} ${json['driver_last_name'] ?? ''}'.trim() ??
                 'Conducteur',
      
      departureTime: parsedDepartureTime,
      
      // Conversion sûre des nombres
      availableSeats: (json['available_seats'] is int) 
          ? json['available_seats'] as int
          : int.tryParse(json['available_seats']?.toString() ?? '0') ?? 0,
      
      pricePerSeat: (json['price_per_seat'] is double) 
          ? json['price_per_seat'] as double
          : (json['price_per_seat'] is int)
              ? (json['price_per_seat'] as int).toDouble()
              : double.tryParse(json['price_per_seat']?.toString() ?? '0') ?? 0.0,
      
      // Autres champs
      driverRating: (json['driver_rating'] is double) 
          ? json['driver_rating'] as double
          : (json['driver_rating'] is int)
              ? (json['driver_rating'] as int).toDouble()
              : double.tryParse(json['driver_rating']?.toString() ?? '5.0') ?? 5.0,
      
      driverIsPremium: json['driver_is_premium'] == true || json['driver_is_premium'] == 1,
      scheduleDays: json['schedule_days'] != null
          ? _parseScheduleDays(json['schedule_days'])
          : null,
      timeSlot: json['schedule_time'] ?? json['time_slot'],
      vehicleInfo: json['vehicle_details'] ?? json['vehicle_info'],
      notes: json['notes'] ?? '',
      isRegularRide: json['is_regular'] == true || json['is_regular'] == 1,
      
      departureStationId: (json['departure_station_id'] is int) 
          ? json['departure_station_id'] as int
          : int.tryParse(json['departure_station_id']?.toString() ?? ''),
      
      arrivalStationId: (json['arrival_station_id'] is int) 
          ? json['arrival_station_id'] as int
          : int.tryParse(json['arrival_station_id']?.toString() ?? ''),
    );
  }

  static List<String>? _parseScheduleDays(dynamic daysData) {
    if (daysData == null) return null;

    if (daysData is List) {
      return List<String>.from(daysData.map((day) => day.toString()));
    } else if (daysData is String) {
      try {
        if (daysData.startsWith('[') && daysData.endsWith(']')) {
          final parsed = jsonDecode(daysData) as List;
          return List<String>.from(parsed.map((day) => day.toString()));
        }
        return daysData.split(',').map((day) => day.trim()).toList();
      } catch (e) {
        print('❌ Erreur parsing schedule_days: $e');
        return null;
      }
    }

    return null;
  }

  // ✅ CORRECTION CRITIQUE : toJson() pour l'API
  Map<String, dynamic> toJson() {
    // Format pour l'affichage dans l'app
    final Map<String, dynamic> json = {
      'ride_id': rideId,
      'driver_id': driverId,
      'available_seats': availableSeats,
      'price_per_seat': pricePerSeat,
      'is_regular': isRegularRide,
    };

    // ✅ ENVOYER LES IDs AU BACKEND (PAS LES NOMS)
    if (departureStationId != null) {
      json['departure_station_id'] = departureStationId;
    }
    if (arrivalStationId != null) {
      json['arrival_station_id'] = arrivalStationId;
    }

    // Date et heure
    if (departureTime != null) {
      json['departure_date'] = departureTime!.toIso8601String().split('T')[0]; // YYYY-MM-DD
      json['departure_time'] = '${departureTime!.hour.toString().padLeft(2, '0')}:${departureTime!.minute.toString().padLeft(2, '0')}';
    }

    // Trajet régulier
    if (scheduleDays != null && scheduleDays!.isNotEmpty) {
      json['schedule_days'] = scheduleDays!.join(',');
    }
    if (timeSlot != null) {
      json['schedule_time'] = timeSlot;
    }

    // Infos optionnelles
    if (vehicleInfo != null && vehicleInfo!.isNotEmpty) {
      json['vehicle_details'] = vehicleInfo;
    }
    if (notes != null && notes!.isNotEmpty) {
      json['notes'] = notes;
    }

    return json;
  }

  // ✅ MÉTHODE SPÉCIALE : Pour l'API de publication (ride_provider.dart)
  Map<String, dynamic> toApiJson() {
    final Map<String, dynamic> json = {
      'available_seats': availableSeats,
      'price_per_seat': pricePerSeat,
    };

    // ✅ CRITIQUE : Toujours envoyer les IDs
    if (departureStationId == null || arrivalStationId == null) {
      throw Exception('Les IDs de stations sont requis pour publier un trajet');
    }

    json['departure_station_id'] = departureStationId;
    json['arrival_station_id'] = arrivalStationId;

    // Date et heure (format backend)
    if (departureTime != null) {
      json['departure_date'] = '${departureTime!.year}-${departureTime!.month.toString().padLeft(2, '0')}-${departureTime!.day.toString().padLeft(2, '0')}';
      json['departure_time'] = '${departureTime!.hour.toString().padLeft(2, '0')}:${departureTime!.minute.toString().padLeft(2, '0')}';
    }

    // Trajet régulier
    if (isRegularRide) {
      json['recurrence'] = 'weekly'; // ou 'daily' selon votre logique
      if (scheduleDays != null && scheduleDays!.isNotEmpty) {
        json['recurrence_days'] = scheduleDays;
      }
    }

    // Infos optionnelles
    if (vehicleInfo != null && vehicleInfo!.isNotEmpty) {
      json['vehicle_details'] = vehicleInfo;
    }
    if (notes != null && notes!.isNotEmpty) {
      json['notes'] = notes;
    }

    return json;
  }

  // Méthodes utilitaires
  String get formattedDate {
    if (departureTime == null) return 'Trajet régulier';
    return '${departureTime!.day.toString().padLeft(2, '0')}/${departureTime!.month.toString().padLeft(2, '0')}/${departureTime!.year}';
  }

  String get formattedTime {
    if (departureTime == null) return timeSlot ?? 'Heure non définie';
    return '${departureTime!.hour.toString().padLeft(2, '0')}h${departureTime!.minute.toString().padLeft(2, '0')}';
  }

  String get displayRoute {
    return '$startPoint → $endPoint';
  }

  String get displayDateTime {
    if (departureTime == null) {
      return isRegularRide ? 'Trajet régulier' : 'Date non définie';
    }
    return '$formattedDate à $formattedTime';
  }

  bool get isTrajetPonctuel => departureTime != null;
  bool get isTrajetRegulier => isRegularRide || scheduleDays != null;
  bool get isAvailable => availableSeats > 0;
  
  double get totalPriceForOneSeat => pricePerSeat;
  
  String get driverInfo {
    final rating = driverRating > 0 ? '★ ${driverRating.toStringAsFixed(1)}' : 'Nouveau';
    final premium = driverIsPremium ? '👑' : '';
    return '$driverName $premium ($rating)';
  }
}