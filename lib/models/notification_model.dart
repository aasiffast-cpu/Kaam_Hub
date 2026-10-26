/// In-app notification model for KaamHub.
enum NotificationType {
  otpSent,
  applicationReceived,
  applicationApproved,
  applicationRejected,
  applicationNeedsInfo,
  newRequest,
  quoteReceived,
  bookingAccepted,
  appointmentReminder,
  jobCancelled,
  jobCompleted,
  newMessage,
  reportStatusUpdate,
  securityAlert,
  general,
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final String? relatedId; // requestId, conversationId, etc.
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    this.relatedId,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == (map['type'] as String? ?? ''),
        orElse: () => NotificationType.general,
      ),
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      isRead: map['isRead'] as bool? ?? false,
      relatedId: map['relatedId'] as String?,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'type': type.name,
        'title': title,
        'body': body,
        'isRead': isRead,
        'relatedId': relatedId,
        'createdAt': createdAt.toIso8601String(),
      };

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId,
      createdAt: createdAt,
    );
  }
}
