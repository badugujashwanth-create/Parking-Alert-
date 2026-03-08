import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/constants/app_strings.dart';
import 'core/widgets/firebase_error_screen.dart';
import 'core/widgets/loading_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FirebaseInitCheck());
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
