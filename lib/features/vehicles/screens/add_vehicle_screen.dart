import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/vehicle_controller.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  Future<void> _saveVehicle() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final uid = context.read<AuthController>().currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login again to add a vehicle.')),
      );
      return;
    }

    try {
      await context.read<VehicleController>().addVehicle(
            uid: uid,
            vehicleNumber: _numberController.text,
            city: _cityController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.vehicleSavedMessage)),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.vehicleSaveFailed)),
      );
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addVehicleTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: AppStrings.vehicleNumberLabel,
                ),
                textCapitalization: TextCapitalization.characters,
                validator: Validators.validateVehicleNumber,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: AppStrings.cityLabel,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) => Validators.validateRequiredField(value, AppStrings.cityLabel),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: context.watch<VehicleController>().isSaving ? null : _saveVehicle,
                  child: context.watch<VehicleController>().isSaving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(AppStrings.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
