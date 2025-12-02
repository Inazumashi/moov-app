import 'package:flutter/material.dart';
import 'package:moovapp/core/models/user_model.dart';
// 👇 1. Importez le service ET le modèle RouteInfo
import 'package:moovapp/core/service/auth_service.dart'; 
import 'package:moovapp/features/inscription/screens/routes_config_screen.dart'; 

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  
  bool get isAuthenticated => _currentUser != null;
  UserModel? get currentUser => _currentUser;

  // --- CONNEXION (Inchangé) ---
  Future<void> login(String email, String password) async {
    try {
      final user = await _authService.signIn(email, password);
      _currentUser = user;
      notifyListeners();
    } catch (e) {
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
    
    required List<RouteInfo> routes, 
  }) async {
    try {
      // 👇 3. TRANSMISSION : On passe les routes au service
      final user = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        universityId: universityId,
        profileType: profileType,
        phoneNumber: phoneNumber,
        routes: routes, // ✅ C'est ce qui manquait !
      );
      
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // --- DÉCONNEXION (Inchangé) ---
  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}