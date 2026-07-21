import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/constants/app_strings.dart';
import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/firebase_error_screen.dart';
import 'core/widgets/loading_screen.dart';
import 'demo/demo_mode_controller.dart';
import 'features/demo/screens/demo_dashboard_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (const bool.fromEnvironment('DEMO_MODE')) {
    runApp(const ParkAlertDemoApp());
    return;
  }
  runApp(const FirebaseInitCheck());
}

class ParkAlertDemoApp extends StatelessWidget {
  const ParkAlertDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DemoModeController(),
      child: MaterialApp(
        title: '${AppStrings.appTitle} Demo',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const DemoDashboardScreen(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}

class FirebaseInitCheck extends StatefulWidget {
  const FirebaseInitCheck({super.key});

  @override
  State<FirebaseInitCheck> createState() => _FirebaseInitCheckState();
}

class _FirebaseInitCheckState extends State<FirebaseInitCheck> {
  late final Future<FirebaseApp> _initialization;
  bool _crashlyticsConfigured = false;

  @override
  void initState() {
    super.initState();
    _initialization = Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  void _configureCrashlytics() {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    ui.PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: LoadingScreen(message: AppStrings.firebaseInitializing),
          );
        }
        if (snapshot.hasError) {
          return MaterialApp(
            home: FirebaseInitErrorScreen(error: snapshot.error),
          );
        }
        if (!_crashlyticsConfigured) {
          _configureCrashlytics();
          _crashlyticsConfigured = true;
        }
        return ParkAlertApp(firebaseInit: Future.value(snapshot.data!));
      },
    );
  }
}
