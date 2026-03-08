import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/routing/app_routes.dart';
import 'core/services/analytics_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/alert_service.dart';
import 'core/services/device_id_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/scan_service.dart';
import 'core/services/user_service.dart';
import 'core/services/vehicle_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/firebase_error_screen.dart';
import 'core/widgets/loading_screen.dart';
import 'demo/demo_mode_controller.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/controllers/user_controller.dart';
import 'features/alerts/controllers/alert_controller.dart';
import 'features/scan/controllers/scan_controller.dart';
import 'features/vehicles/controllers/vehicle_controller.dart';

class ParkAlertApp extends StatefulWidget {
  final Future<FirebaseApp> firebaseInit;

  const ParkAlertApp({super.key, required this.firebaseInit});

  @override
  State<ParkAlertApp> createState() => _ParkAlertAppState();
}

class _ParkAlertAppState extends State<ParkAlertApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();
  late final AuthService _authService;
  late final UserService _userService;
  late final VehicleService _vehicleService;
  late final AlertService _alertService;
  late final ScanService _scanService;
  late final DeviceIdService _deviceIdService;
  late final NotificationService _notificationService;
  late final AnalyticsService _analyticsService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _userService = UserService();
    _vehicleService = VehicleService();
    _alertService = AlertService();
    _scanService = ScanService();
    _deviceIdService = DeviceIdService();
    _notificationService = NotificationService();
    _analyticsService = AnalyticsService();
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    FirebaseMessaging.instance.getInitialMessage().then(_handleMessage);
  }

  void _handleMessage(RemoteMessage? message) {
    final alertId = message?.data['alertId'] as String?;
    if (alertId != null && alertId.isNotEmpty) {
      _analyticsService.logAlertReceived();
      _navigatorKey.currentState?.pushNamed(AppRoutes.alertDetails, arguments: alertId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AnalyticsService>.value(value: _analyticsService),
        ChangeNotifierProvider(
          create: (_) => AuthController(
            authService: _authService,
            userService: _userService,
            notificationService: _notificationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => UserController(userService: _userService),
        ),
        ChangeNotifierProvider(
          create: (_) => VehicleController(
            vehicleService: _vehicleService,
            analyticsService: _analyticsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AlertController(
            alertService: _alertService,
            analyticsService: _analyticsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ScanController(
            scanService: _scanService,
            deviceIdService: _deviceIdService,
            analyticsService: _analyticsService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DemoModeController(),
        ),
      ],
      child: FutureBuilder<FirebaseApp>(
        future: widget.firebaseInit,
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

          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: AppStrings.appTitle,
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
