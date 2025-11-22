import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _prefKey = 'selectedLanguage';

  Locale _locale = const Locale('fr'); // Langue par défaut

  Locale get locale => _locale;

  LanguageProvider() {
    _loadSavedLocale();
  }

  // Charge la langue sauvegardée dans SharedPreferences
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null && ['fr', 'en', 'ar'].contains(code)) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  // Change la langue et sauvegarde
  Future<void> setLocale(Locale locale) async {
    if (!['fr', 'en', 'ar'].contains(locale.languageCode)) return;
    if (locale == _locale) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }

  // Remet la langue par défaut
  Future<void> clearLocale() async {
    _locale = const Locale('fr');
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}
