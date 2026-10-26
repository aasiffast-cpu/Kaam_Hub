import 'package:flutter/material.dart';

/// Notifier managing current application locale (English and Urdu) and RTL direction.
class LocaleNotifier extends ChangeNotifier {
  static final LocaleNotifier _instance = LocaleNotifier._internal();
  factory LocaleNotifier() => _instance;

  LocaleNotifier._internal();

  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isUrdu => _locale.languageCode == 'ur';
  TextDirection get textDirection =>
      isUrdu ? TextDirection.rtl : TextDirection.ltr;

  void setLocale(Locale newLocale) {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
  }

  void setLanguage(String code) {
    setLocale(Locale(code));
  }

  void toggleLanguage() {
    if (isUrdu) {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('ur'));
    }
  }
}
