// File: lib/core/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moovapp/core/models/user_model.dart';
// 👇 1. Importez le service ET le modèle RouteInfo
import 'package:moovapp/core/service/auth_service.dart'; 
import 'package:moovapp/features/inscription/screens/routes_config_screen.dart'; 

class AuthProvider with ChangeNotifier {
<<<<<<< HEAD
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String _error = '';

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isLoggedIn => _user != null;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _user = await _authService.signIn(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
  // On utilise notre service qui parle au backend
=======
>>>>>>> 38397c1094c7156cf54cdb86b901a3d5d3bc6b55
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
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _user = await _authService.signUp(
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
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      // Optionnel: Récupérer les infos utilisateur
      // _user = await _authService.getCurrentUser();
    } else {
      _user = null;
    }
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
      
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