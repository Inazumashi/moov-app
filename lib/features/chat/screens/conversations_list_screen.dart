import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/chat_provider.dart';
import 'package:moovapp/features/chat/screens/chat_screen.dart';

class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({super.key});

  @override
  State<ConversationsListScreen> createState() => _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        actions: [
          if (chatProvider.unreadCount > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${chatProvider.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => chatProvider.loadConversations(),
          ),
        ],
      ),
      body: chatProvider.isLoading && chatProvider.conversations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : chatProvider.conversations.isEmpty
              ? _buildEmptyState(colors)
              : RefreshIndicator(
                  onRefresh: () => chatProvider.loadConversations(),
                  child: ListView.builder(
                    itemCount: chatProvider.conversations.length,
                    itemBuilder: (context, index) {
                      final conv = chatProvider.conversations[index];
                      return _buildConversationTile(conv, colors);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: colors.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Aucune conversation',
            style: TextStyle(fontSize: 18, color: colors.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 8),
          Text(
            'Réservez un trajet pour contacter le conducteur',
            style: TextStyle(color: colors.onSurface.withOpacity(0.4)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conv, ColorScheme colors) {
    final unreadCount = conv['unread_count'] ?? 0;
    final hasUnread = unreadCount > 0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colors.primaryContainer,
        child: Text(
          (conv['other_user_name'] as String? ?? 'U').substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: colors.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conv['other_user_name'] ?? 'Utilisateur',
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (hasUnread)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$unreadCount',
                style: TextStyle(
                  color: colors.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${conv['departure_station'] ?? 'Départ'} → ${conv['arrival_station'] ?? 'Arrivée'}',
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (conv['last_message'] != null)
            Text(
              conv['last_message'],
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: conv['last_message_at'] != null
          ? Text(
              _formatTime(DateTime.parse(conv['last_message_at'].toString())),
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface.withOpacity(0.6),
              ),
            )
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conv['id'],
              otherUserName: conv['other_user_name'] ?? 'Utilisateur',
              rideInfo: '${conv['departure_station'] ?? 'Départ'} → ${conv['arrival_station'] ?? 'Arrivée'}',
            ),
          ),
        ).then((_) {
          Provider.of<ChatProvider>(context, listen: false).loadConversations();
        });
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}j';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
