// lib/core/service/chat_service.dart
import 'dart:async';
import 'package:moovapp/core/api/api_service.dart';

class ChatService {
  final ApiService _apiService;
  Timer? _pollingTimer;
  StreamController<List<Map<String, dynamic>>>? _messageStream;
  Map<int, List<Map<String, dynamic>>> _cachedMessages = {};

  ChatService(this._apiService);

  // STREAM pour les nouveaux messages en temps réel
  Stream<List<Map<String, dynamic>>> getMessageStream(int conversationId) {
    _messageStream ??= StreamController<List<Map<String, dynamic>>>.broadcast();
    
    // Démarrer le polling si ce n'est pas déjà fait
    _startPolling(conversationId);
    
    return _messageStream!.stream;
  }

  void _startPolling(int conversationId) {
    // Arrêter le timer existant
    _pollingTimer?.cancel();
    
    // Démarrer un nouveau timer qui poll toutes les 5 secondes
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final messages = await getMessages(conversationId);
        
        // Vérifier s'il y a de nouveaux messages
        final cached = _cachedMessages[conversationId] ?? [];
        if (messages.length > cached.length) {
          _cachedMessages[conversationId] = messages;
          _messageStream?.add(messages);
        }
      } catch (e) {
        print('❌ Erreur polling messages: $e');
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // NOUVELLE MÉTHODE : Recevoir les nouveaux messages d'une conversation
  Future<List<Map<String, dynamic>>> getNewMessages(
    int conversationId, 
    DateTime lastMessageTime
  ) async {
    try {
      final response = await _apiService.get(
        'chat/conversations/$conversationId/new-messages?since=${lastMessageTime.toIso8601String()}',
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        final data = response['messages'] as List? ?? [];
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('Erreur réception nouveaux messages: $e');
      return [];
    }
  }

  // NOUVELLE MÉTHODE : Écouter les notifications push (idéal pour Firebase Cloud Messaging)
  void setupPushNotifications() {
    // TODO: Intégrer Firebase Cloud Messaging
    print('📱 Configuration notifications push pour le chat');
  }

  // NOUVELLE MÉTHODE : Marquer un message spécifique comme lu
  Future<bool> markMessageAsRead(int messageId) async {
    try {
      final response = await _apiService.put(
        'chat/messages/$messageId/read',
        {},
        isProtected: true,
      );

      return response is Map && response['success'] == true;
    } catch (e) {
      print('Erreur marquer message lu: $e');
      return false;
    }
  }

  // NOUVELLE MÉTHODE : Obtenir le nombre de messages non lus par conversation
  Future<Map<int, int>> getUnreadCountByConversation() async {
    try {
      final response = await _apiService.get(
        'chat/unread-by-conversation',
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        final data = response['unread_counts'] as Map<String, dynamic>? ?? {};
        
        // Convertir les clés String en int
        final result = <int, int>{};
        data.forEach((key, value) {
          final convId = int.tryParse(key);
          if (convId != null) {
            result[convId] = value as int? ?? 0;
          }
        });
        
        return result;
      }
      return {};
    } catch (e) {
      print('Erreur comptage non lus par conversation: $e');
      return {};
    }
  }

  // MÉTHODES EXISTANTES :

  // Obtenir toutes les conversations
  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final response = await _apiService.get(
        'chat/conversations',
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        final data = response['data'] as List? ?? [];
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('Erreur chargement conversations: $e');
      return [];
    }
  }

  // Créer ou récupérer une conversation pour un trajet
  Future<Map<String, dynamic>?> createOrGetConversation(int rideId) async {
    try {
      final response = await _apiService.post(
        'chat/conversations',
        {'ride_id': rideId},
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        return response['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Erreur création conversation: $e');
      return null;
    }
  }

  // Obtenir les messages d'une conversation
  Future<List<Map<String, dynamic>>> getMessages(int conversationId,
      {int page = 1, int limit = 50}) async {
    try {
      final response = await _apiService.get(
        'chat/messages/$conversationId?page=$page&limit=$limit',
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        final data = response['data'] as List? ?? [];
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('Erreur chargement messages: $e');
      return [];
    }
  }

  // Envoyer un message
  Future<bool> sendMessage(int conversationId, String message) async {
    try {
      final response = await _apiService.post(
        'chat/messages',
        {
          'conversation_id': conversationId,
          'message': message,
        },
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur envoi message: $e');
      return false;
    }
  }

  // Marquer messages comme lus
  Future<bool> markAsRead(int conversationId) async {
    try {
      final response = await _apiService.put(
        'chat/conversations/$conversationId/mark-read',
        {},
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur marquer comme lu: $e');
      return false;
    }
  }

  // Obtenir le nombre de messages non lus
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get(
        'chat/unread-count',
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        return response['unread_count'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      print('Erreur chargement unread count: $e');
      return 0;
    }
  }
}