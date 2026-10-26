import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/routes.dart';
import 'firebase_options.dart';

/// KaamHub app entry point.
/// Tries to init Firebase; falls back to local mock mode if credentials are placeholders.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
    debugPrint('[KaamHub] ✅ Firebase ready');
  } catch (e) {
    debugPrint('[KaamHub] ⚠️ Firebase not configured — running in local mode. $e');
  }

  runApp(KaamHubApp(
    initialRoute: AppRoutes.splash,
    firebaseReady: firebaseReady,
  ));
}
