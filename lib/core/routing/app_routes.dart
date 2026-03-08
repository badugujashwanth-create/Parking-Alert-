import 'package:flutter/material.dart';

import '../../features/alerts/screens/alerts_inbox_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/qr/screens/qr_display_screen.dart';
import '../../features/scan/screens/scan_qr_screen.dart';
import '../../features/vehicles/screens/add_vehicle_screen.dart';
import '../../features/vehicles/screens/home_screen.dart';
import '../../features/vehicles/screens/settings_screen.dart';
import '../../features/vehicles/screens/how_it_works_screen.dart';
import '../../features/alerts/screens/alert_details_screen.dart';
import '../../features/demo/screens/demo_activity_screen.dart';
import '../../features/demo/screens/demo_dashboard_screen.dart';
import '../../features/demo/screens/demo_settings_screen.dart';
import '../../features/demo/screens/demo_stats_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const otp = '/otp';
  static const home = '/home';
  static const addVehicle = '/vehicles/add';
  static const qrDisplay = '/qr';
  static const scanQR = '/scan';
  static const alerts = '/alerts';
  static const alertDetails = '/alerts/details';
  static const settings = '/settings';
  static const howItWorks = '/how-it-works';
  static const demoDashboard = '/demo';
  static const demoStats = '/demo/stats';
  static const demoActivity = '/demo/activity';
  static const demoSettings = '/demo/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.otp:
        final phone = settings.arguments;
        if (phone is String && phone.isNotEmpty) {
          return MaterialPageRoute(
            builder: (_) => OTPScreen(phoneNumber: phone),
          );
        }
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.addVehicle:
        return MaterialPageRoute(builder: (_) => const AddVehicleScreen());
      case AppRoutes.qrDisplay:
        final vehicleId = settings.arguments;
        if (vehicleId is String && vehicleId.isNotEmpty) {
          return MaterialPageRoute(
            builder: (_) => QRDisplayScreen(vehicleId: vehicleId),
          );
        }
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.scanQR:
        return MaterialPageRoute(builder: (_) => const ScanQRScreen());
      case AppRoutes.alerts:
        return MaterialPageRoute(builder: (_) => const AlertsInboxScreen());
      case AppRoutes.alertDetails:
        final alertId = settings.arguments;
        if (alertId is String && alertId.isNotEmpty) {
          return MaterialPageRoute(
            builder: (_) => AlertDetailsScreen(alertId: alertId),
          );
        }
        return MaterialPageRoute(builder: (_) => const AlertsInboxScreen());
      case AppRoutes.demoDashboard:
        return MaterialPageRoute(builder: (_) => const DemoDashboardScreen());
      case AppRoutes.demoStats:
        return MaterialPageRoute(builder: (_) => const DemoStatsScreen());
      case AppRoutes.demoActivity:
        return MaterialPageRoute(builder: (_) => const DemoActivityScreen());
      case AppRoutes.demoSettings:
        return MaterialPageRoute(builder: (_) => const DemoSettingsScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.howItWorks:
        return MaterialPageRoute(builder: (_) => const HowItWorksScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
