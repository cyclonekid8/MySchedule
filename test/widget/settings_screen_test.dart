import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschedule/providers/schedule_provider.dart';
import 'package:myschedule/providers/theme_provider.dart';
import 'package:myschedule/services/purchase_service.dart';
import 'package:myschedule/screens/settings_screen.dart';

Widget buildTestApp(Widget child, {
  ThemeProvider? themeProvider,
  PurchaseService? purchaseService,
  ScheduleProvider? scheduleProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => scheduleProvider ?? ScheduleProvider()),
      ChangeNotifierProvider(create: (_) => themeProvider ?? ThemeProvider()),
      ChangeNotifierProvider.value(value: PurchaseService()),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsScreen Widget Tests', () {
    testWidgets('shows Settings title', (tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pump();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows Go Premium banner for free user', (tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pump();
      expect(find.text('Go Premium'), findsOneWidget);
    });

    testWidgets('does not show Go Premium banner for premium user', (tester) async {
      final purchase = PurchaseService();
      SharedPreferences.setMockInitialValues({'simulate_premium': true});
      await purchase.init();
      await tester.pumpWidget(buildTestApp(const SettingsScreen(), purchaseService: purchase));
      await tester.pump();
      expect(find.text('Go Premium'), findsNothing);
    });

    testWidgets('shows theme toggle', (tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pump();
      // Label is 'Dark Mode' in dark theme (default) or 'Light Mode' in light
      expect(
        find.text('Dark Mode').evaluate().isNotEmpty ||
            find.text('Light Mode').evaluate().isNotEmpty,
        true,
      );
    });

    testWidgets('shows Notifications toggle', (tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pump();
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('shows Week starts on option', (tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pump();
      expect(find.text('Week starts on'), findsOneWidget);
    });

    testWidgets('shows Clear all data option', (tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pump();
      expect(find.text('Clear all data'), findsOneWidget);
    });
  });
}
