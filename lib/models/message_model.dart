/// A single chat message in a KaamHub conversation.
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.imageUrl,
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      conversationId: map['conversationId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? 'User',
      text: map['text'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'conversationId': conversationId,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'imageUrl': imageUrl,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// A conversation thread between a customer and provider, optionally linked to a request.
class ConversationModel {
  final String id;
  final String customerId;
  final String customerName;
  final String workerId;
  final String workerName;
  final String? requestId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool customerBlocked;
  final bool workerBlocked;
  final DateTime createdAt;

  const ConversationModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.workerId,
    required this.workerName,
    this.requestId,
    this.lastMessage,
    this.lastMessageAt,
    this.customerBlocked = false,
    this.workerBlocked = false,
    required this.createdAt,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map, String id) {
    return ConversationModel(
      id: id,
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      workerId: map['workerId'] as String? ?? '',
      workerName: map['workerName'] as String? ?? '',
      requestId: map['requestId'] as String?,
      lastMessage: map['lastMessage'] as String?,
      lastMessageAt:
          DateTime.tryParse(map['lastMessageAt'] as String? ?? ''),
      customerBlocked: map['customerBlocked'] as bool? ?? false,
      workerBlocked: map['workerBlocked'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'customerName': customerName,
        'workerId': workerId,
        'workerName': workerName,
        'requestId': requestId,
        'lastMessage': lastMessage,
        'lastMessageAt': lastMessageAt?.toIso8601String(),
        'customerBlocked': customerBlocked,
        'workerBlocked': workerBlocked,
        'createdAt': createdAt.toIso8601String(),
      };

  String otherPartyName(String myUserId) =>
      myUserId == customerId ? workerName : customerName;
}
