import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/user_role.dart';
import '../../services/auth_notifier.dart';

/// Dedicated Login screen for returning customers, workers, and administrators.
class LoginScreen extends StatefulWidget {
  final AuthNotifier authNotifier;

  const LoginScreen({super.key, required this.authNotifier});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _usePassword = false;
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final rawPhone = _phoneController.text.trim();
    final formattedPhone = rawPhone.startsWith('0')
        ? '+92 ${rawPhone.substring(1)}'
        : (rawPhone.startsWith('+92') ? rawPhone : '+92 $rawPhone');

    if (_usePassword) {
      // If logging in via password/PIN
      final pass = _passwordController.text.trim();
      if (pass.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please enter your password or PIN.';
        });
        return;
      }
      // Demo password check
      widget.authNotifier.signInWithDemo(UserRole.customer).then((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.customerHome);
      });
      return;
    }

    // Default: Firebase Phone OTP login
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
            'role': UserRole.customer,
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

  void _quickDemoLogin(UserRole role) async {
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
      appBar: AppBar(title: const Text('Account Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.paddingScreen,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.spaceM),

                // Brand Logo & Header
                Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(50),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.handyman_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceM),
                const Text(
                  'Welcome Back to KaamHub',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXS),
                const Text(
                  'Log in to manage bookings, services, and profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXL),

                // Mobile Number Input
                AppTextField(
                  controller: _phoneController,
                  label: 'Registered Mobile Number',
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
                      return 'Please enter your mobile number';
                    }
                    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
                    if (clean.length < 9) {
                      return 'Enter a valid 10 or 11 digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.spaceM),

                if (_usePassword) ...[
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password or PIN',
                    hintText: '••••••••',
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                  ),
                  const SizedBox(height: AppConstants.spaceS),
                ],

                // Login Mode Toggle & Remember Me
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? true),
                          activeColor: AppColors.primary,
                        ),
                        const Text(
                          'Remember Me',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _usePassword = !_usePassword);
                      },
                      child: Text(
                        _usePassword
                            ? 'Sign in with OTP instead'
                            : 'Sign in with Password',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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

                // Primary Login Button
                PrimaryButton(
                  text: _usePassword ? 'Log In' : 'Send Login OTP Code',
                  isLoading: _isLoading,
                  icon: _usePassword ? Icons.login_rounded : Icons.sms_outlined,
                  onPressed: _handleLogin,
                ),

                const SizedBox(height: AppConstants.spaceL),

                // Sign Up Switch Prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.signUp,
                        );
                      },
                      child: const Text(
                        'Sign Up Now',
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
                const Divider(),
                const SizedBox(height: AppConstants.spaceM),

                // Quick One-Tap Testing Accounts
                const Text(
                  'Quick 1-Tap Login (Development Demo):',
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
                      onPressed: () => _quickDemoLogin(UserRole.customer),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.handyman, size: 16),
                      label: const Text('Worker (Rashid)'),
                      onPressed: () => _quickDemoLogin(UserRole.worker),
                    ),
                    ActionChip(
                      avatar: const Icon(
                        Icons.shield,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      label: const Text('Admin (Supervisor)'),
                      onPressed: () => _quickDemoLogin(UserRole.admin),
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
