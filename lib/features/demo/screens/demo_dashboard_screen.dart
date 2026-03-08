import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../../demo/demo_data.dart';
import '../../../demo/demo_mode_controller.dart';

class DemoDashboardScreen extends StatelessWidget {
  const DemoDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DemoModeController>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Project Demo'),
            const SizedBox(width: 8),
            if (controller.demoEnabled)
              Chip(
                label: const Text('DEMO', style: TextStyle(letterSpacing: 1.2)),
                backgroundColor: Colors.green.shade100,
              ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.updateSettings();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                title: const Text('Demo mode'),
                subtitle: Text(controller.demoEnabled ? 'Mock backend uninterrupted' : 'Demo mode off'),
                value: controller.demoEnabled,
                onChanged: controller.toggleDemo,
                secondary: const Icon(Icons.play_circle),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildModeBadge(controller.demoEnabled),
                  _buildModeBadge(controller.simulateSlowNetwork, label: 'Slow network sim'),
                  _buildModeBadge(controller.simulateApiError, label: 'API errors'),
                  _buildModeBadge(controller.autoGenerateEvents, label: 'Auto events'),
                ],
              ),
              const SizedBox(height: 16),
              _buildButtonsRow(context, controller),
              const SizedBox(height: 16),
              const Text('Live stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              FutureBuilder<Map<String, int>>(
                future: controller.fetchDashboardStats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError) {
                    return _buildErrorCard('Unable to load stats. ${snapshot.error}');
                  }
                  final stats = snapshot.data ?? {};
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: stats.entries.map((entry) => _buildStatCard(entry.key, entry.value)).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text('Recent activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildActivityList(controller),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _copyLogs(context, controller),
                icon: const Icon(Icons.copy_all),
                label: const Text('Copy/export logs'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeBadge(bool active, {String label = 'Demo'}) {
    return Chip(
      label: Text(label),
      backgroundColor: active ? Colors.blue.shade50 : Colors.grey.shade200,
    );
  }

  Widget _buildStatCard(String title, int value) {
    return SizedBox(
      width: 150,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              Text(value.toString(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList(DemoModeController controller) {
    final activities = controller.activityLog;
    return Container(
      height: 360,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            leading: Icon(
              _statusIcon(activity.status),
              color: _statusColor(activity.status),
            ),
            title: Text(activity.event),
            subtitle: Text(activity.timestamp.toLocal().toString()),
            trailing: Text(activity.status.name.toUpperCase()),
          );
        },
        separatorBuilder: (_, __) => const Divider(height: 1),
      ),
    );
  }

  IconData _statusIcon(DemoActivityStatus status) {
    switch (status) {
      case DemoActivityStatus.success:
        return Icons.check_circle;
      case DemoActivityStatus.warning:
        return Icons.info;
      case DemoActivityStatus.error:
        return Icons.cancel;
    }
  }

  Color _statusColor(DemoActivityStatus status) {
    switch (status) {
      case DemoActivityStatus.success:
        return Colors.green;
      case DemoActivityStatus.warning:
        return Colors.amber;
      case DemoActivityStatus.error:
        return Colors.red;
    }
  }

  Widget _buildButtonsRow(BuildContext context, DemoModeController controller) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        ElevatedButton(
          onPressed: () => controller.logEvent('Login successful', DemoActivityStatus.success),
          child: const Text('Log Login'),
        ),
        ElevatedButton(
          onPressed: () => controller.logEvent('Demo API hit', DemoActivityStatus.success),
          child: const Text('Log API hit'),
        ),
        ElevatedButton(
          onPressed: () => controller.logEvent('Error spike detected', DemoActivityStatus.error),
          child: const Text('Log error spike'),
        ),
        ElevatedButton(
          onPressed: () => controller.generateLogs(10),
          child: const Text('Generate 10 logs'),
        ),
        ElevatedButton(
          onPressed: controller.clearLogs,
          child: const Text('Clear logs'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.demoStats),
          child: const Text('Stats screen'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.demoActivity),
          child: const Text('Activity screen'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.demoSettings),
          child: const Text('Settings screen'),
        ),
      ],
    );
  }

  Future<void> _copyLogs(BuildContext context, DemoModeController controller) async {
    final clipboardText = controller.exportLogs();
    await Clipboard.setData(ClipboardData(text: clipboardText));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logs copied to clipboard')));
  }
}
