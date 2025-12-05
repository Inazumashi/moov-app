// File: lib/core/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:moovapp/core/models/user_model.dart';
import 'package:moovapp/core/service/auth_service.dart';
import 'package:moovapp/features/inscription/screens/routes_config_screen.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String _error = '';
  
  bool get isAuthenticated => _currentUser != null;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get error => _error;

  // --- CONNEXION ---
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final user = await _authService.signIn(email, password);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
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
      final user = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        universityId: universityId,
        profileType: profileType,
        phoneNumber: phoneNumber,
        routes: routes,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // --- VÉRIFICATION EMAIL ---
  Future<Map<String, dynamic>> checkUniversityEmail(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.checkUniversityEmail(email);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // --- VÉRIFICATION CODE ---
  Future<Map<String, dynamic>> verifyEmailCode(String email, String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.verifyEmailCode(email, code);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // --- RÉENVOYER CODE ---
  Future<Map<String, dynamic>> resendVerificationCode(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.resendVerificationCode(email);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // --- MISE À JOUR PROFIL ---
  Future<void> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _authService.updateProfile(
        fullName: fullName,
        phone: phone,
      );
      
      // Mettre à jour l'utilisateur local
      if (_currentUser != null) {
        _currentUser = UserModel(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          fullName: fullName,
          universityId: _currentUser!.universityId,
          profileType: _currentUser!.profileType,
          phoneNumber: phone,
          averageRating: _currentUser!.averageRating,
          ridesCompleted: _currentUser!.ridesCompleted,
          isPremium: _currentUser!.isPremium,
        );
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // --- DÉCONNEXION ---
  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // --- VÉRIFIER ÉTAT CONNEXION ---
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn) {
      _currentUser = null;
    }
    notifyListeners();
  }

  // --- EFFACER ERREUR ---
  void clearError() {
    _error = '';
    notifyListeners();
  }
}