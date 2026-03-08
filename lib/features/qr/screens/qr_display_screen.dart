import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/services/analytics_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../vehicles/controllers/vehicle_controller.dart';
import '../../vehicles/models/vehicle.dart';

class QRDisplayScreen extends StatefulWidget {
  const QRDisplayScreen({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  State<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends State<QRDisplayScreen> {
  bool _hasLoggedView = false;

  String _qrPayload(String qrId) => 'https://parkalert.in/q/$qrId';

  void _logView() {
    if (_hasLoggedView) return;
    _hasLoggedView = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsService>().logQrViewed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthController>().currentUser?.uid;
    final vehicleController = context.read<VehicleController>();
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in again.')),
      );
    }

    return StreamBuilder<Vehicle?>(
      stream: vehicleController.watchVehicle(uid, widget.vehicleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final vehicle = snapshot.data;
        if (vehicle == null) {
          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.qrTitle)),
            body: const Center(child: Text(AppStrings.qrMissing)),
          );
        }
        _logView();
        return Scaffold(
          appBar: AppBar(title: const Text(AppStrings.qrTitle)),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.qrSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: _qrPayload(vehicle.qrId),
                      size: 220,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  vehicle.vehicleNumber,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  vehicle.city,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _VehicleStatusChips(vehicle: vehicle),
                if (vehicle.lastScannedAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${AppStrings.vehicleLastScannedLabel}: ${DateFormat('dd MMM, hh:mm a').format(vehicle.lastScannedAt!.toLocal())}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 16),
                _QrActiveToggle(vehicle: vehicle),
                SwitchListTile(
                  title: const Text(AppStrings.vehicleStatusToggleLabel),
                  subtitle: Text(
                    vehicle.status == 'active'
                        ? AppStrings.vehicleStatusActive
                        : AppStrings.vehicleStatusDisabled,
                  ),
                  value: vehicle.status == 'active',
                  onChanged: (value) async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await vehicleController.updateVehicleStatus(
                        uid: uid,
                        vehicleId: vehicle.vehicleId,
                        qrId: vehicle.qrId,
                        isActiveStatus: value,
                      );
                    } catch (_) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text(AppStrings.qrToggleFailed)),
                      );
                    }
                  },
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: null,
                      child: const Text(AppStrings.qrDownload),
                    ),
                    OutlinedButton(
                      onPressed: null,
                      child: const Text(AppStrings.qrShare),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VehicleStatusChips extends StatelessWidget {
  const _VehicleStatusChips({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        vehicle.status == 'active' ? Theme.of(context).colorScheme.primary : Colors.grey;
    final qrColor = vehicle.qrActive ? Colors.green : Colors.redAccent;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Chip(
          label: Text(
            vehicle.status == 'active'
                ? AppStrings.qrVehicleStatusActive
                : AppStrings.qrVehicleStatusDisabled,
          ),
          avatar: Icon(Icons.directions_car, color: statusColor, size: 18),
        ),
        const SizedBox(width: 8),
        Chip(
          label: Text(vehicle.qrActive ? AppStrings.qrStatusActive : AppStrings.qrStatusInactive),
          avatar: Icon(Icons.qr_code_2, color: qrColor, size: 18),
        ),
      ],
    );
  }
}

class _QrActiveToggle extends StatelessWidget {
  const _QrActiveToggle({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<VehicleController>();
    final uid = context.read<AuthController>().currentUser?.uid;
    return SwitchListTile(
      title: const Text(AppStrings.qrToggleLabel),
      value: vehicle.qrActive,
      onChanged: (value) async {
        if (uid == null) return;
        final messenger = ScaffoldMessenger.of(context);
        try {
          await controller.toggleQrActive(
            uid: uid,
            vehicleId: vehicle.vehicleId,
            qrId: vehicle.qrId,
            isActive: value,
          );
        } catch (_) {
          messenger.showSnackBar(
            const SnackBar(content: Text(AppStrings.qrToggleFailed)),
          );
        }
      },
    );
  }
}
