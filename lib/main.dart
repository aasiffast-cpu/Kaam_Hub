import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KaamHubApp(initialRoute: AppRoutes.splash));
}
