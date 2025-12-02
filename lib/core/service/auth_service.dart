import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/user_model.dart';
import 'package:moovapp/features/inscription/screens/routes_config_screen.dart'; 

class AuthService {
  final ApiService _api = ApiService();


  Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await _api.post(
        'auth/login', 
        {
          'email': email, 
          'password': password
        },
      );

      final String token = response['token'];
      final Map<String, dynamic> userData = response['user'];

      await _api.storeToken(token);
      return UserModel.fromJson(userData);

    } catch (e) {
      rethrow;
    }
  }

  
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String universityId, 
    required String profileType, 
    required String phoneNumber,
    required List<RouteInfo> routes, 
  }) async {
    try {
      
      List<String> names = fullName.trim().split(" ");
      String firstName = names.isNotEmpty ? names.first : "";
      String lastName = names.length > 1 ? names.sublist(1).join(" ") : "";

      // 2. Préparation des routes pour le JSON
      List<Map<String, dynamic>> routesFormatted = routes.map((route) {
        return {
          "depart": route.depart,
          "arrivee": route.arrivee,
          "jours": route.jours.toList(), 
          "heure": route.plageHoraire
        };
      }).toList();

      // 3. Appel API avec les BONNES clés (snake_case pour le backend)
      final response = await _api.post(
        'auth/register',
        {
          'email': email,
          'password': password,
          'first_name': firstName,      
          'last_name': lastName,        
          'university_id': universityId,
          'profile_type': profileType,  
          'phone': phoneNumber,         
          'routes': routesFormatted,    
        },
      );

      final String token = response['token'];
      final Map<String, dynamic> userData = response['user'];

      await _api.storeToken(token);
      return UserModel.fromJson(userData);

    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _api.deleteToken();
  }
}