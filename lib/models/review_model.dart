/// Review/rating left by a customer after a completed service request.
class ReviewModel {
  final String id;
  final String requestId;
  final String customerId;
  final String customerName;
  final String workerId;
  final double rating; // 1.0 – 5.0
  final String? comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.requestId,
    required this.customerId,
    required this.customerName,
    required this.workerId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      requestId: map['requestId'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? 'Customer',
      workerId: map['workerId'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      comment: map['comment'] as String?,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'requestId': requestId,
        'customerId': customerId,
        'customerName': customerName,
        'workerId': workerId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
      };
}
