import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:park_alert/core/utils/validators.dart';

void main() {
  test('tracked Firestore rules deny client alert creation and scan logs', () {
    final rules = File('firestore.rules').readAsStringSync();
    expect(rules, contains('match /alerts/{alertId}'));
    expect(rules, contains('allow create: if false;'));
    expect(rules, contains('match /scanLogs/{scanId}'));
    expect(rules, contains('allow read, write: if false;'));
    expect(rules, isNot(contains('allow read, write: if true')));
  });

  test('client scan service fails closed before a direct alert write', () {
    final source = File('lib/core/services/scan_service.dart').readAsStringSync();
    expect(source, contains("'trusted_backend_required'"));
    expect(source, isNot(contains("collection('scanLogs')")));
    expect(source, isNot(contains("collection('alerts')")));
  });

  test('input validators reject empty and undersized values', () {
    expect(Validators.validatePhone(''), isNotNull);
    expect(Validators.validatePhone('12345'), isNotNull);
    expect(Validators.validatePhone('+91 98765 43210'), isNull);
    expect(Validators.validateVehicleNumber('TS09AB1234'), isNull);
    expect(Validators.validateVehicleNumber('TS1'), isNotNull);
  });
}
