import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../demo/demo_mode_controller.dart';
import '../../../demo/demo_data.dart';

class DemoActivityScreen extends StatefulWidget {
  const DemoActivityScreen({super.key});

  @override
  State<DemoActivityScreen> createState() => _DemoActivityScreenState();
}

class _DemoActivityScreenState extends State<DemoActivityScreen> {
  String _query = '';
  DemoActivityStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DemoModeController>();
    final filtered = controller.activityLog.where((activity) {
      final matchesQuery = activity.event.toLowerCase().contains(_query.toLowerCase());
      final matchesType = _filter == null || activity.status == _filter;
      return matchesQuery && matchesType;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Activity log')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Search events', prefixIcon: Icon(Icons.search)),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Filter:'),
                const SizedBox(width: 8),
                DropdownButton<DemoActivityStatus?>(
                  value: _filter,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...DemoActivityStatus.values.map(
                      (status) => DropdownMenuItem(value: status, child: Text(status.name.toUpperCase())),
                    )
                  ],
                  onChanged: (value) => setState(() => _filter = value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No matching activity yet.'))
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final activity = filtered[index];
                        return ListTile(
                          leading: Icon(_statusIcon(activity.status), color: _statusColor(activity.status)),
                          title: Text(activity.event),
                          subtitle: Text(activity.timestamp.toLocal().toString()),
                          trailing: Text(activity.status.name.toUpperCase()),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(DemoActivityStatus status) {
    switch (status) {
      case DemoActivityStatus.success:
        return Icons.check_circle;
      case DemoActivityStatus.warning:
        return Icons.error;
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
}
