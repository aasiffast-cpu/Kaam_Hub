import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../models/user_role.dart';

/// Admin screen showing all registered users with activate/deactivate controls.
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  // Use seeded mock users — in production this queries the users collection
  final List<UserModel> _users = [
    UserModel(
      uid: 'customer_demo_001',
      name: 'Ali Hassan',
      phoneNumber: '+92 300 1234567',
      role: UserRole.customer,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      isActive: true,
    ),
    UserModel(
      uid: 'customer_demo_002',
      name: 'Sara Fatima',
      phoneNumber: '+92 321 9876543',
      role: UserRole.customer,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isActive: true,
    ),
    UserModel(
      uid: 'worker_demo_001',
      name: 'Muhammad Usman',
      phoneNumber: '+92 333 1112233',
      role: UserRole.worker,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      isActive: true,
    ),
    UserModel(
      uid: 'worker_demo_002',
      name: 'Tariq Mehmood',
      phoneNumber: '+92 345 4445566',
      role: UserRole.worker,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      isActive: true,
    ),
    UserModel(
      uid: 'admin_demo_001',
      name: 'Admin User',
      phoneNumber: '+92 300 0000001',
      role: UserRole.admin,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      isActive: true,
    ),
  ];

  String _searchQuery = '';
  String _filterRole = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery) ||
          user.phoneNumber.contains(_searchQuery);
      final matchesRole = _filterRole == 'All' ||
          user.role.displayName == _filterRole;
      return matchesSearch && matchesRole;
    }).toList();
  }

  void _toggleUserStatus(UserModel user) {
    final index = _users.indexWhere((u) => u.uid == user.uid);
    if (index != -1) {
      setState(() {
        _users[index] = _users[index].copyWith(isActive: !user.isActive);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: user.isActive ? AppColors.error : AppColors.success,
          content: Text(
            user.isActive
                ? '${user.name} deactivated. They can no longer log in.'
                : '${user.name} reactivated.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredUsers;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: Column(
        children: [
          // Search + Filter bar
          Padding(
            padding: AppConstants.paddingScreen,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textMuted),
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Customer', 'Service Worker', 'Administrator']
                        .map((role) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(role),
                                selected: _filterRole == role,
                                onSelected: (_) =>
                                    setState(() => _filterRole = role),
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: _filterRole == role
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          // Users count
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceM),
            child: Row(
              children: [
                Text('${filtered.length} users',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No users found.'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceM),
                    itemCount: filtered.length,
                    separatorBuilder: (_, r) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = filtered[index];
                      return _UserTile(
                          user: user, onToggle: () => _toggleUserStatus(user));
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onToggle;

  const _UserTile({required this.user, required this.onToggle});

  Color get _roleColor {
    switch (user.role) {
      case UserRole.admin:
        return AppColors.accent;
      case UserRole.worker:
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceM),
      decoration: BoxDecoration(
        color: user.isActive ? AppColors.surface : AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
            color: user.isActive
                ? AppColors.cardBorder
                : AppColors.error.withAlpha(60)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _roleColor.withAlpha(25),
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _roleColor),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _roleColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(
                            AppConstants.radiusFull),
                      ),
                      child: Text(user.role.displayName,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _roleColor)),
                    ),
                  ],
                ),
                Text(user.phoneNumber,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                if (!user.isActive)
                  const Text('DEACTIVATED',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.error,
                          fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          if (user.role != UserRole.admin)
            Switch(
              value: user.isActive,
              onChanged: (_) => onToggle(),
              activeThumbColor: AppColors.success,
            ),
        ],
      ),
    );
  }
}
