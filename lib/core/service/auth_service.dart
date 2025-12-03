// File: lib/core/service/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moovapp/core/models/user_model.dart';
<<<<<<< HEAD
import 'dart:io';

class AuthService {
  // ✅ URL DYNAMIQUE POUR CHAQUE PLATEFORME
  static String get _baseUrl {
    // Pour le web (Chrome)
    if (identical(0, 0.0)) {
      // kIsWeb alternative
      return 'http://localhost:3000/api/auth';
    }
    // Pour Android
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/auth';
    }
    // Pour iOS
    if (Platform.isIOS) {
      return 'http://localhost:3000/api/auth';
    }
    // Par défaut
    return 'http://localhost:3000/api/auth';
  }

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final url = '$_baseUrl/login';
      print('🔄 AUTH: Connexion avec $email');
      print('📍 URL: $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('✅ AUTH RESPONSE: ${response.statusCode}');
      print('📊 AUTH BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'jwt_token', value: data['token']);
=======
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
>>>>>>> 38397c1094c7156cf54cdb86b901a3d5d3bc6b55

        return UserModel.fromJson(data['user']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Échec de la connexion');
      }
    } catch (e) {
<<<<<<< HEAD
      print('❌ AUTH ERROR: $e');
      rethrow;
    }
  }

=======
      rethrow;
    }
  }
  
  // ---------------------------------------------------------------------------
  // INSCRIPTION
  // ---------------------------------------------------------------------------
>>>>>>> 38397c1094c7156cf54cdb86b901a3d5d3bc6b55
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
<<<<<<< HEAD
    required String universityId,
    required String profileType,
=======
    required String universityId, 
    required String profileType, 
>>>>>>> 38397c1094c7156cf54cdb86b901a3d5d3bc6b55
    required String phoneNumber,
    required List<RouteInfo> routes, 
  }) async {
    try {
<<<<<<< HEAD
      final url = '$_baseUrl/register';
      print('🔄 AUTH: Inscription avec $email');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'fullName': fullName,
              'universityId': universityId,
              'profileType': profileType,
              'phoneNumber': phoneNumber,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('✅ AUTH RESPONSE: ${response.statusCode}');
=======
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
>>>>>>> 38397c1094c7156cf54cdb86b901a3d5d3bc6b55

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'jwt_token', value: data['token']);
        return UserModel.fromJson(data['user']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Échec de l\'inscription');
      }
    } catch (e) {
<<<<<<< HEAD
      print('❌ AUTH ERROR: $e');
=======
>>>>>>> 38397c1094c7156cf54cdb86b901a3d5d3bc6b55
      rethrow;
    }
  }

<<<<<<< HEAD
  Future<void> signOut() async {
    await _storage.delete(key: 'jwt_token');
=======
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
>>>>>>> 38397c1094c7156cf54cdb86b901a3d5d3bc6b55
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
