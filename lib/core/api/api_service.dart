import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // URL intelligente selon la plateforme
  String get _baseUrl {
    if (kIsWeb) {
      return "http://localhost:3000/api";
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:3000/api";
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return "http://localhost:3000/api";
    } else {
      return "http://localhost:3000/api";
    }
  }

  final _storage = const FlutterSecureStorage();
  final String _tokenKey = 'jwt_token';

  // --- GESTION DU TOKEN ---

  Future<void> storeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // --- PRÉPARATION DES REQUÊTES ---

  Future<Map<String, String>> _getHeaders({bool isProtected = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    if (isProtected) {
      final String? token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // --- GESTION DES RÉPONSES ---

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    }

    else if (response.statusCode == 401) {
      deleteToken();
      final body = response.body.isNotEmpty ? ' - ${response.body}' : '';
      throw Exception('Session expirée. Veuillez vous reconnecter.$body');
    }

    else if (response.statusCode == 400) {
      try {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Requête incorrecte');
      } catch (e) {
        throw Exception('Erreur dans la requête: ${response.body}');
      }
    }

    else {
      try {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur inconnue');
      } catch (e) {
        final body = response.body.isNotEmpty ? ' - ${response.body}' : '';
        throw Exception('Erreur serveur (${response.statusCode})$body');
      }
    }
  }

  // --- MÉTHODES PUBLIQUES ---

  Future<dynamic> get(String endpoint, {bool isProtected = true}) async {
    final Uri url = Uri.parse('$_baseUrl/$endpoint');
    print('🌐 GET: $url');

    try {
      final headers = await _getHeaders(isProtected: isProtected);
      final response = await http.get(url, headers: headers);
      print('📡 Réponse: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur GET: $e');
      rethrow;
    }
  }

  // ✅ CORRECTION CRITIQUE : isProtected = TRUE par défaut pour POST
  Future<dynamic> post(String endpoint, Map<String, dynamic> data,
      {bool isProtected = true}) async {  // ✅ CHANGÉ de false à true
    final Uri url = Uri.parse('$_baseUrl/$endpoint');
    print('🌐 POST: $url');
    print('📦 Data: $data');

    try {
      final headers = await _getHeaders(isProtected: isProtected);

      // Vérification du token pour les routes protégées
      if (isProtected) {
        final token = await getToken();
        if (token == null || token.isEmpty) {
          print('🔴 Aucun token disponible pour route protégée');
          throw Exception('Session expirée. Veuillez vous reconnecter.');
        }
        print('🔑 Token présent: ${token.substring(0, 20)}...');
      }

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );
      print('📡 Réponse: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur POST: $e');
      rethrow;
    }
  }

  // PUT avec body
  Future<dynamic> put(String endpoint, Map<String, dynamic> data,
      {bool isProtected = true}) async {
    final Uri url = Uri.parse('$_baseUrl/$endpoint');

    try {
      final headers = await _getHeaders(isProtected: isProtected);
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur PUT: $e');
      rethrow;
    }
  }

  // DELETE avec ou sans body
  Future<dynamic> delete(String endpoint,
      {Map<String, dynamic>? data, bool isProtected = true}) async {
    final Uri url = Uri.parse('$_baseUrl/$endpoint');

    try {
      final headers = await _getHeaders(isProtected: isProtected);

      final request = http.Request('DELETE', url);
      request.headers.addAll(headers);

      if (data != null) {
        request.body = json.encode(data);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur DELETE: $e');
      rethrow;
    }
  }
}