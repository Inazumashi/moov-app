// lib/core/providers/chat_provider.dart - VERSION AMÉLIORÉE ET CORRIGÉE
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moovapp/core/service/chat_service.dart';
import 'package:moovapp/core/api/api_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService;
  final ApiService _apiService;

  String? _currentUserId;
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _currentMessages = [];
  bool _isLoading = false;
  String _error = '';
  int _unreadCount = 0;
  bool _disposed = false;
  int? _currentConversationId;
  DateTime? _lastMessageTime;
  Timer? _conversationsTimer;
  Map<int, Timer> _messageTimers = {};

  ChatProvider()
      : _chatService = ChatService(ApiService()),
        _apiService = ApiService();

  List<Map<String, dynamic>> get conversations => _conversations;
  List<Map<String, dynamic>> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get unreadCount => _unreadCount;
  String? get currentUserId => _currentUserId;
  int? get currentConversationId => _currentConversationId;

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _stopAllPolling();
    super.dispose();
  }

  void _stopAllPolling() {
    _chatService.stopPolling();
    _conversationsTimer?.cancel();
    _messageTimers.forEach((_, timer) => timer.cancel());
    _messageTimers.clear();
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    _chatService.setupPushNotifications();
    _safeNotifyListeners();
  }

  // CHARGER LES CONVERSATIONS AVEC MISE À JOUR AUTO
  Future<void> loadConversations() async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      _conversations = await _chatService.getConversations();
      _unreadCount = await _chatService.getUnreadCount();
      _isLoading = false;
      _safeNotifyListeners();

      _startConversationsPolling();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  void _startConversationsPolling() {
    _conversationsTimer?.cancel();

    _conversationsTimer =
        Timer.periodic(const Duration(seconds: 30), (_) async {
      if (_disposed) return;

      try {
        final newConversations = await _chatService.getConversations();
        final newUnreadCount = await _chatService.getUnreadCount();

        if (_hasConversationsChanged(newConversations) ||
            newUnreadCount != _unreadCount) {
          _conversations = newConversations;
          _unreadCount = newUnreadCount;
          _safeNotifyListeners();
        }
      } catch (e) {
        print('❌ Erreur polling conversations: $e');
      }
    });
  }

  bool _hasConversationsChanged(List<Map<String, dynamic>> newConversations) {
    if (newConversations.length != _conversations.length) return true;

    for (int i = 0; i < newConversations.length; i++) {
      final oldConv = _conversations[i];
      final newConv = newConversations[i];

      if (oldConv['last_message'] != newConv['last_message'] ||
          oldConv['unread_count'] != newConv['unread_count'] ||
          oldConv['updated_at'] != newConv['updated_at']) {
        return true;
      }
    }

    return false;
  }

  // CHARGER LES MESSAGES AVEC RÉCEPTION EN TEMPS RÉEL
  Future<void> loadMessages(int conversationId) async {
    _isLoading = true;
    _error = '';
    _currentConversationId = conversationId;
    _safeNotifyListeners();

    try {
      _currentMessages = await _chatService.getMessages(conversationId);

      if (_currentMessages.isNotEmpty) {
        final lastMsg = _currentMessages.last;
        _lastMessageTime = DateTime.parse(lastMsg['created_at'].toString());
      }

      await _chatService.markAsRead(conversationId);

      _isLoading = false;
      _safeNotifyListeners();

      _startMessagePolling(conversationId);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  void _startMessagePolling(int conversationId) {
    _stopMessagePolling(conversationId);

    final timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_disposed || _currentConversationId != conversationId) return;

      try {
        // Méthode 1: Via getNewMessages
        if (_lastMessageTime != null) {
          final newMessages = await _chatService.getNewMessages(
              conversationId, _lastMessageTime!);

          if (newMessages.isNotEmpty) {
            _addNewMessages(newMessages);
          }
        }

        // Méthode 2: Vérifier aussi via le compteur de non-lus
        final unreadByConv = await _chatService.getUnreadCountByConversation();
        final convUnreadCount = unreadByConv[conversationId] ?? 0;

        if (convUnreadCount > 0 && _currentMessages.isNotEmpty) {
          // Recharger tous les messages pour être sûr
          final allMessages = await _chatService.getMessages(conversationId);
          if (allMessages.length > _currentMessages.length) {
            _currentMessages = allMessages;
            if (allMessages.isNotEmpty) {
              final lastMsg = allMessages.last;
              _lastMessageTime =
                  DateTime.parse(lastMsg['created_at'].toString());
            }
            _safeNotifyListeners();
          }
        }
      } catch (e) {
        print('❌ Erreur polling nouveaux messages: $e');
      }
    });

    _messageTimers[conversationId] = timer;
  }

  void _stopMessagePolling(int conversationId) {
    _messageTimers[conversationId]?.cancel();
    _messageTimers.remove(conversationId);
  }

  void _addNewMessages(List<Map<String, dynamic>> newMessages) {
    // Filtrer les doublons
    final existingIds = _currentMessages.map((msg) => msg['id']).toSet();
    final uniqueNewMessages =
        newMessages.where((msg) => !existingIds.contains(msg['id'])).toList();

    if (uniqueNewMessages.isNotEmpty) {
      _currentMessages.addAll(uniqueNewMessages);

      final lastNewMsg = uniqueNewMessages.last;
      _lastMessageTime = DateTime.parse(lastNewMsg['created_at'].toString());

      // Marquer comme lus si ce ne sont pas mes messages
      for (final msg in uniqueNewMessages) {
        if (msg['sender_id'].toString() != _currentUserId) {
          _chatService.markMessageAsRead(msg['id'] as int);
        }
      }

      _safeNotifyListeners();

      // Mettre à jour la liste des conversations
      _updateConversationsAfterNewMessage();
    }
  }

  void _updateConversationsAfterNewMessage() async {
    try {
      final newConversations = await _chatService.getConversations();
      if (_hasConversationsChanged(newConversations)) {
        _conversations = newConversations;
        _unreadCount = await _chatService.getUnreadCount();
        _safeNotifyListeners();
      }
    } catch (e) {
      print('❌ Erreur mise à jour conversations: $e');
    }
  }

  // ENVOYER UN MESSAGE ET GÉRER LA RÉPONSE
  Future<bool> sendMessage(int conversationId, String message) async {
    try {
      // Optimistic update
      final tempMessage = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'conversation_id': conversationId,
        'sender_id': _currentUserId,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
        'is_sent': false,
        'is_temp': true,
      };

      _currentMessages.add(tempMessage);
      _lastMessageTime = DateTime.now();
      _safeNotifyListeners();

      // Envoyer au serveur
      final success = await _chatService.sendMessage(conversationId, message);

      if (success) {
        // Retirer le message temporaire et recharger les vrais messages
        _currentMessages.removeWhere((msg) => msg['is_temp'] == true);
        await loadMessages(conversationId);
        return true;
      } else {
        // Marquer le message comme échoué
        final failedIndex =
            _currentMessages.indexWhere((msg) => msg['is_temp'] == true);
        if (failedIndex != -1) {
          _currentMessages[failedIndex]['is_sent'] = false;
          _currentMessages[failedIndex]['send_error'] = true;
          _safeNotifyListeners();
        }
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _safeNotifyListeners();
      return false;
    }
  }

  // NOUVELLE MÉTHODE : Répondre à un message spécifique
  Future<bool> replyToMessage(
      int conversationId, String message, int? replyToMessageId) async {
    try {
      final response = await _apiService.post(
        'chat/messages/reply',
        {
          'conversation_id': conversationId,
          'message': message,
          'reply_to_message_id': replyToMessageId,
        },
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        await loadMessages(conversationId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      _safeNotifyListeners();
      return false;
    }
  }

  // CRÉER OU OBTENIR UNE CONVERSATION
  Future<int?> getOrCreateConversation(int rideId,
      {String? otherUserId}) async {
    try {
      final conversation = await _chatService.createOrGetConversation(rideId,
          otherUserId: otherUserId);

      if (conversation != null) {
        return conversation['id'] as int?;
      }
      return null;
    } catch (e) {
      _error = e.toString();
      _safeNotifyListeners();
      return null;
    }
  }

  // NOUVELLE MÉTHODE : Obtenir le statut de lecture d'un message
  Future<Map<String, dynamic>> getMessageStatus(int messageId) async {
    try {
      final response = await _apiService.get(
        'chat/messages/$messageId/status',
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        return response['status'] as Map<String, dynamic>? ?? {};
      }
      return {};
    } catch (e) {
      print('Erreur statut message: $e');
      return {};
    }
  }

  // NOUVELLE MÉTHODE : Supprimer un message
  Future<bool> deleteMessage(int messageId) async {
    try {
      final response = await _apiService.delete(
        'chat/messages/$messageId',
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        if (_currentConversationId != null) {
          await loadMessages(_currentConversationId!);
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      _safeNotifyListeners();
      return false;
    }
  }

  // NOUVELLE MÉTHODE : Recharger uniquement les conversations (sans polluer)
  Future<void> refreshConversations() async {
    try {
      _conversations = await _chatService.getConversations();
      _unreadCount = await _chatService.getUnreadCount();
      _safeNotifyListeners();
    } catch (e) {
      print('❌ Erreur refresh conversations: $e');
    }
  }

  // NOUVELLE MÉTHODE : Rechercher dans les conversations
  Future<List<Map<String, dynamic>>> searchInConversation(
      int conversationId, String query) async {
    try {
      final response = await _apiService.get(
        'chat/conversations/$conversationId/search?q=$query',
        isProtected: true,
      );

      if (response is Map && response['success'] == true) {
        final data = response['messages'] as List? ?? [];
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('Erreur recherche messages: $e');
      return [];
    }
  }

  // EFFACER LES MESSAGES COURANTS
  void clearCurrentMessages() {
    if (_currentConversationId != null) {
      _stopMessagePolling(_currentConversationId!);
    }
    _currentMessages = [];
    _currentConversationId = null;
    _lastMessageTime = null;
    _safeNotifyListeners();
  }

  // NOUVELLE MÉTHODE : Récupérer une conversation par son ID
  Map<String, dynamic>? getConversationById(int conversationId) {
    try {
      return _conversations.firstWhere(
        (conv) => conv['id'] == conversationId,
        orElse: () => {},
      );
    } catch (e) {
      return null;
    }
  }

  // NOUVELLE MÉTHODE : Vérifier si un utilisateur est dans la conversation
  Future<bool> isUserInConversation(int conversationId, int userId) async {
    try {
      final conversation = getConversationById(conversationId);
      if (conversation != null && conversation['participants'] != null) {
        final participants = conversation['participants'] as List;
        return participants.any((p) => p['id'] == userId);
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
