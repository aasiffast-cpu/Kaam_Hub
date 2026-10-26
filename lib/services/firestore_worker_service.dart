import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/worker_model.dart';
import 'worker_service.dart';

/// Real Firestore implementation of [WorkerService].
/// All worker data is persisted in Firebase Cloud Firestore `workers` collection.
class FirestoreWorkerService implements WorkerService {
  static final FirestoreWorkerService _instance =
      FirestoreWorkerService._internal();
  factory FirestoreWorkerService() => _instance;
  FirestoreWorkerService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _col = 'workers';

  @override
  Stream<List<WorkerModel>> get workersStream => _db
      .collection(_col)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => WorkerModel.fromMap(d.data(), id: d.id))
          .toList());

  @override
  Future<WorkerModel?> getWorkerById(String workerId) async {
    final doc = await _db.collection(_col).doc(workerId).get();
    if (!doc.exists || doc.data() == null) return null;
    return WorkerModel.fromMap(doc.data()!, id: doc.id);
  }

  @override
  Future<WorkerModel?> getWorkerByUserId(String userId) async {
    final snap = await _db
        .collection(_col)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return WorkerModel.fromMap(snap.docs.first.data(), id: snap.docs.first.id);
  }

  @override
  Future<List<WorkerModel>> getApprovedWorkers({
    String? category,
    String? city,
  }) async {
    Query<Map<String, dynamic>> query = _db
        .collection(_col)
        .where('verificationStatus', isEqualTo: 'approved');
    if (category != null && category.isNotEmpty) {
      query = query.where('serviceCategory', isEqualTo: category);
    }
    if (city != null && city.isNotEmpty) {
      query = query.where('city', isEqualTo: city);
    }
    final snap = await query.get();
    return snap.docs
        .map((d) => WorkerModel.fromMap(d.data(), id: d.id))
        .toList();
  }

  @override
  Future<List<WorkerModel>> getPendingApplications() async {
    final snap = await _db
        .collection(_col)
        .where('verificationStatus', isEqualTo: 'pending')
        .get();
    return snap.docs
        .map((d) => WorkerModel.fromMap(d.data(), id: d.id))
        .toList();
  }

  @override
  Future<void> submitVerificationDocuments({
    required String workerId,
    required String profileImageUrl,
    required String cnicFrontUrl,
    required String cnicBackUrl,
    required String policeClearanceUrl,
  }) async {
    await _db.collection(_col).doc(workerId).update({
      'profileImageUrl': profileImageUrl,
      'cnicFrontUrl': cnicFrontUrl,
      'cnicBackUrl': cnicBackUrl,
      'policeClearanceUrl': policeClearanceUrl,
      'verificationStatus': 'pending',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> setVerificationStatus({
    required String workerId,
    required WorkerVerificationStatus status,
    String? rejectionReason,
  }) async {
    final Map<String, dynamic> data = {
      'verificationStatus': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (rejectionReason != null) data['rejectionReason'] = rejectionReason;
    await _db.collection(_col).doc(workerId).update(data);
  }

  @override
  Future<WorkerModel> registerWorker(WorkerModel worker) async {
    final ref = _db.collection(_col).doc(worker.id);
    await ref.set(worker.toMap());
    return worker;
  }
}
