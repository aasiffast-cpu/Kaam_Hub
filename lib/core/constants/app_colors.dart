import 'package:flutter/material.dart';

/// Centralized color palette for KaamHub.
/// Designed for a premium, trustworthy Pakistani services brand:
/// Deep forest green / emerald primary, warm off-white backgrounds,
/// dark readable text, and a restrained amber accent.
class AppColors {
  AppColors._();

  // Primary Brand Colors (Deep Forest Green / Emerald)
  static const Color primary = Color(0xFF0F5132); // Deep Forest Green
  static const Color primaryLight = Color(0xFF198754); // Emerald Green
  static const Color primaryDark = Color(0xFF0A3622); // Deepest Pine

  // Secondary Accent Colors (Leaf Green / Mint)
  static const Color secondary = Color(0xFF137547); // Refined Green
  static const Color secondaryLight = Color(0xFF2E8B57); // Sea Green

  // Accent (Restrained Warm Amber / Gold)
  static const Color accent = Color(0xFFD97706); // Warm Amber
  static const Color accentLight = Color(0xFFF59E0B); // Amber Accent

  // Neutral Colors (Warm off-white background, crisp surface, warm borders)
  static const Color background = Color(0xFFF9FAF8); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);

  // Typography Colors
  static const Color textPrimary = Color(0xFF111827); // Dark readable charcoal
  static const Color textSecondary = Color(0xFF4B5563); // Readable slate
  static const Color textMuted = Color(0xFF9CA3AF); // Muted grey

  // Semantic Feedback Colors
  static const Color success = Color(0xFF10B981); // Emerald success
  static const Color error = Color(0xFFDC2626); // Crimson error
  static const Color warning = Color(0xFFD97706); // Amber warning
  static const Color info = Color(0xFF0284C7); // Sky blue info

  // Status Badge Colors
  static const Color badgePendingBg = Color(0xFFFEF3C7);
  static const Color badgePendingText = Color(0xFF92400E);
  static const Color badgeApprovedBg = Color(0xFFDCFCE7);
  static const Color badgeApprovedText = Color(0xFF166534);
  static const Color badgeRejectedBg = Color(0xFFFEE2E2);
  static const Color badgeRejectedText = Color(0xFF991B1B);
}
