import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:park_alert/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('safe demo completes a local alert lifecycle', (tester) async {
    await tester.pumpWidget(const ParkAlertDemoApp());
    await tester.pumpAndSettle();

    expect(find.text('SYNTHETIC / LOCAL / NOT SENT'), findsOneWidget);
    expect(find.text('PA-DEMO-1042'), findsOneWidget);

    await tester.tap(find.text('Blocking exit'));
    await tester.enterText(find.byKey(const ValueKey('demo-note')), 'Please move when safe.');
    await tester.ensureVisible(find.byKey(const ValueKey('prepare-alert')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('prepare-alert')));
    await tester.pumpAndSettle();

    expect(find.text('LOCAL PREVIEW — NO MESSAGE SENT'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('deliver-locally')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('deliver-locally')));
    await tester.pumpAndSettle();

    expect(find.text('New synthetic alert. No push notification was sent.'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('resolve-alert')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('resolve-alert')));
    await tester.pumpAndSettle();

    expect(find.text('RESOLVED'), findsOneWidget);
    expect(find.text('Resolved locally. No external side effect.'), findsOneWidget);
  });

  testWidgets('alert preview stays disabled until a reason is selected', (tester) async {
    await tester.pumpWidget(const ParkAlertDemoApp());
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(find.byKey(const ValueKey('prepare-alert')));
    expect(button.onPressed, isNull);
  });
}
