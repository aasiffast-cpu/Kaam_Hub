import '../models/worker_model.dart';

/// Abstract service contract for Worker profiles, discovery, and verification.
abstract class WorkerService {
  /// Stream providing live updates to worker profiles.
  Stream<List<WorkerModel>> get workersStream;

  /// Fetches an individual worker by their worker ID.
  Future<WorkerModel?> getWorkerById(String workerId);

  /// Fetches the worker record linked to a given user ID.
  Future<WorkerModel?> getWorkerByUserId(String userId);

  /// Returns approved and discoverable workers for customer search and filtering.
  Future<List<WorkerModel>> getApprovedWorkers({
    String? category,
    String? city,
  });

  /// Returns pending applications for administrator inspection.
  Future<List<WorkerModel>> getPendingApplications();

  /// Submits the compulsory verification documents for a worker.
  Future<void> submitVerificationDocuments({
    required String workerId,
    required String profileImageUrl,
    required String cnicFrontUrl,
    required String cnicBackUrl,
    required String policeClearanceUrl,
  });

  /// Approves or rejects a worker application (Admin only).
  Future<void> setVerificationStatus({
    required String workerId,
    required WorkerVerificationStatus status,
    String? rejectionReason,
  });

  /// Registers a new worker profile.
  Future<WorkerModel> registerWorker(WorkerModel worker);
}
