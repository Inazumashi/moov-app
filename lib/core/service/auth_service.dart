<<<<<<< HEAD
// File: lib/core/service/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moovapp/core/models/user_model.dart';
import 'dart:io';

class AuthService {
  // ✅ URL DYNAMIQUE POUR CHAQUE PLATEFORME
  static String get _baseUrl {
    // Pour le web (Chrome)
    if (identical(0, 0.0)) { // kIsWeb alternative
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
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(Duration(seconds: 10));

      print('✅ AUTH RESPONSE: ${response.statusCode}');
      print('📊 AUTH BODY: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'jwt_token', value: data['token']);
        
        return UserModel.fromJson(data['user']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Échec de la connexion');
      }
    } catch (e) {
      print('❌ AUTH ERROR: $e');
=======
import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/user_model.dart';

class AuthService {
  // On utilise notre nouveau service API
  final ApiService _api = ApiService();

  // Connexion réelle via l'API
  Future<UserModel?> signIn(String email, String password) async {
    try {
      // 1. Appel à l'API (POST /auth/login)
      // On utilise la méthode 'post' de notre ApiService
      final response = await _api.post(
        'auth/login', 
        {
          'email': email, 
          'password': password
        },
      );

      // 2. Si succès, l'API renvoie un token et l'utilisateur
      // (C'est ce que nous avons codé dans le backend auth.controller.js)
      final String token = response['token'];
      final Map<String, dynamic> userData = response['user'];

      // 3. On stocke le token pour les prochaines requêtes
      await _api.storeToken(token);

      // 4. On convertit le JSON en objet UserModel
      return UserModel.fromJson(userData);

    } catch (e) {
      // On relance l'erreur pour l'afficher dans l'UI (LoginScreen)
      // Par exemple : "Mot de passe incorrect"
>>>>>>> 7280f87d548931f0299a52342393de5087fd56ae
      rethrow;
    }
  }

<<<<<<< HEAD
=======
  // Inscription réelle via l'API
>>>>>>> 7280f87d548931f0299a52342393de5087fd56ae
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String universityId, // ex: "Université Mohammed VI..."
    required String profileType,  // ex: "Étudiant"
    required String phoneNumber,
  }) async {
    try {
<<<<<<< HEAD
      final url = '$_baseUrl/register';
      print('🔄 AUTH: Inscription avec $email');
      
      final response = await http.post(
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
      ).timeout(Duration(seconds: 10));

      print('✅ AUTH RESPONSE: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'jwt_token', value: data['token']);
        return UserModel.fromJson(data['user']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Échec de l\'inscription');
      }
    } catch (e) {
      print('❌ AUTH ERROR: $e');
=======
      // 1. Appel à l'API (POST /auth/register)
      final response = await _api.post(
        'auth/register',
        {
          'email': email,
          'password': password,
          'fullName': fullName,
          'universityName': universityId, // Attention à bien mapper les noms attendus par le backend
          'profileType': profileType,
          'phoneNumber': phoneNumber, // Si votre backend gère le téléphone à l'inscription
        },
      );

      // 2. Récupération des données
      final String token = response['token'];
      final Map<String, dynamic> userData = response['user'];

      // 3. Stockage du token
      await _api.storeToken(token);

      // 4. Retour du modèle utilisateur
      return UserModel.fromJson(userData);

    } catch (e) {
      // En cas d'erreur (ex: email déjà utilisé), on relance l'erreur
>>>>>>> 7280f87d548931f0299a52342393de5087fd56ae
      rethrow;
    }
  }

<<<<<<< HEAD
  Future<void> signOut() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
=======
  // Déconnexion
  Future<void> signOut() async {
    // On supprime simplement le token du téléphone
    await _api.deleteToken();
  }
>>>>>>> 7280f87d548931f0299a52342393de5087fd56ae
}