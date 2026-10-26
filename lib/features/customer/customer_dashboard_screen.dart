import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_map_picker.dart';
import '../../models/service_request_model.dart';
import '../../models/user_role.dart';
import '../../models/worker_model.dart';
import '../../services/auth_notifier.dart';
import '../../services/location_service.dart';
import '../../services/mock_request_service.dart';
import '../../services/mock_worker_service.dart';

/// Full Customer Dashboard widget featuring bottom navigation with 4 tabs:
/// 1. Home / Explore Services
/// 2. My Bookings & Orders
/// 3. Corridor Street Map
/// 4. Customer Account & Settings
class CustomerDashboardScreen extends StatefulWidget {
  final AuthNotifier? authNotifier;
  final int initialTabIndex;

  const CustomerDashboardScreen({
    super.key,
    this.authNotifier,
    this.initialTabIndex = 0,
  });

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
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
          _CustomerExploreTab(authNotifier: widget.authNotifier),
          _CustomerBookingsTab(authNotifier: widget.authNotifier),
          const _CustomerMapTab(),
          _CustomerAccountTab(authNotifier: widget.authNotifier),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded, color: AppColors.primary),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primary,
            ),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded, color: AppColors.primary),
            label: 'Corridor Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 1: Explore & Browse Verified Workers
// -------------------------------------------------------------
class _CustomerExploreTab extends StatefulWidget {
  final AuthNotifier? authNotifier;

  const _CustomerExploreTab({this.authNotifier});

  @override
  State<_CustomerExploreTab> createState() => _CustomerExploreTabState();
}

class _CustomerExploreTabState extends State<_CustomerExploreTab> {
  final MockWorkerService _workerService = MockWorkerService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  int _selectedCategoryIndex = 0;
  late String _currentServiceArea;
  String _searchQuery = '';

  List<WorkerModel> _allWorkers = [];
  bool _isLoadingWorkers = true;

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'All Trades',
      'subtitle': 'Browse all verified service workers along the corridor',
      'icon': Icons.handyman_rounded,
    },
    {
      'title': AppStrings.catPlumber,
      'subtitle': AppStrings.catPlumberDesc,
      'icon': Icons.plumbing_rounded,
    },
    {
      'title': AppStrings.catElectrician,
      'subtitle': AppStrings.catElectricianDesc,
      'icon': Icons.bolt_rounded,
    },
    {
      'title': AppStrings.catMistri,
      'subtitle': AppStrings.catMistriDesc,
      'icon': Icons.foundation_rounded,
    },
    {
      'title': AppStrings.catCarWasher,
      'subtitle': AppStrings.catCarWasherDesc,
      'icon': Icons.local_car_wash_rounded,
    },
    {
      'title': AppStrings.catMechanic,
      'subtitle': AppStrings.catMechanicDesc,
      'icon': Icons.car_repair_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchWorkers();
    _currentServiceArea = _locationService.streetAddress;
    _locationService.addListener(_onLocationUpdated);
    _locationService.autoDetectLocation(requestIfDenied: false);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _onLocationUpdated() {
    if (mounted) {
      setState(() {
        _currentServiceArea = _locationService.streetAddress;
      });
    }
  }

  @override
  void dispose() {
    _locationService.removeListener(_onLocationUpdated);
    _searchController.dispose();
    super.dispose();
  }

  void _fetchWorkers() async {
    setState(() => _isLoadingWorkers = true);
    final workers = await _workerService.getApprovedWorkers();
    if (mounted) {
      setState(() {
        _allWorkers = workers;
        _isLoadingWorkers = false;
      });
    }
  }

  List<WorkerModel> get _filteredWorkers {
    return _allWorkers.where((worker) {
      if (_selectedCategoryIndex > 0) {
        final categoryTitle =
            _categories[_selectedCategoryIndex]['title'] as String;
        if (worker.serviceCategory.toLowerCase() !=
            categoryTitle.toLowerCase()) {
          return false;
        }
      }

      if (_searchQuery.isNotEmpty) {
        final matchesName = worker.displayName.toLowerCase().contains(
          _searchQuery,
        );
        final matchesCategory = worker.serviceCategory.toLowerCase().contains(
          _searchQuery,
        );
        final matchesCity = worker.city.toLowerCase().contains(_searchQuery);
        final matchesSubcategory = worker.subCategories.any(
          (s) => s.toLowerCase().contains(_searchQuery),
        );
        if (!matchesName &&
            !matchesCategory &&
            !matchesCity &&
            !matchesSubcategory) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authNotifier?.currentUser;
    final workers = _filteredWorkers;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user != null
                  ? 'Hello, ${user.name}'
                  : 'KaamHub Customer Dashboard',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const Text(
              'Sahiwal ➔ Lahore • Police Cleared Workers',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Account Profile',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchWorkers(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppConstants.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input Field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search worker name, skill, or corridor city...',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceM),

              // Corridor City & Map Location Bar
              InkWell(
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.mapLocation,
                  );
                  if (result != null && result is Map) {
                    setState(() {
                      _currentServiceArea = result['address'] as String;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(color: AppColors.primary.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_locationService.isAutoDetected ? 'Auto-Detected GPS Location (Pakistan)' : 'Service Location (Tap to change on Map)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _currentServiceArea,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),

              // Category Section Title
              const Text(
                'Browse by Trade / Service',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceS),

              // Categories horizontal list
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategoryIndex == index;
                    return ChoiceChip(
                      label: Text(cat['title'] as String),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppConstants.spaceM),

              // Active Category Description Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      _categories[_selectedCategoryIndex]['icon'] as IconData,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _categories[_selectedCategoryIndex]['subtitle']
                            as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),

              // Workers Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Verified Workers (${workers.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (_selectedCategoryIndex > 0 || _searchQuery.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategoryIndex = 0;
                          _searchController.clear();
                        });
                      },
                      child: const Text(
                        'Show All',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceS),

              // Workers List
              if (_isLoadingWorkers)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (workers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No Workers Found',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Try choosing another trade category or clearing your search.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategoryIndex = 0;
                            _searchController.clear();
                          });
                        },
                        child: const Text('View All Corridor Workers'),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: workers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppConstants.spaceM),
                  itemBuilder: (context, index) {
                    final worker = workers[index];
                    return _buildWorkerCard(worker);
                  },
                ),
              const SizedBox(height: AppConstants.spaceXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerCard(WorkerModel worker) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.workerProfile,
            arguments: worker,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: worker.profileImageUrl.isNotEmpty
                        ? Image.network(
                            worker.profileImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.person_rounded,
                                  size: 36,
                                  color: AppColors.textSecondary,
                                ),
                          )
                        : const Icon(
                            Icons.person_rounded,
                            size: 36,
                            color: AppColors.textSecondary,
                          ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                worker.displayName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.badgeApprovedBg,
                                borderRadius: BorderRadius.circular(
                                  AppConstants.radiusFull,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    size: 13,
                                    color: AppColors.badgeApprovedText,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.badgeApprovedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${worker.serviceCategory} • ${worker.experienceYears} Years Exp',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              worker.city,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceM),

              if (worker.subCategories.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: worker.subCategories.take(3).map((sub) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        sub,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppConstants.spaceM),
              ],

              const Divider(height: 1),
              const SizedBox(height: AppConstants.spaceS),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${worker.averageRating} (${worker.reviewCount})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'From Rs. ${worker.startingRate.toInt()}/visit',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const Row(
                    children: [
                      Text(
                        'View Profile',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 2: Customer Bookings & Order History (live data)
// -------------------------------------------------------------
class _CustomerBookingsTab extends StatefulWidget {
  final AuthNotifier? authNotifier;
  const _CustomerBookingsTab({this.authNotifier});

  @override
  State<_CustomerBookingsTab> createState() => _CustomerBookingsTabState();
}

class _CustomerBookingsTabState extends State<_CustomerBookingsTab> {
  final MockRequestService _requestService = MockRequestService();
  List<ServiceRequestModel> _requests = [];
  bool _isLoading = true;

  String get _userId =>
      widget.authNotifier?.currentUser?.uid ?? 'customer_demo_001';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final reqs = await _requestService.getRequestsForCustomer(_userId);
    if (mounted) {
      setState(() {
        _requests = reqs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final active =
        _requests.where((r) => r.status.isActive).toList();
    final completed = _requests
        .where((r) => r.status == ServiceRequestStatus.completed)
        .toList();
    final others = _requests
        .where((r) =>
            r.status == ServiceRequestStatus.cancelled ||
            r.status == ServiceRequestStatus.disputed)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings & Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadRequests,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.createRequest,
              arguments: <String, dynamic>{});
          _loadRequests();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Request'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRequests,
              child: _requests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.work_outline_rounded,
                              size: 56, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          const Text('No service requests yet',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap the button below to create your first service request.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.pushNamed(
                                  context, AppRoutes.createRequest,
                                  arguments: <String, dynamic>{});
                              _loadRequests();
                            },
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Create Service Request'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: AppConstants.paddingScreen,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        if (active.isNotEmpty) ...[
                          _SectionHeader(
                              title: 'Active Requests (${active.length})'),
                          ...active.map((r) => _RequestCard(
                              request: r,
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  AppRoutes.requestDetail,
                                  arguments: {
                                    'requestId': r.id,
                                    'isWorkerView': false,
                                  },
                                );
                                _loadRequests();
                              })),
                          const SizedBox(height: AppConstants.spaceM),
                        ],
                        if (completed.isNotEmpty) ...[
                          _SectionHeader(
                              title:
                                  'Completed (${completed.length})'),
                          ...completed.map((r) => _RequestCard(
                              request: r,
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  AppRoutes.requestDetail,
                                  arguments: {
                                    'requestId': r.id,
                                    'isWorkerView': false,
                                  },
                                );
                                _loadRequests();
                              })),
                          const SizedBox(height: AppConstants.spaceM),
                        ],
                        if (others.isNotEmpty) ...[
                          _SectionHeader(
                              title: 'Cancelled / Disputed'),
                          ...others.map((r) => _RequestCard(
                              request: r,
                              onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.requestDetail,
                                    arguments: {
                                      'requestId': r.id,
                                      'isWorkerView': false,
                                    },
                                  ))),
                        ],
                        const SizedBox(height: 80),
                      ],
                    ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spaceS),
      child: Text(title,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w800)),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ServiceRequestModel request;
  final VoidCallback onTap;

  const _RequestCard({required this.request, required this.onTap});

  Color get _statusColor {
    switch (request.status) {
      case ServiceRequestStatus.completed:
        return AppColors.success;
      case ServiceRequestStatus.cancelled:
        return AppColors.error;
      case ServiceRequestStatus.disputed:
        return AppColors.warning;
      case ServiceRequestStatus.inProgress:
        return AppColors.info;
      case ServiceRequestStatus.accepted:
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          side: BorderSide(color: _statusColor.withAlpha(60), width: 1.2),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spaceM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(request.serviceCategory,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(
                            AppConstants.radiusFull),
                      ),
                      child: Text(request.status.displayName,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(request.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 13, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(request.serviceAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    ),
                  ],
                ),
                if (request.workerName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.engineering_rounded,
                          size: 13, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(request.workerName!,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ],
                if (request.quotedAmount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${request.quotedAmount!.toInt()}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 3: Corridor Street Map Tab
// -------------------------------------------------------------
class _CustomerMapTab extends StatelessWidget {
  const _CustomerMapTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Corridor Live Map Explorer')),
      body: const AppMapPicker(autoDetectOnOpen: true),
    );
  }
}

// -------------------------------------------------------------
// TAB 4: Customer Account Tab
// -------------------------------------------------------------
class _CustomerAccountTab extends StatelessWidget {
  final AuthNotifier? authNotifier;

  const _CustomerAccountTab({this.authNotifier});

  @override
  Widget build(BuildContext context) {
    final user = authNotifier?.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Account')),
      body: ListView(
        padding: AppConstants.paddingScreen,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary,
                backgroundImage:
                    user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user?.photoUrl == null || user!.photoUrl!.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: AppConstants.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Customer User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.phoneNumber ?? '+92 300 1234567',
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
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusFull,
                        ),
                      ),
                      child: const Text(
                        'Verified Customer',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceM),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            icon: const Icon(Icons.edit_note_rounded, size: 18),
            label: const Text('Edit Profile Details'),
          ),
          const SizedBox(height: AppConstants.spaceL),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline_rounded,
                color: AppColors.primary),
            title: const Text('Messages'),
            subtitle: const Text('Chat with service providers'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.chatList),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined,
                color: AppColors.primary),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.notifications),
          ),
          ListTile(
            leading: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
            ),
            title: const Text('Saved Addresses'),
            subtitle: const Text('Farid Town Sahiwal, Gulberg Lahore'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.mapLocation);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded,
                color: AppColors.primary),
            title: const Text('Help Center & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.helpCenter),
          ),
          ListTile(
            leading: const Icon(
              Icons.security_outlined,
              color: AppColors.primary,
            ),
            title: const Text('Safety & Verification Info'),
            subtitle: const Text('Punjab Police Khidmat Markaz Checked'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.helpCenter),
          ),
          ListTile(
            leading: const Icon(
              Icons.swap_horiz_rounded,
              color: AppColors.secondary,
            ),
            title: const Text('Switch to Service Worker Portal'),
            subtitle: const Text('Offer your trade services and get jobs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              if (authNotifier != null) {
                await authNotifier!.signInWithDemo(UserRole.worker);
              }
              if (context.mounted) {
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.workerDashboard,
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

