import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../../alerts/screens/alerts_inbox_screen.dart';
import '../../scan/screens/scan_qr_screen.dart';
import 'my_vehicles_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final int selectedIndex;

  const HomeScreen({super.key, this.selectedIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  static const _tabLabels = [
    AppStrings.homeMyVehicles,
    AppStrings.homeScan,
    AppStrings.homeAlerts,
    AppStrings.homeSettings,
  ];

  final List<Widget> _pages = const [
    MyVehiclesScreen(),
    ScanQRScreen(),
    AlertsInboxScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabLabels[_currentIndex]),
        actions: [
          IconButton(
            tooltip: 'Demo dashboard',
            icon: const Icon(Icons.dashboard_customize_outlined),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.demoDashboard),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.directions_car), label: AppStrings.homeMyVehicles),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: AppStrings.homeScan),
          NavigationDestination(icon: Icon(Icons.notifications), label: AppStrings.homeAlerts),
          NavigationDestination(icon: Icon(Icons.settings), label: AppStrings.homeSettings),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addVehicle),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
