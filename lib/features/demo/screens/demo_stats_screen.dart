import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../demo/demo_mode_controller.dart';

class DemoStatsScreen extends StatelessWidget {
  const DemoStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DemoModeController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Demo statistics')),
      body: FutureBuilder<Map<String, int>>(
        future: controller.fetchDashboardStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Unable to load stats: ${snapshot.error}'));
          }
          final stats = snapshot.data ?? {};
          final maxValue = stats.values.fold<int>(1, (prev, next) => next > prev ? next : prev);
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: stats.entries.map((entry) {
                final normalized = (entry.value / maxValue).clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Stack(
                        children: [
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade300,
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: normalized,
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.blue.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${entry.value} units'),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
