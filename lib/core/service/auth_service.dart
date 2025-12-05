// File: lib/core/services/auth_service.dart
import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import du modèle RouteInfo
import 'package:moovapp/features/inscription/screens/routes_config_screen.dart';

class AuthService {
  final ApiService _api = ApiService();

  // ---------------------------------------------------------------------------
  // 1. CONNEXION
  // ---------------------------------------------------------------------------
  Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await _api.post(
        'auth/login', 
        {
          'email': email, 
          'password': password
        },
        isProtected: false,
      );

      final String token = response['token'];
      final Map<String, dynamic> userData = response['user'];

      await _api.storeToken(token);
      await _saveUserDataLocally(userData);

      return UserModel.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }
  
  // ---------------------------------------------------------------------------
  // 2. INSCRIPTION (CORRIGÉ)
  // ---------------------------------------------------------------------------
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String universityId, 
    required String profileType, 
    required String phoneNumber,
    required List<RouteInfo> routes, 
  }) async {
    try {
      // Découper le nom complet en prénom et nom
      List<String> names = fullName.trim().split(" ");
      String firstName = names.isNotEmpty ? names.first : "";
      String lastName = names.length > 1 ? names.sublist(1).join(" ") : "";

      // Formater les routes pour le backend
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
        isProtected: false,
      );

      final String token = response['token'];
      final Map<String, dynamic> userData = response['user'];

      await _api.storeToken(token);
      await _saveUserDataLocally(userData);

      return UserModel.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. VÉRIFICATION EMAIL UNIVERSITAIRE
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> checkUniversityEmail(String email) async {
    try {
      return await _api.post(
        'auth/check-email',
        {'email': email},
        isProtected: false,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 4. VÉRIFICATION CODE
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> verifyEmailCode(String email, String code) async {
    try {
      return await _api.post(
        'auth/verify-code',
        {'email': email, 'code': code},
        isProtected: false,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 5. RÉENVOYER CODE
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> resendVerificationCode(String email) async {
    try {
      return await _api.post(
        'auth/resend-code',
        {'email': email},
        isProtected: false,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 6. MISE À JOUR PROFIL
  // ---------------------------------------------------------------------------
  Future<void> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    try {
      List<String> names = fullName.trim().split(" ");
      String firstName = names.isNotEmpty ? names.first : "";
      String lastName = names.length > 1 ? names.sublist(1).join(" ") : "";

      await _api.put(
        'auth/profile',
        {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
        },
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('first_name', firstName);
      await prefs.setString('last_name', lastName);
      await prefs.setString('phone', phone);
      
    } catch (e) {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 7. DÉCONNEXION
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    await _api.deleteToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ---------------------------------------------------------------------------
  // 8. VÉRIFICATION CONNEXION
  // ---------------------------------------------------------------------------
  Future<bool> isLoggedIn() async {
    final token = await _api.getToken();
    return token != null && token.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // 9. SAUVEGARDE LOCALE
  // ---------------------------------------------------------------------------
  Future<void> _saveUserDataLocally(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('user_id', userData['id']?.toString() ?? '');
    await prefs.setString('email', userData['email'] ?? '');
    await prefs.setString('first_name', userData['first_name'] ?? '');
    await prefs.setString('last_name', userData['last_name'] ?? '');
    await prefs.setString('phone', userData['phone'] ?? '');
    await prefs.setString('university', userData['university'] ?? '');
    await prefs.setString('profile_type', userData['profile_type'] ?? '');
    await prefs.setDouble('rating', (userData['rating'] as num?)?.toDouble() ?? 5.0);
  }
}