import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/ride_model.dart';
import 'package:moovapp/core/models/university_model.dart';
import 'package:intl/intl.dart'; 

class RideService {
  // On utilise notre service API pour faire les requêtes
  final ApiService _api = ApiService();

  // 1. RECHERCHER DES TRAJETS
  Future<List<RideModel>> searchRides(
      String from, String to, DateTime date) async {
    try {
      // On formate la date pour l'envoyer à l'API (ex: 2025-10-12)
      final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Appel GET vers /rides/search avec des paramètres dans l'URL
      // Exemple: /rides/search?departure=Casa&arrival=Rabat&date=2025-10-12
      final response = await _api.get(
        'rides/search?departure=$from&arrival=$to&date=$formattedDate',
        isProtected: false, // La recherche peut être publique
      );

      // L'API renvoie une liste JSON ([{}, {}]). On la convertit en liste de RideModel.
      // (Assurez-vous que RideModel a une factory 'fromJson')
      /* Note: Si RideModel.fromJson n'existe pas encore, vous devrez l'ajouter dans ride_model.dart
         Pour l'instant, je suppose qu'elle existe ou que vous allez l'ajouter.
         Si elle n'existe pas, ce code ne compilera pas.
      */
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => RideModel.fromJson(json)).toList();

    } catch (e) {
      // En cas d'erreur, on renvoie une liste vide ou on relance l'erreur
      print('Erreur recherche: $e');
      rethrow;
    }
  }

  // 2. PUBLIER UN TRAJET
  Future<void> publishRide(RideModel ride) async {
    try {
      // Appel POST vers /rides/publish
      // On doit être connecté (isProtected: true)
      await _api.post(
        'rides/publish',
        ride.toJson(), // On convertit l'objet RideModel en JSON
        isProtected: true,
      );
      
    } catch (e) {
      print('Erreur publication: $e');
      rethrow;
    }
  }

  // 3. RÉCUPÉRER LES FAVORIS (OU MES TRAJETS)
  Future<List<RideModel>> getFavoriteRides(String userId) async {
    try {
      // Appel GET vers une route imaginaire pour les favoris
      // (À implémenter dans le backend si elle n'existe pas)
      final response = await _api.get(
        'users/me/favorites', // Exemple d'URL
        isProtected: true,
      );

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => RideModel.fromJson(json)).toList();

    } catch (e) {
      print('Erreur favoris: $e');
      return []; // Retourne une liste vide en cas d'erreur
    }
  }

  // 4. RÉCUPÉRER LES UNIVERSITÉS
  // (Utile pour l'écran de sélection de l'université)
  Future<List<UniversityModel>> getUniversities() async {
    try {
      // Appel GET vers /universities (si vous créez cette route dans le backend)
      // Sinon, on peut garder la liste statique pour l'instant.
      
      // Pour l'exemple, imaginons que l'API existe :
      /*
      final response = await _api.get('universities', isProtected: false);
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => UniversityModel.fromJson(json)).toList();
      */

      // En attendant l'API, on retourne la liste statique (simulée)
      await Future.delayed(const Duration(milliseconds: 200));
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
    } catch (e) {
      return [];
    }
  }
}