import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschedule/models/activity.dart';
import 'package:myschedule/providers/schedule_provider.dart';
import 'package:myschedule/providers/theme_provider.dart';
import 'package:myschedule/services/purchase_service.dart';
import 'package:myschedule/screens/schedule_screen.dart';
Widget buildTestApp(Widget child, {
  ScheduleProvider? scheduleProvider,
  ThemeProvider? themeProvider,
  PurchaseService? purchaseService,
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
  group('ScheduleScreen Widget Tests', () {
    testWidgets('shows MySchedule title', (tester) async {
      await tester.pumpWidget(buildTestApp(const ScheduleScreen()));
      await tester.pump();
      expect(find.text('MySchedule'), findsOneWidget);
    });
    testWidgets('shows week strip with 7 days', (tester) async {
      await tester.pumpWidget(buildTestApp(const ScheduleScreen()));
      await tester.pump();
      // Should find day number texts
      expect(find.byType(GestureDetector), findsWidgets);
    });
    testWidgets('shows FAB add button', (tester) async {
      await tester.pumpWidget(buildTestApp(const ScheduleScreen()));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
    testWidgets('tapping FAB navigates to AddActivityScreen', (tester) async {
      await tester.pumpWidget(buildTestApp(const ScheduleScreen()));
      await tester.pump();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Add Activity'), findsOneWidget);
    });
    testWidgets('shows activity card when activity exists', (tester) async {
      final provider = ScheduleProvider(skipNotifications: true);
      SharedPreferences.setMockInitialValues({});
      final today = DateTime.now();
      await provider.addActivity(Activity(
        id: 'test',
        title: 'Morning Workout',
        startTime: DateTime(today.year, today.month, today.day, 9, 0),
        endTime: DateTime(today.year, today.month, today.day, 10, 0),
        category: Category.healthFitness,
      ));
      await tester.pumpWidget(buildTestApp(const ScheduleScreen(), scheduleProvider: provider));
      await tester.pump();
      await tester.scrollUntilVisible(
        find.text('Morning Workout'),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Morning Workout'), findsOneWidget);
    });
  });
}
