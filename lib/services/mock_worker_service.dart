import 'dart:async';

import '../core/constants/app_strings.dart';
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
    final now = DateTime.now();

    final seedList = [
      // 1. Electrician in Sahiwal
      WorkerModel(
        id: 'w_sahiwal_01',
        userId: 'u_work_01',
        displayName: 'Rashid Ali',
        phoneNumber: '+92 300 7654321',
        profileImageUrl: 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?auto=format&fit=crop&q=80&w=256',
        serviceCategory: AppStrings.catElectrician,
        subCategories: ['UPS / Inverter', 'Wiring', 'Fans & Lights'],
        city: 'Sahiwal',
        serviceAreas: [
          'Farid Town',
          'Fateh Sher Colony',
          'High Street',
          'Scheme 2',
        ],
        experienceYears: 6,
        startingRate: 800,
        verificationStatus: WorkerVerificationStatus.approved,
        averageRating: 4.9,
        reviewCount: 38,
        completedJobsCount: 84,
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now,
      ),

      // 2. Plumber in Sahiwal
      WorkerModel(
        id: 'w_sahiwal_02',
        userId: 'u_work_02',
        displayName: 'Muhammad Usman',
        phoneNumber: '+92 301 2345678',
        profileImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=256',
        serviceCategory: AppStrings.catPlumber,
        subCategories: ['Tap Repair', 'Geyser Installation', 'Water Tank'],
        city: 'Sahiwal',
        serviceAreas: ['Tariq Bin Ziad Colony', 'Civil Lines', 'Farid Town'],
        experienceYears: 8,
        startingRate: 1000,
        verificationStatus: WorkerVerificationStatus.approved,
        averageRating: 4.8,
        reviewCount: 45,
        completedJobsCount: 112,
        createdAt: now.subtract(const Duration(days: 150)),
        updatedAt: now,
      ),

      // 3. Mistri / Mason in Okara
      WorkerModel(
        id: 'w_okara_01',
        userId: 'u_work_03',
        displayName: 'Karamat Ustad',
        phoneNumber: '+92 302 3456789',
        profileImageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=256',
        serviceCategory: AppStrings.catMistri,
        subCategories: ['Tiles Fitting', 'Plaster', 'Small Masonry Repairs'],
        city: 'Okara',
        serviceAreas: ['Depalpur Chowk', 'Kachehri Bazaar', 'Mandi Road'],
        experienceYears: 12,
        startingRate: 1500,
        verificationStatus: WorkerVerificationStatus.approved,
        averageRating: 4.9,
        reviewCount: 52,
        completedJobsCount: 130,
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now,
      ),

      // 4. Car Washer in Lahore
      WorkerModel(
        id: 'w_lahore_01',
        userId: 'u_work_04',
        displayName: 'Hamza Bilal',
        phoneNumber: '+92 303 4567890',
        profileImageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=256',
        serviceCategory: AppStrings.catCarWasher,
        subCategories: ['Home Wash', 'Interior Detail', 'Engine Degrease'],
        city: 'Lahore',
        serviceAreas: ['Gulberg', 'Model Town', 'Johar Town', 'DHA'],
        experienceYears: 4,
        startingRate: 900,
        verificationStatus: WorkerVerificationStatus.approved,
        averageRating: 4.7,
        reviewCount: 29,
        completedJobsCount: 65,
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now,
      ),

      // 5. Mechanic in Lahore
      WorkerModel(
        id: 'w_lahore_02',
        userId: 'u_work_05',
        displayName: 'Sajid Mehmood',
        phoneNumber: '+92 304 5678901',
        profileImageUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&q=80&w=256',
        serviceCategory: AppStrings.catMechanic,
        subCategories: [
          'Oil Change',
          'Battery Replacement',
          'Breakdown Repair',
        ],
        city: 'Lahore',
        serviceAreas: ['Thokar Niaz Baig', 'Johar Town', 'Faisal Town'],
        experienceYears: 10,
        startingRate: 1200,
        verificationStatus: WorkerVerificationStatus.approved,
        averageRating: 4.9,
        reviewCount: 61,
        completedJobsCount: 145,
        createdAt: now.subtract(const Duration(days: 220)),
        updatedAt: now,
      ),

      // 6. Pending Worker Applicant with submitted verification documents (for Admin testing)
      WorkerModel(
        id: 'w_pending_01',
        userId: 'u_work_06',
        displayName: 'Tariq Mahmood',
        phoneNumber: '+92 305 9876543',
        profileImageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=256',
        serviceCategory: AppStrings.catElectrician,
        subCategories: ['Wiring', 'Switchboards', 'UPS Setup'],
        city: 'Lahore',
        serviceAreas: ['Johar Town', 'Wapda Town'],
        experienceYears: 5,
        startingRate: 850,
        verificationStatus: WorkerVerificationStatus.pending,
        cnicFrontUrl: 'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?auto=format&fit=crop&q=80&w=600',
        cnicBackUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&q=80&w=600',
        policeClearanceUrl: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&q=80&w=600',
        workPhotoUrls: [
          'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&q=80&w=400',
          'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&q=80&w=400',
        ],
        createdAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now,
      ),
    ];

    for (final worker in seedList) {
      _workers[worker.id] = worker;
    }
    _streamController.add(_workers.values.toList());
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
