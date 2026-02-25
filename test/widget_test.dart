import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bioid_flutter/main.dart';
import 'package:bioid_flutter/providers/app_settings_provider.dart';

void main() {
  testWidgets('BioIDApp smoke test', (WidgetTester tester) async {
    final settings = AppSettingsProvider();
    await tester.pumpWidget(BioIDApp(settingsProvider: settings));
    // The home screen should render without crashing.
    expect(find.text('BioID'), findsOneWidget);
  });
}
