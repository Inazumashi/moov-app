import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/models/university_model.dart';

// Ce service gérera la recherche, la publication et la gestion des trajets.
// Pour l'instant, ce sont des fonctions "bouchons" (placeholders).

class RideService {
  // Simule une recherche de trajets
  Future<List<RideModel>> searchRides(
      String from, String to, DateTime date) async {
    print('Recherche de trajets de $from à $to pour le $date');
    // TODO: Ajouter la vraie logique de recherche (ex: Firebase)
    await Future.delayed(const Duration(seconds: 1));

    // On simule deux résultats de recherche
    return [
      RideModel(
        rideId: 'ride_1',
        driverId: 'driver_A',
        driverName: 'Karim El Idrissi',
        driverRating: 4.7,
        startPoint: 'Ben Guerir',
        endPoint: 'Casablanca',
        departureTime: DateTime.now().add(const Duration(hours: 3)),
        availableSeats: 4,
        pricePerSeat: 70,
      ),
      RideModel(
        rideId: 'ride_2',
        driverId: 'driver_B',
        driverName: 'Amina Laaroussi',
        driverRating: 4.9,
        driverIsPremium: true,
        startPoint: 'UM6P Campus',
        endPoint: 'Marrakech',
        departureTime: DateTime.now().add(const Duration(hours: 5)),
        availableSeats: 3,
        pricePerSeat: 45,
      ),
    ];
  }

  // Simule la publication d'un trajet
  Future<void> publishRide(RideModel ride) async {
    print('Publication du trajet de ${ride.startPoint} à ${ride.endPoint}');
    // TODO: Ajouter la vraie logique de publication (ex: Firebase)
    await Future.delayed(const Duration(seconds: 1));
  }

  // Simule la récupération des trajets favoris
  Future<List<RideModel>> getFavoriteRides(String userId) async {
    print('Récupération des favoris pour $userId');
    // TODO: Ajouter la vraie logique
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      RideModel(
        rideId: 'ride_3',
        driverId: 'driver_C',
        driverName: 'Fatima Zahra',
        driverRating: 4.8,
        driverIsPremium: true,
        startPoint: 'Ben Guerir Centre',
        endPoint: 'UM6P Campus',
        departureTime: DateTime.now().add(const Duration(days: 1)),
        availableSeats: 3,
        pricePerSeat: 15,
      ),
    ];
  }

  // Simule la récupération de la liste des universités
  Future<List<UniversityModel>> getUniversities() async {
    print('Récupération des universités...');
    // TODO: Ajouter la vraie logique
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      UniversityModel(
        universityId: 'um6p',
        name: 'Université Mohammed VI Polytechnique',
        studentCount: 3200,
        domain: 'um6p.ma',
      ),
      UniversityModel(
        universityId: 'uca',
        name: 'Université Cadi Ayyad',
        studentCount: 45000,
        domain: 'uca.ma',
      ),
      UniversityModel(
        universityId: 'uir',
        name: 'Université Internationale de Rabat',
        studentCount: 5000,
        domain: 'uir.ac.ma',
      ),
    ];
  }
}