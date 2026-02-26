import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschedule/models/activity.dart';
import 'package:myschedule/providers/schedule_provider.dart';
import 'package:myschedule/providers/theme_provider.dart';
import 'package:myschedule/services/purchase_service.dart';
import 'package:myschedule/screens/add_activity_screen.dart';

Widget buildTestApp(Widget child, {
  ScheduleProvider? scheduleProvider,
  PurchaseService? purchaseService,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => scheduleProvider ?? ScheduleProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => purchaseService ?? PurchaseService()),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AddActivityScreen Widget Tests', () {
    testWidgets('shows Add Activity title', (tester) async {
      await tester.pumpWidget(buildTestApp(const AddActivityScreen()));
      await tester.pump();
      expect(find.text('Add Activity'), findsOneWidget);
    });

    testWidgets('shows all required fields', (tester) async {
      await tester.pumpWidget(buildTestApp(const AddActivityScreen()));
      await tester.pump();
      expect(find.text('ACTIVITY NAME'), findsOneWidget);
      expect(find.text('DATE'), findsOneWidget);
      expect(find.text('TIME'), findsOneWidget);
      expect(find.text('CATEGORY'), findsOneWidget);
      expect(find.text('REPEAT'), findsOneWidget);
    });

    testWidgets('shows all categories', (tester) async {
      await tester.pumpWidget(buildTestApp(const AddActivityScreen()));
      await tester.pump();
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Health & Fitness'), findsOneWidget);
    });

    testWidgets('shows Save Activity button', (tester) async {
      await tester.pumpWidget(buildTestApp(const AddActivityScreen()));
      await tester.pump();
      expect(find.text('Save Activity'), findsOneWidget);
    });

    testWidgets('shows error when saving empty title', (tester) async {
      await tester.pumpWidget(buildTestApp(const AddActivityScreen()));
      await tester.pump();
      await tester.tap(find.text('Save Activity'));
      await tester.pump();
      expect(find.text('Please enter an activity name'), findsOneWidget);
    });

    testWidgets('saves activity with valid title', (tester) async {
      final provider = ScheduleProvider();
      await tester.pumpWidget(buildTestApp(const AddActivityScreen(), scheduleProvider: provider));
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, 'Morning Prayer');
      await tester.tap(find.text('Save Activity'));
      await tester.pumpAndSettle();
      expect(provider.activities.length, 1);
      expect(provider.activities.first.title, 'Morning Prayer');
    });

    testWidgets('free user sees paywall after 2 activities today', (tester) async {
      final provider = ScheduleProvider();
      final purchase = PurchaseService();
      SharedPreferences.setMockInitialValues({});
      final today = DateTime.now();

      // Add 2 activities for today
      for (int i = 0; i < 2; i++) {
        await provider.addActivity(Activity(
          id: 'act-$i',
          title: 'Activity $i',
          startTime: DateTime(today.year, today.month, today.day, 9 + i, 0),
          endTime: DateTime(today.year, today.month, today.day, 10 + i, 0),
          category: Category.work,
        ));
      }

      await tester.pumpWidget(buildTestApp(
        const AddActivityScreen(),
        scheduleProvider: provider,
        purchaseService: purchase,
      ));
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, 'Third Activity');
      await tester.tap(find.text('Save Activity'));
      await tester.pumpAndSettle();
      // Should show paywall
      expect(find.textContaining('Premium'), findsWidgets);
    });

    testWidgets('premium user can add more than 2 activities today', (tester) async {
      final provider = ScheduleProvider();
      final purchase = PurchaseService();
      SharedPreferences.setMockInitialValues({'simulate_premium': true});
      await purchase.init();
      final today = DateTime.now();

      for (int i = 0; i < 2; i++) {
        await provider.addActivity(Activity(
          id: 'act-$i',
          title: 'Activity $i',
          startTime: DateTime(today.year, today.month, today.day, 9 + i, 0),
          endTime: DateTime(today.year, today.month, today.day, 10 + i, 0),
          category: Category.work,
        ));
      }

      await tester.pumpWidget(buildTestApp(
        const AddActivityScreen(),
        scheduleProvider: provider,
        purchaseService: purchase,
      ));
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, 'Third Activity');
      await tester.tap(find.text('Save Activity'));
      await tester.pumpAndSettle();
      expect(provider.activities.length, 3);
    });

    testWidgets('repeat buttons are selectable', (tester) async {
      await tester.pumpWidget(buildTestApp(const AddActivityScreen()));
      await tester.pump();
      await tester.tap(find.text('Daily'));
      await tester.pump();
      expect(find.text('Daily'), findsOneWidget);
    });

    testWidgets('back button navigates back', (tester) async {
      await tester.pumpWidget(buildTestApp(const AddActivityScreen()));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_rounded));
      await tester.pumpAndSettle();
    });
  });
}
