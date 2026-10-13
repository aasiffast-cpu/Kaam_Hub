import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_role.dart';
import '../../models/worker_model.dart';
import '../../services/auth_notifier.dart';
import '../../services/mock_worker_service.dart';

/// Service Provider (Worker) Dashboard widget with 4 dedicated tabs:
/// 1. Jobs & Live Requests
/// 2. Earnings & Performance
/// 3. Verification Documents (Profile Photo, CNIC Front/Back, Police Clearance)
/// 4. My Public Profile & Settings
class ServiceProviderDashboardScreen extends StatefulWidget {
  final AuthNotifier? authNotifier;
  final int initialTabIndex;

  const ServiceProviderDashboardScreen({
    super.key,
    this.authNotifier,
    this.initialTabIndex = 0,
  });

  @override
  State<ServiceProviderDashboardScreen> createState() =>
      _ServiceProviderDashboardScreenState();
}

class _ServiceProviderDashboardScreenState
    extends State<ServiceProviderDashboardScreen> {
  late int _currentTabIndex;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _ProviderJobsTab(authNotifier: widget.authNotifier),
          const _ProviderEarningsTab(),
          _ProviderDocumentsTab(authNotifier: widget.authNotifier),
          _ProviderProfileSettingsTab(authNotifier: widget.authNotifier),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentTabIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.work_outline_rounded),
            selectedIcon: Icon(Icons.work_rounded, color: AppColors.secondary),
            label: 'Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(
              Icons.payments_rounded,
              color: AppColors.secondary,
            ),
            label: 'Earnings',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            selectedIcon: Icon(
              Icons.verified_user_rounded,
              color: AppColors.secondary,
            ),
            label: 'Verification',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: AppColors.secondary,
            ),
            label: 'My Profile',
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 1: Jobs & Live Requests
// -------------------------------------------------------------
class _ProviderJobsTab extends StatefulWidget {
  final AuthNotifier? authNotifier;

  const _ProviderJobsTab({this.authNotifier});

  @override
  State<_ProviderJobsTab> createState() => _ProviderJobsTabState();
}

class _ProviderJobsTabState extends State<_ProviderJobsTab> {
  final MockWorkerService _workerService = MockWorkerService();
  WorkerModel? _worker;

  bool _isAvailable = true;
  int _activeJobs = 2;
  int _completedJobs = 18;
  String _jobStatus =
      'pending'; // 'pending', 'accepted', 'completed', 'declined'

  @override
  void initState() {
    super.initState();
    _loadWorker();
  }

  void _loadWorker() async {
    final user = widget.authNotifier?.currentUser;
    WorkerModel? worker;
    if (user != null) {
      worker = await _workerService.getWorkerByUserId(user.uid);
    }
    worker ??= await _workerService.getWorkerById('w_sahiwal_01');

    if (mounted) {
      setState(() {
        _worker = worker;
      });
    }
  }

  void _acceptJob() {
    setState(() {
      _jobStatus = 'accepted';
      _activeJobs++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.success,
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Job Accepted! Customer notified you are on your way.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _declineJob() {
    setState(() => _jobStatus = 'declined');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Job declined. Passed to other corridor workers.'),
      ),
    );
  }

  void _completeJob() {
    setState(() {
      _jobStatus = 'completed';
      _activeJobs--;
      _completedJobs++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.success,
        content: Text('Job marked completed! Earnings updated.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authNotifier?.currentUser;
    final worker = _worker;
    final isPending =
        worker?.verificationStatus == WorkerVerificationStatus.pending;
    final isApproved =
        worker?.verificationStatus == WorkerVerificationStatus.approved;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user != null
                  ? '${user.name} (Service Provider)'
                  : 'Service Provider Dashboard',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              '${worker?.serviceCategory ?? 'Electrician'} • ${worker?.city ?? 'Lahore'}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Text(
                _isAvailable ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isAvailable ? AppColors.success : AppColors.textMuted,
                ),
              ),
              Switch(
                value: _isAvailable,
                onChanged: (v) => setState(() => _isAvailable = v),
                activeThumbColor: AppColors.success,
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppConstants.paddingScreen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compulsory Verification Status Banner
            if (isPending) ...[
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.badgePendingBg,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: AppColors.badgePendingText.withAlpha(60),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.pending_actions_rounded,
                          color: AppColors.badgePendingText,
                        ),
                        const SizedBox(width: AppConstants.spaceM),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verification: Pending Admin Review',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.badgePendingText,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Profile Photo, CNIC Front/Back & Police Clearance submitted.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.badgePendingText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.workerDocumentUpload,
                            arguments: worker,
                          );
                        },
                        icon: const Icon(
                          Icons.document_scanner_rounded,
                          size: 16,
                        ),
                        label: const Text('View Uploaded Documents'),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (isApproved) ...[
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.badgeApprovedBg,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.success.withAlpha(50)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.badgeApprovedText,
                      size: 28,
                    ),
                    SizedBox(width: AppConstants.spaceM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✓ Verified & Police Cleared Provider',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.badgeApprovedText,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Your profile is live across Sahiwal-Lahore corridor!',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.badgeApprovedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.error.withAlpha(60)),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Compulsory Documents Missing',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Upload your Profile Photo, CNIC Front/Back & Police Clearance to start receiving jobs.',
                      style: TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.workerDocumentUpload,
                          arguments: worker,
                        );
                      },
                      child: const Text('Upload 4 Compulsory Documents'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppConstants.spaceL),

            // Performance Metrics
            Row(
              children: [
                Expanded(
                  child: _ProviderStatCard(
                    title: 'Active Jobs',
                    value: '$_activeJobs',
                    icon: Icons.work_outline,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: _ProviderStatCard(
                    title: 'Completed',
                    value: '$_completedJobs',
                    icon: Icons.task_alt,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: _ProviderStatCard(
                    title: 'Rating',
                    value: '${worker?.averageRating ?? 4.9} ★',
                    icon: Icons.star_border,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceL),

            // Incoming Requests Header
            const Text(
              'Incoming Job Requests',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppConstants.spaceS),

            // Interactive Request Card
            if (_jobStatus == 'pending') ...[
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  side: const BorderSide(color: AppColors.cardBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Water Motor & Pipe Leakage',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Rs. 1,000 est.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Customer: Tariq Javed • Civil Lines, Sahiwal (1.8 km)',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.map_rounded, size: 16),
                            label: const Text('Map'),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.mapLocation,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spaceS),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _declineJob,
                              child: const Text('Decline'),
                            ),
                          ),
                          const SizedBox(width: AppConstants.spaceM),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _acceptJob,
                              child: const Text('Accept Job'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_jobStatus == 'accepted') ...[
              Card(
                elevation: 0,
                color: AppColors.badgeApprovedBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  side: BorderSide(color: AppColors.success.withAlpha(50)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Water Motor & Pipe Leakage',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.badgeApprovedText,
                            ),
                          ),
                          Text(
                            'ACCEPTED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.badgeApprovedText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Location: House 12, Civil Lines, Sahiwal',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.badgeApprovedText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _completeJob,
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Mark Completed'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_jobStatus == 'completed') ...[
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified,
                        color: AppColors.success,
                        size: 28,
                      ),
                      const SizedBox(width: AppConstants.spaceM),
                      const Expanded(
                        child: Text(
                          'Job successfully completed & earnings credited.',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _jobStatus = 'pending'),
                        child: const Text('Reset Demo'),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cancel_outlined,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppConstants.spaceM),
                      const Expanded(child: Text('Job request was declined.')),
                      TextButton(
                        onPressed: () => setState(() => _jobStatus = 'pending'),
                        child: const Text('Reset Demo'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppConstants.spaceXL),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 2: Earnings & Performance
// -------------------------------------------------------------
class _ProviderEarningsTab extends StatelessWidget {
  const _ProviderEarningsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings & Payouts')),
      body: ListView(
        padding: AppConstants.paddingScreen,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceL),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Net Earnings',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  'Rs. 24,500',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'This Week: Rs. 6,800',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      'Next Payout: Friday',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceL),

          const Text(
            'Recent Completed Jobs',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppConstants.spaceS),
          _buildEarningTile(
            'Wiring & Switchboard Installation',
            'Rs. 1,500',
            'Today, 2:30 PM',
          ),
          _buildEarningTile('UPS Battery Setup', 'Rs. 1,200', 'Yesterday'),
          _buildEarningTile(
            'Main Breaker Replacement',
            'Rs. 800',
            '11 Oct 2026',
          ),
          _buildEarningTile('Ceiling Fan Repair', 'Rs. 600', '09 Oct 2026'),
        ],
      ),
    );
  }

  Widget _buildEarningTile(String title, String amount, String date) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.arrow_downward_rounded,
          color: AppColors.success,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        subtitle: Text(date, style: const TextStyle(fontSize: 11)),
        trailing: Text(
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 3: Identity & Police Documents (Compulsory 4/4)
// -------------------------------------------------------------
class _ProviderDocumentsTab extends StatelessWidget {
  final AuthNotifier? authNotifier;

  const _ProviderDocumentsTab({this.authNotifier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compulsory Verification Documents')),
      body: ListView(
        padding: AppConstants.paddingScreen,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spaceM),
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(20),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(color: AppColors.secondary.withAlpha(60)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_rounded, color: AppColors.secondary),
                SizedBox(width: AppConstants.spaceM),
                Expanded(
                  child: Text(
                    'As per Punjab Police Safety Policy, all 4 documents must remain active and valid.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceL),

          _buildDocStatusCard(
            title: '1. Profile Photo (Face Image)',
            subtitle: 'Visible to customers on your public profile',
            status: 'Uploaded & Verified ✓',
            isComplete: true,
            icon: Icons.face_rounded,
          ),
          const SizedBox(height: AppConstants.spaceM),

          _buildDocStatusCard(
            title: '2. CNIC Front Side (Shanakhti Card)',
            subtitle: '13-digit national identity card number & photo',
            status: 'Uploaded & Verified ✓',
            isComplete: true,
            icon: Icons.credit_card_rounded,
          ),
          const SizedBox(height: AppConstants.spaceM),

          _buildDocStatusCard(
            title: '3. CNIC Back Side (Pichla Rukh)',
            subtitle: 'Corridor address & issuance stamp',
            status: 'Uploaded & Verified ✓',
            isComplete: true,
            icon: Icons.credit_card_outlined,
          ),
          const SizedBox(height: AppConstants.spaceM),

          _buildDocStatusCard(
            title: '4. Police Clearance Certificate',
            subtitle: 'Punjab Police Khidmat Markaz Character Verification',
            status: 'Uploaded & Verified ✓',
            isComplete: true,
            icon: Icons.local_police_rounded,
          ),
          const SizedBox(height: AppConstants.spaceL),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.workerDocumentUpload);
            },
            icon: const Icon(Icons.cloud_upload_rounded),
            label: const Text('Update / Re-upload Documents'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocStatusCard({
    required String title,
    required String subtitle,
    required String status,
    required bool isComplete,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.secondary, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.badgeApprovedBg,
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          ),
          child: Text(
            status,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.badgeApprovedText,
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 4: My Public Profile & Settings
// -------------------------------------------------------------
class _ProviderProfileSettingsTab extends StatelessWidget {
  final AuthNotifier? authNotifier;

  const _ProviderProfileSettingsTab({this.authNotifier});

  @override
  Widget build(BuildContext context) {
    final user = authNotifier?.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Provider Profile')),
      body: ListView(
        padding: AppConstants.paddingScreen,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.secondary,
                child: Icon(
                  Icons.handyman_rounded,
                  size: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppConstants.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Rashid Ali (Electrician)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.phoneNumber ?? '+92 300 7654321',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.badgeApprovedBg,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusFull,
                        ),
                      ),
                      child: const Text(
                        'Verified & Police Cleared',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.badgeApprovedText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceL),
          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.visibility_outlined,
              color: AppColors.secondary,
            ),
            title: const Text('Preview My Public Profile'),
            subtitle: const Text(
              'See how thousands of customers view your rates & badges',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.workerProfile,
                arguments: 'w_sahiwal_01',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.tune_rounded, color: AppColors.secondary),
            title: const Text('Edit Trade Rates & Skills'),
            subtitle: const Text('Starting from Rs. 800/visit • UPS, Wiring'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.location_city_rounded,
              color: AppColors.secondary,
            ),
            title: const Text('Service Areas Covered'),
            subtitle: const Text('Farid Town, High Street, Scheme 2 (Sahiwal)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.mapLocation);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.swap_horiz_rounded,
              color: AppColors.primary,
            ),
            title: const Text('Switch to Customer Mode'),
            subtitle: const Text('Book other trades and services'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              if (authNotifier != null) {
                await authNotifier!.signInWithDemo(UserRole.customer);
              }
              if (context.mounted) {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.customerDashboard,
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Sign Out',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () async {
              if (authNotifier != null) {
                await authNotifier!.signOut();
              }
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (r) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ProviderStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ProviderStatCard({
    required this.title,
    required this.value,
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppConstants.spaceS),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
