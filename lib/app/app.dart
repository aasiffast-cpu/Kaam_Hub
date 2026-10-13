import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../services/auth_notifier.dart';
import 'routes.dart';
import 'theme.dart';

/// Root Application Widget for KaamHub with reactive authentication state.
class KaamHubApp extends StatefulWidget {
  final AuthNotifier? authNotifier;

  const KaamHubApp({super.key, this.authNotifier});

  @override
  State<KaamHubApp> createState() => _KaamHubAppState();
}

class _KaamHubAppState extends State<KaamHubApp> {
  late final AuthNotifier _authNotifier;

  @override
  void initState() {
    super.initState();
    _authNotifier = widget.authNotifier ?? AuthNotifier();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authNotifier,
      builder: (context, _) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: AppRoutes.initial,
          onGenerateRoute: (settings) =>
              AppRoutes.onGenerateRoute(settings, _authNotifier),
        );
      },
    );
  }
}
