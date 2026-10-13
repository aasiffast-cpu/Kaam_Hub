import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/worker_model.dart';
import '../../services/mock_worker_service.dart';

/// Individual Public Worker Profile Screen.
///
/// Scalable for thousands of registered service workers.
/// Accessible by any customer/client to review worker credentials,
/// ratings, verified badges, past work photos, and book services.
/// Note: Sensitive CNIC & Police documents remain private and are never exposed here.
class WorkerProfileScreen extends StatefulWidget {
  final String? workerId;
  final WorkerModel? initialWorker;

  const WorkerProfileScreen({super.key, this.workerId, this.initialWorker});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  final MockWorkerService _workerService = MockWorkerService();
  WorkerModel? _worker;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorker();
  }

  void _loadWorker() async {
    if (widget.initialWorker != null) {
      setState(() {
        _worker = widget.initialWorker;
        _isLoading = false;
      });
      return;
    }

    if (widget.workerId != null) {
      final fetched = await _workerService.getWorkerById(widget.workerId!);
      if (mounted) {
        setState(() {
          _worker = fetched;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _showBookingSheet() {
    final worker = _worker;
    if (worker == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String serviceType = worker.subCategories.isNotEmpty
            ? worker.subCategories.first
            : worker.serviceCategory;
        final addressController = TextEditingController(
          text: '${worker.city} (Corridor)',
        );
        final notesController = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Book ${worker.displayName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
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
              Text(
                'Starting rate: Rs. ${worker.startingRate.toInt()} / visit • Verified Provider',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Selected Service Field
              const Text(
                'Service Needed:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: serviceType,
                    isExpanded: true,
                    items:
                        (worker.subCategories.isNotEmpty
                                ? worker.subCategories
                                : [worker.serviceCategory])
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        serviceType = val;
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Address Field
              const Text(
                'Your Location Address:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              const SizedBox(height: 12),

              // Notes
              const Text(
                'Job Description / Problem Notes:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Water motor not starting, urgent repair',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text(
                  'Confirm Booking Request',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.success,
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Booking sent to ${worker.displayName}! Worker has been notified.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageZoom(String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
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
              constraints: const BoxConstraints(maxHeight: 400),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Image not available')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Worker Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final worker = _worker;
    if (worker == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Worker Profile')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_off_outlined,
                size: 64,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: AppConstants.spaceM),
              const Text(
                'Worker Profile Not Found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppConstants.spaceS),
              const Text(
                'This profile might be unpublished or under review.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppConstants.spaceL),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sliver App Bar with Header & Profile Avatar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                worker.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black87)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        if (worker.profileImageUrl.isNotEmpty) {
                          _showImageZoom(
                            worker.profileImageUrl,
                            worker.displayName,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: AppColors.cardBorder,
                          backgroundImage: worker.profileImageUrl.isNotEmpty
                              ? NetworkImage(worker.profileImageUrl)
                              : null,
                          child: worker.profileImageUrl.isEmpty
                              ? const Icon(Icons.person, size: 48)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Profile Body
          SliverToBoxAdapter(
            child: Padding(
              padding: AppConstants.paddingScreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.spaceS),

                  // Name, Category, and Availability
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              worker.displayName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${worker.serviceCategory} • ${worker.experienceYears} Years Experience',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 15,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${worker.city} Corridor Hub',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: worker.isAvailable
                              ? AppColors.badgeApprovedBg
                              : AppColors.badgePendingBg,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusFull,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: worker.isAvailable
                                    ? AppColors.success
                                    : AppColors.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              worker.isAvailable ? 'Available' : 'Busy',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: worker.isAvailable
                                    ? AppColors.badgeApprovedText
                                    : AppColors.badgePendingText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceM),

                  // Trust & Verification Badges Section
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spaceM),
                    decoration: BoxDecoration(
                      color: AppColors.badgeApprovedBg,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      border: Border.all(
                        color: AppColors.success.withAlpha(50),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              color: AppColors.badgeApprovedText,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'KaamHub Trust & Safety Verified',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.badgeApprovedText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildSafetyCheckBadge('✓ NADRA CNIC Verified'),
                            const SizedBox(width: 8),
                            _buildSafetyCheckBadge('✓ Punjab Police Cleared'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Identity, CNIC, and police records verified by KaamHub compliance administration.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.badgeApprovedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceL),

                  // Performance Metrics Summary Bar
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.star_rounded,
                          iconColor: AppColors.accent,
                          value: '${worker.averageRating} ★',
                          label: '${worker.reviewCount} Reviews',
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceS),
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.task_alt_rounded,
                          iconColor: AppColors.primary,
                          value: '${worker.completedJobsCount}',
                          label: 'Jobs Done',
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceS),
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.payments_outlined,
                          iconColor: AppColors.success,
                          value: 'Rs. ${worker.startingRate.toInt()}',
                          label: 'Per Visit',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceL),

                  // Service Areas Chips
                  if (worker.serviceAreas.isNotEmpty) ...[
                    const Text(
                      'Service Areas Covered',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceS),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: worker.serviceAreas.map((area) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusFull,
                            ),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.pin_drop_outlined,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                area,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppConstants.spaceL),
                  ],

                  // Skills & Subcategories
                  if (worker.subCategories.isNotEmpty) ...[
                    const Text(
                      'Specialized Skills & Trade Services',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceS),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: worker.subCategories.map((skill) {
                        return Chip(
                          backgroundColor: AppColors.primary.withAlpha(15),
                          side: BorderSide(
                            color: AppColors.primary.withAlpha(40),
                          ),
                          label: Text(
                            skill,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppConstants.spaceL),
                  ],

                  // Work Photo Portfolio
                  if (worker.workPhotoUrls.isNotEmpty) ...[
                    const Text(
                      'Recent Work Photos',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceS),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: worker.workPhotoUrls.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        itemBuilder: (ctx, index) {
                          final photoUrl = worker.workPhotoUrls[index];
                          return GestureDetector(
                            onTap: () => _showImageZoom(
                              photoUrl,
                              'Work Portfolio ${index + 1}',
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusM,
                              ),
                              child: Image.network(
                                photoUrl,
                                width: 120,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceL),
                  ],

                  // Client Reviews Section
                  const Text(
                    'Customer Ratings & Reviews',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceS),

                  _buildReviewCard(
                    customerName: 'Muhammad Bilal (Okara)',
                    rating: 5,
                    comment: 'Rashid arrived on time and repaired our electrical wiring fault quickly. Very respectful and verified worker.',
                    date: '3 days ago',
                  ),
                  const SizedBox(height: 8),
                  _buildReviewCard(
                    customerName: 'Tariq Javed (Farid Town, Sahiwal)',
                    rating: 5,
                    comment: 'Excellent workmanship! Having police clearance gave my family complete peace of mind.',
                    date: '1 week ago',
                  ),
                  const SizedBox(height: 100), // Spacing for bottom CTA
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Sticky Booking & Direct Call CTA Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Direct calling ${worker.displayName} (${worker.phoneNumber})...',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.call_rounded, color: AppColors.primary),
                label: const Text('Call'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppConstants.spaceM),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showBookingSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: const Text(
                    'Book Service Now',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyCheckBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.badgeApprovedText,
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String customerName,
    required int rating,
    required String comment,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                customerName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: List.generate(
                  rating,
                  (_) => const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
