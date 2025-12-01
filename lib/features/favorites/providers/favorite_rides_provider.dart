import 'package:flutter/material.dart';
import 'package:moovapp/core/models/favorite_ride.dart';

class FavoriteRidesProvider extends ChangeNotifier {
  List<FavoriteRide> _favorites = [];

  // ✅ Getter renommé pour correspondre à ton écran
  List<FavoriteRide> get rides => _favorites;

  bool isFavorite(String name) {
    return _favorites.any((ride) => ride.name == name);
  }

  void toggleFavorite(FavoriteRide ride) {
    if (isFavorite(ride.name)) {
      _favorites.removeWhere((r) => r.name == ride.name);
    } else {
      _favorites.add(ride);
    }
    notifyListeners();
  }

  // ✅ Ajouter removeRide pour l'écran
  void removeRide(FavoriteRide ride) {
    _favorites.removeWhere((r) => r.name == ride.name);
    notifyListeners();
  }
}
