import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myschedule/models/note.dart';
import 'package:myschedule/providers/schedule_provider.dart';
import 'package:myschedule/providers/theme_provider.dart';
import 'package:myschedule/services/purchase_service.dart';
import 'package:myschedule/screens/notes_screen.dart';

// Use .value() for singletons so Provider does not dispose them between tests
Widget buildTestApp(Widget child, {ScheduleProvider? scheduleProvider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) =>
            scheduleProvider ?? ScheduleProvider(skipNotifications: true),
      ),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider.value(value: PurchaseService()),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NotesScreen Widget Tests', () {
    testWidgets('shows Notes title', (tester) async {
      await tester.pumpWidget(buildTestApp(const NotesScreen()));
      await tester.pump();
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('shows FAB add button', (tester) async {
      await tester.pumpWidget(buildTestApp(const NotesScreen()));
      await tester.pump();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows existing note in list', (tester) async {
      final provider = ScheduleProvider(skipNotifications: true);
      final now = DateTime.now();
      provider.addNote(Note(
        id: 'note-1',
        title: 'Shopping List',
        body: 'Milk, eggs, bread',
        createdAt: now,
        updatedAt: now,
      ));
      await tester.pumpWidget(buildTestApp(
        const NotesScreen(),
        scheduleProvider: provider,
      ));
      await tester.pump();
      expect(find.text('Shopping List'), findsOneWidget);
    });

    testWidgets('shows search bar', (tester) async {
      await tester.pumpWidget(buildTestApp(const NotesScreen()));
      await tester.pump();
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('tapping FAB opens new note sheet', (tester) async {
      await tester.pumpWidget(buildTestApp(const NotesScreen()));
      await tester.pump();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('New Note'), findsOneWidget);
    });
  });
}
