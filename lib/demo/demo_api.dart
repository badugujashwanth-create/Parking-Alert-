import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'demo_data.dart';

const _usersKey = 'demo_users';
const _settingsKey = 'demo_settings';
final _random = Random();

Future<void> simulateLatency([int ms = 600]) async {
  await Future.delayed(Duration(milliseconds: ms));
}

void simulateRandomFailure({double rate = 0.1, bool enabled = false}) {
  if (!enabled) return;
  if (_random.nextDouble() < rate) {
    throw Exception('Demo random failure');
  }
}

class DemoApi {
  static final List<DemoUser> _users = List.of(DemoData.users);
  static final Map<String, bool> _settings = {
    for (final setting in DemoData.settings) setting.key: setting.defaultValue,
  };

  static bool _usersInitialized = false;
  static bool _settingsInitialized = false;

  static Future<void> _ensureUsers() async {
    if (_usersInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final storedUsers = prefs.getString(_usersKey);
    if (storedUsers != null && storedUsers.isNotEmpty) {
      try {
        final list = jsonDecode(storedUsers) as List<dynamic>;
        _users
          ..clear()
          ..addAll(list
              .map((item) => DemoUser.fromJson(item as Map<String, dynamic>))
              .toList());
      } catch (_) {
        // corrupted local cache; keep defaults
      }
    }
    _usersInitialized = true;
  }

  static Future<void> _persistUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(_users.map((user) => user.toJson()).toList());
    await prefs.setString(_usersKey, payload);
  }

  static Future<void> _ensureSettings() async {
    if (_settingsInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_settingsKey);
    if (stored != null && stored.isNotEmpty) {
      try {
        final map = jsonDecode(stored) as Map<String, dynamic>;
        _settings
          ..clear()
          ..addEntries(
            map.entries.map((entry) => MapEntry(entry.key, entry.value as bool)),
          );
      } catch (_) {
        // fall back to defaults
      }
    }
    _settingsInitialized = true;
  }

  static Future<List<DemoUser>> getUsers({bool simulateError = false}) async {
    await simulateLatency();
    simulateRandomFailure(enabled: simulateError);
    await _ensureUsers();
    return List<DemoUser>.from(_users);
  }

  static Future<DemoUser> createUser({
    required String name,
    required String email,
    required String role,
    bool simulateError = false,
  }) async {
    await simulateLatency();
    simulateRandomFailure(enabled: simulateError);
    await _ensureUsers();
    final id = const Uuid().v4();
    final user = DemoUser(
      id: id,
      name: name,
      email: email,
      role: role,
      joinedAt: DateTime.now().toUtc(),
    );
    _users.insert(0, user);
    await _persistUsers();
    return user;
  }

  static Future<List<DemoActivity>> getActivity({bool simulateError = false}) async {
    await simulateLatency();
    simulateRandomFailure(enabled: simulateError);
    return List<DemoActivity>.from(DemoData.activity);
  }

  static Future<List<DemoReport>> generateReport(
    String type, {
    bool simulateError = false,
  }) async {
    await simulateLatency(800);
    simulateRandomFailure(enabled: simulateError);
    final lowerType = type.toLowerCase();
    final results = DemoData.reports.where((report) {
      return report.type.name.contains(lowerType) || report.title.toLowerCase().contains(lowerType);
    }).toList();
    if (results.isEmpty) {
      return DemoData.reports.take(1).toList();
    }
    return results;
  }

  static Future<Map<String, bool>> getSettings({bool simulateError = false}) async {
    await simulateLatency();
    simulateRandomFailure(enabled: simulateError);
    await _ensureSettings();
    return Map<String, bool>.from(_settings);
  }

  static Future<void> saveSettings(
    Map<String, bool> values, {
    bool simulateError = false,
  }) async {
    await simulateLatency();
    simulateRandomFailure(enabled: simulateError);
    _settings
      ..clear()
      ..addEntries(values.entries.map((entry) => MapEntry(entry.key, entry.value)));
    await _persistSettings();
  }

  static Future<void> _persistSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(_settings));
  }
}
