import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_map_picker.dart';
import '../../models/user_role.dart';
import '../../models/worker_model.dart';
import '../../services/auth_notifier.dart';
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
          const _CustomerBookingsTab(),
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
  final TextEditingController _searchController = TextEditingController();

  int _selectedCategoryIndex = 0;
  String _currentServiceArea = 'Farid Town, Sahiwal';
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
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
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
                          Icons.map_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Service Location (Sahiwal ➔ Lahore)',
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
// TAB 2: Customer Bookings & Order History
// -------------------------------------------------------------
class _CustomerBookingsTab extends StatelessWidget {
  const _CustomerBookingsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings & Orders')),
      body: ListView(
        padding: AppConstants.paddingScreen,
        children: [
          // Active Booking Card
          const Text(
            'Active Service Request',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppConstants.spaceS),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              side: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text(
                            'UPS & Wiring Repair',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.badgeApprovedBg,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusFull,
                          ),
                        ),
                        child: const Text(
                          'ON THE WAY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.badgeApprovedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Assigned Provider: Rashid Ali (Electrician • Verified & Police Cleared)',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Address: House 24, Street 3, Farid Town, Sahiwal',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppConstants.spaceM),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Calling Rashid Ali (+92 300 7654321)...',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.call, size: 16),
                          label: const Text('Call Worker'),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceM),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.mapLocation);
                          },
                          icon: const Icon(Icons.map_rounded, size: 16),
                          label: const Text('Track on Map'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceL),

          // Completed Past Bookings
          const Text(
            'Past Completed Services',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppConstants.spaceS),
          _buildPastBookingTile(
            serviceName: 'Tap Leakage & Tank Inspection',
            providerName: 'Muhammad Usman (Plumber)',
            date: '10 Oct 2026',
            cost: 'Rs. 1,000',
            rating: '5 ★',
          ),
          const SizedBox(height: AppConstants.spaceS),
          _buildPastBookingTile(
            serviceName: 'Car Wash & Interior Polish',
            providerName: 'Hamza Bilal (Car Washer)',
            date: '28 Sep 2026',
            cost: 'Rs. 900',
            rating: '4.8 ★',
          ),
        ],
      ),
    );
  }

  Widget _buildPastBookingTile({
    required String serviceName,
    required String providerName,
    required String date,
    required String cost,
    required String rating,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.success.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
          ),
        ),
        title: Text(
          serviceName,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          '$providerName • $date',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              cost,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            Text(
              rating,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
      body: const AppMapPicker(
        initialCityId: 'sahiwal',
      ),
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
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 40, color: Colors.white),
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
          const SizedBox(height: AppConstants.spaceL),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
            ),
            title: const Text('Saved Corridor Addresses'),
            subtitle: const Text('Farid Town Sahiwal, Gulberg Lahore'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.mapLocation);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.payment_outlined,
              color: AppColors.primary,
            ),
            title: const Text('Payment Methods'),
            subtitle: const Text('Cash on Delivery, JazzCash, Easypaisa'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.security_outlined,
              color: AppColors.primary,
            ),
            title: const Text('Safety & Police Verification Guarantee'),
            subtitle: const Text('Punjab Police Khidmat Markaz Checked'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
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
