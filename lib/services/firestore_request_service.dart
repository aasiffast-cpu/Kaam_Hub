import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_request_model.dart';

/// Real Firestore implementation for service requests.
class FirestoreRequestService {
  static final FirestoreRequestService _instance =
      FirestoreRequestService._internal();
  factory FirestoreRequestService() => _instance;
  FirestoreRequestService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _col = 'service_requests';

  Stream<List<ServiceRequestModel>> requestsForCustomer(String customerId) =>
      _db
          .collection(_col)
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs
              .map((d) => ServiceRequestModel.fromMap(d.data(), d.id))
              .toList());

  Stream<List<ServiceRequestModel>> requestsForWorker(String workerId) =>
      _db
          .collection(_col)
          .where('workerId', isEqualTo: workerId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs
              .map((d) => ServiceRequestModel.fromMap(d.data(), d.id))
              .toList());

  Stream<List<ServiceRequestModel>> allRequests() =>
      _db
          .collection(_col)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs
              .map((d) => ServiceRequestModel.fromMap(d.data(), d.id))
              .toList());

  Future<ServiceRequestModel> createRequest(
      ServiceRequestModel request) async {
    final ref = _db.collection(_col).doc(request.id);
    await ref.set(request.toMap());
    return request;
  }

  Future<void> updateStatus(
      String requestId, ServiceRequestStatus status) async {
    await _db.collection(_col).doc(requestId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<ServiceRequestModel?> getRequest(String requestId) async {
    final doc = await _db.collection(_col).doc(requestId).get();
    if (!doc.exists || doc.data() == null) return null;
    return ServiceRequestModel.fromMap(doc.data()!, doc.id);
  }
}
