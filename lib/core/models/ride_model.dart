class RideModel {
  final String rideId;
  final String driverId;
  final String driverName;
  final double driverRating;
  final bool driverIsPremium;

  final String startPoint; // "Ben Guerir Centre"
  final String endPoint; // "UM6P Campus"
  
  final DateTime departureTime;
  final int availableSeats;
  final double pricePerSeat;
  
  final String? vehicleInfo; // "Dacia Logan - Blanche"
  final String? notes; // "Informations complémentaires..."
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

  // Ici, on ajoutera plus tard des fonctions
  // pour convertir ce modèle depuis/vers JSON (pour Firebase)
}
