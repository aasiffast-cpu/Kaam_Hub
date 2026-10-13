import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/user_role.dart';
import '../../services/auth_notifier.dart';

/// 6-digit OTP verification screen with countdown and role-aware redirection.
class OtpVerificationScreen extends StatefulWidget {
  final AuthNotifier authNotifier;
  final String verificationId;
  final String phoneNumber;
  final String? name;
  final UserRole initialRole;

  const OtpVerificationScreen({
    super.key,
    required this.authNotifier,
    required this.verificationId,
    required this.phoneNumber,
    this.name,
    this.initialRole = UserRole.customer,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  int _resendCountdown = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _resendCountdown = 45;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Please enter a 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await widget.authNotifier.verifyOtp(
        verificationId: widget.verificationId,
        smsCode: code,
        defaultName: widget.name,
        initialRole: widget.initialRole,
      );

      if (!mounted) return;

      // Role-Aware Navigation Redirection
      String targetRoute;
      switch (user?.role ?? widget.initialRole) {
        case UserRole.customer:
          targetRoute = AppRoutes.customerHome;
          break;
        case UserRole.worker:
          targetRoute = AppRoutes.workerDocumentUpload;
          break;
        case UserRole.admin:
          targetRoute = AppRoutes.adminDashboard;
          break;
      }

      Navigator.pushNamedAndRemoveUntil(context, targetRoute, (r) => false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e
            .toString()
            .replaceAll('Exception: ', '')
            .replaceAll('AppException: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.spaceM),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_rounded,
                    size: 40,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceM),
              const Text(
                'Enter Verification Code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXS),
              Text(
                'We sent a 6-digit code to ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),

              // Demo Helper Card
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.accent.withAlpha(60)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.accent),
                    SizedBox(width: AppConstants.spaceM),
                    Expanded(
                      child: Text(
                        'Demo Mode: Enter OTP code 123456 to verify and sign in.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spaceXL),

              // 6-Digit OTP Text Field
              AppTextField(
                controller: _otpController,
                hintText: '• • • • • •',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.pin_outlined),
                onChanged: (val) {
                  if (val.length == 6) {
                    _handleVerify();
                  }
                },
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
                text: 'Verify & Sign In',
                isLoading: _isLoading,
                icon: Icons.check_circle_outline_rounded,
                onPressed: _handleVerify,
              ),

              const SizedBox(height: AppConstants.spaceL),
              Center(
                child: _resendCountdown > 0
                    ? Text(
                        'Resend code in $_resendCountdown seconds',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          _startCountdown();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'A new OTP has been sent (123456).',
                              ),
                            ),
                          );
                        },
                        child: const Text('Resend Code'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
