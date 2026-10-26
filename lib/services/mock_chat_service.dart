import '../models/message_model.dart';

/// Mock in-app chat service for KaamHub.
/// Only conversation participants can access messages (enforced by service).
class MockChatService {
  static final MockChatService _instance = MockChatService._internal();
  factory MockChatService() => _instance;
  MockChatService._internal() {
    _seedData();
  }

  final List<ConversationModel> _conversations = [];
  final List<MessageModel> _messages = [];

  void _seedData() {
    final now = DateTime.now();

    _conversations.addAll([
      ConversationModel(
        id: 'conv_001',
        customerId: 'customer_demo_001',
        customerName: 'Ali Hassan',
        workerId: 'worker_001',
        workerName: 'Muhammad Usman',
        requestId: 'req_001',
        lastMessage: 'Theek hai, kal 10 baje aa jata hoon',
        lastMessageAt: now.subtract(const Duration(minutes: 45)),
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      ConversationModel(
        id: 'conv_002',
        customerId: 'customer_demo_001',
        customerName: 'Ali Hassan',
        workerId: 'worker_002',
        workerName: 'Tariq Mehmood',
        requestId: 'req_002',
        lastMessage: 'Job completed. Shukriya!',
        lastMessageAt: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ]);

    _messages.addAll([
      MessageModel(
        id: 'msg_001',
        conversationId: 'conv_001',
        senderId: 'customer_demo_001',
        senderName: 'Ali Hassan',
        text: 'Assalam o Alaikum, UPS wiring repair chahiye urgent',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      MessageModel(
        id: 'msg_002',
        conversationId: 'conv_001',
        senderId: 'worker_001',
        senderName: 'Muhammad Usman',
        text: 'Walaikum Assalam. Kya problem hai exactly?',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 2, minutes: 50)),
      ),
      MessageModel(
        id: 'msg_003',
        conversationId: 'conv_001',
        senderId: 'customer_demo_001',
        senderName: 'Ali Hassan',
        text: 'UPS se wiring nahi ho rahi, 2 rooms mein light nahi',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 2, minutes: 45)),
      ),
      MessageModel(
        id: 'msg_004',
        conversationId: 'conv_001',
        senderId: 'worker_001',
        senderName: 'Muhammad Usman',
        text: 'Theek hai, 1200 rupay lagenge. Quote accept kar lo.',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      MessageModel(
        id: 'msg_005',
        conversationId: 'conv_001',
        senderId: 'customer_demo_001',
        senderName: 'Ali Hassan',
        text: 'Quote accept kar liya. Kal kab aa sakte ho?',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
      ),
      MessageModel(
        id: 'msg_006',
        conversationId: 'conv_001',
        senderId: 'worker_001',
        senderName: 'Muhammad Usman',
        text: 'Theek hai, kal 10 baje aa jata hoon',
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
    ]);
  }

  // ── Access control: verify participant ───────────────────────────────────

  bool _isParticipant(String conversationId, String userId) {
    try {
      final conv = _conversations.firstWhere((c) => c.id == conversationId);
      return conv.customerId == userId || conv.workerId == userId;
    } catch (_) {
      return false;
    }
  }

  // ── Conversations ────────────────────────────────────────────────────────

  Future<List<ConversationModel>> getConversationsForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _conversations
        .where((c) => c.customerId == userId || c.workerId == userId)
        .toList()
      ..sort((a, b) =>
          (b.lastMessageAt ?? b.createdAt)
              .compareTo(a.lastMessageAt ?? a.createdAt));
  }

  Future<ConversationModel?> getOrCreateConversation({
    required String customerId,
    required String customerName,
    required String workerId,
    required String workerName,
    String? requestId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _conversations.firstWhere(
        (c) =>
            c.customerId == customerId &&
            c.workerId == workerId &&
            (requestId == null || c.requestId == requestId),
      );
    } catch (_) {
      final id = 'conv_${DateTime.now().millisecondsSinceEpoch}';
      final conv = ConversationModel(
        id: id,
        customerId: customerId,
        customerName: customerName,
        workerId: workerId,
        workerName: workerName,
        requestId: requestId,
        createdAt: DateTime.now(),
      );
      _conversations.insert(0, conv);
      return conv;
    }
  }

  // ── Messages ─────────────────────────────────────────────────────────────

  /// Returns messages only for verified participants.
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    required String requestingUserId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (!_isParticipant(conversationId, requestingUserId)) {
      throw Exception('Access denied: not a participant');
    }
    return _messages
        .where((m) => m.conversationId == conversationId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
    String? imageUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_isParticipant(conversationId, senderId)) {
      throw Exception('Access denied: not a participant');
    }
    final id = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    final msg = MessageModel(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );
    _messages.add(msg);

    // Update conversation last message
    final convIndex =
        _conversations.indexWhere((c) => c.id == conversationId);
    if (convIndex != -1) {
      final conv = _conversations[convIndex];
      _conversations[convIndex] = ConversationModel(
        id: conv.id,
        customerId: conv.customerId,
        customerName: conv.customerName,
        workerId: conv.workerId,
        workerName: conv.workerName,
        requestId: conv.requestId,
        lastMessage: text,
        lastMessageAt: DateTime.now(),
        customerBlocked: conv.customerBlocked,
        workerBlocked: conv.workerBlocked,
        createdAt: conv.createdAt,
      );
    }
    return msg;
  }

  Future<void> markMessagesRead({
    required String conversationId,
    required String userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!_isParticipant(conversationId, userId)) return;
    for (var i = 0; i < _messages.length; i++) {
      if (_messages[i].conversationId == conversationId &&
          _messages[i].senderId != userId) {
        _messages[i] = MessageModel(
          id: _messages[i].id,
          conversationId: _messages[i].conversationId,
          senderId: _messages[i].senderId,
          senderName: _messages[i].senderName,
          text: _messages[i].text,
          imageUrl: _messages[i].imageUrl,
          isRead: true,
          createdAt: _messages[i].createdAt,
        );
      }
    }
  }

  int getUnreadCount(String userId) {
    return _messages.where((m) {
      final conv = _conversations.firstWhere(
        (c) => c.id == m.conversationId,
        orElse: () => ConversationModel(
          id: '',
          customerId: '',
          customerName: '',
          workerId: '',
          workerName: '',
          createdAt: DateTime.now(),
        ),
      );
      final isParticipant =
          conv.customerId == userId || conv.workerId == userId;
      return isParticipant && m.senderId != userId && !m.isRead;
    }).length;
  }
}
