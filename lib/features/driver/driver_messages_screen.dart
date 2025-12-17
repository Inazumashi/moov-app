// lib/features/driver/screens/driver_messages_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/chat_provider.dart';
import 'package:moovapp/features/chat/screens/chat_screen.dart';

class DriverMessagesScreen extends StatefulWidget {
  const DriverMessagesScreen({Key? key}) : super(key: key);

  @override
  State<DriverMessagesScreen> createState() => _DriverMessagesScreenState();
}

class _DriverMessagesScreenState extends State<DriverMessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: const Text('Mes Messages'),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount > 0) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${provider.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false)
                  .loadConversations();
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.conversations.isEmpty) {
            return _buildEmptyState(colors);
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadConversations(),
            child: ListView.builder(
              itemCount: provider.conversations.length,
              itemBuilder: (context, index) {
                final conversation = provider.conversations[index];
                return _buildConversationTile(context, conversation, colors);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: colors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune conversation',
            style: TextStyle(
              fontSize: 18,
              color: colors.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les passagers qui réservent vos trajets\npourront vous contacter ici',
            style: TextStyle(
              color: colors.onSurface.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    Map<String, dynamic> conversation,
    ColorScheme colors,
  ) {
    final unreadCount = conversation['unread_count'] ?? 0;
    final hasUnread = unreadCount > 0;
    final otherUserName = conversation['other_user_name'] ?? 'Passager';
    final departureStation = conversation['departure_station'] ?? 'Départ';
    final arrivalStation = conversation['arrival_station'] ?? 'Arrivée';
    final lastMessage = conversation['last_message'];
    final lastMessageAt = conversation['last_message_at'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: colors.primaryContainer,
              child: Text(
                otherUserName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (hasUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                otherUserName,
                style: TextStyle(
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$departureStation → $arrivalStation',
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (lastMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  lastMessage.toString(),
                  style: TextStyle(
                    fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: lastMessageAt != null
            ? Text(
                _formatTime(DateTime.parse(lastMessageAt.toString())),
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
                conversationId: conversation['id'],
                otherUserName: otherUserName,
                rideInfo: '$departureStation → $arrivalStation',
              ),
            ),
          ).then((_) {
            // Recharger après retour du chat
            Provider.of<ChatProvider>(context, listen: false)
                .loadConversations();
          });
        },
      ),
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