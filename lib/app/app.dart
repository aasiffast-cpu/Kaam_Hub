import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import 'routes.dart';
import 'theme.dart';

/// Root Application Widget for KaamHub.
class KaamHubApp extends StatelessWidget {
  const KaamHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.initial,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
