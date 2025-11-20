import 'package:flutter/material.dart';
import 'package:moovapp/core/models/user_model.dart';
import 'package:moovapp/core/service/auth_service.dart';

class AuthProvider with ChangeNotifier {
  // On utilise notre service qui parle au backend
  final AuthService _authService = AuthService();

  // L'état de l'utilisateur actuel
  UserModel? _currentUser;
  
  // Getter pour savoir si on est connecté
  bool get isAuthenticated => _currentUser != null;
  
  // Getter pour récupérer les infos de l'utilisateur (pour le Profil)
  UserModel? get currentUser => _currentUser;

  // --- CONNEXION ---
  Future<void> login(String email, String password) async {
    try {
      // 1. On appelle le service pour se connecter
      final user = await _authService.signIn(email, password);
      
      // 2. Si ça marche, on stocke l'utilisateur dans le Provider
      _currentUser = user;
      
      // 3. On prévient toute l'app que l'utilisateur a changé (pour mettre à jour l'UI)
      notifyListeners();
    } catch (e) {
      // Si erreur, on la transmet à l'écran (pour afficher "Mot de passe incorrect")
      rethrow;
    }
  }

  // --- INSCRIPTION ---
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String universityId,
    required String profileType,
    required String phoneNumber,
  }) async {
    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        universityId: universityId,
        profileType: profileType,
        phoneNumber: phoneNumber,
      );
      
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // --- DÉCONNEXION ---
  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null; // On vide l'utilisateur
    notifyListeners(); // On prévient l'app (retour à l'écran Login)
  }
}