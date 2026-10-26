import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message_model.dart';

/// Real Firebase/Firestore implementation for chat and conversations.
class FirebaseChatService {
  static final FirebaseChatService _instance = FirebaseChatService._internal();
  factory FirebaseChatService() => _instance;
  FirebaseChatService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Real-time stream of messages in a conversation.
  Stream<List<MessageModel>> messagesStream(String conversationId) =>
      _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((s) => s.docs
              .map((d) => MessageModel.fromMap(d.data(), d.id))
              .toList());

  /// Real-time stream of all conversations for a user.
  Stream<List<ConversationModel>> conversationsStream(String userId) =>
      _db
          .collection('conversations')
          .where('participantIds', arrayContains: userId)
          .orderBy('lastMessageAt', descending: true)
          .snapshots()
          .map((s) => s.docs
              .map((d) => ConversationModel.fromMap(d.data(), d.id))
              .toList());

  /// Sends a message within a conversation.
  Future<void> sendMessage({
    required String conversationId,
    required MessageModel message,
  }) async {
    final batch = _db.batch();

    final msgRef = _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(message.id);
    batch.set(msgRef, message.toMap());

    final convRef = _db.collection('conversations').doc(conversationId);
    batch.set(
      convRef,
      {
        'lastMessage': message.text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': message.senderId,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Gets or creates a conversation between a customer and worker for a request.
  Future<String> getOrCreateConversation({
    required String customerId,
    required String workerId,
    required String requestId,
    required String customerName,
    required String workerName,
  }) async {
    final convId = 'conv_${requestId}_${customerId}_$workerId';
    final convRef = _db.collection('conversations').doc(convId);
    final doc = await convRef.get();
    if (!doc.exists) {
      await convRef.set({
        'id': convId,
        'participantIds': [customerId, workerId],
        'customerId': customerId,
        'workerId': workerId,
        'requestId': requestId,
        'customerName': customerName,
        'workerName': workerName,
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'customerBlocked': false,
        'workerBlocked': false,
      });
    }
    return convId;
  }

  /// Marks all messages in a conversation as read for a specific user.
  Future<void> markAsRead(String conversationId, String userId) async {
    final unread = await _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
