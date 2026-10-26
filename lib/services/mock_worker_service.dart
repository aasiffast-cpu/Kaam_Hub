import 'dart:async';

import '../models/worker_model.dart';
import 'worker_service.dart';

/// In-memory worker database service simulating thousands of individual worker profiles.
class MockWorkerService implements WorkerService {
  static final MockWorkerService _instance = MockWorkerService._internal();
  factory MockWorkerService() => _instance;

  final StreamController<List<WorkerModel>> _streamController =
      StreamController<List<WorkerModel>>.broadcast();

  final Map<String, WorkerModel> _workers = {};

  MockWorkerService._internal() {
    _seedInitialWorkers();
  }

  void _seedInitialWorkers() {
    // No fake data — real workers come from Firestore or user registrations.
    _streamController.add([]);
  }

  @override
  Stream<List<WorkerModel>> get workersStream => _streamController.stream;

  @override
  Future<WorkerModel?> getWorkerById(String workerId) async {
    return _workers[workerId];
  }

  @override
  Future<WorkerModel?> getWorkerByUserId(String userId) async {
    for (final w in _workers.values) {
      if (w.userId == userId) return w;
    }
    return null;
  }

  @override
  Future<List<WorkerModel>> getApprovedWorkers({
    String? category,
    String? city,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _workers.values.where((w) {
      if (w.verificationStatus != WorkerVerificationStatus.approved) {
        return false;
      }
      if (category != null &&
          category.isNotEmpty &&
          w.serviceCategory != category) {
        return false;
      }
      if (city != null &&
          city.isNotEmpty &&
          w.city.toLowerCase() != city.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<List<WorkerModel>> getPendingApplications() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _workers.values
        .where((w) => w.verificationStatus == WorkerVerificationStatus.pending)
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
    await Future.delayed(const Duration(milliseconds: 600));
    final existing = _workers[workerId];
    if (existing != null) {
      _workers[workerId] = existing.copyWith(
        profileImageUrl: profileImageUrl,
        cnicFrontUrl: cnicFrontUrl,
        cnicBackUrl: cnicBackUrl,
        policeClearanceUrl: policeClearanceUrl,
        verificationStatus: WorkerVerificationStatus.pending,
        updatedAt: DateTime.now(),
      );
      _streamController.add(_workers.values.toList());
    }
  }

  @override
  Future<void> setVerificationStatus({
    required String workerId,
    required WorkerVerificationStatus status,
    String? rejectionReason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final existing = _workers[workerId];
    if (existing != null) {
      _workers[workerId] = existing.copyWith(
        verificationStatus: status,
        rejectionReason: rejectionReason,
        updatedAt: DateTime.now(),
      );
      _streamController.add(_workers.values.toList());
    }
  }

  @override
  Future<WorkerModel> registerWorker(WorkerModel worker) async {
    _workers[worker.id] = worker;
    _streamController.add(_workers.values.toList());
    return worker;
  }
}
