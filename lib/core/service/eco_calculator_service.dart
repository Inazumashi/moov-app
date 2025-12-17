// lib/core/service/eco_calculator_service.dart
class EcoCalculatorService {
  // Constantes pour les calculs
  static const double _averageFuelConsumption = 5.0; // L/100km
  static const double _gasolineCO2PerKm = 114.0; // grammes de CO2 par km
  static const double _dieselCO2PerKm = 133.5; // grammes de CO2 par km
  static const double _averageFuelPriceDH = 12.0; // DH par litre (essence)
  
  // Type de carburant par défaut
  static const FuelType _defaultFuelType = FuelType.gasoline;

  /// Calcule les émissions de CO2 économisées en covoiturage
  /// 
  /// [totalDistance] - Distance totale parcourue en km
  /// [numberOfPeople] - Nombre de personnes dans le covoiturage
  /// [fuelType] - Type de carburant utilisé
  /// 
  /// Returns: CO2 économisé en kg
  static double calculateCO2Saved({
    required double totalDistance,
    required int numberOfPeople,
    FuelType fuelType = FuelType.gasoline,
  }) {
    if (totalDistance <= 0 || numberOfPeople <= 1) return 0;

    // CO2 par km selon le type de carburant
    final co2PerKm = fuelType == FuelType.gasoline 
        ? _gasolineCO2PerKm 
        : _dieselCO2PerKm;

    // CO2 total si chacun prenait sa voiture (en grammes)
    final totalCO2Individual = totalDistance * co2PerKm * numberOfPeople;

    // CO2 réel en covoiturage (une seule voiture)
    final totalCO2Carpooling = totalDistance * co2PerKm;

    // CO2 économisé (en grammes)
    final co2SavedGrams = totalCO2Individual - totalCO2Carpooling;

    // Convertir en kg et arrondir
    return (co2SavedGrams / 1000).roundToDouble();
  }

  /// Calcule l'argent économisé en covoiturage
  /// 
  /// [totalDistance] - Distance totale parcourue en km
  /// [pricePerPerson] - Prix payé par personne
  /// [numberOfPassengers] - Nombre de passagers (sans le conducteur)
  /// [fuelType] - Type de carburant
  /// 
  /// Returns: Argent économisé en DH pour le conducteur
  static double calculateMoneySaved({
    required double totalDistance,
    required double pricePerPerson,
    required int numberOfPassengers,
    FuelType fuelType = FuelType.gasoline,
  }) {
    if (totalDistance <= 0 || numberOfPassengers <= 0) return 0;

    // Coût total du carburant pour le trajet
    final fuelNeeded = (totalDistance / 100) * _averageFuelConsumption;
    final fuelCost = fuelNeeded * _averageFuelPriceDH;

    // Revenus du covoiturage
    final revenue = pricePerPerson * numberOfPassengers;

    // Économies = Revenus - Coût du carburant
    final savings = revenue - fuelCost;

    return savings > 0 ? savings.roundToDouble() : 0;
  }

  /// Calcule l'argent économisé pour un passager
  /// 
  /// [totalDistance] - Distance totale parcourue en km
  /// [pricePerPerson] - Prix payé par personne
  /// 
  /// Returns: Argent économisé en DH par rapport à une voiture personnelle
  static double calculatePassengerSavings({
    required double totalDistance,
    required double pricePerPerson,
  }) {
    if (totalDistance <= 0) return 0;

    // Coût si le passager prenait sa propre voiture
    final fuelNeeded = (totalDistance / 100) * _averageFuelConsumption;
    final fuelCost = fuelNeeded * _averageFuelPriceDH;

    // Coût de péage estimé (environ 20% du coût carburant)
    final tollCost = fuelCost * 0.2;

    // Coût total si voiture personnelle
    final totalCostAlone = fuelCost + tollCost;

    // Économies = Coût seul - Prix covoiturage
    final savings = totalCostAlone - pricePerPerson;

    return savings > 0 ? savings.roundToDouble() : 0;
  }

  /// Calcule les statistiques écologiques pour un utilisateur
  /// 
  /// [completedTrips] - Liste des trajets complétés
  /// 
  /// Returns: Map avec statistiques écologiques
  static Map<String, double> calculateUserEcoStats({
    required List<Map<String, dynamic>> completedTrips,
  }) {
    double totalDistance = 0;
    double totalCO2Saved = 0;
    double totalMoneySaved = 0;
    int totalPassengers = 0;

    for (var trip in completedTrips) {
      // Distance estimée (50km par défaut si non spécifiée)
      final distance = trip['distance']?.toDouble() ?? 50.0;
      
      // Nombre de passagers
      final passengers = trip['passengers'] as int? ?? 1;
      
      // Prix par personne
      final pricePerSeat = trip['price_per_seat']?.toDouble() ?? 20.0;

      totalDistance += distance;
      totalPassengers += passengers;

      // Calculer CO2 économisé
      totalCO2Saved += calculateCO2Saved(
        totalDistance: distance,
        numberOfPeople: passengers + 1, // +1 pour le conducteur
        fuelType: FuelType.gasoline,
      );

      // Calculer argent économisé (si conducteur)
      if (trip['is_driver'] == true) {
        totalMoneySaved += calculateMoneySaved(
          totalDistance: distance,
          pricePerPerson: pricePerSeat,
          numberOfPassengers: passengers,
        );
      } else {
        // Si passager
        totalMoneySaved += calculatePassengerSavings(
          totalDistance: distance,
          pricePerPerson: pricePerSeat,
        );
      }
    }

    return {
      'total_distance': totalDistance.roundToDouble(),
      'co2_saved_kg': totalCO2Saved.roundToDouble(),
      'money_saved_dh': totalMoneySaved.roundToDouble(),
      'total_passengers': totalPassengers.toDouble(),
      'trees_equivalent': (totalCO2Saved / 21).roundToDouble(), // 1 arbre absorbe ~21kg CO2/an
    };
  }

  /// Formatte le CO2 économisé pour l'affichage
  static String formatCO2Saved(double co2Kg) {
    if (co2Kg < 1) {
      return '${(co2Kg * 1000).round()} g';
    } else if (co2Kg < 1000) {
      return '${co2Kg.round()} kg';
    } else {
      return '${(co2Kg / 1000).toStringAsFixed(1)} t';
    }
  }

  /// Formatte l'argent économisé pour l'affichage
  static String formatMoneySaved(double moneyDH) {
    if (moneyDH < 1000) {
      return '${moneyDH.round()} DH';
    } else {
      return '${(moneyDH / 1000).toStringAsFixed(1)}k DH';
    }
  }
}

/// Enum pour les types de carburant
enum FuelType {
  gasoline, // Essence
  diesel,   // Gazole
}