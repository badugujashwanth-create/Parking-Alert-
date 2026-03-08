import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/routing/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/vehicle_controller.dart';
import '../models/vehicle.dart';

class MyVehiclesScreen extends StatelessWidget {
  const MyVehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthController>().currentUser?.uid;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
          child: uid == null
                ? const Center(child: Text('Please log in again.'))
                : StreamBuilder<List<Vehicle>>(
                    stream: context.read<VehicleController>().watchVehicles(uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final vehicles = snapshot.data ?? [];
                      if (vehicles.isEmpty) {
                        return _EmptyState(onAddVehicle: () => _openAddVehicle(context));
                      }
                      return ListView.separated(
                        itemCount: vehicles.length,
                        itemBuilder: (_, index) => _VehicleTile(vehicle: vehicles[index], uid: uid),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openAddVehicle(context),
              child: const Text(AppStrings.addVehicleButton),
            ),
          ),
        ],
      ),
    );
  }

  void _openAddVehicle(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.addVehicle);
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddVehicle;

  const _EmptyState({required this.onAddVehicle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.directions_car_outlined, size: 64),
        const SizedBox(height: 12),
        Text(
          AppStrings.vehiclesEmptyTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        const Text(AppStrings.vehiclesEmptyBody),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: onAddVehicle, child: const Text(AppStrings.addVehicleButton)),
      ],
    );
  }
}

class _VehicleTile extends StatelessWidget {
  final Vehicle vehicle;
  final String uid;

  const _VehicleTile({
    required this.vehicle,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(vehicle.vehicleNumber),
        subtitle: Text('${vehicle.city} - ${vehicle.status.toUpperCase()}'),
        leading: Icon(
          vehicle.qrActive ? Icons.qr_code_2 : Icons.qr_code_2_outlined,
          color: vehicle.qrActive ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.qrDisplay, arguments: vehicle.vehicleId),
              child: const Text('View QR'),
            ),
            Switch(
              value: vehicle.qrActive,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) => context.read<VehicleController>().toggleQrActive(
                uid: uid,
                vehicleId: vehicle.vehicleId,
                qrId: vehicle.qrId,
                isActive: value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
