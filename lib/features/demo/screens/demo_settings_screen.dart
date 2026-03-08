import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../demo/demo_mode_controller.dart';

class DemoSettingsScreen extends StatelessWidget {
  const DemoSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DemoModeController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Demo settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Simulate slow network'),
            subtitle: const Text('Injects longer delays (400+ ms)'),
            value: controller.simulateSlowNetwork,
            onChanged: (value) => controller.updateSettings(slowNetwork: value),
            secondary: const Icon(Icons.speed),
          ),
          SwitchListTile(
            title: const Text('Simulate API error'),
            subtitle: const Text('Randomly fails Dashboard/Stats/Activity calls'),
            value: controller.simulateApiError,
            onChanged: (value) => controller.updateSettings(apiError: value),
            secondary: const Icon(Icons.bug_report),
          ),
          SwitchListTile(
            title: const Text('Auto-generate events'),
            subtitle: const Text('Adds synthetic events to the activity list'),
            value: controller.autoGenerateEvents,
            onChanged: (value) => controller.updateSettings(autoGenerate: value),
            secondary: const Icon(Icons.auto_mode),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.clearLogs,
            child: const Text('Reset activity log'),
          ),
        ],
      ),
    );
  }
}
