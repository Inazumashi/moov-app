// File: lib/core/services/auth_service.dart - VERSION COMPATIBLE AVEC VOTRE UserModel
import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moovapp/features/inscription/screens/routes_config_screen.dart';

class AuthService {
  final ApiService _api = ApiService();

  // ---------------------------------------------------------------------------
  // 1. CONNEXION - COMPATIBLE AVEC UserModel
  // ---------------------------------------------------------------------------
  Future<UserModel> signIn(String email, String password) async {
    try {
      print('🔐 Tentative de connexion pour: $email');
      
      final response = await _api.post(
        'auth/login',
        {'email': email, 'password': password},
        isProtected: false,
      );

      final String token = response['token'];
      final Map<String, dynamic> userData = response['user'];

      await _api.storeToken(token);
      await _saveUserDataLocally(userData);

      print('✅ Connexion réussie pour: ${userData['email']}');
      
      // ✅ UTILISER LA VERSION CORRECTE DE UserModel
      return UserModel.fromJson(userData);
    } catch (e) {
      print('❌ ERREUR CONNEXION: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. INSCRIPTION - COMPATIBLE AVEC UserModel
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

      // Données à envoyer (format backend)
      final requestData = {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'university': universityId,
        'profile_type': profileType,
        'phone': phoneNumber,
        'student_id': null,
        'routes': routesFormatted,
      };

      print('📤 INSCRIPTION - Données envoyées:');
      print('Email: $email');
      print('FullName: $fullName');
      print('Université: $universityId');

      // Envoyer la requête
      final response = await _api.post(
        'auth/register',
        requestData,
        isProtected: false,
      );

      print('📥 INSCRIPTION - Réponse reçue');

      final String token = response['token'];
      final Map<String, dynamic> userData = response['user'];

      await _api.storeToken(token);
      await _saveUserDataLocally(userData);

      // ✅ UTILISER LA VERSION CORRECTE DE UserModel
      return UserModel.fromJson(userData);
    } catch (e) {
      print('❌ ERREUR INSCRIPTION: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. SAUVEGARDE LOCALE - COMPATIBLE AVEC UserModel
  // ---------------------------------------------------------------------------
  Future<void> _saveUserDataLocally(Map<String, dynamic> userData) async {
    print('💾 Sauvegarde locale des données utilisateur...');

    final prefs = await SharedPreferences.getInstance();

    // ✅ SAUVEGARDER POUR UserModel (version simple)
    await prefs.setString('uid', userData['id']?.toString() ?? '');
    await prefs.setString('email', userData['email'] ?? '');
    
    // Combiner prénom et nom pour fullName
    final firstName = userData['first_name'] ?? '';
    final lastName = userData['last_name'] ?? '';
    final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ').trim();
    await prefs.setString('fullName', fullName);
    
    await prefs.setString('university', userData['university'] ?? userData['university_id'] ?? '');
    await prefs.setString('profileType', userData['profile_type'] ?? '');
    await prefs.setString('phone', userData['phone'] ?? '');
    await prefs.setDouble('rating', (userData['rating'] as num?)?.toDouble() ?? 0.0);
    await prefs.setInt('ridesCount', userData['rides_count'] ?? userData['total_trips'] ?? 0);
    await prefs.setBool('isPremium', userData['is_premium'] ?? false);

    print('✅ Données sauvegardées avec succès');
  }

  // ---------------------------------------------------------------------------
  // 4. LECTURE LOCALE - COMPATIBLE AVEC UserModel
  // ---------------------------------------------------------------------------
  Future<UserModel?> getLocalUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid') ?? '';
      
      if (uid.isEmpty) {
        print('⚠️ Aucun utilisateur local trouvé');
        return null;
      }

      // ✅ CRÉER UserModel AVEC LA VERSION SIMPLE
      return UserModel(
        uid: uid,
        email: prefs.getString('email') ?? '',
        fullName: prefs.getString('fullName') ?? '',
        universityId: prefs.getString('university') ?? '',
        profileType: prefs.getString('profileType') ?? '',
        phoneNumber: prefs.getString('phone'),
        averageRating: prefs.getDouble('rating') ?? 0.0,
        ridesCompleted: prefs.getInt('ridesCount') ?? 0,
        isPremium: prefs.getBool('isPremium') ?? false,
      );
    } catch (e) {
      print('❌ Erreur lecture utilisateur local: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // 5. MISE À JOUR PROFIL - COMPATIBLE AVEC UserModel
  // ---------------------------------------------------------------------------
  Future<void> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    try {
      // Découper le nom complet
      List<String> names = fullName.trim().split(" ");
      String firstName = names.isNotEmpty ? names.first : "";
      String lastName = names.length > 1 ? names.sublist(1).join(" ") : "";

      print('📝 Mise à jour profil: $fullName');

      await _api.put(
        'auth/profile',
        {
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
        },
      );

      // Mettre à jour localement
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fullName', fullName);
      await prefs.setString('phone', phone);

      print('✅ Profil mis à jour avec succès');
    } catch (e) {
      print('❌ ERREUR mise à jour profil: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 6. DÉTERMINER SI UTILISATEUR EST CONDUCTEUR
  // ---------------------------------------------------------------------------
  Future<bool> isUserDriver() async {
    try {
      // Option 1: Vérifier dans les préférences (si sauvegardé)
      final prefs = await SharedPreferences.getInstance();
      final isDriver = prefs.getBool('is_driver') ?? false;
      
      // Option 2: Vérifier via API
      if (!isDriver) {
        final response = await _api.get('auth/profile');
        if (response['user'] != null) {
          final userData = response['user'];
          final driverStatus = userData['is_driver'] ?? false;
          await prefs.setBool('is_driver', driverStatus);
          return driverStatus;
        }
      }
      
      return isDriver;
    } catch (e) {
      print('⚠️ Erreur vérification conducteur: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 7. DÉCONNEXION
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    print('👋 Déconnexion...');
    await _api.deleteToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('✅ Déconnexion réussie');
  }

  // ---------------------------------------------------------------------------
  // 8. VÉRIFICATION CONNEXION
  // ---------------------------------------------------------------------------
  Future<bool> isLoggedIn() async {
    final token = await _api.getToken();
    final isLogged = token != null && token.isNotEmpty;
    print('🔑 Utilisateur connecté: $isLogged');
    return isLogged;
  }

  // ---------------------------------------------------------------------------
  // 9. AUTRES MÉTHODES (RESTENT IDENTIQUES)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> checkUniversityEmail(String email) async {
    try {
      final response = await _api.post(
        'auth/check-email',
        {'email': email},
        isProtected: false,
      );
      return response;
    } catch (e) {
      print('❌ Erreur vérification email: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyEmailCode(String email, String code) async {
    try {
      final response = await _api.post(
        'auth/verify-code',
        {'email': email, 'code': code},
        isProtected: true,
      );
      return response;
    } catch (e) {
      print('❌ Erreur vérification code: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resendVerificationCode(String email) async {
    try {
      final response = await _api.post(
        'auth/resend-code',
        {'email': email},
        isProtected: false,
      );
      return response;
    } catch (e) {
      print('❌ Erreur renvoi code: $e');
      rethrow;
    }
  }

  Future<UserModel?> fetchProfileFromServer() async {
    try {
      final response = await _api.get('auth/profile');
      if (response != null && response['user'] != null) {
        final userData = response['user'] as Map<String, dynamic>;
        await _saveUserDataLocally(userData);
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      print('❌ Erreur fetchProfileFromServer: $e');
      return null;
    }
  }
}