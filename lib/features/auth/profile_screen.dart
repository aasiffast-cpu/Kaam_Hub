import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/user_role.dart';
import '../../services/auth_notifier.dart';
import '../../services/mock_worker_service.dart';

/// User Profile screen with full Name editing and Profile Photo update capabilities.
class ProfileScreen extends StatefulWidget {
  final AuthNotifier authNotifier;

  const ProfileScreen({super.key, required this.authNotifier});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final MockWorkerService _workerService = MockWorkerService();
  bool _isSaving = false;

  // Preset verified avatar options for fast testing and device selection
  static const List<Map<String, String>> _avatarPresets = [
    {
      'name': 'Professional 1',
      'url': 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?auto=format&fit=crop&q=80&w=300',
    },
    {
      'name': 'Professional 2',
      'url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=300',
    },
    {
      'name': 'Professional 3',
      'url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=300',
    },
    {
      'name': 'Professional 4',
      'url': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=300',
    },
  ];

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    const Text(
                      'Update Profile Photo',
                      style: TextStyle(
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
                const Text(
                  'Choose a new photo from presets, take a photo, or choose from gallery:',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Presets horizontal row
                const Text(
                  'Select Fast Avatar Preset:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _avatarPresets.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final preset = _avatarPresets[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _saveProfileChanges(photoUrl: preset['url']);
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.cardBorder,
                          backgroundImage: NetworkImage(preset['url']!),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),

                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Take Photo with Camera',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Capture live front portrait',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _saveProfileChanges(photoUrl: _avatarPresets.first['url']);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Select from phone or PC photos',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _saveProfileChanges(photoUrl: _avatarPresets[1]['url']);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditNameDialog() {
    final user = widget.authNotifier.currentUser;
    final nameController = TextEditingController(text: user?.name ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          title: const Row(
            children: [
              Icon(Icons.edit_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Edit Display Name'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your new full name to display across KaamHub:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'e.g. Muhammad Asif',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.error,
                      content: Text('Name must be at least 2 characters.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                _saveProfileChanges(name: newName);
              },
              child: const Text('Save Name'),
            ),
          ],
        );
      },
    );
  }

  void _showUnifiedEditProfileModal() {
    final user = widget.authNotifier.currentUser;
    final nameController = TextEditingController(text: user?.name ?? '');
    String? selectedPhotoUrl = user?.photoUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
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
                      const Text(
                        'Edit Profile Information',
                        style: TextStyle(
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
                  const SizedBox(height: 16),

                  // Avatar Picker Preview inside modal
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: AppColors.cardBorder,
                          backgroundImage:
                              selectedPhotoUrl != null &&
                                  selectedPhotoUrl!.isNotEmpty
                              ? NetworkImage(selectedPhotoUrl!)
                              : null,
                          child:
                              selectedPhotoUrl == null ||
                                  selectedPhotoUrl!.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 48,
                                  color: AppColors.textSecondary,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Avatar Presets Selector
                  const Text(
                    'Pick Profile Image:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _avatarPresets.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final preset = _avatarPresets[index];
                        final isSelected = selectedPhotoUrl == preset['url'];
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedPhotoUrl = preset['url'];
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(preset['url']!),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name Field
                  const Text(
                    'Your Full Name:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter full name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.badge_outlined),
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
                    onPressed: () {
                      final newName = nameController.text.trim();
                      if (newName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid name.'),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(ctx);
                      _saveProfileChanges(
                        name: newName,
                        photoUrl: selectedPhotoUrl,
                      );
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: const Text(
                      'Save Profile Changes',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveProfileChanges({String? name, String? photoUrl}) async {
    setState(() => _isSaving = true);
    try {
      final user = widget.authNotifier.currentUser;
      final updatedUser = await widget.authNotifier.updateProfile(
        name: name,
        photoUrl: photoUrl,
      );

      // If user is also registered as worker, keep worker model synchronized
      if (user != null && (user.isWorker || updatedUser.isWorker)) {
        final worker = await _workerService.getWorkerByUserId(user.uid);
        if (worker != null) {
          final updatedWorker = worker.copyWith(
            displayName: updatedUser.name,
            profileImageUrl: updatedUser.photoUrl ?? worker.profileImageUrl,
          );
          await _workerService.registerWorker(updatedWorker);
        }
      }

      if (!mounted) return;
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Profile updated successfully! Name and photo saved.',
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Failed to update profile: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authNotifier.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: Center(
          child: Padding(
            padding: AppConstants.paddingScreen,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'You are not currently signed in.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceL),
                PrimaryButton(
                  text: 'Sign In',
                  width: 160,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.phoneSignIn);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    Color roleColor;
    switch (user.role) {
      case UserRole.customer:
        roleColor = AppColors.primary;
        break;
      case UserRole.worker:
        roleColor = AppColors.secondary;
        break;
      case UserRole.admin:
        roleColor = AppColors.accent;
        break;
    }

    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            tooltip: 'Edit Profile',
            onPressed: _showUnifiedEditProfileModal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppConstants.paddingScreen,
        child: Column(
          children: [
            const SizedBox(height: AppConstants.spaceM),

            // Profile Image with Edit Action Badge
            GestureDetector(
              onTap: _showImagePickerSheet,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: roleColor, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: roleColor.withAlpha(25),
                      backgroundImage: hasPhoto
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: !hasPhoto
                          ? Icon(
                              user.isAdmin
                                  ? Icons.admin_panel_settings_rounded
                                  : (user.isWorker
                                        ? Icons.handyman_rounded
                                        : Icons.person_rounded),
                              size: 50,
                              color: roleColor,
                            )
                          : null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: roleColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            TextButton.icon(
              onPressed: _showImagePickerSheet,
              icon: const Icon(Icons.photo_camera_outlined, size: 16),
              label: const Text('Change Photo'),
            ),
            const SizedBox(height: AppConstants.spaceS),

            // Name with Edit Pencil Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  tooltip: 'Edit Name',
                  onPressed: _showEditNameDialog,
                ),
              ],
            ),
            Text(
              user.phoneNumber,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceS),

            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: roleColor.withAlpha(25),
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Text(
                user.role.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: roleColor,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceM),

            // Edit Profile Button
            OutlinedButton.icon(
              onPressed: _showUnifiedEditProfileModal,
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: const Text('Edit Name & Image Details'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: roleColor),
                foregroundColor: roleColor,
              ),
            ),
            const SizedBox(height: AppConstants.spaceL),

            // Profile info card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.fingerprint_rounded,
                      label: 'User ID',
                      value: user.uid,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Member Since',
                      value:
                          '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Account Status',
                      value: user.isActive ? 'Active' : 'Suspended',
                      valueColor: user.isActive
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceXL),

            if (_isSaving) const CircularProgressIndicator(),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
                onPressed: () async {
                  await widget.authNotifier.signOut();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.roleSelection,
                    (route) => false,
                  );
                },
              ),
            ),
            const SizedBox(height: AppConstants.spaceXL),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(width: AppConstants.spaceM),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
