// File: lib/core/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class ApiService {
  // ✅ URL DYNAMIQUE POUR CHAQUE PLATEFORME
  static String get _baseUrl {
    // Pour le web (Chrome)
    if (kIsWeb) {
      return "http://localhost:3000/api";
    }
    // Pour Android
    if (Platform.isAndroid) {
      return "http://10.0.2.2:3000/api";
    }
    // Pour iOS
    if (Platform.isIOS) {
      return "http://localhost:3000/api";
    }
    // Par défaut
    return "http://localhost:3000/api";
  }

  // ✅ AJOUT: Pour détecter si on est sur le web
  static bool get kIsWeb => identical(0, 0.0);

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final url = '$_baseUrl/$endpoint';
      print('🔄 API CALL: GET $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: 10));
      
      print('✅ API RESPONSE: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ API ERROR: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = '$_baseUrl/$endpoint';
      print('🔄 API CALL: POST $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      ).timeout(Duration(seconds: 10));
      
      print('✅ API RESPONSE: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      print('❌ API ERROR: $e');
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = '$_baseUrl/$endpoint';
      final response = await http.put(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      ).timeout(Duration(seconds: 10));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final url = '$_baseUrl/$endpoint';
      final response = await http.delete(
        Uri.parse(url),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: 10));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    print('📊 Response status: ${response.statusCode}');
    print('📊 Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('Erreur de parsing JSON: $e');
      }
    } else {
      throw HttpException(
        'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        statusCode: response.statusCode,
      );
    }
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;

  HttpException(this.message, {this.statusCode = 0});

  @override
  String toString() => message;
}