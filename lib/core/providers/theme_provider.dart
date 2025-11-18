import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Pour la console (debug)

// 1. ThemeProvider est une classe qui change (ChangeNotifier)
class ThemeProvider with ChangeNotifier {
  // 2. État du thème (par défaut: clair)
  bool _isDarkMode = false;
  
  // TODO: Ajoutez ici la logique pour lire la préférence stockée (SharedPreferences)

  // 3. Getter pour lire l'état actuel
  bool get isDarkMode => _isDarkMode;

  // 4. Getter pour retourner le mode de thème Flutter (light ou dark)
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // 5. Fonction pour basculer le thème (utilisé par le Switch dans settings_screen)
  void toggleTheme(bool value) {
    if (_isDarkMode == value) return; // Évite les reconstructions inutiles
    
    _isDarkMode = value;
    
    if (kDebugMode) {
      print('THÈME CHANGÉ: ${_isDarkMode ? "Sombre" : "Clair"}');
    }
    
    // 6. Notifier les widgets de se reconstruire (changer de couleur)
    notifyListeners();
    // TODO: Sauvegarder la préférence dans SharedPreferences pour qu'elle persiste
  }
}