import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/message_model.dart';
import '../../services/auth_notifier.dart';
import '../../services/mock_chat_service.dart';
import 'chat_screen.dart';

/// List of all conversations for the current user.
class ChatListScreen extends StatefulWidget {
  final AuthNotifier? authNotifier;

  const ChatListScreen({super.key, this.authNotifier});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final MockChatService _chatService = MockChatService();
  List<ConversationModel> _conversations = [];
  bool _isLoading = true;

  String get _currentUserId =>
      widget.authNotifier?.currentUser?.uid ?? 'customer_demo_001';

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    final convs = await _chatService.getConversationsForUser(_currentUserId);
    if (mounted) {
      setState(() {
        _conversations = convs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 56, color: AppColors.textMuted),
                      SizedBox(height: 16),
                      Text('No conversations yet',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary)),
                      SizedBox(height: 6),
                      Text(
                        'Message a service provider to get started.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.separated(
                    padding: AppConstants.paddingScreen,
                    itemCount: _conversations.length,
                    separatorBuilder: (_, r) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final conv = _conversations[index];
                      final otherName = conv.otherPartyName(_currentUserId);
                      return _ConversationCard(
                        conversation: conv,
                        otherPartyName: otherName,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                conversationId: conv.id,
                                otherPartyName: otherName,
                                authNotifier: widget.authNotifier,
                              ),
                            ),
                          );
                          _loadConversations();
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final ConversationModel conversation;
  final String otherPartyName;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.conversation,
    required this.otherPartyName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceM),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withAlpha(20),
                child: Text(
                  otherPartyName.isNotEmpty
                      ? otherPartyName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(otherPartyName,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        if (conversation.lastMessageAt != null)
                          Text(
                            _formatTime(conversation.lastMessageAt!),
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textMuted),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conversation.lastMessage ?? 'No messages yet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                    if (conversation.requestId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.link_rounded,
                                size: 12, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text('Request #${conversation.requestId}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.primary)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
