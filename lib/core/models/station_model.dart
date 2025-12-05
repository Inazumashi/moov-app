// File: lib/core/models/station_model.dart
import 'dart:math';

class StationModel {
  final int id;
  final String name;
  final String type; // 'university', 'train_station', 'bus_station', 'landmark', 'city'
  final String city;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int? universityId;
  final String? universityName;
  final bool isFavorite;
  final int rideCount;
  final int searchCount;
  final String label; // Pour l'affichage dans l'auto-complétion

  StationModel({
    required this.id,
    required this.name,
    required this.type,
    required this.city,
    this.address,
    this.latitude,
    this.longitude,
    this.universityId,
    this.universityName,
    this.isFavorite = false,
    this.rideCount = 0,
    this.searchCount = 0,
    required this.label,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 'landmark',
      city: json['city'] ?? '',
      address: json['address'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      universityId: json['university_id'],
      universityName: json['university_name'],
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
      rideCount: json['ride_count'] ?? 0,
      searchCount: json['search_count'] ?? 0,
      label: json['label'] ?? '${json['name']}, ${json['city']}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'university_id': universityId,
      'university_name': universityName,
      'is_favorite': isFavorite,
      'ride_count': rideCount,
      'search_count': searchCount,
      'label': label,
    };
  }

  // Pour l'affichage
  String get displayName {
    if (universityName != null && universityName!.isNotEmpty) {
      return '$name ($universityName)';
    }
    return name;
  }

  // Vérifie si c'est une station d'université
  bool get isUniversity => type == 'university';

  // Vérifie si c'est une gare
  bool get isTrainStation => type == 'train_station';

  // Vérifie si c'est un arrêt de bus
  bool get isBusStation => type == 'bus_station';

  // Pour les distances (si on a les coordonnées)
  double? distanceTo(double lat, double lng) {
    if (latitude == null || longitude == null) return null;
    
    // Formule haversine simplifiée
    const R = 6371.0; // Rayon de la Terre en km
    
    // Convertir les degrés en radians
    double toRadians(double degree) => degree * pi / 180;
    
    final dLat = toRadians(latitude! - lat);
    final dLon = toRadians(longitude! - lng);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(toRadians(latitude!)) * cos(toRadians(lat)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  // Vérifier si les coordonnées sont disponibles
  bool get hasCoordinates => latitude != null && longitude != null;

  // Obtenir la position sous forme de Map pour les packages de carte
  Map<String, double>? get position {
    if (latitude == null || longitude == null) return null;
    return {'lat': latitude!, 'lng': longitude!};
  }

  // Obtenir l'adresse complète
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city.isNotEmpty) parts.add(city);
    return parts.join(', ');
  }

  // Pour le tri
  static int sortByDistance(StationModel a, StationModel b, double userLat, double userLng) {
    final distA = a.distanceTo(userLat, userLng) ?? double.infinity;
    final distB = b.distanceTo(userLat, userLng) ?? double.infinity;
    return distA.compareTo(distB);
  }

  static int sortByName(StationModel a, StationModel b) => 
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  static int sortByPopularity(StationModel a, StationModel b) => 
      (b.rideCount + b.searchCount).compareTo(a.rideCount + a.searchCount);
}