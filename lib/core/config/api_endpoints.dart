// lib/core/config/api_endpoints.dart
// Centralisé endpoints et constantes API

class ApiEndpoints {
  // Base URL - à configurer selon l'environnement
  static const String baseUrl = 'http://localhost:3000/api';
  static const String productionUrl = 'https://moovapp.com/api';

  // ============================================
  // 🔍 SEARCH & RIDES
  // ============================================
  static const String searchRides = '/search/rides';
  static const String searchSuggestions = '/search/rides/suggestions';
  static const String rideDetails = '/rides';
  static const String publishRide = '/rides';
  static const String myRides = '/rides/my-rides';
  static const String deleteRide = '/rides/:id';
  static const String updateRide = '/rides/:id';

  // ============================================
  // 💖 FAVORITES
  // ============================================
  static const String favoritesBase = '/advanced/favorite-rides';
  static const String addFavorite = '$favoritesBase';
  static const String removeFavorite = '$favoritesBase/:id';
  static const String getFavorites = '$favoritesBase';

  // ============================================
  // 📅 RESERVATIONS
  // ============================================
  static const String reservationsBase = '/reservations';
  static const String createReservation = '$reservationsBase';
  static const String myReservations = '$reservationsBase/my-reservations';
  static const String getReservationsForRide = '$reservationsBase/for-ride/:id';
  static const String completeReservation = '$reservationsBase/:id/complete';
  static const String cancelReservation = '$reservationsBase/:id/cancel';
  static const String confirmReservation = '$reservationsBase/:id/confirm';

  // ============================================
  // ⭐ RATINGS
  // ============================================
  static const String ratingsBase = '/ratings';
  static const String rateDriver = '$ratingsBase';
  static const String getDriverRatings = '$ratingsBase/driver/:id';
  static const String getMyRatings = '$ratingsBase/my-ratings';

  // ============================================
  // 💬 CHAT
  // ============================================
  static const String chatBase = '/chat';
  static const String conversations = '$chatBase/conversations';
  static const String createConversation = '$chatBase/conversations';
  static const String messages = '$chatBase/messages';
  static const String sendMessage = '$chatBase/messages';
  static const String markConversationRead = '$chatBase/conversations/:id/mark-read';
  static const String unreadCount = '$chatBase/unread-count';

  // ============================================
  // 📊 STATISTICS
  // ============================================
  static const String statsBase = '/stats';
  static const String dashboard = '$statsBase/dashboard';
  static const String monthlyStats = '$statsBase/monthly';
  static const String topRoutes = '$statsBase/top-routes';
  static const String recentActivity = '$statsBase/recent-activity';

  // ============================================
  // 👤 AUTHENTICATION
  // ============================================
  static const String authBase = '/auth';
  static const String login = '$authBase/login';
  static const String register = '$authBase/register';
  static const String logout = '$authBase/logout';
  static const String refreshToken = '$authBase/refresh-token';
  static const String me = '$authBase/me';
  static const String universities = '$authBase/universities';

  // ============================================
  // 🚩 STATIONS
  // ============================================
  static const String stationsBase = '/stations';
  static const String listStations = '$stationsBase';
  static const String stationAutocomplete = '$stationsBase/autocomplete';
  static const String stationById = '$stationsBase/:id';
}

// ============================================
// Query parameter helpers
// ============================================
class QueryParams {
  // Search params
  static const String departureStationId = 'departure_station_id';
  static const String arrivalStationId = 'arrival_station_id';
  static const String departureDate = 'departure_date';
  static const String minPrice = 'min_price';
  static const String maxPrice = 'max_price';
  static const String minRating = 'min_rating';
  static const String maxRating = 'max_rating';
  static const String verifiedOnly = 'verified_only';
  static const String departureTimeStart = 'departure_time_start';
  static const String departureTimeEnd = 'departure_time_end';
  static const String page = 'page';
  static const String limit = 'limit';

  // Chat params
  static const String conversationId = 'conversation_id';
  static const String rideId = 'ride_id';

  // Stats params
  static const String year = 'year';
}

// ============================================
// Response status codes
// ============================================
class ApiStatusCode {
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int serverError = 500;
}

// ============================================
// Error messages
// ============================================
class ApiErrorMessage {
  static const String networkError = 'Erreur réseau. Vérifiez votre connexion.';
  static const String serverError = 'Erreur serveur. Réessayez plus tard.';
  static const String unauthorized = 'Authentification requise. Veuillez vous connecter.';
  static const String forbidden = 'Vous n\'avez pas la permission d\'accéder à cette ressource.';
  static const String notFound = 'Ressource non trouvée.';
  static const String timeout = 'Délai d\'attente dépassé. Réessayez.';
  static const String invalidData = 'Données invalides. Vérifiez vos entrées.';
  static const String noInternet = 'Pas de connexion internet.';
}

// ============================================
// Pagination defaults
// ============================================
class PaginationDefaults {
  static const int defaultPage = 1;
  static const int defaultLimit = 20;
  static const int maxLimit = 100;
}

// ============================================
// Timeouts
// ============================================
class TimeoutDuration {
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration chatRefreshInterval = Duration(seconds: 3);
  static const Duration tokenRefreshBuffer = Duration(minutes: 5);
}

// ============================================
// Headers
// ============================================
class ApiHeaders {
  static const String contentType = 'Content-Type';
  static const String contentTypeJson = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer ';
  static const String userAgent = 'User-Agent';
  static const String accept = 'Accept';
}
