import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/worker_model.dart';
import '../../services/auth_notifier.dart';
import '../../services/image_picker_service.dart';
import '../../services/mock_worker_service.dart';

/// Compulsory Document Upload Screen for Service Workers.
///
/// Requires 4 compulsory items:
/// 1. Public Profile Image
/// 2. CNIC Front Side
/// 3. CNIC Back Side
/// 4. Punjab Police Clearance Certificate
class WorkerDocumentUploadScreen extends StatefulWidget {
  final AuthNotifier? authNotifier;
  final WorkerModel? existingWorker;

  const WorkerDocumentUploadScreen({
    super.key,
    this.authNotifier,
    this.existingWorker,
  });

  @override
  State<WorkerDocumentUploadScreen> createState() =>
      _WorkerDocumentUploadScreenState();
}

class _WorkerDocumentUploadScreenState
    extends State<WorkerDocumentUploadScreen> {
  final MockWorkerService _workerService = MockWorkerService();

  String? _profileImageUrl;
  String? _cnicFrontUrl;
  String? _cnicBackUrl;
  String? _policeClearanceUrl;

  bool _isSubmitting = false;
  String? _validationError;

  // Realistic verified sample presets for instant frictionless testing on all platforms
  static const String _defaultProfileSample =
      'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?auto=format&fit=crop&q=80&w=400';
  static const String _defaultCnicFrontSample =
      'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?auto=format&fit=crop&q=80&w=800';
  static const String _defaultCnicBackSample =
      'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&q=80&w=800';
  static const String _defaultPoliceClearanceSample =
      'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&q=80&w=800';

  @override
  void initState() {
    super.initState();
    _loadExistingWorkerData();
  }

  void _loadExistingWorkerData() async {
    final user = widget.authNotifier?.currentUser;
    WorkerModel? worker = widget.existingWorker;

    if (worker == null && user != null) {
      worker = await _workerService.getWorkerByUserId(user.uid);
    }

    if (worker != null && mounted) {
      setState(() {
        if (worker!.profileImageUrl.isNotEmpty) {
          _profileImageUrl = worker.profileImageUrl;
        }
        _cnicFrontUrl = worker.cnicFrontUrl;
        _cnicBackUrl = worker.cnicBackUrl;
        _policeClearanceUrl = worker.policeClearanceUrl;
      });
    }
  }

  int get _uploadedCount {
    int count = 0;
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) count++;
    if (_cnicFrontUrl != null && _cnicFrontUrl!.isNotEmpty) count++;
    if (_cnicBackUrl != null && _cnicBackUrl!.isNotEmpty) count++;
    if (_policeClearanceUrl != null && _policeClearanceUrl!.isNotEmpty) count++;
    return count;
  }

  bool get _allDocumentsUploaded => _uploadedCount == 4;

  void _pickDocument({
    required String title,
    required String docKey,
    required String defaultPreset,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upload $title',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select an image upload method or attach a verified identity document:',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Option 1: Sample verified document (Instant 1-tap testing)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Attach Verified High-Res Document',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Use verified clear image for instant review demo',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    _setDocumentUrl(docKey, defaultPreset);
                    Navigator.pop(ctx);
                  },
                ),

                // Option 2: Live camera capture
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                  title: const Text(
                    'Take Photo with Camera',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Capture document front and corners clearly',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final dataUrl = await ImagePickerService.pickImage(
                      source: ImageSource.camera,
                    );
                    if (dataUrl != null) {
                      _setDocumentUrl(docKey, dataUrl);
                    }
                  },
                ),

                // Option 3: Choose from gallery
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.accent,
                    ),
                  ),
                  title: const Text(
                    'Select from Device Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'JPG, PNG or PDF format (max 5MB)',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final dataUrl = await ImagePickerService.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (dataUrl != null) {
                      _setDocumentUrl(docKey, dataUrl);
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _setDocumentUrl(String docKey, String url) {
    setState(() {
      _validationError = null;
      switch (docKey) {
        case 'profile':
          _profileImageUrl = url;
          break;
        case 'cnic_front':
          _cnicFrontUrl = url;
          break;
        case 'cnic_back':
          _cnicBackUrl = url;
          break;
        case 'police_clearance':
          _policeClearanceUrl = url;
          break;
      }
    });
  }

  void _previewDocument(String title, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppBar(
              title: Text(title, style: const TextStyle(fontSize: 16)),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 380),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: AppColors.cardBorder,
                  alignment: Alignment.center,
                  child: const Text('Image preview not available'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.check),
                label: const Text('Close Preview'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    // 1. Mandatory Validation: All 4 documents MUST be present
    if (_profileImageUrl == null || _profileImageUrl!.isEmpty) {
      setState(
        () => _validationError =
            'Profile Image is mandatory! Please upload your face photo.',
      );
      return;
    }
    if (_cnicFrontUrl == null || _cnicFrontUrl!.isEmpty) {
      setState(
        () => _validationError =
            'CNIC Front side is mandatory! Please upload your CNIC front.',
      );
      return;
    }
    if (_cnicBackUrl == null || _cnicBackUrl!.isEmpty) {
      setState(
        () => _validationError =
            'CNIC Back side is mandatory! Please upload your CNIC back.',
      );
      return;
    }
    if (_policeClearanceUrl == null || _policeClearanceUrl!.isEmpty) {
      setState(
        () => _validationError = 'Police Clearance Certificate is mandatory! Please upload your Khidmat Markaz certificate.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _validationError = null;
    });

    try {
      final user = widget.authNotifier?.currentUser;
      final workerId =
          widget.existingWorker?.id ??
          (user != null
              ? 'w_${user.uid}'
              : 'w_pending_${DateTime.now().millisecondsSinceEpoch}');

      // If worker doesn't exist yet, register base profile
      final existing = await _workerService.getWorkerById(workerId);
      if (existing == null) {
        final newWorker = WorkerModel(
          id: workerId,
          userId: user?.uid ?? 'u_worker',
          displayName: user?.name ?? 'Registered Worker',
          phoneNumber: user?.phoneNumber ?? '+92 300 0000000',
          profileImageUrl: _profileImageUrl!,
          serviceCategory: 'Electrician',
          city: 'Sahiwal',
          experienceYears: 5,
          startingRate: 800,
          verificationStatus: WorkerVerificationStatus.pending,
          cnicFrontUrl: _cnicFrontUrl,
          cnicBackUrl: _cnicBackUrl,
          policeClearanceUrl: _policeClearanceUrl,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _workerService.registerWorker(newWorker);
      } else {
        await _workerService.submitVerificationDocuments(
          workerId: workerId,
          profileImageUrl: _profileImageUrl!,
          cnicFrontUrl: _cnicFrontUrl!,
          cnicBackUrl: _cnicBackUrl!,
          policeClearanceUrl: _policeClearanceUrl!,
        );
      }

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      // Show Congratulatory Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 28,
              ),
              SizedBox(width: 10),
              Text('Documents Submitted!'),
            ],
          ),
          content: const Text(
            'All 4 compulsory documents (Profile Photo, CNIC Front, CNIC Back, Police Clearance Certificate) have been uploaded successfully.\n\nOur administrative safety team is reviewing your documents. You can check your status on your Worker Dashboard.',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.workerDashboard,
                );
              },
              child: const Text('Go to Worker Dashboard'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _validationError = 'Failed to submit documents: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mandatory Document Upload')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.spaceS),

              // Trust & Security Notice Banner
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.secondary.withAlpha(50)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.secondary,
                      size: 26,
                    ),
                    SizedBox(width: AppConstants.spaceM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Punjab Safety & Trust Policy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'To protect customers and workers, KaamHub requires 4 compulsory identity documents before publishing your profile: Profile Photo, CNIC Front, CNIC Back, and Police Clearance Certificate.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),

              // Upload Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Verification Progress',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$_uploadedCount of 4 Completed',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _allDocumentsUploaded
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _uploadedCount / 4.0,
                  minHeight: 8,
                  backgroundColor: AppColors.cardBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _allDocumentsUploaded
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),

              // 1. Profile Photo (Compulsory)
              _buildDocumentCard(
                title: '1. Profile Photo (Chehray Ki Tasweer)',
                subtitle: 'Compulsory clear front-facing face photo. This photo will be visible to customers on your public profile.',
                badgeText: 'COMPULSORY',
                badgeColor: AppColors.error,
                icon: Icons.face_rounded,
                currentUrl: _profileImageUrl,
                onUpload: () => _pickDocument(
                  title: 'Profile Photo',
                  docKey: 'profile',
                  defaultPreset: _defaultProfileSample,
                ),
                onPreview: () =>
                    _previewDocument('Profile Photo', _profileImageUrl!),
                isCircularPreview: true,
              ),
              const SizedBox(height: AppConstants.spaceM),

              // 2. CNIC Front Side (Compulsory)
              _buildDocumentCard(
                title: '2. CNIC Front Side (Shanakhti Card)',
                subtitle: 'Clear photo of your computerized National Identity Card front showing 13-digit number & photo.',
                badgeText: 'COMPULSORY',
                badgeColor: AppColors.error,
                icon: Icons.credit_card_rounded,
                currentUrl: _cnicFrontUrl,
                onUpload: () => _pickDocument(
                  title: 'CNIC Front Side',
                  docKey: 'cnic_front',
                  defaultPreset: _defaultCnicFrontSample,
                ),
                onPreview: () =>
                    _previewDocument('CNIC Front Side', _cnicFrontUrl!),
              ),
              const SizedBox(height: AppConstants.spaceM),

              // 3. CNIC Back Side (Compulsory)
              _buildDocumentCard(
                title: '3. CNIC Back Side (Pichla Rukh)',
                subtitle: 'Photo of CNIC back showing your registered permanent/present address and issuance stamp.',
                badgeText: 'COMPULSORY',
                badgeColor: AppColors.error,
                icon: Icons.credit_card_outlined,
                currentUrl: _cnicBackUrl,
                onUpload: () => _pickDocument(
                  title: 'CNIC Back Side',
                  docKey: 'cnic_back',
                  defaultPreset: _defaultCnicBackSample,
                ),
                onPreview: () =>
                    _previewDocument('CNIC Back Side', _cnicBackUrl!),
              ),
              const SizedBox(height: AppConstants.spaceM),

              // 4. Police Clearance Certificate (Compulsory)
              _buildDocumentCard(
                title: '4. Police Clearance Certificate',
                subtitle: 'Character verification certificate issued by Punjab Police Khidmat Markaz or District Police.',
                badgeText: 'COMPULSORY',
                badgeColor: AppColors.error,
                icon: Icons.local_police_rounded,
                currentUrl: _policeClearanceUrl,
                onUpload: () => _pickDocument(
                  title: 'Police Clearance Certificate',
                  docKey: 'police_clearance',
                  defaultPreset: _defaultPoliceClearanceSample,
                ),
                onPreview: () => _previewDocument(
                  'Police Clearance Certificate',
                  _policeClearanceUrl!,
                ),
              ),

              if (_validationError != null) ...[
                const SizedBox(height: AppConstants.spaceM),
                Container(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(color: AppColors.error.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppConstants.spaceM),
                      Expanded(
                        child: Text(
                          _validationError!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppConstants.spaceXL),

              // Submit Button
              PrimaryButton(
                text: _allDocumentsUploaded
                    ? 'Submit All 4 Documents for Verification'
                    : 'Submit Documents ($_uploadedCount/4)',
                isLoading: _isSubmitting,
                icon: Icons.cloud_upload_rounded,
                onPressed: _handleSubmit,
              ),

              const SizedBox(height: AppConstants.spaceM),

              // Skip / Later note (Allows worker to explore dashboard while pending)
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.workerDashboard,
                    );
                  },
                  child: const Text(
                    'Save Draft & Return to Dashboard',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required String? currentUrl,
    required VoidCallback onUpload,
    required VoidCallback onPreview,
    bool isCircularPreview = false,
  }) {
    final isUploaded = currentUrl != null && currentUrl.isNotEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        side: BorderSide(
          color: isUploaded
              ? AppColors.success.withAlpha(80)
              : AppColors.cardBorder,
          width: isUploaded ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isUploaded
                        ? AppColors.badgeApprovedBg
                        : badgeColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusFull,
                    ),
                  ),
                  child: Text(
                    isUploaded ? 'UPLOADED ✓' : badgeText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isUploaded
                          ? AppColors.badgeApprovedText
                          : badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: AppConstants.spaceM),

            // Document state preview or upload action
            if (isUploaded) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    if (isCircularPreview)
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(currentUrl),
                      )
                    else
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          currentUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(width: AppConstants.spaceM),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Document Attached',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'High resolution • Ready for review',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined),
                      tooltip: 'Preview Document',
                      onPressed: onPreview,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Change Document',
                      onPressed: onUpload,
                    ),
                  ],
                ),
              ),
            ] else ...[
              OutlinedButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.file_upload_outlined, size: 18),
                label: const Text('Attach / Upload Document'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
