import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/city_location.dart';
import '../../models/user_role.dart';
import '../../services/auth_notifier.dart';

/// Dedicated Sign-Up / Registration screen for new Customers and Service Workers.
class SignUpScreen extends StatefulWidget {
  final AuthNotifier authNotifier;

  const SignUpScreen({super.key, required this.authNotifier});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  UserRole _selectedRole = UserRole.customer;
  String _selectedCity = 'Sahiwal';
  String _selectedCategory = AppStrings.catPlumber;
  int _experienceYears = 3;
  bool _agreedToTerms = true;

  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _serviceCategories = [
    AppStrings.catPlumber,
    AppStrings.catElectrician,
    AppStrings.catMistri,
    AppStrings.catCarWasher,
    AppStrings.catMechanic,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      setState(() {
        _errorMessage =
            'Please accept the Terms of Service to create an account.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final rawPhone = _phoneController.text.trim();
    final formattedPhone = rawPhone.startsWith('0')
        ? '+92 ${rawPhone.substring(1)}'
        : (rawPhone.startsWith('+92') ? rawPhone : '+92 $rawPhone');

    widget.authNotifier.sendOtp(
      phoneNumber: formattedPhone,
      onCodeSent: (verificationId) {
        setState(() => _isLoading = false);
        Navigator.pushNamed(
          context,
          AppRoutes.otpVerification,
          arguments: {
            'verificationId': verificationId,
            'phoneNumber': formattedPhone,
            'name': _nameController.text.trim(),
            'role': _selectedRole,
            'city': _selectedCity,
            'serviceCategory': _selectedRole == UserRole.worker
                ? _selectedCategory
                : null,
            'experienceYears': _selectedRole == UserRole.worker
                ? _experienceYears
                : null,
          },
        );
      },
      onError: (err) {
        setState(() {
          _isLoading = false;
          _errorMessage = err;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.paddingScreen,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.spaceS),

                const Text(
                  'Join KaamHub Marketplace',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXS),
                const Text(
                  'Book verified local workers or offer your trade services across the Sahiwal to Lahore corridor.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceL),

                // 1. Account Role Picker
                const Text(
                  'Choose Your Account Type:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
                          fontWeight: FontWeight.w700,
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
                          fontWeight: FontWeight.w700,
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
                const SizedBox(height: AppConstants.spaceL),

                // 2. Full Name
                AppTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'e.g. Muhammad Ali',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spaceM),

                // 3. Mobile Number
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
                const SizedBox(height: AppConstants.spaceM),

                // 4. City Selector (Sahiwal to Lahore corridor)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'City / Region',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceXS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceM,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusM,
                        ),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCity,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: CorridorCities.all.map((c) {
                            return DropdownMenuItem<String>(
                              value: c.name,
                              child: Text('${c.name} (${c.district})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCity = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceM),

                // 5. Worker Specific Fields
                if (_selectedRole == UserRole.worker) ...[
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spaceM),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(15),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      border: Border.all(
                        color: AppColors.secondary.withAlpha(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.handyman,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Worker Professional Details:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spaceM),

                        // Service Category
                        const Text(
                          'Primary Trade / Service:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spaceM,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusM,
                            ),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              items: _serviceCategories.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(cat),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedCategory = val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spaceM),

                        // Experience Slider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Experience:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$_experienceYears Years',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _experienceYears.toDouble(),
                          min: 1,
                          max: 25,
                          divisions: 24,
                          activeColor: AppColors.secondary,
                          onChanged: (v) =>
                              setState(() => _experienceYears = v.round()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceM),
                ],

                // 6. Terms Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (v) =>
                          setState(() => _agreedToTerms = v ?? true),
                      activeColor: AppColors.primary,
                    ),
                    const Expanded(
                      child: Text(
                        'I agree to KaamHub Terms of Service, Privacy Policy & Verification Standards.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: AppConstants.spaceS),
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

                const SizedBox(height: AppConstants.spaceL),

                // Register Button
                PrimaryButton(
                  text: 'Register & Send OTP',
                  isLoading: _isLoading,
                  icon: Icons.person_add_rounded,
                  onPressed: _handleSignUp,
                ),

                const SizedBox(height: AppConstants.spaceL),

                // Switch to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        );
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
