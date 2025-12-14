import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // CORRECTION : URL intelligente selon la plateforme
  String get _baseUrl {
    if (kIsWeb) {
      // En web, utiliser localhost
      return "http://localhost:3000/api";
    }

    // Pour mobile, détecter la plateforme
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android : utiliser 10.0.2.2
      return "http://10.0.2.2:3000/api";
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS : utiliser localhost
      return "http://localhost:3000/api";
    } else {
      // Autres plateformes : utiliser localhost
      return "http://localhost:3000/api";
    }
  }

  // OU SIMPLEMENT : Remettez votre URL originale et changez selon votre besoin
  // Si vous êtes sur Android, utilisez "http://10.0.2.2:3000/api"
  // Si vous êtes sur iOS, utilisez "http://localhost:3000/api"
  // Si vous êtes sur web, utilisez "http://localhost:3000/api"

  // Décommentez la ligne qui correspond à votre plateforme :
  // final String _baseUrl = "http://localhost:3000/api"; // ← iOS et Web
  // final String _baseUrl = "http://10.0.2.2:3000/api"; // ← Android
  //final String _baseUrl = "http://localhost:3000/api"; // ← PAR DÉFAUT (iOS/Web)

  // 2. INITIALISER LE STOCKAGE SÉCURISÉ
  final _storage = const FlutterSecureStorage();
  final String _tokenKey = 'jwt_token'; // La clé pour retrouver notre token

  // --- GESTION DU TOKEN ---

  // Sauvegarder le token (après connexion/inscription)
  Future<void> storeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Lire le token (pour les requêtes)
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Supprimer le token (pour la déconnexion)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // --- PRÉPARATION DES REQUÊTES ---

  // Cette fonction prépare les en-têtes (headers) de la requête
  // Si 'isProtected' est vrai, elle ajoute le token JWT.
  Future<Map<String, String>> _getHeaders({bool isProtected = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };

    if (isProtected) {
      final String? token = await getToken();
      if (token != null) {
        // C'est ici qu'on ajoute le "pass" pour le serveur
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // --- GESTION DES RÉPONSES ---

  // Cette fonction vérifie si le serveur a répondu avec succès ou erreur
  dynamic _handleResponse(http.Response response) {
    // Codes 200 (OK) et 201 (Créé) sont des succès
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // On décode le JSON reçu du serveur
      return json.decode(response.body);
    }

    // Code 401 (Non autorisé) : Le token est invalide ou expiré
    else if (response.statusCode == 401) {
      deleteToken(); // On supprime le token localement
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    }

    // Code 400 (Bad Request)
    else if (response.statusCode == 400) {
      try {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Requête incorrecte');
      } catch (e) {
        throw Exception('Erreur dans la requête: ${response.body}');
      }
    }

    // Autres erreurs (404, 500...)
    else {
      // On essaie de lire le message d'erreur envoyé par le serveur
      try {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur inconnue');
      } catch (e) {
        throw Exception('Erreur serveur (${response.statusCode})');
      }
    }
  }

  // --- MÉTHODES PUBLIQUES (GET, POST) ---

  // Fonction GET (pour récupérer des données, ex: liste de trajets)
  Future<dynamic> get(String endpoint, {bool isProtected = true}) async {
    final Uri url = Uri.parse('$_baseUrl/$endpoint');
    print('🌐 GET: $url'); // Log pour débogage

    try {
      final headers = await _getHeaders(isProtected: isProtected);
      final response = await http.get(url, headers: headers);
      print('📡 Réponse: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Erreur GET: $e');
      throw Exception('Erreur de connexion : $e');
    }
  }

  // Fonction POST (pour envoyer des données, ex: connexion, publication)
  Future<dynamic> post(String endpoint, Map<String, dynamic> data,
      {bool isProtected = false}) async {
    final Uri url = Uri.parse('$_baseUrl/$endpoint');
    print('🌐 POST: $url');
    print('📦 Data: $data');

    try {
      final headers = await _getHeaders(isProtected: isProtected);
      
      // 🔍 VÉRIFICATION DU TOKEN POUR LES ROUTES PROTÉGÉES
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
      throw Exception('Erreur de connexion : $e');
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
      throw Exception('Erreur PUT: $e');
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
      throw Exception('Erreur DELETE: $e');
    }
  }
}
