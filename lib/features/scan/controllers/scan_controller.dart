import 'package:flutter/material.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/services/device_id_service.dart';
import '../../../core/services/scan_service.dart';
import '../models/scan_preview.dart';

class ScanController extends ChangeNotifier {
  ScanController({
    required ScanService scanService,
    required DeviceIdService deviceIdService,
    required AnalyticsService analyticsService,
  })  : _scanService = scanService,
        _deviceIdService = deviceIdService,
        _analyticsService = analyticsService;

  final ScanService _scanService;
  final DeviceIdService _deviceIdService;
  final AnalyticsService _analyticsService;

  ScanPreview? _preview;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSending = false;

  ScanPreview? get preview => _preview;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;

  Future<void> loadPreview(String qrId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _analyticsService.logScanStarted();
      _preview = await _scanService.loadPreview(qrId);
    } catch (error) {
      _errorMessage = error is ScanException ? error.message : 'Unable to load QR';
      _preview = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendAlert({
    required String reason,
    String? note,
    String? scannerPhone,
  }) async {
    if (_preview == null) {
      throw Exception('No preview available');
    }
    _isSending = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final deviceId = await _deviceIdService.getDeviceId();
      await _scanService.recordAlert(
        preview: _preview!,
        reason: reason,
        note: note,
        scannerDeviceId: deviceId,
        scannerPhone: scannerPhone,
      );
      await _analyticsService.logAlertSent(reason: reason);
    } catch (error) {
      if (error is ScanException) {
        if (error.code == 'rate_limited') {
          await _analyticsService.logRateLimited();
        }
        if (error.code == 'quiet_hours_suppressed') {
          await _analyticsService.logQuietHoursSuppressed();
        }
      }
      _errorMessage = error is ScanException ? error.message : 'Unable to send alert';
      rethrow;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
