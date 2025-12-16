import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moovapp/core/models/payment_method.dart';

class PaymentService {
  static const String _paymentMethodsKey = 'payment_methods';
  static const String _paypalClientId = 'YOUR_PAYPAL_CLIENT_ID'; // À remplacer par votre client ID
  static const String _paypalClientSecret = 'YOUR_PAYPAL_CLIENT_SECRET'; // À remplacer par votre client secret

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
          print("onSuccess: $params");
          String paymentId = params['data']['id'];
          onSuccess(paymentId);
        },
        onError: (error) {
          print("onError: $error");
          onError(error.toString());
        },
        onCancel: () {
          print('cancelled:');
          onError('Payment cancelled');
        },
      ),
    ));
  }

  // Gestion des méthodes de paiement
  Future<List<PaymentMethod>> getPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final methodsJson = prefs.getStringList(_paymentMethodsKey) ?? [];
    return methodsJson.map((json) => PaymentMethod.fromJson(jsonDecode(json))).toList();
  }

  Future<void> addPaymentMethod(PaymentMethod method) async {
    final prefs = await SharedPreferences.getInstance();
    var methods = await getPaymentMethods();

    // Si c'est la méthode par défaut, désactiver les autres
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
}