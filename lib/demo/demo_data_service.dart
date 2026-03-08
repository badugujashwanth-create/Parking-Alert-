import 'dart:math';

import 'demo_data.dart';

class DemoDataService {
  DemoDataService();

  final Random _random = Random(23);

  Duration _delay(bool slow) => Duration(milliseconds: slow ? 420 : 220 + _random.nextInt(120));

  Future<void> _maybeThrow(bool simulateError) async {
    if (!simulateError) return;
    final shouldFail = _random.nextDouble() < 0.35;
    if (shouldFail) {
      throw Exception('Simulated demo API failure');
    }
  }

  Future<Map<String, int>> getDashboardStats({
    required bool slowNetwork,
    required bool simulateError,
  }) async {
    await Future.delayed(_delay(slowNetwork));
    await _maybeThrow(simulateError);
    return {
      'Requests Today': 162,
      'Blocked IPs': 4,
      'Errors': 2,
      'Avg Latency (ms)': 312,
    };
  }

  Future<List<DemoActivity>> getRecentActivity({
    required bool slowNetwork,
    required bool simulateError,
    required bool autoGenerate,
  }) async {
    await Future.delayed(_delay(slowNetwork));
    await _maybeThrow(simulateError);
    final base = List<DemoActivity>.from(DemoData.activity);
    if (autoGenerate) {
      final generated = List<DemoActivity>.generate(12, (index) {
        final status = DemoActivityStatus.values[index % DemoActivityStatus.values.length];
        return DemoActivity(
          timestamp: DateTime.now().toUtc().subtract(Duration(minutes: index * 5)),
          event: 'Auto event ${index + 1}',
          status: status,
        );
      });
      base.insertAll(0, generated);
    }
    while (base.length < 20) {
      final index = base.length % DemoData.activity.length;
      final template = DemoData.activity[index];
      base.add(
        DemoActivity(
          timestamp: template.timestamp.add(Duration(minutes: base.length)),
          event: template.event,
          status: template.status,
        ),
      );
    }
    return base;
  }

  Future<List<String>> getAlerts({
    required bool slowNetwork,
    required bool simulateError,
  }) async {
    await Future.delayed(_delay(slowNetwork));
    await _maybeThrow(simulateError);
    return const [
      'Owner inbox cleared 3m ago',
      'Field agent assigned to Sector 11',
      'Daily compliance report ready',
      'Blocked vehicle flagged for follow-up',
    ];
  }
}
