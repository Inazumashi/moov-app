import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moovapp/core/models/payment_method.dart';

class PaymentService {
  static const String _paymentMethodsKey = 'payment_methods';
  
  // ⚠️ IMPORTANT : Remplace ces clés par tes identifiants Sandbox PayPal
  static const String _paypalClientId = 'YOUR_PAYPAL_CLIENT_ID'; 
  static const String _paypalClientSecret = 'YOUR_PAYPAL_CLIENT_SECRET';

  // ⚠️ CONFIGURATION URL BACKEND
  // Si tu utilises l'Émulateur Android : utilise 'http://10.0.2.2:3000'
  // Si tu utilises un Téléphone Physique : utilise l'IP de ton PC (ex: 'http://192.168.1.15:3000')
  static const String _baseUrl = 'http://10.0.2.2:3000/api'; 

  // Simuler un serveur pour les tokens PayPal (en production, ceci devrait être côté serveur)
  Future<String> _getPayPalAccessToken() async {
    final response = await http.post(
      Uri.parse('https://api.sandbox.paypal.com/v1/oauth2/token'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$_paypalClientId:$_paypalClientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Failed to get PayPal access token');
    }
  }

  Future<void> initiatePayPalPayment({
    required BuildContext context,
    required double amount,
    required String currency,
    required String description,
    required Function(String paymentId) onSuccess,
    required Function(String error) onError,
  }) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => PaypalCheckoutView(
        sandboxMode: true, // true pour sandbox, false pour production
        clientId: _paypalClientId,
        secretKey: _paypalClientSecret,
        transactions: [
          {
            "amount": {
              "total": amount.toStringAsFixed(2),
              "currency": currency,
              "details": {
                "subtotal": amount.toStringAsFixed(2),
                "shipping": '0',
                "shipping_discount": 0
              }
            },
            "description": description,
            "item_list": {
              "items": [
                {
                  "name": "Abonnement Premium Moov",
                  "quantity": 1,
                  "price": amount.toStringAsFixed(2),
                  "currency": currency
                }
              ],
            }
          }
        ],
        note: "Contact us for any questions on your order.",
        onSuccess: (Map params) async {
          print("onSuccess PayPal: $params");
          // On extrait l'ID de paiement renvoyé par PayPal
          String paymentId = params['data']['id'];
          onSuccess(paymentId);
        },
        onError: (error) {
          print("onError PayPal: $error");
          onError(error.toString());
        },
        onCancel: () {
          print('cancelled:');
          onError('Paiement annulé');
        },
      ),
    ));
  }

  // --- Gestion locale des méthodes de paiement (inchangé) ---
  
  Future<List<PaymentMethod>> getPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final methodsJson = prefs.getStringList(_paymentMethodsKey) ?? [];
    return methodsJson.map((json) => PaymentMethod.fromJson(jsonDecode(json))).toList();
  }

  Future<void> addPaymentMethod(PaymentMethod method) async {
    final prefs = await SharedPreferences.getInstance();
    var methods = await getPaymentMethods();

    if (method.isDefault) {
      methods = methods.map((m) => m.copyWith(isDefault: false)).toList();
    }

    methods.add(method);
    final methodsJson = methods.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_paymentMethodsKey, methodsJson);
  }

  Future<void> removePaymentMethod(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final methods = await getPaymentMethods();
    methods.removeWhere((m) => m.id == id);
    final methodsJson = methods.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_paymentMethodsKey, methodsJson);
  }

  Future<void> setDefaultPaymentMethod(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final methods = await getPaymentMethods();
    final updatedMethods = methods.map((method) => method.copyWith(isDefault: method.id == id)).toList();
    final methodsJson = updatedMethods.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_paymentMethodsKey, methodsJson);
  }

  Future<PaymentMethod?> getDefaultPaymentMethod() async {
    final methods = await getPaymentMethods();
    try {
      return methods.firstWhere((m) => m.isDefault);
    } catch (e) {
      return methods.isNotEmpty ? methods.first : null;
    }
  }

  // ---------------------------------------------------------------------------
  // NOUVELLE FONCTION : Vérification avec le Backend
  // ---------------------------------------------------------------------------
  
  Future<void> verifyPaymentWithBackend(String paymentId, double amount) async {
    final url = Uri.parse('$_baseUrl/payment/verify-paypal');
    
    print("Envoi verification au backend : $url avec PaymentID: $paymentId");

    final prefs = await SharedPreferences.getInstance();
    // On récupère le token JWT sauvegardé lors du Login
    // Vérifie que la clé est bien 'token' ou 'auth_token' selon ton AuthProvider
    final token = prefs.getString('token'); 

    if (token == null) {
      throw Exception("Erreur d'authentification : Vous devez être connecté.");
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'paymentId': paymentId,
          'amount': amount,
          'currency': 'MAD'
        }),
      );

      print("Réponse Backend Code: ${response.statusCode}");
      print("Réponse Backend Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // C'est bon, le backend a validé !
        return;
      } else {
        // Le backend a refusé (déjà payé, erreur serveur, etc.)
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur lors de la validation du paiement');
      }
    } catch (e) {
      print("Erreur connection Backend: $e");
      throw Exception("Impossible de contacter le serveur : $e");
    }
  }
}