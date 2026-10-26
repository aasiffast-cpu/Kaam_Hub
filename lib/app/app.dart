import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/localization/app_locale_notifier.dart';
import '../services/auth_notifier.dart';
import '../services/mock_auth_service.dart';
import 'routes.dart';
import 'theme.dart';

/// Root Application Widget for KaamHub with reactive authentication and localization state.
class KaamHubApp extends StatefulWidget {
  final AuthNotifier? authNotifier;
  final LocaleNotifier? localeNotifier;
  final String? initialRoute;

  /// Whether Firebase was successfully initialised.
  /// When true, Firestore / Firebase Auth services are used.
  /// When false, in-memory mock services are used (no fake seeded data).
  final bool firebaseReady;

  const KaamHubApp({
    super.key,
    this.authNotifier,
    this.localeNotifier,
    this.initialRoute,
    this.firebaseReady = false,
  });

  @override
  State<KaamHubApp> createState() => _KaamHubAppState();
}

class _KaamHubAppState extends State<KaamHubApp> {
  late final AuthNotifier _authNotifier;
  late final LocaleNotifier _localeNotifier;

  @override
  void initState() {
    super.initState();
    _authNotifier =
        widget.authNotifier ?? AuthNotifier(authService: MockAuthService());
    _localeNotifier = widget.localeNotifier ?? LocaleNotifier();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_authNotifier, _localeNotifier]),
      builder: (context, _) {
        return Directionality(
          textDirection: _localeNotifier.textDirection,
          child: MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: _localeNotifier.locale,
            initialRoute: widget.initialRoute ?? AppRoutes.initial,
            onGenerateRoute: (settings) =>
                AppRoutes.onGenerateRoute(settings, _authNotifier),
          ),
        );
      },
    );
  }
}
