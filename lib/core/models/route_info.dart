// File: lib/core/models/route_info.dart
import 'package:flutter/foundation.dart';

class RouteInfo {
  final String depart;
  final String arrivee;
  final List<String> jours;
  final String plageHoraire;

  RouteInfo({
    required this.depart,
    required this.arrivee,
    required this.jours,
    required this.plageHoraire,
  });

  // Pour la conversion en JSON (pour l'API)
  Map<String, dynamic> toJson() {
    return {
      'depart': depart,
      'arrivee': arrivee,
      'jours': jours,
      'heure': plageHoraire,
    };
  }

  // Pour afficher dans l'UI
  String get displayText {
    final joursStr = jours.join(', ');
    return '$depart → $arrivee ($joursStr à $plageHoraire)';
  }

  // Pour comparer deux RouteInfo
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is RouteInfo &&
        other.depart == depart &&
        other.arrivee == arrivee &&
        listEquals(other.jours, jours) &&
        other.plageHoraire == plageHoraire;
  }

  @override
  int get hashCode {
    return depart.hashCode ^
        arrivee.hashCode ^
        jours.hashCode ^
        plageHoraire.hashCode;
  }

  // Copie avec modifications
  RouteInfo copyWith({
    String? depart,
    String? arrivee,
    List<String>? jours,
    String? plageHoraire,
  }) {
    return RouteInfo(
      depart: depart ?? this.depart,
      arrivee: arrivee ?? this.arrivee,
      jours: jours ?? this.jours,
      plageHoraire: plageHoraire ?? this.plageHoraire,
    );
  }
}