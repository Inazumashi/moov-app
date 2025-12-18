// lib/features/chat/screens/chat_screen.dart - VERSION AVEC RÉPONSES
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/chat_provider.dart';
import 'package:moovapp/core/providers/auth_provider.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final String otherUserName;
  final String rideInfo;
  final int? replyToMessageId; // NOUVEAU : ID du message auquel on répond

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    required this.rideInfo,
    this.replyToMessageId, // NOUVEAU
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _refreshTimer;
  int? _replyToMessageId; // Message auquel on répond
  Map<String, dynamic>? _replyToMessage; // Détails du message de réponse

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startAutoRefresh();
    
    // Si on répond à un message spécifique
    if (widget.replyToMessageId != null) {
      _replyToMessageId = widget.replyToMessageId;
      _findReplyMessage();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _loadMessages() {
    Provider.of<ChatProvider>(context, listen: false)
        .loadMessages(widget.conversationId);
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        _loadMessages();
      }
    });
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    bool success;
    if (_replyToMessageId != null) {
      // Envoyer une réponse à un message spécifique
      success = await chatProvider.replyToMessage(
        widget.conversationId,
        message,
        _replyToMessageId,
      );
    } else {
      // Envoyer un message normal
      success = await chatProvider.sendMessage(
        widget.conversationId,
        message,
      );
    }

    if (success) {
      _messageController.clear();
      _cancelReply(); // Annuler la réponse après envoi
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _findReplyMessage() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final message = chatProvider.currentMessages.firstWhere(
      (msg) => msg['id'] == _replyToMessageId,
      orElse: () => {},
    );
    
    if (message.isNotEmpty) {
      setState(() {
        _replyToMessage = message;
      });
    }
  }

  void _setReplyToMessage(Map<String, dynamic> message) {
    setState(() {
      _replyToMessageId = message['id'] as int?;
      _replyToMessage = message;
    });
    
    // Focus sur le champ de texte
    FocusScope.of(context).requestFocus(FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _cancelReply() {
    setState(() {
      _replyToMessageId = null;
      _replyToMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUserName,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              widget.rideInfo,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showChatOptions(context, chatProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // BARRE DE RÉPONSE (si on répond à un message)
          if (_replyToMessage != null) _buildReplyBar(colors),
          
          Expanded(
            child: chatProvider.isLoading && chatProvider.currentMessages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : chatProvider.currentMessages.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun message. Dites bonjour ! 👋',
                          style: TextStyle(
                            color: colors.onSurface.withOpacity(0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: chatProvider.currentMessages.length,
                        itemBuilder: (context, index) {
                          final message = chatProvider.currentMessages[index];
                          return _buildMessageBubble(
                            message, 
                            colors, 
                            chatProvider,
                            onReply: _setReplyToMessage,
                          );
                        },
                      ),
          ),

          // CHAMP DE SAISIE AVEC RÉPONSE
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Indicateur de réponse
                if (_replyToMessage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.reply, size: 16, color: colors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Réponse à: ${_replyToMessage?['message'] ?? ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurface.withOpacity(0.7),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 16),
                          onPressed: _cancelReply,
                        ),
                      ],
                    ),
                  ),
                
                Row(
                  children: [
                    // Bouton pour sélectionner un message à citer
                    IconButton(
                      icon: Icon(Icons.reply, color: colors.primary),
                      onPressed: () {
                        // TODO: Implémenter sélection de message
                      },
                    ),
                    
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: _replyToMessage != null 
                              ? 'Votre réponse...' 
                              : 'Écrivez un message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    CircleAvatar(
                      backgroundColor: colors.primary,
                      child: IconButton(
                        icon: Icon(Icons.send, color: colors.onPrimary),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBar(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: colors.primary.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.reply, size: 16, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vous répondez à ${_replyToMessage?['sender_name'] ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                Text(
                  _replyToMessage?['message'] ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurface.withOpacity(0.7),
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 16),
            onPressed: _cancelReply,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> message,
    ColorScheme colors,
    ChatProvider provider, {
    required Function(Map<String, dynamic>) onReply,
  }) {
    // 1. Utiliser AuthProvider pour une identification fiable
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid;
    
    // Comparaison améliorée : convertir les deux en string pour éviter erreurs de type
    final isMe = message['sender_id'].toString() == currentUserId.toString();
    
    final isReply = message['reply_to_message_id'] != null;
    final repliedMessage = isReply ? _findRepliedMessage(provider, message) : null;
    final isRead = message['is_read'] == true;

    return GestureDetector(
      onLongPress: () => _showMessageOptions(context, message, provider, isMe),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // MESSAGE CITÉ (si c'est une réponse)
              if (isReply && repliedMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.outline.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.reply, size: 12, color: colors.primary),
                          const SizedBox(width: 4),
                          Text(
                            repliedMessage['sender_name']?.toString() ?? '',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        repliedMessage['message']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              
              // BULLE DE MESSAGE PRINCIPALE
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? colors.primary : colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomRight: isMe ? const Radius.circular(0) : null,
                    bottomLeft: !isMe ? const Radius.circular(0) : null,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['message'].toString(),
                      style: TextStyle(
                        color: isMe ? colors.onPrimary : colors.onSurfaceVariant,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _formatMessageTime(DateTime.parse(message['created_at'].toString())),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe
                                ? colors.onPrimary.withOpacity(0.7)
                                : colors.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message['is_sent'] == false 
                                ? Icons.access_time 
                                : Icons.done_all,
                            size: 14,
                            color: message['is_sent'] == false
                                ? colors.onPrimary.withOpacity(0.7)
                                : (isRead ? Colors.lightBlueAccent : colors.onPrimary.withOpacity(0.7)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // BOUTONS D'ACTION (apparaissent au survol, optionnel)
              // Note: Le long-press est souvent mieux sur mobile
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic>? _findRepliedMessage(ChatProvider provider, Map<String, dynamic> message) {
    final replyId = message['reply_to_message_id'];
    if (replyId == null) return null;
    
    return provider.currentMessages.firstWhere(
      (msg) => msg['id'] == replyId,
      orElse: () => {},
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showChatOptions(BuildContext context, ChatProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Supprimer la conversation'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConversationDialog(context, provider);
            },
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Bloquer l\'utilisateur'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implémenter blocage
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Signaler'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implémenter signalement
            },
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(BuildContext context, Map<String, dynamic> message, ChatProvider provider, bool isMe) {

    
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Répondre'),
            onTap: () {
              Navigator.pop(context);
              _setReplyToMessage(message);
            },
          ),
          if (isMe)
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Supprimer le message'),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(message['id'], provider);
              },
            ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copier'),
            onTap: () {
              Navigator.pop(context);
              // Copier le texte
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Signaler le message'),
            onTap: () {
              Navigator.pop(context);
              // Signaler
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMessage(int messageId, ChatProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le message'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce message ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteMessage(messageId);
    }
  }

  Future<void> _showDeleteConversationDialog(BuildContext context, ChatProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la conversation'),
        content: const Text('Tous les messages seront supprimés définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implémenter suppression de conversation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversation supprimée')),
      );
    }
  }
}