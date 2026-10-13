import 'package:flutter/material.dart';

/// Centralized color palette for the KaamHub application.
/// Provides consistent brand colors, neutral tones, and semantic state colors.
class AppColors {
  AppColors._();

  // Primary Brand Colors (Trustworthy, reliable blue)
  static const Color primary = Color(0xFF1E40AF); // Deep Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E3A8A);

  // Secondary Accent Colors (Growth, safety green)
  static const Color secondary = Color(0xFF0D9488); // Teal
  static const Color secondaryLight = Color(0xFF14B8A6);

  // Accent / Warning (Amber/Gold)
  static const Color accent = Color(0xFFF59E0B);

  // Neutral Colors (Backgrounds, surfaces, borders)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Semantic Feedback Colors
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF2563EB);

  // Status Badge Colors
  static const Color badgePendingBg = Color(0xFFFEF3C7);
  static const Color badgePendingText = Color(0xFF92400E);
  static const Color badgeApprovedBg = Color(0xFFDCFCE7);
  static const Color badgeApprovedText = Color(0xFF166534);
  static const Color badgeRejectedBg = Color(0xFFFEE2E2);
  static const Color badgeRejectedText = Color(0xFF991B1B);
}
