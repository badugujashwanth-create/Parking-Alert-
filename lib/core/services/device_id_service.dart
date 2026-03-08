import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdService {
  DeviceIdService({SharedPreferences? preferences})
      : _preferences = preferences;

  final SharedPreferences? _preferences;
  static const _prefKey = 'scanner_device_id';

  Future<String> getDeviceId() async {
    final prefs = _preferences ?? await SharedPreferences.getInstance();
    final existing = prefs.getString(_prefKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final generated = _generateId();
    await prefs.setString(_prefKey, generated);
    return generated;
  }

  String _generateId({int length = 20}) {
    const alphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final random = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(alphabet[random.nextInt(alphabet.length)]);
    }
    return buffer.toString();
  }
}
