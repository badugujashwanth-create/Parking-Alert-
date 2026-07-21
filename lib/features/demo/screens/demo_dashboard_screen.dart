import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../../demo/demo_data.dart';
import '../../../demo/demo_mode_controller.dart';

class DemoDashboardScreen extends StatefulWidget {
  const DemoDashboardScreen({super.key});

  @override
  State<DemoDashboardScreen> createState() => _DemoDashboardScreenState();
}

class _DemoDashboardScreenState extends State<DemoDashboardScreen> {
  static const _reasons = ['Blocking exit', 'Lights left on', 'Safety concern'];
  final _noteController = TextEditingController();
  String? _reason;
  bool _prepared = false;
  bool _delivered = false;
  bool _resolved = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _prepare() {
    if (_reason == null) return;
    setState(() {
      _prepared = true;
      _delivered = false;
      _resolved = false;
    });
    context.read<DemoModeController>().logEvent('Local alert preview prepared', DemoActivityStatus.warning);
  }

  void _deliverLocally() {
    setState(() => _delivered = true);
    context.read<DemoModeController>().logEvent('Alert added to simulated owner inbox', DemoActivityStatus.success);
  }

  void _resolve() {
    setState(() => _resolved = true);
    context.read<DemoModeController>().logEvent('Simulated owner resolved alert', DemoActivityStatus.success);
  }

  void _reset() {
    _noteController.clear();
    setState(() {
      _reason = null;
      _prepared = false;
      _delivered = false;
      _resolved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkAlert safe simulation'),
        actions: [
          TextButton(onPressed: _reset, child: const Text('Reset demo')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: colors.errorContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SYNTHETIC / LOCAL / NOT SENT', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('This workflow makes no Firebase, notification, camera, account, or network request. Real delivery remains disabled until the owner verifies rules, App Check, key restrictions, abuse controls, and devices.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _StepCard(
            number: '01',
            title: 'Inspect a synthetic QR result',
            child: Wrap(
              spacing: 24,
              runSpacing: 8,
              children: const [
                _Fact(label: 'QR alias', value: 'PA-DEMO-1042'),
                _Fact(label: 'Vehicle', value: 'TS •••• 4821'),
                _Fact(label: 'Availability', value: 'Demo fixture only'),
              ],
            ),
          ),
          _StepCard(
            number: '02',
            title: 'Prepare an alert locally',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reason', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _reasons.map((reason) {
                    return ChoiceChip(
                      key: ValueKey('reason-$reason'),
                      label: Text(reason),
                      selected: _reason == reason,
                      onSelected: (_) => setState(() {
                        _reason = reason;
                        _prepared = false;
                        _delivered = false;
                        _resolved = false;
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('demo-note'),
                  controller: _noteController,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    labelText: 'Optional synthetic note',
                    hintText: 'Example: Please move when safe.',
                    border: OutlineInputBorder(),
                  ),
                ),
                FilledButton.icon(
                  key: const ValueKey('prepare-alert'),
                  onPressed: _reason == null ? null : _prepare,
                  icon: const Icon(Icons.preview_outlined),
                  label: const Text('Prepare local alert preview'),
                ),
              ],
            ),
          ),
          if (_prepared)
            _StepCard(
              number: '03',
              title: 'Review before simulated delivery',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reason: $_reason'),
                  Text('Note: ${_noteController.text.trim().isEmpty ? 'No note provided' : _noteController.text.trim()}'),
                  const Text('Destination: simulated owner inbox'),
                  const SizedBox(height: 8),
                  const Text('LOCAL PREVIEW — NO MESSAGE SENT', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  FilledButton(
                    key: const ValueKey('deliver-locally'),
                    onPressed: _delivered ? null : _deliverLocally,
                    child: const Text('Add to simulated owner inbox'),
                  ),
                ],
              ),
            ),
          if (_delivered)
            _StepCard(
              number: '04',
              title: 'Simulated owner inbox',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(_resolved ? Icons.check_circle : Icons.notifications_active, color: _resolved ? Colors.green : colors.primary),
                title: Text(_reason!),
                subtitle: Text(_resolved ? 'Resolved locally. No external side effect.' : 'New synthetic alert. No push notification was sent.'),
                trailing: _resolved
                    ? const Chip(label: Text('RESOLVED'))
                    : FilledButton.tonal(
                        key: const ValueKey('resolve-alert'),
                        onPressed: _resolve,
                        child: const Text('Resolve'),
                      ),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.demoActivity),
                child: const Text('Inspect local activity'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.demoSettings),
                child: const Text('Inspect simulation controls'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.number, required this.title, required this.child});

  final String number;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$number / $title', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
