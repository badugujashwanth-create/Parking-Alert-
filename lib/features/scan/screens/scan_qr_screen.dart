import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../scan/controllers/scan_controller.dart';
import '../../scan/models/scan_preview.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final MobileScannerController _scannerController = MobileScannerController(formats: [BarcodeFormat.qrCode]);
  final List<String> _reasons = [
    AppStrings.reasonNoParking,
    AppStrings.reasonAmbulanceBlocked,
    AppStrings.reasonAccident,
    AppStrings.reasonFire,
  ];
  String? _lastPayload;
  bool _isProcessingPayload = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessingPayload) return;
    final barcode = capture.barcodes.firstWhere(
      (element) => element.rawValue != null,
      orElse: () => Barcode(rawValue: null),
    );
    final value = barcode.rawValue;
    if (value == null || value == _lastPayload) return;
    _lastPayload = value;
    _processPayload(value);
  }

  Future<void> _processPayload(String payload) async {
    final qrId = _extractQrId(payload);
    if (qrId == null) return;
    setState(() => _isProcessingPayload = true);
    final controller = context.read<ScanController>();
    await controller.loadPreview(qrId);
    setState(() => _isProcessingPayload = false);
    if (controller.preview == null) {
      _showMessage(controller.errorMessage ?? AppStrings.scanInvalidQr);
      return;
    }
    await _showConfirmation(controller.preview!);
  }

  Future<void> _showConfirmation(ScanPreview preview) async {
    final noteController = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        var selectedReason = _reasons.first;
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
            builder: (context, setState) {
              final isSending = context.watch<ScanController>().isSending;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.qr_code_scanner),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppStrings.scanVehicleFound(preview.vehicleNumber),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(preview.city, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _reasons.map((reason) {
                        final selected = reason == selectedReason;
                        return ChoiceChip(
                          label: Text(reason),
                          selected: selected,
                          onSelected: (_) => setState(() => selectedReason = reason),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      maxLength: 120,
                      decoration: const InputDecoration(
                        labelText: AppStrings.scanNoteHint,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: isSending
                          ? null
                          : () async {
                              final note = noteController.text.trim();
                              try {
                                await _submitAlert(
                                  selectedReason,
                                  note.isEmpty ? null : note,
                                );
                                if (!mounted) return;
                                Navigator.of(this.context).pop();
                                _showMessage(AppStrings.scanAlertSent);
                              } catch (_) {
                                if (!mounted) return;
                                final error = this.context.read<ScanController>().errorMessage;
                                _showMessage(error ?? AppStrings.scanSendFailed);
                              }
                            },
                      child: isSending
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text(AppStrings.scanSendButton),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
    noteController.dispose();
  }

  String? _extractQrId(String payload) {
    final uri = Uri.tryParse(payload.trim());
    if (uri != null && uri.host.contains('parkalert.in') && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    return payload.trim().isEmpty ? null : payload.trim();
  }

  Future<void> _submitAlert(String reason, String? note) async {
    final controller = context.read<ScanController>();
    final authController = context.read<AuthController>();
    await controller.sendAlert(
      reason: reason,
      note: note,
      scannerPhone: authController.currentUser?.phoneNumber,
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ScanController>().isLoading;
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _handleBarcode,
        ),
        if (isLoading || _isProcessingPayload)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black38,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        Align(
          alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(153),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              AppStrings.scanInstruction,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
