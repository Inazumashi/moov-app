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
    if (identical(0, 0.0)) {
      // kIsWeb alternative
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

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

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
      rethrow;
    }
  }

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String universityId,
    required String profileType,
    required String phoneNumber,
  }) async {
    try {
      final url = '$_baseUrl/register';
      print('🔄 AUTH: Inscription avec $email');

      final response = await http
          .post(
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
          )
          .timeout(const Duration(seconds: 10));

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
      rethrow;
    }
  }

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
}
