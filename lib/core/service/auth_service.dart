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
        {'email': email, 'password': password},
        isProtected: false,
      );

      final String token = response['token'];
      final Map<String, dynamic> userData = response['user'];

      await _api.storeToken(token);
      await _saveUserDataLocally(userData);

      return UserModel.fromJson(userData);
    } catch (e) {
      print('❌ ERREUR CONNEXION: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. INSCRIPTION (CORRIGÉ AVEC LOGS)
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

      // ✅ DONNÉES À ENVOYER (avec le bon format)
      final requestData = {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'university':
            universityId, // ✅ CORRIGÉ: "university" au lieu de "university_id"
        'profile_type': profileType,
        'phone': phoneNumber,
        'student_id': null,
        'routes': routesFormatted,
      };

      // ✅ LOG: Afficher les données avant l'envoi
      print('═══════════════════════════════════════');
      print('📤 INSCRIPTION - Données envoyées au backend:');
      print('Email: $email');
      print('Prénom: $firstName');
      print('Nom: $lastName');
      print('Université: $universityId');
      print('Type de profil: $profileType');
      print('Téléphone: $phoneNumber');
      print('Nombre de routes: ${routesFormatted.length}');
      print('Données complètes: $requestData');
      print('═══════════════════════════════════════');

      // Envoyer la requête
      final response = await _api.post(
        'auth/register',
        requestData,
        isProtected: false,
      );

      // ✅ LOG: Afficher la réponse du backend
      print('═══════════════════════════════════════');
      print('📥 INSCRIPTION - Réponse du backend:');
      print('Success: ${response['success']}');
      print('Message: ${response['message']}');
      print('User ID: ${response['user']?['id']}');
      print('Réponse complète: $response');
      print('═══════════════════════════════════════');

      final String token = response['token'];
      final Map<String, dynamic> userData = response['user'];

      await _api.storeToken(token);
      await _saveUserDataLocally(userData);

      return UserModel.fromJson(userData);
    } catch (e) {
      // ✅ LOG: Afficher l'erreur détaillée
      print('═══════════════════════════════════════');
      print('❌ ERREUR INSCRIPTION DÉTAILLÉE:');
      print('Type: ${e.runtimeType}');
      print('Message: $e');
      print('═══════════════════════════════════════');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. VÉRIFICATION EMAIL UNIVERSITAIRE
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> checkUniversityEmail(String email) async {
    try {
      print('📧 Vérification email: $email');

      final response = await _api.post(
        'auth/check-email',
        {'email': email},
        isProtected: false,
      );

      print('✅ Email vérifié: ${response['success']}');
      return response;
    } catch (e) {
      print('❌ ERREUR vérification email: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 4. VÉRIFICATION CODE
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> verifyEmailCode(
      String email, String code) async {
    try {
      print('🔐 Vérification code pour: $email');

      // Ce endpoint doit s'exécuter en contexte d'utilisateur (token JWT)
      // pour que le backend puisse associer la vérification à l'utilisateur.
      final response = await _api.post(
        'auth/verify-code',
        {'email': email, 'code': code},
        isProtected: true,
      );

      print('✅ Code vérifié: ${response['success']}');
      return response;
    } catch (e) {
      print('❌ ERREUR vérification code: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 5. RÉENVOYER CODE
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> resendVerificationCode(String email) async {
    try {
      print('🔄 Renvoi du code pour: $email');

      final response = await _api.post(
        'auth/resend-code',
        {'email': email},
        isProtected: false,
      );

      print('✅ Code renvoyé: ${response['success']}');
      return response;
    } catch (e) {
      print('❌ ERREUR renvoi code: $e');
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

      print('📝 Mise à jour profil: $firstName $lastName');

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

      print('✅ Profil mis à jour avec succès');
    } catch (e) {
      print('❌ ERREUR mise à jour profil: $e');
      rethrow;
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
  // 9. SAUVEGARDE LOCALE
  // ---------------------------------------------------------------------------
  Future<void> _saveUserDataLocally(Map<String, dynamic> userData) async {
    print('💾 Sauvegarde données utilisateur localement...');

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_id', userData['id']?.toString() ?? '');
    await prefs.setString('email', userData['email'] ?? '');
    await prefs.setString('first_name', userData['first_name'] ?? '');
    await prefs.setString('last_name', userData['last_name'] ?? '');
    await prefs.setString('phone', userData['phone'] ?? '');
    await prefs.setString('university', userData['university'] ?? '');
    await prefs.setString('profile_type', userData['profile_type'] ?? '');
    await prefs.setDouble(
        'rating', (userData['rating'] as num?)?.toDouble() ?? 5.0);

    print('✅ Données utilisateur sauvegardées');
  }

  // ---------------------------------------------------------------------------
  // LIRE L'UTILISATEUR LOCALEMENT
  // ---------------------------------------------------------------------------
  Future<UserModel?> getLocalUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('user_id') ?? '';
      if (id.isEmpty) return null;

      final firstName = prefs.getString('first_name') ?? '';
      final lastName = prefs.getString('last_name') ?? '';
      final fullName =
          [firstName, lastName].where((s) => s.isNotEmpty).join(' ').trim();

      final email = prefs.getString('email') ?? '';
      final university = prefs.getString('university') ?? '';
      final profileType = prefs.getString('profile_type') ?? '';
      final phone = prefs.getString('phone') ?? '';
      final rating = prefs.getDouble('rating') ?? 0.0;
      final rides = prefs.getInt('rides_count') ?? 0;
      final isPremium = prefs.getBool('is_premium') ?? false;

      return UserModel(
        uid: id,
        email: email,
        fullName: fullName,
        universityId: university,
        profileType: profileType,
        phoneNumber: phone,
        averageRating: rating,
        ridesCompleted: rides,
        isPremium: isPremium,
      );
    } catch (e) {
      print('❌ Erreur lecture utilisateur local: $e');
      return null;
    }
  }

  // Récupérer le profil utilisateur depuis le backend (route protégée)
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
      rethrow;
    }
  }
}
