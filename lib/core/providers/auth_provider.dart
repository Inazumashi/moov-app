// File: lib/core/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moovapp/core/models/user_model.dart';
import 'package:moovapp/core/service/auth_service.dart';

class AuthProvider with ChangeNotifier {
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
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _user = await _authService.signUp(
    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        universityId: universityId,
        profileType: profileType,
        phoneNumber: phoneNumber,
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

  // --- DÉCONNEXION ---
  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null; // On vide l'utilisateur
    notifyListeners(); // On prévient l'app (retour à l'écran Login)
  }
}