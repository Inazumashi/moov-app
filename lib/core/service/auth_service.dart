import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/user_model.dart';
import 'package:moovapp/features/inscription/screens/routes_config_screen.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 

class AuthService {
  final ApiService _api = ApiService();

  // ---------------------------------------------------------------------------
  // CONNEXION
  // ---------------------------------------------------------------------------
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
      
      // ✅ Sauvegarde locale pour Home et Profil
      await _saveUserDataLocally(userData); 

      return UserModel.fromJson(userData);

    } catch (e) {
      rethrow;
    }
  }
  
  // ---------------------------------------------------------------------------
  // INSCRIPTION
  // ---------------------------------------------------------------------------
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

      List<Map<String, dynamic>> routesFormatted = routes.map((route) {
        return {
          "depart": route.depart,
          "arrivee": route.arrivee,
          "jours": route.jours.toList(), 
          "heure": route.plageHoraire
        };
      }).toList();

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

      // ✅ Sauvegarde locale après inscription
      await _saveUserDataLocally(userData);

      return UserModel.fromJson(userData);

    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // MISE À JOUR DU PROFIL 
  // ---------------------------------------------------------------------------
  Future<void> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    try {
      // 1. Découpage du nom
      List<String> names = fullName.trim().split(" ");
      String firstName = names.isNotEmpty ? names.first : "";
      String lastName = names.length > 1 ? names.sublist(1).join(" ") : "";

      // 2. Appel API (Note: Si votre API n'a pas PUT, utilisez POST)
      await _api.post( // ou _api.post selon votre backend
        'auth/update', 
        {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
        },
      );

      // 3. Mise à jour de la mémoire locale immédiatement
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('first_name', firstName);
      await prefs.setString('last_name', lastName);
      await prefs.setString('phone', phone);
      
      // Si le backend renvoie l'objet user mis à jour, on pourrait aussi refaire _saveUserDataLocally(response['user'])

    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // DÉCONNEXION
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    await _api.deleteToken();
    // ✅ On efface TOUT (Token + Infos profil)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
  }

  // ---------------------------------------------------------------------------
  // SAUVEGARDE LOCALE
  // ---------------------------------------------------------------------------
  Future<void> _saveUserDataLocally(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Infos de base (Pour HomeScreen)
    await prefs.setString('first_name', userData['first_name'] ?? '');
    await prefs.setString('last_name', userData['last_name'] ?? '');
    
    // Gestion des variantes de noms de clés (selon votre backend)
    await prefs.setString('university_id', userData['university'] ?? userData['university_id'] ?? ''); 
    await prefs.setString('profile_type', userData['profile_type'] ?? userData['role'] ?? ''); 

    // 2. Infos supplémentaires (Pour ProfileScreen)
    await prefs.setString('email', userData['email'] ?? '');
    await prefs.setString('phone', userData['phone'] ?? '');
  }
}