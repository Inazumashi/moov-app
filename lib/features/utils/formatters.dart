import 'package:intl/intl.dart';

// Ce fichier contiendra des fonctions statiques pour formater
// des données à afficher à l'utilisateur.

class AppFormatters {
  // Formate une date en "10 Oct"
  static String formatDateShort(DateTime date) {
    // Vous aurez besoin d'ajouter le package 'intl' à votre pubspec.yaml
    // pour que cela fonctionne : flutter pub add intl
    return DateFormat('d MMM', 'fr_FR').format(date);
  }

  // Formate une heure en "08:00"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'fr_FR').format(date);
  }

  // Formate un prix en "15 MAD"
  static String formatCurrency(double price) {
    // Note: Pour une vraie app, utilisez un package de formatage de devise
    // qui gère mieux les différentes langues et symboles.
    return '${price.toStringAsFixed(0)} MAD';
  }
}
