// File: lib/core/service/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moovapp/core/models/user_model.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:3000/api/auth';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'jwt_token', value: data['token']);
        
        return UserModel.fromJson(data['user']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Échec de la connexion');
      }
    } catch (e) {
      print('Erreur connexion: $e');
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
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
          'universityId': universityId,
          'profileType': profileType,
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'jwt_token', value: data['token']);
        
        return UserModel.fromJson(data['user']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Échec de l\'inscription');
      }
    } catch (e) {
      print('Erreur inscription: $e');
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