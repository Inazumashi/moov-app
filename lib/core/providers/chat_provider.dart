import 'package:flutter/material.dart';
import 'package:moovapp/core/services/chat_service.dart';
import 'package:moovapp/core/api/api_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService;
  
  String? _currentUserId;
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _currentMessages = [];
  bool _isLoading = false;
  String _error = '';
  int _unreadCount = 0;
  bool _disposed = false;

  ChatProvider() : _chatService = ChatService(ApiService());

  List<Map<String, dynamic>> get conversations => _conversations;
  List<Map<String, dynamic>> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get unreadCount => _unreadCount;
  String? get currentUserId => _currentUserId;

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  Future<void> loadConversations() async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      _conversations = await _chatService.getConversations();
      _unreadCount = await _chatService.getUnreadCount();
      _isLoading = false;
      _safeNotifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> loadMessages(int conversationId) async {
    _isLoading = true;
    _error = '';
    _safeNotifyListeners();

    try {
      _currentMessages = await _chatService.getMessages(conversationId);
      
      // Marquer comme lu
      await _chatService.markAsRead(conversationId);
      
      _isLoading = false;
      _safeNotifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<bool> sendMessage(int conversationId, String message) async {
    try {
      final success = await _chatService.sendMessage(conversationId, message);
      if (success) {
        // Recharger les messages après envoi
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

  // Créer ou obtenir une conversation pour un trajet
  Future<int?> getOrCreateConversation(int rideId) async {
    try {
      final conversation = await _chatService.createOrGetConversation(rideId);
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

  // Rafraîchir les conversations
  Future<void> refreshConversations() async {
    await loadConversations();
  }
}
