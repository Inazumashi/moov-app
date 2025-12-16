import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumProvider with ChangeNotifier {
  static const String _premiumStatusKey = 'is_premium';
  static const String _premiumExpiryKey = 'premium_expiry';

  bool _isPremium = false;
  DateTime? _premiumExpiry;

  bool get isPremium => _isPremium;
  DateTime? get premiumExpiry => _premiumExpiry;

  Future<void> loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumStatusKey) ?? false;

    final expiryString = prefs.getString(_premiumExpiryKey);
    if (expiryString != null) {
      _premiumExpiry = DateTime.parse(expiryString);
      // Vérifier si l'abonnement a expiré
      if (_premiumExpiry!.isBefore(DateTime.now())) {
        _isPremium = false;
        _premiumExpiry = null;
        await _saveStatus();
      }
    }

    notifyListeners();
  }

  Future<void> activatePremium() async {
    _isPremium = true;
    _premiumExpiry = DateTime.now().add(const Duration(days: 30)); // 30 jours
    await _saveStatus();
    notifyListeners();
  }

  Future<void> deactivatePremium() async {
    _isPremium = false;
    _premiumExpiry = null;
    await _saveStatus();
    notifyListeners();
  }

  Future<void> _saveStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumStatusKey, _isPremium);
    if (_premiumExpiry != null) {
      await prefs.setString(_premiumExpiryKey, _premiumExpiry!.toIso8601String());
    } else {
      await prefs.remove(_premiumExpiryKey);
    }
  }

  String getRemainingTime() {
    if (!_isPremium || _premiumExpiry == null) return '';

    final remaining = _premiumExpiry!.difference(DateTime.now());
    if (remaining.isNegative) return '';

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;

    if (days > 0) {
      return '$days jours';
    } else if (hours > 0) {
      return '$hours heures';
    } else {
      return 'Moins d\'1 heure';
    }
  }
}