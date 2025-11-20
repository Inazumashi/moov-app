import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/user_model.dart';

class AuthService {
  final ApiService _api = ApiService();

  // Connexion réelle via l'API
  Future<UserModel?> signIn(String email, String password) async {
    try {
      // 1. Appel à l'API (POST /auth/login)
      final response = await _api.post(
        'auth/login', 
        {
          'email': email, 
          'password': password
        },
      );

      // 2. Si succès, l'API renvoie un token et l'utilisateur
      final String token = response['token'];
      final Map<String, dynamic> userData = response['user'];

      // 3. On stocke le token pour les prochaines requêtes
      await _api.storeToken(token);

      // 4. On convertit le JSON en objet UserModel
      return UserModel.fromJson(userData);

    } catch (e) {
      // On relance l'erreur pour l'afficher dans l'UI (LoginScreen)
      rethrow;
    }
  }

  // Inscription réelle via l'API
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String universityId, // ex: "Université Mohammed VI..."
    required String profileType,  // ex: "Étudiant"
    required String phoneNumber,
  }) async {
    try {
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
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    // On supprime simplement le token du téléphone
    await _api.deleteToken();
  }
}