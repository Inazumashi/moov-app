import 'dart:convert'; // Pour convertir les données en JSON
import 'package:http/http.dart' as http; // Pour faire les appels réseau
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Pour stocker le token

class ApiService {
  // 1. DÉFINIR L'URL DE VOTRE API NODE.JS
  // IMPORTANT:
  // - Émulateur Android : utilisez 'http://10.0.2.2:5000/api/v1'
  // - Émulateur iOS : utilisez 'http://localhost:5000/api/v1'
  // - Téléphone réel : utilisez l'adresse IP de votre PC (ex: 'http://192.168.1.15:5000/api/v1')
  final String _baseUrl = "http://10.0.2.2:5001/api/v1";

  // 2. INITIALISER LE STOCKAGE SÉCURISÉ
  final _storage = const FlutterSecureStorage();
  final String _tokenKey = 'jwt_token'; // La clé pour retrouver notre token

  // --- GESTION DU TOKEN ---

  // Sauvegarder le token (après connexion/inscription)
  Future<void> storeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Lire le token (pour les requêtes)
  Future<String?> _getToken() async {
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
      final String? token = await _getToken();
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

    // Autres erreurs (400, 404, 500...)
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

    try {
      final headers = await _getHeaders(isProtected: isProtected);
      final response = await http.get(url, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }

  // Fonction POST (pour envoyer des données, ex: connexion, publication)
  Future<dynamic> post(String endpoint, Map<String, dynamic> data,
      {bool isProtected = false}) async {
    final Uri url = Uri.parse('$_baseUrl/$endpoint');

    try {
      final headers = await _getHeaders(isProtected: isProtected);
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data), // On convertit les données en JSON
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur de connexion : $e');
    }
  }

  // Vous pourrez ajouter PUT et DELETE plus tard si nécessaire
}
