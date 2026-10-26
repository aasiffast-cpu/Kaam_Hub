import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/worker_model.dart';
import '../../services/auth_notifier.dart';
import '../../services/mock_worker_service.dart';

/// Admin dashboard console with full verification document inspection.
///
/// Administrators inspect worker's 4 compulsory documents:
/// Profile Photo, CNIC Front, CNIC Back, and Police Clearance Certificate.
class AdminDashboardScreen extends StatefulWidget {
  final AuthNotifier? authNotifier;

  const AdminDashboardScreen({super.key, this.authNotifier});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final MockWorkerService _workerService = MockWorkerService();

  List<WorkerModel> _pendingWorkers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    final pending = await _workerService.getPendingApplications();
    if (mounted) {
      setState(() {
        _pendingWorkers = pending;
        _isLoading = false;
      });
    }
  }

  void _approveWorker(WorkerModel worker) async {
    await _workerService.setVerificationStatus(
      workerId: worker.id,
      status: WorkerVerificationStatus.approved,
    );
    _loadData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Worker ${worker.displayName} Approved! Profile is now published.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _rejectWorker(WorkerModel worker) async {
    final reasonController = TextEditingController(
      text: 'CNIC or Police clearance document is blurry. Please re-upload.',
    );

    final shouldReject = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        title: const Text('Reject Verification Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the reason why ${worker.displayName}\'s application is rejected:',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Blurry CNIC photo or invalid clearance',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Rejection'),
          ),
        ],
      ),
    );

    if (shouldReject == true) {
      await _workerService.setVerificationStatus(
        workerId: worker.id,
        status: WorkerVerificationStatus.rejected,
        rejectionReason: reasonController.text.trim(),
      );
      _loadData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Application for ${worker.displayName} was rejected.'),
        ),
      );
    }
  }

  void _openDocumentInspectionModal(WorkerModel worker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker.displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${worker.serviceCategory} • ${worker.city} • ${worker.phoneNumber}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  const Row(
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Inspection: 4 Compulsory Documents',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildInspectionDocTile(
                    title: '1. Profile Photo (Face Image)',
                    subtitle: 'Visible to customers on worker profile',
                    imageUrl: worker.profileImageUrl.isNotEmpty
                        ? worker.profileImageUrl
                        : null,
                    isCircular: true,
                  ),
                  const SizedBox(height: 12),

                  _buildInspectionDocTile(
                    title: '2. CNIC Front Side (Shanakhti Card)',
                    subtitle: 'Verify 13-digit CNIC number, photo & full name',
                    imageUrl: worker.cnicFrontUrl,
                  ),
                  const SizedBox(height: 12),

                  _buildInspectionDocTile(
                    title: '3. CNIC Back Side (Pichla Rukh)',
                    subtitle:
                        'Verify permanent/present address along the corridor',
                    imageUrl: worker.cnicBackUrl,
                  ),
                  const SizedBox(height: 12),

                  _buildInspectionDocTile(
                    title: '4. Police Clearance Certificate',
                    subtitle:
                        'Punjab Police Khidmat Markaz Character Verification',
                    imageUrl: worker.policeClearanceUrl,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _rejectWorker(worker);
                          },
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Reject Application'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceM),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _approveWorker(worker);
                          },
                          icon: const Icon(Icons.check_circle_rounded),
                          label: const Text('Approve & Publish'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInspectionDocTile({
    required String title,
    required String subtitle,
    required String? imageUrl,
    bool isCircular = false,
  }) {
    final hasDoc = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: hasDoc
              ? AppColors.success.withAlpha(70)
              : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: hasDoc
                      ? AppColors.badgeApprovedBg
                      : AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  hasDoc ? 'ATTACHED ✓' : 'MISSING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: hasDoc
                        ? AppColors.badgeApprovedText
                        : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          if (hasDoc)
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => Dialog(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppBar(
                          title: Text(
                            title,
                            style: const TextStyle(fontSize: 15),
                          ),
                          automaticallyImplyLeading: false,
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Text('Document preview not available'),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      imageUrl,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 80,
                        color: AppColors.cardBorder,
                        alignment: Alignment.center,
                        child: const Text('Image preview error'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusFull,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Tap to Zoom Document',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.cardBorder.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Document not provided by applicant',
                style: TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildManagementTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppConstants.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(30),
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, size: 14, color: AppColors.accent),
                SizedBox(width: 4),
                Text(
                  'Super Admin',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppConstants.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Security Notice
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.info.withAlpha(60)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security_rounded, color: AppColors.info),
                    SizedBox(width: AppConstants.spaceM),
                    Expanded(
                      child: Text(
                        'Admin panel guarded by Firebase Security Rules & backend role claims.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.info,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),

              // Top Metrics Grid
              const Text(
                'Marketplace Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceS),
              Row(
                children: [
                  const Expanded(
                    child: _AdminStatCard(
                      title: 'Total Bookings',
                      count: '142',
                      icon: Icons.calendar_today_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: _AdminStatCard(
                      title: 'Pending Approvals',
                      count: '${_pendingWorkers.length}',
                      icon: Icons.pending_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceM),
              const Row(
                children: [
                  Expanded(
                    child: _AdminStatCard(
                      title: 'Active Workers',
                      count: '5',
                      icon: Icons.engineering_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: _AdminStatCard(
                      title: 'Open Complaints',
                      count: '0',
                      icon: Icons.report_problem_rounded,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceL),

              // Platform Management Section
              const Text(
                'Platform Management',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceS),
              _buildManagementTile(
                context,
                icon: Icons.category_rounded,
                title: 'Manage Service Categories',
                subtitle: 'Add, edit, enable or disable trade categories',
                color: AppColors.primary,
                route: AppRoutes.adminCategories,
              ),
              const SizedBox(height: AppConstants.spaceS),
              _buildManagementTile(
                context,
                icon: Icons.location_city_rounded,
                title: 'Manage Cities',
                subtitle: 'Enable or disable corridor cities',
                color: AppColors.secondary,
                route: AppRoutes.adminCities,
              ),
              const SizedBox(height: AppConstants.spaceS),
              _buildManagementTile(
                context,
                icon: Icons.receipt_long_rounded,
                title: 'All Service Requests',
                subtitle: 'View bookings, disputes and reports',
                color: AppColors.warning,
                route: AppRoutes.adminRequests,
              ),
              const SizedBox(height: AppConstants.spaceS),
              _buildManagementTile(
                context,
                icon: Icons.people_rounded,
                title: 'Manage Users',
                subtitle: 'Activate or deactivate customer / worker accounts',
                color: AppColors.info,
                route: AppRoutes.adminUsers,
              ),
              const SizedBox(height: AppConstants.spaceL),

              // Pending Worker Approvals Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pending Worker Verifications (${_pendingWorkers.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    tooltip: 'Refresh',
                    onPressed: _loadData,
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceS),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_pendingWorkers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.success,
                        size: 44,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'All Applications Reviewed!',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'There are currently no worker verification requests awaiting review.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pendingWorkers.length,
                  separatorBuilder: (_, r) =>
                      const SizedBox(height: AppConstants.spaceM),
                  itemBuilder: (context, index) {
                    final worker = _pendingWorkers[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusM,
                        ),
                        side: const BorderSide(color: AppColors.cardBorder),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spaceM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.cardBorder,
                                      backgroundImage:
                                          worker.profileImageUrl.isNotEmpty
                                          ? NetworkImage(worker.profileImageUrl)
                                          : null,
                                      child: worker.profileImageUrl.isEmpty
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          worker.displayName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          '${worker.serviceCategory} • ${worker.city}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.badgePendingBg,
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.radiusFull,
                                    ),
                                  ),
                                  child: const Text(
                                    'Needs Review',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.badgePendingText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Phone: ${worker.phoneNumber} • Experience: ${worker.experienceYears} Years',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Documents: Profile Photo, CNIC Front/Back, Police Clearance ${worker.hasCompleteDocuments ? '(4/4 Complete)' : '(Incomplete)'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: worker.hasCompleteDocuments
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spaceM),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _openDocumentInspectionModal(worker),
                                    icon: const Icon(
                                      Icons.description_outlined,
                                      size: 16,
                                    ),
                                    label: const Text('Inspect 4 Documents'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: AppConstants.spaceXL),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const _AdminStatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceM),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Icon(icon, color: color, size: 22),
              ],
            ),
            const SizedBox(height: AppConstants.spaceS),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
