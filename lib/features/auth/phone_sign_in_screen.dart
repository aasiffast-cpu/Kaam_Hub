import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/user_role.dart';
import '../../services/auth_notifier.dart';

/// Phone number sign-in screen implementing Firebase-compatible OTP initiation.
class PhoneSignInScreen extends StatefulWidget {
  final AuthNotifier authNotifier;

  const PhoneSignInScreen({super.key, required this.authNotifier});

  @override
  State<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  UserRole _selectedRole = UserRole.customer;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleSendOtp() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final rawPhone = _phoneController.text.trim();
    // Normalize Pakistani phone number
    final formattedPhone = rawPhone.startsWith('0')
        ? '+92 ${rawPhone.substring(1)}'
        : (rawPhone.startsWith('+92') ? rawPhone : '+92 $rawPhone');

    widget.authNotifier.sendOtp(
      phoneNumber: formattedPhone,
      onCodeSent: (verificationId) {
        setState(() {
          _isLoading = false;
        });

        Navigator.pushNamed(
          context,
          AppRoutes.otpVerification,
          arguments: {
            'verificationId': verificationId,
            'phoneNumber': formattedPhone,
            'name': _nameController.text.trim(),
            'role': _selectedRole,
          },
        );
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
      },
    );
  }

  void _signInDemo(UserRole role) async {
    setState(() => _isLoading = true);
    await widget.authNotifier.signInWithDemo(role);
    setState(() => _isLoading = false);

    if (!mounted) return;
    switch (role) {
      case UserRole.customer:
        Navigator.pushReplacementNamed(context, AppRoutes.customerHome);
        break;
      case UserRole.worker:
        Navigator.pushReplacementNamed(context, AppRoutes.workerDashboard);
        break;
      case UserRole.admin:
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In with Phone')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.paddingScreen,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.spaceM),
                // Header Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.spaceM),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone_iphone_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceM),
                const Text(
                  'Enter Your Phone Number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXS),
                const Text(
                  'We will send a 6-digit OTP verification code to verify your identity.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXL),

                // Full Name Input
                AppTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'e.g. Ali Raza',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spaceM),

                // Phone Input with +92 prefix
                AppTextField(
                  controller: _phoneController,
                  label: 'Mobile Number',
                  hintText: '0300 1234567',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.centerLeft,
                    width: 70,
                    child: const Text(
                      '🇵🇰 +92',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
                    if (clean.length < 9) {
                      return 'Enter a valid 10 or 11 digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spaceL),

                // Role selection for registration (Admin strictly hidden!)
                const Text(
                  'I am registering as:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceS),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_outline, size: 18),
                            SizedBox(width: 6),
                            Text('Customer'),
                          ],
                        ),
                        selected: _selectedRole == UserRole.customer,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _selectedRole == UserRole.customer
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedRole = UserRole.customer);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceM),
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.construction_outlined, size: 18),
                            SizedBox(width: 6),
                            Text('Service Worker'),
                          ],
                        ),
                        selected: _selectedRole == UserRole.worker,
                        selectedColor: AppColors.secondary,
                        labelStyle: TextStyle(
                          color: _selectedRole == UserRole.worker
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedRole = UserRole.worker);
                          }
                        },
                      ),
                    ),
                  ],
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: AppConstants.spaceM),
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spaceM),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(20),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: AppConstants.spaceXL),
                PrimaryButton(
                  text: 'Send Verification OTP',
                  isLoading: _isLoading,
                  icon: Icons.send_rounded,
                  onPressed: _handleSendOtp,
                ),

                const SizedBox(height: AppConstants.spaceXL),
                const Divider(),
                const SizedBox(height: AppConstants.spaceM),

                // Quick Demo Login Pills (Developer / Reviewer convenience)
                const Text(
                  'Quick 1-Tap Test Accounts (Development Mode):',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceS),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.person, size: 16),
                      label: const Text('Customer (Ahmed)'),
                      onPressed: () => _signInDemo(UserRole.customer),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.handyman, size: 16),
                      label: const Text('Worker (Rashid)'),
                      onPressed: () => _signInDemo(UserRole.worker),
                    ),
                    ActionChip(
                      avatar: const Icon(
                        Icons.shield,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      label: const Text('Admin (Supervisor)'),
                      onPressed: () => _signInDemo(UserRole.admin),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
