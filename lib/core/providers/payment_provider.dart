import 'package:flutter/material.dart';
import 'package:moovapp/core/models/payment_method.dart';
import 'package:moovapp/core/service/payment_service.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = false;
  String? _error;

  List<PaymentMethod> get paymentMethods => _paymentMethods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPaymentMethods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _paymentMethods = await _paymentService.getPaymentMethods();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPaymentMethod(PaymentMethod method) async {
    try {
      await _paymentService.addPaymentMethod(method);
      await loadPaymentMethods(); // Recharger la liste
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removePaymentMethod(String id) async {
    try {
      await _paymentService.removePaymentMethod(id);
      await loadPaymentMethods();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> setDefaultPaymentMethod(String id) async {
    try {
      await _paymentService.setDefaultPaymentMethod(id);
      await loadPaymentMethods();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
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
    await _paymentService.initiatePayPalPayment(
      context: context,
      amount: amount,
      currency: currency,
      description: description,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  // ---------------------------------------------------------------------------
  // NOUVELLE MÉTHODE : Appeler le backend pour valider le paiement
  // ---------------------------------------------------------------------------
  Future<void> verifyAndActivatePremium(String paymentId, double amount) async {
    try {
      // On peut mettre isLoading à true si on veut montrer un loader
      _isLoading = true;
      notifyListeners();

      await _paymentService.verifyPaymentWithBackend(paymentId, amount);
      
      // Si on arrive ici, c'est que le backend a répondu 200 OK.
      // On retire l'erreur potentielle précédente
      _error = null;

    } catch (e) {
      _error = e.toString();
      notifyListeners();
      // On relance l'erreur pour que l'écran (PremiumScreen) puisse afficher la SnackBar rouge
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PaymentMethod?> getDefaultPaymentMethod() async {
    return await _paymentService.getDefaultPaymentMethod();
  }
}