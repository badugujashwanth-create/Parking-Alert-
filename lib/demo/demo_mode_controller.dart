import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'demo_data.dart';
import 'demo_data_service.dart';

const _kDemoMode = 'demo_mode_enabled';
const _kSlowNetwork = 'demo_mode_slow_network';
const _kApiError = 'demo_mode_api_error';
const _kAutoGenerate = 'demo_mode_auto_generate';

class DemoModeController extends ChangeNotifier {
  DemoModeController() {
    _service = DemoDataService();
    _activityLog = List.of(DemoData.activity);
    _init();
  }

  late final DemoDataService _service;
  final Random _random = Random();

  bool _demoEnabled = const bool.fromEnvironment('DEMO_MODE', defaultValue: true);
  bool get demoEnabled => _demoEnabled;

  bool _simulateSlowNetwork = false;
  bool get simulateSlowNetwork => _simulateSlowNetwork;

  bool _simulateApiError = false;
  bool get simulateApiError => _simulateApiError;

  bool _autoGenerateEvents = false;
  bool get autoGenerateEvents => _autoGenerateEvents;

  List<DemoActivity> _baseActivities = [];
  List<DemoActivity> get baseActivities => List.unmodifiable(_baseActivities);

  final List<DemoActivity> _customActivities = [];
  List<DemoActivity> get customActivities => List.unmodifiable(_customActivities);

  List<DemoActivity> _activityLog = [];
  List<DemoActivity> get activityLog => List.unmodifiable(_activityLog);

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _demoEnabled = prefs.getBool(_kDemoMode) ?? _demoEnabled;
    _simulateSlowNetwork = prefs.getBool(_kSlowNetwork) ?? _simulateSlowNetwork;
    _simulateApiError = prefs.getBool(_kApiError) ?? _simulateApiError;
    _autoGenerateEvents = prefs.getBool(_kAutoGenerate) ?? _autoGenerateEvents;
    await _refreshServiceActivity();
    notifyListeners();
  }

  Future<void> _persistSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDemoMode, _demoEnabled);
    await prefs.setBool(_kSlowNetwork, _simulateSlowNetwork);
    await prefs.setBool(_kApiError, _simulateApiError);
    await prefs.setBool(_kAutoGenerate, _autoGenerateEvents);
  }

  Future<void> toggleDemo(bool enabled) async {
    _demoEnabled = enabled;
    await _persistSettings();
    notifyListeners();
  }

  Future<void> updateSettings({
    bool? slowNetwork,
    bool? apiError,
    bool? autoGenerate,
  }) async {
    if (slowNetwork != null) {
      _simulateSlowNetwork = slowNetwork;
    }
    if (apiError != null) {
      _simulateApiError = apiError;
    }
    if (autoGenerate != null) {
      _autoGenerateEvents = autoGenerate;
    }
    await _persistSettings();
    await _refreshServiceActivity();
    notifyListeners();
  }

  Future<Map<String, int>> fetchDashboardStats() {
    return _service.getDashboardStats(
      slowNetwork: _simulateSlowNetwork,
      simulateError: _simulateApiError,
    );
  }

  Future<List<String>> fetchAlerts() {
    return _service.getAlerts(
      slowNetwork: _simulateSlowNetwork,
      simulateError: _simulateApiError,
    );
  }

  Future<void> _refreshServiceActivity() async {
    try {
      _baseActivities = await _service.getRecentActivity(
        slowNetwork: _simulateSlowNetwork,
        simulateError: _simulateApiError,
        autoGenerate: _autoGenerateEvents,
      );
    } catch (_) {
      _baseActivities = List.of(DemoData.activity);
    }
    _rebuildLog();
  }

  void _rebuildLog() {
    final combined = [..._customActivities, ..._baseActivities];
    if (combined.length > 20) {
      _activityLog = combined.sublist(0, 20);
    } else {
      _activityLog = combined;
    }
  }

  void logEvent(String event, DemoActivityStatus status) {
    _customActivities.insert(
      0,
      DemoActivity(timestamp: DateTime.now().toUtc(), event: event, status: status),
    );
    if (_customActivities.length > 12) {
      _customActivities.removeLast();
    }
    _rebuildLog();
    notifyListeners();
  }

  void generateLogs(int count) {
    final statuses = DemoActivityStatus.values;
    for (var i = 0; i < count; i++) {
      final status = statuses[_random.nextInt(statuses.length)];
      _customActivities.insert(
        0,
        DemoActivity(
          timestamp: DateTime.now().toUtc().subtract(Duration(minutes: i * 3)),
          event: 'Generated event #${i + 1}',
          status: status,
        ),
      );
    }
    if (_customActivities.length > 20) {
      _customActivities.removeRange(20, _customActivities.length);
    }
    _rebuildLog();
    notifyListeners();
  }

  void clearLogs() {
    _customActivities.clear();
    _rebuildLog();
    notifyListeners();
  }

  String exportLogs() {
    final buffer = StringBuffer();
    for (final entry in _activityLog) {
      buffer.writeln(
          '${entry.timestamp.toLocal().toIso8601String()} | ${entry.status.name.toUpperCase()} | ${entry.event}');
    }
    return buffer.toString();
  }
}
