import 'package:flutter/material.dart';

import 'app_locale_notifier.dart';

/// Centralized localization dictionary for KaamHub (English and Urdu).
class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final notifier = LocaleNotifier();
    return AppLocalizations(notifier.locale);
  }

  bool get isUrdu => locale.languageCode == 'ur';

  // ── Branding & Taglines ──────────────────────────────────────────────────
  String get appName => isUrdu ? 'کام ہب' : 'KaamHub';
  String get appTagline =>
      isUrdu ? 'قابل بھروسہ مقامی ہنر مند' : 'Verified Local Service Experts';
  String get appSubtitle => isUrdu
      ? 'قابل اعتماد پلمبر، الیکٹریشن اور مستری فوری تلاش اور بک کریں۔'
      : 'Connect with trusted plumbers, electricians, masons & more.';

  // ── Language Selection ───────────────────────────────────────────────────
  String get selectLanguage => isUrdu ? 'زبان منتخب کریں' : 'Select Language';
  String get english => 'English';
  String get urdu => 'اردو';

  // ── User Roles ───────────────────────────────────────────────────────────
  String get roleCustomer => isUrdu ? 'گاہک' : 'Customer';
  String get roleWorker =>
      isUrdu ? 'سروس کاریگر / ہنرمند' : 'Service Provider';
  String get roleAdmin => isUrdu ? 'انتظامیہ' : 'Administrator';

  String get customerRoleDescription => isUrdu
      ? 'گھریلو سروسز تلاش کریں، ریٹس کا موازنہ کریں اور ماہرین بک کریں۔'
      : 'Find, compare, and book verified local service workers.';
  String get workerRoleDescription => isUrdu
      ? 'نئے کام کی درخواستیں وصول کریں اور اپنا روزگار بڑھائیں۔'
      : 'Receive job requests, manage bookings, and grow your work.';
  String get adminRoleDescription => isUrdu
      ? 'درخواستوں کی جانچ، تصدیق اور بکنگز کی نگرانی کریں۔'
      : 'Manage applications, inspect worker verifications, and supervise bookings.';

  // ── Portals & Navigation ─────────────────────────────────────────────────
  String get customerDashboard =>
      isUrdu ? 'گاہک ڈیش بورڈ' : 'Customer Dashboard';
  String get workerDashboard =>
      isUrdu ? 'سروس پرووائیڈر ڈیش بورڈ' : 'Service Provider Dashboard';
  String get adminDashboard => isUrdu ? 'ایڈمن ڈیش بورڈ' : 'Admin Dashboard';

  // ── Auth & Common Actions ────────────────────────────────────────────────
  String get logIn => isUrdu ? 'لاگ اِن' : 'Log In';
  String get signUp => isUrdu ? 'سائن اپ' : 'Sign Up';
  String get signOut => isUrdu ? 'لاگ آؤٹ' : 'Sign Out';
  String get continueText => isUrdu ? 'جاری رکھیں' : 'Continue';
  String get cancel => isUrdu ? 'منسوخ' : 'Cancel';
  String get tryAgain => isUrdu ? 'دوبارہ کوشش کریں' : 'Try Again';
  String get save => isUrdu ? 'محفوظ کریں' : 'Save';
  String get search =>
      isUrdu ? 'سروس یا ہنرمند تلاش کریں...' : 'Search services or workers...';

  // ── Currency & Location ──────────────────────────────────────────────────
  String get currencyPkr => isUrdu ? 'روپے' : 'PKR';
  String get selectCity => isUrdu ? 'شہر منتخب کریں' : 'Select City';
  String get verified => isUrdu ? 'تصدیق شدہ' : 'Verified';

  // ── Service Categories ───────────────────────────────────────────────────
  String get catPlumber => isUrdu ? 'پلمبر' : 'Plumber';
  String get catElectrician => isUrdu ? 'الیکٹریشن' : 'Electrician';
  String get catMistri => isUrdu ? 'مستری / راج' : 'Mistri / Mason';
  String get catCarWasher => isUrdu ? 'کار واشر' : 'Car Washer';
  String get catMechanic => isUrdu ? 'مکینک' : 'Mechanic';
}
