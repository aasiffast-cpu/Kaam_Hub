import 'package:flutter/material.dart';

/// Layout metrics, animation durations, and collection names for KaamHub.
class AppConstants {
  AppConstants._();

  // Spacing & Padding
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;

  // Border Radii
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusFull = 999.0;

  // Common Edge Insets
  static const EdgeInsets paddingScreen = EdgeInsets.all(spaceM);
  static const EdgeInsets paddingCard = EdgeInsets.all(spaceM);

  // Firestore Collection Names (matching Section 6 of PROJECT_GUIDE.md)
  static const String colUsers = 'users';
  static const String colWorkers = 'workers';
  static const String colServices = 'services';
  static const String colBookings = 'bookings';
  static const String colReviews = 'reviews';
  static const String colComplaints = 'complaints';

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
}
