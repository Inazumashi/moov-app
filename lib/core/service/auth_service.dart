import 'package:moovapp/core/models/user_model.dart';

// Ce service gérera l'inscription, la connexion et la déconnexion.
// Pour l'instant, ce sont des fonctions "bouchons" (placeholders).

class AuthService {
  // Simule une connexion
  Future<UserModel?> signIn(String email, String password) async {
    print('Tentative de connexion avec $email');
    // TODO: Ajouter la vraie logique de connexion (ex: Firebase)
    await Future.delayed(const Duration(seconds: 1));
    
    // On simule un utilisateur connecté
    return UserModel(
      uid: 'fake_uid_123',
      email: email,
      fullName: 'Ahmed Benali (Simulé)',
      universityId: 'um6p',
      profileType: 'Étudiant',
    );
  }

  // Simule une inscription
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String universityId,
    required String profileType,
    required String phoneNumber,
  }) async {
    print('Tentative d\'inscription pour $fullName');
    // TODO: Ajouter la vraie logique d'inscription (ex: Firebase)
    await Future.delayed(const Duration(seconds: 1));
    
    // On simule un nouvel utilisateur
    return UserModel(
      uid: 'fake_uid_456',
      email: email,
      fullName: fullName,
      universityId: universityId,
      profileType: profileType,
      phoneNumber: phoneNumber,
    );
  }

  // Simule une déconnexion
  Future<void> signOut() async {
    print('Déconnexion...');
    // TODO: Ajouter la vraie logique de déconnexion
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
