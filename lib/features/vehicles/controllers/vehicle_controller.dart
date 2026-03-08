import 'package:flutter/material.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/services/vehicle_service.dart';
import '../models/vehicle.dart';

class VehicleController extends ChangeNotifier {
  VehicleController({
    required VehicleService vehicleService,
    required AnalyticsService analyticsService,
  })  : _vehicleService = vehicleService,
        _analyticsService = analyticsService;

  final AnalyticsService _analyticsService;

  final VehicleService _vehicleService;

  bool _isSaving = false;
  String? _errorMessage;

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Stream<List<Vehicle>> watchVehicles(String uid) {
    return _vehicleService.watchVehicles(uid);
  }

  Stream<Vehicle?> watchVehicle(String uid, String vehicleId) {
    return _vehicleService.watchVehicle(uid, vehicleId);
  }

  Future<void> addVehicle({
    required String uid,
    required String vehicleNumber,
    required String city,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _vehicleService.addVehicle(
        uid: uid,
        vehicleNumber: vehicleNumber,
        city: city,
      );
      await _analyticsService.logVehicleAdded();
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> toggleQrActive({
    required String uid,
    required String vehicleId,
    required String qrId,
    required bool isActive,
  }) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _vehicleService.toggleQrActive(
        uid: uid,
        vehicleId: vehicleId,
        qrId: qrId,
        isActive: isActive,
      );
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    }
  }

  Future<void> updateVehicleStatus({
    required String uid,
    required String vehicleId,
    required String qrId,
    required bool isActiveStatus,
  }) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _vehicleService.updateVehicleStatus(
        uid: uid,
        vehicleId: vehicleId,
        qrId: qrId,
        isActiveStatus: isActiveStatus,
      );
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    }
  }
}
