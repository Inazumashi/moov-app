// 🧪 TESTING GUIDE - Flux complets à tester
// À exécuter après que le backend soit déployé

import 'package:moovapp/core/providers/ride_provider.dart';
import 'package:moovapp/core/providers/chat_provider.dart';
import 'package:moovapp/core/providers/reservation_provider.dart';
import 'package:moovapp/core/providers/auth_provider.dart';

// ============================================
// TEST 1: SUGGESTIONS
// ============================================
Future<void> testSuggestions(RideProvider rideProvider) async {
  print('🧪 TEST 1: Suggestions');
  
  try {
    // Load suggestions
    await rideProvider.loadSuggestions();
    
    if (rideProvider.suggestions.isEmpty) {
      print('❌ Aucune suggestion chargée');
      return;
    }
    
    print('✅ ${rideProvider.suggestions.length} suggestions chargées');
    
    final firstRide = rideProvider.suggestions.first;
    print('   - Premier trajet: ${firstRide.startPoint} → ${firstRide.endPoint}');
    print('   - Prix: ${firstRide.pricePerSeat}€');
    print('   - Conducteur: ${firstRide.driverName}');
    
  } catch (e) {
    print('❌ Erreur suggestions: $e');
  }
}

// ============================================
// TEST 2: RECHERCHE AVANCÉE
// ============================================
Future<void> testAdvancedSearch(RideProvider rideProvider) async {
  print('\n🧪 TEST 2: Recherche Avancée');
  
  try {
    // Simulation: Paris (ID: 1) → Lyon (ID: 2)
    final departureId = 1;
    final arrivalId = 2;
    final date = DateTime(2025, 1, 15);
    
    await rideProvider.searchRides(
      departureId: departureId,
      arrivalId: arrivalId,
      date: date,
      minPrice: 0,
      maxPrice: 100,
      minRating: 3.5,
      verifiedOnly: false,
    );
    
    if (rideProvider.searchResults.isEmpty) {
      print('❌ Aucun résultat de recherche');
      return;
    }
    
    print('✅ ${rideProvider.searchResults.length} résultats trouvés');
    print('   Filtres appliqués: ${rideProvider.appliedFilters}');
    
    rideProvider.searchResults.forEach((ride) {
      print('   - ${ride.startPoint} → ${ride.endPoint}: ${ride.pricePerSeat}€');
    });
    
  } catch (e) {
    print('❌ Erreur recherche avancée: $e');
  }
}

// ============================================
// TEST 3: FAVORIS
// ============================================
Future<void> testFavorites(RideProvider rideProvider) async {
  print('\n🧪 TEST 3: Favoris');
  
  try {
    if (rideProvider.searchResults.isEmpty) {
      print('❌ Aucun résultat de recherche (run test 2 first)');
      return;
    }
    
    final rideId = rideProvider.searchResults.first.rideId;
    
    // Test: ajouter aux favoris
    print('   Ajout aux favoris: $rideId');
    await rideProvider.addToFavorites(rideId);
    
    if (rideProvider.isFavorite(rideId)) {
      print('✅ Trajet ajouté aux favoris');
    }
    
    // Test: charger favoris
    await rideProvider.loadFavoriteRides();
    print('✅ ${rideProvider.favoriteRides.length} favoris chargés');
    
    // Test: retirer des favoris
    await rideProvider.removeFromFavorites(rideId);
    if (!rideProvider.isFavorite(rideId)) {
      print('✅ Trajet retiré des favoris');
    }
    
  } catch (e) {
    print('❌ Erreur favoris: $e');
  }
}

// ============================================
// TEST 4: RÉSERVATION
// ============================================
Future<void> testReservation(
  RideProvider rideProvider,
  ReservationProvider reservationProvider,
) async {
  print('\n🧪 TEST 4: Réservation');
  
  try {
    if (rideProvider.searchResults.isEmpty) {
      print('❌ Aucun résultat de recherche (run test 2 first)');
      return;
    }
    
    final ride = rideProvider.searchResults.first;
    final rideId = ride.rideId;
    final numberOfSeats = 1;
    final totalPrice = (ride.pricePerSeat) * numberOfSeats;
    
    print('   Création réservation:');
    print('   - Trajet: $rideId');
    print('   - Places: $numberOfSeats');
    print('   - Total: ${totalPrice}€');
    
    final success = await reservationProvider.createReservation(
      rideId: int.parse(rideId),
      seats: numberOfSeats,
    );
    
    if (success) {
      print('✅ Réservation créée avec succès');
      
      // Load user reservations
      await reservationProvider.loadReservations();
      print('   ${reservationProvider.reservations.length} réservations chargées');
    } else {
      print('❌ Erreur création réservation');
    }
    
  } catch (e) {
    print('❌ Erreur réservation: $e');
  }
}

// ============================================
// TEST 5: CHAT
// ============================================
Future<void> testChat(
  ChatProvider chatProvider,
  RideProvider rideProvider,
) async {
  print('\n🧪 TEST 5: Chat');
  
  try {
    if (rideProvider.searchResults.isEmpty) {
      print('❌ Aucun résultat de recherche (run test 2 first)');
      return;
    }
    
    final rideId = int.parse(rideProvider.searchResults.first.rideId);
    
    // Créer/obtenir conversation
    final conversationId = await chatProvider.getOrCreateConversation(rideId);
    
    if (conversationId == null) {
      print('❌ Erreur création conversation');
      return;
    }
    
    print('✅ Conversation créée/obtenue: $conversationId');
    
    // Charger messages
    await chatProvider.loadMessages(conversationId);
    print('   ${chatProvider.currentMessages.length} messages chargés');
    
    // Envoyer un message
    print('   Envoi message test...');
    final success = await chatProvider.sendMessage(
      conversationId,
      'Bonjour! Je suis intéressé par ce trajet.',
    );
    
    if (success) {
      print('✅ Message envoyé avec succès');
      print('   ${chatProvider.currentMessages.length} messages après envoi');
    } else {
      print('❌ Erreur envoi message');
    }
    
    // Charger conversations
    await chatProvider.loadConversations();
    print('✅ ${chatProvider.conversations.length} conversations chargées');
    print('   Unread count: ${chatProvider.unreadCount}');
    
  } catch (e) {
    print('❌ Erreur chat: $e');
  }
}

// ============================================
// TEST 6: MARQUAGE COMME TERMINÉ & RATING
// ============================================
Future<void> testCompletionAndRating(
  ReservationProvider reservationProvider,
) async {
  print('\n🧪 TEST 6: Marquage Terminé + Rating');
  
  try {
    // Load user reservations
    await reservationProvider.loadReservations();
    
    if (reservationProvider.reservations.isEmpty) {
      print('❌ Aucune réservation (run test 4 first)');
      return;
    }
    
    final reservation = reservationProvider.reservations.first;
    final reservationId = reservation.id;
    
    print('   Marquage réservation $reservationId comme terminée...');
    
    final success = await reservationProvider.markCompleted(reservationId);
    
    if (success) {
      print('✅ Réservation marquée comme terminée');
      print('   Status: ${reservation.status}');
    } else {
      print('❌ Erreur marquage terminé');
    }
    
  } catch (e) {
    print('❌ Erreur marquage/rating: $e');
  }
}

// ============================================
// TEST 7: STATISTIQUES
// ============================================
Future<void> testStatistics() async {
  print('\n🧪 TEST 7: Statistiques');
  
  try {
    // Load dashboard
    print('✅ Test statistiques (exemple - intégrer StatsProvider se disponible)');
    
  } catch (e) {
    print('❌ Erreur statistiques: $e');
  }
}

// ============================================
// MAIN TEST RUNNER
// ============================================
Future<void> runAllTests(
  RideProvider rideProvider,
  ChatProvider chatProvider,
  ReservationProvider reservationProvider,
) async {
  print('🚀 DÉMARRAGE DES TESTS COMPLETS\n');
  print('================================================');
  
  try {
    // Test 1: Suggestions
    await testSuggestions(rideProvider);
    
    // Test 2: Recherche avancée
    await testAdvancedSearch(rideProvider);
    
    // Test 3: Favoris
    await testFavorites(rideProvider);
    
    // Test 4: Réservation
    await testReservation(rideProvider, reservationProvider);
    
    // Test 5: Chat
    await testChat(chatProvider, rideProvider);
    
    // Test 6: Marquage terminé
    await testCompletionAndRating(reservationProvider);
    
    // Test 7: Statistiques
    await testStatistics();
    
    print('\n================================================');
    print('✅ TOUS LES TESTS COMPLÉTÉS\n');
    
  } catch (e) {
    print('\n❌ ERREUR CRITIQUE: $e');
  }
}

// ============================================
// COMMENT LANCER LES TESTS
// ============================================
/*
// Dans une page de test ou debug:

import 'package:provider/provider.dart';

void _runTests(BuildContext context) {
  final rideProvider = Provider.of<RideProvider>(context, listen: false);
  final chatProvider = Provider.of<ChatProvider>(context, listen: false);
  final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
  final statsProvider = Provider.of<StatsProvider>(context, listen: false);
  
  runAllTests(
    rideProvider,
    chatProvider,
    reservationProvider,
    statsProvider,
  );
}

// Dans build():
ElevatedButton(
  onPressed: () => _runTests(context),
  child: const Text('Run Tests'),
),
*/
