import 'package:moovapp/core/api/api_service.dart';

class ChatService {
  final ApiService _apiService;

  ChatService(this._apiService);

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
