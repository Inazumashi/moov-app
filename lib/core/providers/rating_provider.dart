// File: lib/core/providers/rating_provider.dart
import 'package:flutter/material.dart';
import 'package:moovapp/core/service/rating_service.dart';
import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/models/rating_model.dart';

class RatingProvider with ChangeNotifier {
  final RatingService _ratingService;

  List<RatingModel> _driverRatings = [];
  List<RatingModel> _myRatings = [];
  bool _isLoading = false;
  String _error = '';
  double _driverAverageRating = 0.0;
  int _driverTotalRatings = 0;

  RatingProvider() : _ratingService = RatingService(ApiService());

  // Getters
  List<RatingModel> get driverRatings => _driverRatings;
  List<RatingModel> get myRatings => _myRatings;
  bool get isLoading => _isLoading;
  String get error => _error;
  double get driverAverageRating => _driverAverageRating;
  int get driverTotalRatings => _driverTotalRatings;

  // Noter un conducteur
  Future<bool> rateDriver({
    required int bookingId,
    required int rideId,
    required int driverId,
    required int rating,
    String? comment,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _ratingService.rateDriver(
        bookingId: bookingId,
        rideId: rideId,
        driverId: driverId,
        rating: rating,
        comment: comment,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Charger les notes d'un conducteur
  Future<void> loadDriverRatings(int driverId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _ratingService.getDriverRatings(driverId);

      if (response['success'] == true || response['ratings'] != null) {
        _driverRatings = _ratingService.extractRatingsFromResponse(response);
        _driverAverageRating =
            (response['average_rating'] as num?)?.toDouble() ?? 0.0;
        _driverTotalRatings = response['total_ratings'] ?? _driverRatings.length;
      } else {
        _driverRatings = [];
        _driverAverageRating = 0.0;
        _driverTotalRatings = 0;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger mes notes données
  Future<void> loadMyRatings() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _ratingService.getMyRatings();

      if (response['success'] == true || response['ratings'] != null) {
        _myRatings = _ratingService.extractRatingsFromResponse(response);
      } else {
        _myRatings = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Vérifier si peut noter
  Future<bool> canRate(int bookingId) async {
    try {
      final response = await _ratingService.canRate(bookingId);
      return response['can_rate'] ?? false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Réinitialiser les erreurs
  void clearError() {
    _error = '';
    notifyListeners();
  }
}
