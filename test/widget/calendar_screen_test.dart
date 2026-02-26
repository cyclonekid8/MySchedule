import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschedule/models/activity.dart';
import 'package:myschedule/providers/schedule_provider.dart';
import 'package:myschedule/providers/theme_provider.dart';
import 'package:myschedule/services/purchase_service.dart';
import 'package:myschedule/screens/calendar_screen.dart';

Widget buildTestApp(Widget child, {ScheduleProvider? scheduleProvider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => scheduleProvider ?? ScheduleProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => PurchaseService()),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CalendarScreen Widget Tests', () {
    testWidgets('shows Calendar title', (tester) async {
      await tester.pumpWidget(buildTestApp(const CalendarScreen()));
      await tester.pump();
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('shows FAB add button', (tester) async {
      await tester.pumpWidget(buildTestApp(const CalendarScreen()));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows no activities message when empty', (tester) async {
      await tester.pumpWidget(buildTestApp(const CalendarScreen()));
      await tester.pump();
      expect(find.text('No activities this day'), findsOneWidget);
    });

    testWidgets('shows activity count for selected day', (tester) async {
      final provider = ScheduleProvider();
      final today = DateTime.now();
      await provider.addActivity(Activity(
        id: 'test',
        title: 'Work Meeting',
        startTime: DateTime(today.year, today.month, today.day, 9, 0),
        endTime: DateTime(today.year, today.month, today.day, 10, 0),
        category: Category.work,
      ));
      await tester.pumpWidget(buildTestApp(const CalendarScreen(), scheduleProvider: provider));
      await tester.pump();
      expect(find.text('1 activities'), findsOneWidget);
    });

    testWidgets('shows activity title in list', (tester) async {
      final provider = ScheduleProvider();
      final today = DateTime.now();
      await provider.addActivity(Activity(
        id: 'test',
        title: 'Work Meeting',
        startTime: DateTime(today.year, today.month, today.day, 9, 0),
        endTime: DateTime(today.year, today.month, today.day, 10, 0),
        category: Category.work,
      ));
      await tester.pumpWidget(buildTestApp(const CalendarScreen(), scheduleProvider: provider));
      await tester.pump();
      expect(find.text('Work Meeting'), findsOneWidget);
    });

    testWidgets('tapping activity navigates to edit screen', (tester) async {
      final provider = ScheduleProvider();
      final today = DateTime.now();
      await provider.addActivity(Activity(
        id: 'test',
        title: 'Work Meeting',
        startTime: DateTime(today.year, today.month, today.day, 9, 0),
        endTime: DateTime(today.year, today.month, today.day, 10, 0),
        category: Category.work,
      ));
      await tester.pumpWidget(buildTestApp(const CalendarScreen(), scheduleProvider: provider));
      await tester.pump();
      await tester.tap(find.text('Work Meeting'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Activity'), findsOneWidget);
    });

    testWidgets('tapping FAB navigates to AddActivityScreen', (tester) async {
      await tester.pumpWidget(buildTestApp(const CalendarScreen()));
      await tester.pump();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Add Activity'), findsOneWidget);
    });
  });
}
