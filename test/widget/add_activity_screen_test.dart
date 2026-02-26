import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      ChangeNotifierProvider(
        create: (_) =>
            scheduleProvider ?? ScheduleProvider(skipNotifications: true),
      ),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(
        create: (_) => purchaseService ?? PurchaseService(),
      ),
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

    testWidgets('shows required field labels', (tester) async {
      await tester.pumpWidget(buildTestApp(const AddActivityScreen()));
      await tester.pump();
      expect(find.text('ACTIVITY NAME'), findsOneWidget);
      expect(find.text('DATE'), findsOneWidget);
    });

    testWidgets('shows text input field', (tester) async {
      await tester.pumpWidget(buildTestApp(const AddActivityScreen()));
      await tester.pump();
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('can enter activity name', (tester) async {
      await tester.pumpWidget(buildTestApp(const AddActivityScreen()));
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, 'Morning Prayer');
      await tester.pump();
      expect(find.text('Morning Prayer'), findsOneWidget);
    });

    testWidgets('back button navigates back', (tester) async {
      await tester.pumpWidget(buildTestApp(const AddActivityScreen()));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_rounded));
      await tester.pumpAndSettle();
    });
  });
}
