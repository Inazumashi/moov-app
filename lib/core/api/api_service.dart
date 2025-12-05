import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // 1. URL DE BASE - MODIFIEZ SELON VOTRE CONFIGURATION
  // Pour émulateur Android : 'http://10.0.2.2:5001/api'
  // Pour émulateur iOS : 'http://localhost:5001/api'
  // Pour vrai appareil : 'http://VOTRE_IP:5001/api'
  final String _baseUrl = "http://10.0.2.2:5001/api";
  
  // 2. STOCKAGE SÉCURISÉ
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _tokenKey = 'jwt_token';

  // --- GESTION DU TOKEN ---
  
  // Sauvegarder le token
  Future<void> storeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Récupérer le token (RENDOMMÉE PUBLIQUE)
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Supprimer le token
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // --- PRÉPARATION DES HEADERS ---
  
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
    print('API Response: ${response.statusCode} - ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {'success': true};
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      deleteToken();
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    } else {
      try {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur serveur');
      } catch (e) {
        throw Exception('Erreur serveur (${response.statusCode})');
      }
    }
  }

  // --- MÉTHODES HTTP ---
  
  // GET
  Future<dynamic> get(String endpoint, {bool isProtected = true}) async {
    final Uri url = Uri.parse('$_baseUrl/$endpoint');
    
    try {
      final headers = await _getHeaders(isProtected: isProtected);
      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur GET: $e');
    }
  }

  // POST
  Future<dynamic> post(String endpoint, Map<String, dynamic> data,
      {bool isProtected = false}) async {
    final Uri url = Uri.parse('$_baseUrl/$endpoint');
    
    try {
      final headers = await _getHeaders(isProtected: isProtected);
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur POST: $e');
    }
  }

  // PUT
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
      throw Exception('Erreur PUT: $e');
    }
  }

  // DELETE
  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? data, bool isProtected = true}) async {
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
      throw Exception('Erreur DELETE: $e');
    }
  }
}