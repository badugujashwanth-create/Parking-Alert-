import 'package:flutter/material.dart';

import '../../../core/services/alert_service.dart';
import '../../../core/services/analytics_service.dart';
import '../models/alert_item.dart';

class AlertController extends ChangeNotifier {
  AlertController({
    required AlertService alertService,
    required AnalyticsService analyticsService,
  })  : _alertService = alertService,
        _analyticsService = analyticsService;

  final AlertService _alertService;
  final AnalyticsService _analyticsService;
  String _filter = 'all';

  String get filter => _filter;

  set filter(String value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  Stream<List<AlertItem>> watchAlerts(String uid) {
    return _alertService.watchAlerts(uid, status: _filter);
  }

  Stream<int> watchNewCount(String uid) {
    return _alertService.watchNewCount(uid);
  }

  Stream<AlertItem?> watchAlert(String uid, String alertId) {
    return _alertService.watchAlert(uid, alertId);
  }

  Future<void> resolveAlert({
    required String uid,
    required String alertId,
    String? ownerNote,
  }) async {
    await _alertService.resolveAlert(
      uid: uid,
      alertId: alertId,
      ownerNote: ownerNote,
    );
    await _analyticsService.logAlertResolved();
  }

  Future<void> deleteAlert({
    required String uid,
    required String alertId,
  }) {
    return _alertService.deleteAlert(uid: uid, alertId: alertId);
  }

  Future<void> updateOwnerNote({
    required String uid,
    required String alertId,
    required String ownerNote,
  }) {
    return _alertService.updateOwnerNote(
      uid: uid,
      alertId: alertId,
      ownerNote: ownerNote,
    );
  }

  Future<void> blockScanner({
    required String uid,
    required String type,
    required String value,
  }) {
    return _alertService.blockScanner(uid: uid, type: type, value: value);
  }
}
