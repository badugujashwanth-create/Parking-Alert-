import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../alerts/controllers/alert_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/alert_item.dart';

class AlertDetailsScreen extends StatefulWidget {
  const AlertDetailsScreen({super.key, required this.alertId});

  final String alertId;

  @override
  State<AlertDetailsScreen> createState() => _AlertDetailsScreenState();
}

class _AlertDetailsScreenState extends State<AlertDetailsScreen> {
  bool _isResolving = false;
  bool _isSavingNote = false;
  bool _isBlockingPhone = false;
  bool _isBlockingDevice = false;
  final TextEditingController _ownerNoteController = TextEditingController();
  String? _lastOwnerNote;

  String _maskPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length <= 4) return phone;
    final prefix = cleaned.substring(0, 3);
    final suffix = cleaned.substring(cleaned.length - 2);
    return '$prefix****$suffix';
  }

  Future<void> _onResolve(String uid) async {
    setState(() => _isResolving = true);
    try {
      final noteText = _ownerNoteController.text.trim();
      await context.read<AlertController>().resolveAlert(
            uid: uid,
            alertId: widget.alertId,
            ownerNote: noteText.isEmpty ? null : noteText,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.alertResolvedSnackbar)),
      );
    } finally {
      if (mounted) {
        setState(() => _isResolving = false);
      }
    }
  }

  Future<void> _saveOwnerNote(String uid) async {
    if (_isSavingNote) return;
    setState(() => _isSavingNote = true);
    try {
      final note = _ownerNoteController.text.trim();
      await context.read<AlertController>().updateOwnerNote(
            uid: uid,
            alertId: widget.alertId,
            ownerNote: note,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.alertOwnerNoteSaved)),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingNote = false);
      }
    }
  }

  Future<void> _blockScanner({
    required String uid,
    required String type,
    required String value,
    required VoidCallback onComplete,
  }) async {
    if (value.isEmpty) return;
    try {
      await context.read<AlertController>().blockScanner(
            uid: uid,
            type: type,
            value: value,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.alertBlockSuccess)),
      );
    } finally {
      if (mounted) onComplete();
    }
  }

  @override
  void dispose() {
    _ownerNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthController>().currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view alerts.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.alertsTitle)),
      body: StreamBuilder<AlertItem?>(
        stream: context.read<AlertController>().watchAlert(uid, widget.alertId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final alert = snapshot.data;
          if (alert == null) {
            return const Center(child: Text('Alert not found'));
          }
          final scanner = alert.scannerPhone;
          final scannerLabel = scanner?.isNotEmpty == true
              ? _maskPhone(scanner!)
              : AppStrings.alertScannerUnknown;
          final createdAt = alert.createdAt;
          final timeLabel = createdAt != null ? TimeOfDay.fromDateTime(createdAt).format(context) : '--:--';
          final noteLabel = alert.note?.isNotEmpty == true ? alert.note! : 'No note provided';
          if (_lastOwnerNote != alert.ownerNote) {
            _lastOwnerNote = alert.ownerNote;
            _ownerNoteController.text = alert.ownerNote ?? '';
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.reason, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Time: $timeLabel'),
                const SizedBox(height: 8),
                Text('Scanner: $scannerLabel'),
                const SizedBox(height: 16),
                if (alert.scannerDeviceId?.isNotEmpty == true)
                  Text(
                    '${AppStrings.alertScannerDeviceLabel}: ${alert.scannerDeviceId}',
                  ),
                Text(
                  'Note',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(noteLabel),
                const SizedBox(height: 16),
                TextField(
                  controller: _ownerNoteController,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    labelText: AppStrings.alertOwnerNoteLabel,
                    hintText: AppStrings.alertOwnerNoteHint,
                    border: OutlineInputBorder(),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isSavingNote ? null : () => _saveOwnerNote(uid),
                    child: _isSavingNote
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(AppStrings.alertSaveOwnerNote),
                  ),
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (scanner?.isNotEmpty == true)
                      FilledButton.icon(
                        onPressed: _isBlockingPhone
                            ? null
                            : () {
                                setState(() => _isBlockingPhone = true);
                                _blockScanner(
                                  uid: uid,
                                  type: 'phone',
                                  value: scanner!,
                                  onComplete: () => setState(() => _isBlockingPhone = false),
                                );
                              },
                        icon: const Icon(Icons.block),
                        label: const Text(AppStrings.alertBlockScanner),
                      ),
                    if (alert.scannerDeviceId?.isNotEmpty == true)
                      FilledButton.icon(
                        onPressed: _isBlockingDevice
                            ? null
                            : () {
                                setState(() => _isBlockingDevice = true);
                                _blockScanner(
                                  uid: uid,
                                  type: 'device',
                                  value: alert.scannerDeviceId!,
                                  onComplete: () => setState(() => _isBlockingDevice = false),
                                );
                              },
                        icon: const Icon(Icons.vpn_key),
                        label: const Text(AppStrings.alertBlockDevice),
                      ),
                  ],
                ),
                if (alert.status == 'new')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isResolving ? null : () => _onResolve(uid),
                      child: _isResolving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text(AppStrings.alertMarkResolved),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
